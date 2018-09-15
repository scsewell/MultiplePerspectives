#ifndef ATMOSPHERICS_INCLUDE_
#define ATMOSPHERICS_INCLUDE_

// See original article for details: https://developer.nvidia.com/gpugems/GPUGems2/gpugems2_chapter16.html

float3 _CamPos;             // The camera position in local space
float3 _LightPos;           // The light direciton in local space
float3 _InvWavelength;      // 1 / pow(wavelength, 4) for the red, green, and blue channels
float3 _ScatterScale;
float3 _FrontColorScale;
float _KrESun;              // Kr * ESun
float _KmESun;              // Km * ESun
float _OuterRadius;         // The outer (atmosphere) radius
float _OuterRadius2;        // the outer radius squared
float _InnerRadius;         // The inner (planetary) radius
float _InnerRadius2;        // The inner radius squared
float _Scale;               // 1 / (outerRadius - innerRadius)
float _ScaleDepth;          // The scale depth (i.e. the altitude at which the atmosphere's average density is found)
float _ScaleOverScaleDepth; // scale / scaleDepth
float _HdrExposure;         // HDR exposure
float _G;                   // The Mie phase asymmetry factor
float _G2;                  // The Mie phase asymmetry factor squared
float _SampleCount;         // The number of samples to use


#define ATMOSPHERICS_SETUP  float camHeight = length(camPos);               \
float camHeight2 = camHeight * camHeight;                                   \
float3 ray = pos - camPos;                                                  \
float far = length(ray);                                                    \
ray /= far;                                                                 \
float b = 2.0 * dot(camPos, ray); /* Calculate the closest intersection of the ray from camera with the outer atmosphere */ \
float c = camHeight2 - _OuterRadius2;                                       \
float det = max(0.0, mad(b, b, -4 * c));                                    \
float near = 0.5 * (-b - sqrt(det));                                        \
float3 start = mad(near, ray, camPos); /* Calculate the ray's start and end positions in the atmosphere */  \
far -= near;                                                                \

#define ATMOSPHERICS_LOOP_START float sampleLength = far / _SampleCount;    \
float scaledLength = sampleLength * _Scale;                                 \
float3 sampleRay = ray * sampleLength;                                      \
float3 samplePoint = mad(sampleRay, 0.5, start);                            \
float3 frontColor = 0;                                                      \
float3 attenuation;                                                         \
for (int s = 0;  s< int(_SampleCount); s++) {                               \
    float height = length(samplePoint);                                     \
    float depth = exp(_ScaleOverScaleDepth * (_InnerRadius - height));      \

#define ATMOSPHERICS_LOOP_END samplePoint += sampleRay;                     \
    attenuation = exp(-scatter * _ScatterScale);                            \
    frontColor += attenuation * depth * scaledLength;                       \
}                                                                           \

float Scale(float fCos)
{
    float x0 = 1.0 - fCos;
    float x1 = mad(x0, 5.25, -6.80);
    float x2 = mad(x0, x1, 3.83);
    float x3 = mad(x0, x2, 0.459);
    float x4 = mad(x0, x3, -0.00287);
    return 0.25 * exp(x4);
}

half3 ComputeSurfaceAtmospherics(float3 localPos, float3 camPos)
{
    float3 pos = localPos * _InnerRadius;
    ATMOSPHERICS_SETUP
    float fDepth = exp((_InnerRadius - _OuterRadius) / _ScaleDepth);
    float camAngle = dot(-ray, pos) / length(pos);
    float lightAngle = dot(_LightPos, pos) / length(pos);
    float camScale = Scale(camAngle);
    float camOffset = fDepth * camScale;
    float temp = Scale(lightAngle) + camScale;
    ATMOSPHERICS_LOOP_START
    float scatter = mad(fDepth, temp, -camOffset);
    ATMOSPHERICS_LOOP_END
    return 1.0 - exp(mad(attenuation, 0.25, frontColor * _FrontColorScale) * -_HdrExposure);
}

// Gets the Mie scattering phase.
float MiePhase(float fCos, float fCos2, float g, float g2)
{
    return 1.5 * ((1.0 - g2) / (2.0 + g2)) * (1.0 + fCos2) / pow((1.0 + g2) - (2.0 * g * fCos), 1.5);
}

// Gets the Rayleigh scattering phase.
float RayleighPhase(float fCos2)
{
    return mad(fCos2, 0.75, 0.75);
}

half4 ComputeAtmosphere(float3 localPos, float3 camPos)
{
    float3 pos = localPos * _OuterRadius;
    ATMOSPHERICS_SETUP
    float startAngle = dot(ray, start) / _OuterRadius;
    float startOffset = exp(-1.0 / _ScaleDepth) * Scale(startAngle);
    ATMOSPHERICS_LOOP_START
    float lightAngle = dot(_LightPos, samplePoint) / height;
    float camAngle = dot(ray, samplePoint) / height;
    float scatter = mad(Scale(lightAngle) - Scale(camAngle), depth, startOffset);
    ATMOSPHERICS_LOOP_END
    float fCos = dot(_LightPos, normalize(camPos - pos));
    float fCos2 = fCos * fCos;
    float c0 = _InvWavelength * _KrESun * RayleighPhase(fCos2);
    float c1 = _KmESun * MiePhase(fCos, fCos2, _G, _G2);
    float3 col = frontColor * (c0 + c1);
    col = 1.0 - exp(col * -_HdrExposure);
    return float4(col, col.b);
}

#endif // ATMOSPHERICS_INCLUDE_
