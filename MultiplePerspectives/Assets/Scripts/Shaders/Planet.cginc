#ifndef PLANET_INCLUDE_
#define PLANET_INCLUDE_

#include "Atmospherics.cginc"

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

half3 GetPlanetDiffuse(float2 uv)
{
    return tex2D(_PlanetDiffuse, uv).rgb;
}

half3 GetPlanetSpecular(float2 uv, float3 localPos, float3 camPos, float3 normal)
{
    float3 viewDir = normalize(camPos - localPos);
    float nh = max(0, dot(normal, normalize(_LightPos + viewDir)));
    return _PlanetSpecularColor * tex2D(_PlanetSpecular, uv).r * pow(nh, _PlanetGlossiness * 128.0);
}

half3 GetPlanetClouds(float2 uv)
{
    float t = frac(_Time.x * _PlanetCloudTimeScale);
    float sampleCount = round(_PlanetCloudSamples);
    float2 currentPos = uv;
    float2 timeOffset = float2(_Time.x * _PlanetCloudDriftSpeed, 0);
    half clouds = 0;

    for (int s = 0; s < sampleCount; s++)
    {
        // move the position one step using the vector field
        float2 lastPos = currentPos;
        currentPos += (tex2D(_PlanetCloudVelocity, currentPos + timeOffset).rg - 0.5) * _PlanetCloudVelocityScale;

        // get the point along the way from the last sample to use
        float2 samplePos = lerp(lastPos, currentPos, t);

        // sample the texture and weight the contribution
        half sample = tex2D(_PlanetClouds, samplePos + timeOffset).r;
        half weight = -mad(abs(0.5 - ((s + t) / sampleCount)), 2.0, -1.0);
        clouds += sample * weight;
    }
    return clouds * _PlanetCloudIntensity;
}

half3 GetCityLights(float2 uv, float3 normal, half cloudStrengh)
{
    half3 lights = _PlanetLightsColor * tex2D(_PlanetLights, uv).r;
    half lightStrength = saturate((dot(-normal, _LightPos) + 0.025) * 2);
    half clearSky = saturate(1.0 - (cloudStrengh * 2.0));
    return lights * lightStrength * clearSky;
}

half3 ComputePlanetSurfaceColor(float2 uv, float3 localPos)
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

half3 ComputePlanetSurfaceColor(float2 uv, float3 localPos, float3 camPos)
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
