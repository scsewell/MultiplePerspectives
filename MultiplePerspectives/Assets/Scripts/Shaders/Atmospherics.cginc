#ifndef ATMOSPHERICS_INCLUDE_
#define ATMOSPHERICS_INCLUDE_

// See original article for details: https://developer.nvidia.com/gpugems/GPUGems2/gpugems2_chapter16.html

float3 v3Translate;         // The objects world pos
float3 v3LightPos;          // The direction vector to the light source
float3 v3InvWavelength;     // 1 / pow(wavelength, 4) for the red, green, and blue channels
float fOuterRadius;         // The outer (atmosphere) radius
float fOuterRadius2;        // fOuterRadius^2
float fInnerRadius;         // The inner (planetary) radius
float fInnerRadius2;        // fInnerRadius^2
float fKrESun;              // Kr * ESun
float fKmESun;              // Km * ESun
float fKr4PI;               // Kr * 4 * PI
float fKm4PI;               // Km * 4 * PI
float fScale;               // 1 / (fOuterRadius - fInnerRadius)
float fScaleDepth;          // The scale depth (i.e. the altitude at which the atmosphere's average density is found)
float fScaleOverScaleDepth; // fScale / fScaleDepth
float fHdrExposure;         // HDR exposure
float g;                    // The Mie phase asymmetry factor
float g2;                   // The Mie phase asymmetry factor squared
float sampleCount;          // The number of samples to use

float Scale(float fCos)
{
    float x = 1.0 - fCos;
    return 0.25 * exp(-0.00287 + x * (0.459 + x * (3.83 + x * (-6.80 + x * 5.25))));
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

#define ATMOSPHERICS_SETUP float3 camPos = _WorldSpaceCameraPos - v3Translate; /* Get the camera position */   \
float camHeight = length(camPos);                                                   \
float camHeight2 = camHeight * camHeight;                                           \
float3 pos = mul(unity_ObjectToWorld, v.vertex).xyz - v3Translate; /* Get the ray from the camera to the vertex and its length (which is the far point of the ray passing through the atmosphere) */    \
float3 ray = pos - camPos;                                                          \
float far = length(ray);                                                            \
ray /= far;                                                                         \
float B = 2.0 * dot(camPos, ray); /* Calculate the closest intersection of the ray with the outer atmosphere (which is the near point of the ray passing through the atmosphere) */ \
float C = camHeight2 - fOuterRadius2;                                               \
float det = max(0.0, mad(B, B, -4 * C));                                            \
float near = 0.5 * (-B - sqrt(det));                                                \
float3 start = mad(near, ray, camPos); /* Calculate the ray's start and end positions in the atmosphere, then calculate its scattering offset */    \
far -= near;                                                                        \


#define ATMOSPHERICS_LOOP_START float sampleLength = far / sampleCount; /* Initialize the scattering loop variables */  \
float scaledLength = sampleLength * fScale;                                         \
float3 sampleRay = ray * sampleLength;                                              \
float3 samplePoint = mad(sampleRay, 0.5, start);                                    \
float3 frontColor = float3(0.0, 0.0, 0.0); /* Now loop through the sample rays */   \
float3 attenuation;                                                                 \
for (int i = 0; i< int(sampleCount); i++) {                                         \
    float height = length(samplePoint);                                             \
    float depth = exp(fScaleOverScaleDepth * (fInnerRadius - height));              \


#define ATMOSPHERICS_LOOP_END samplePoint += sampleRay;                             \
    attenuation = exp(-scatter * mad(v3InvWavelength, fKr4PI, fKm4PI));             \
    frontColor += attenuation * depth * scaledLength;                               \
}                                                                                   \

#endif // ATMOSPHERICS_INCLUDE_
