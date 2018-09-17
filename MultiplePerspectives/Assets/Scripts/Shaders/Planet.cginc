#ifndef PLANET_INCLUDE_
#define PLANET_INCLUDE_

#include "Atmospherics.cginc"
#include "UVUtils.cginc"

sampler2D _PlanetDiffuse;
half _PlanetAtmosphereIntesity;
half _PlanetNightIntensity;

sampler2D _PlanetSpecular;
half4 _PlanetSpecularColor;
half _PlanetGlossiness;

sampler2D _PlanetLights;
half4 _PlanetLightsColor;

sampler2D _PlanetClouds;
half _PlanetCloudIntensity;
half _PlanetCloudDriftSpeed;
sampler2D _PlanetCloudVelocity;
half _PlanetCloudVelocityScale;
float _PlanetCloudTimeScale;
float _PlanetCloudSamples;

half3 GetPlanetDiffuse(UVGrad uv)
{
    return Sample(_PlanetDiffuse, uv).rgb;
}

half3 GetPlanetSpecular(UVGrad uv, float3 localPos, float3 camPos, float3 normal)
{
    float3 viewDir = normalize(camPos - localPos);
    float nh = max(0, dot(normal, normalize(_LightPos + viewDir)));
    return _PlanetSpecularColor * Sample(_PlanetSpecular, uv).r * pow(nh, _PlanetGlossiness * 128.0);
}

half3 GetPlanetClouds(UVGrad uv)
{
    float t = frac(_Time.x * _PlanetCloudTimeScale);
    float sampleCount = round(_PlanetCloudSamples);
    float2 currentPos = uv.uv;
    float2 timeOffset = float2(_Time.x * _PlanetCloudDriftSpeed, 0);
    half clouds = 0;

    UNITY_LOOP
    for (int s = 0; s < sampleCount; s++)
    {
        // move the position one step using the vector field
        float2 lastPos = currentPos;

        UVGrad velocityUV = uv;
        velocityUV.uv = currentPos + timeOffset;
        currentPos += (Sample(_PlanetCloudVelocity, velocityUV).rg - 0.5) * _PlanetCloudVelocityScale;

        // get the point along the way from the last sample to use
        float2 samplePos = lerp(lastPos, currentPos, t);

        // sample the texture and weight the contribution
        UVGrad cloudUV = uv;
        cloudUV.uv = samplePos + timeOffset;
        half sample = Sample(_PlanetClouds, cloudUV).r;
        half weight = -mad(abs(0.5 - ((s + t) / sampleCount)), 2.0, -1.0);
        clouds += sample * weight;
    }
    return clouds * _PlanetCloudIntensity;
}

half3 GetCityLights(UVGrad uv, float3 normal, half cloudStrengh)
{
    half3 lights = _PlanetLightsColor * Sample(_PlanetLights, uv).r;
    half lightStrength = saturate((dot(-normal, _LightPos) + 0.025) * 2.0);
    half clearSky = saturate(1.0 - (cloudStrengh * 2.0));
    return lights * lightStrength * clearSky;
}

half3 ComputePlanetSurfaceColor(UVGrad uv, float3 localPos)
{
    float3 camPos = localPos * 2.0;

    half3 diffuse = GetPlanetDiffuse(uv);
    half3 clouds = GetPlanetClouds(uv);
    half3 lights = GetCityLights(uv, localPos, clouds.r);
    half3 atmosphere = ComputeSurfaceAtmospherics(localPos, camPos);

    half3 result = lerp(diffuse, clouds, clouds);
    result *= (1 - _PlanetNightIntensity) + (_PlanetNightIntensity * (atmosphere.b / _PlanetAtmosphereIntesity));
    return mad(atmosphere, _PlanetAtmosphereIntesity, result + lights);
}

half3 ComputePlanetSurfaceColor(UVGrad uv, float3 localPos, float3 camPos)
{
    half3 diffuse = GetPlanetDiffuse(uv);
    half3 spec = GetPlanetSpecular(uv, localPos, camPos, localPos);
    half3 clouds = GetPlanetClouds(uv);
    half3 lights = GetCityLights(uv, localPos, clouds.r);
    half3 atmosphere = ComputeSurfaceAtmospherics(localPos, camPos);

    half3 result = lerp(diffuse + spec, clouds, clouds);
    result *= (1 - _PlanetNightIntensity) + (_PlanetNightIntensity * (atmosphere.b / _PlanetAtmosphereIntesity));
    return mad(atmosphere, _PlanetAtmosphereIntesity, result + lights);
}

#endif // PLANET_INCLUDE_
