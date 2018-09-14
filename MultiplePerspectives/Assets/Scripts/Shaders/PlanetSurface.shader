Shader "Custom/PlanetSurface"
{
    Properties
    {
        _MainTex("Main", 2D) = "white" {}
        _AtmosphereIntesity("Atmosphere Intensity", Range(0, 1)) = 0.5
        _NightIntensity("Night Intensity", Range(0, 1)) = 1.0

        _Specular("Spec Color", Color) = (1,1,1,1)
        _Glossiness("Smoothness", Range(0, 10)) = 0.5
        _SpecularMap("Specular Map (R)", 2D) = "white" {}

        [HDR]_CityLightsColor("City Light Color (R)", Color) = (1,1,1,1)
        _CityLights("City Lights", 2D) = "white" {}
        
		[Space(30)]_Clouds ("Clouds (R)", 2D) = "white" {}
        _CloudsIntensity("Clouds Intensity", Range(0, 2)) = 1.0
        _TimeScale ("Time Scale", Range(0, 10)) = 1.0
        [IntRange]_Samples ("Samples", Range(1, 16)) = 3.0
        _VelocityField("Velocity (RG), Period Offset (B)", 2D) = "white" {}
        _Velocity ("Velocity Scale", Range(0, 0.1)) = 0.05
    }

    SubShader
    {
        Pass
        {
            Tags
            { 
                "RenderType" = "Opaque"
            }

            CGPROGRAM
            #pragma target 4.0
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Atmospherics.cginc"

            sampler2D _MainTex;
            half _AtmosphereIntesity;
            half _NightIntensity;

            fixed4 _Specular;
            half _Glossiness;
            sampler2D _SpecularMap;

            half4 _CityLightsColor;
            sampler2D _CityLights;

            sampler2D _Clouds;
            half _CloudsIntensity;
            sampler2D _VelocityField;
            float _TimeScale;
            float _Samples;
            float _Velocity;

            struct v2f
            {
                float4 pos      : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 normal   : NORMAL0;
                float3 lightDir : NORMAL1;
                float2 uv       : TEXCOORD1;
                float3 c0       : COLOR0;
                float3 c1       : COLOR1;
            };

            v2f vert(appdata_base v)
            {
                ATMOSPHERICS_SETUP

                // Calculate the ray's starting position, then calculate its scattering offset
                float fDepth = exp((fInnerRadius - fOuterRadius) / fScaleDepth);
                float camAngle = dot(-ray, pos) / length(pos);
                float lightAngle = dot(v3LightPos, pos) / length(pos);
                float camScale = Scale(camAngle);
                float camOffset = fDepth * camScale;
                float temp = Scale(lightAngle) + camScale;

                ATMOSPHERICS_LOOP_START
                 float scatter = mad(fDepth, temp, -camOffset);
                ATMOSPHERICS_LOOP_END

                v2f o;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.pos = mul(UNITY_MATRIX_VP, float4(o.worldPos, 1.0));
                o.normal = UnityObjectToWorldDir(v.vertex);
                o.lightDir = v3LightPos;
                o.uv = v.texcoord.xy;
                o.c0 = frontColor * mad(v3InvWavelength, fKrESun, fKmESun);
                o.c1 = attenuation;

                return o;
            }

            half3 frag(v2f i) : SV_Target
            {
                half3 normal = normalize(i.normal);
                half3 lightDir = normalize(i.lightDir);
                half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

                // diffuse
                half3 diffuse = tex2D(_MainTex, i.uv).rgb;

                // specular
                float nh = max(0, dot(normal, normalize(lightDir + viewDir)));
                half3 spec = _Specular * tex2D(_SpecularMap, i.uv).r * pow(nh, _Glossiness * 128.0);

                // clouds
                float t = frac(_Time.x * _TimeScale);
                // This causes some sort of artifacting where t=0. maybe this just reveals an underlying issue?
                // Couldn't find anything wrong though
                //float t = frac((_Time.x + tex2D(_VelocityField, i.uv).b) * _TimeScale);

                float sampleCount = round(_Samples);
                float2 currentPos = i.uv;
                half3 clouds = half3(0, 0, 0);

                for (int s = 0; s < sampleCount; s++)
                {
                    // move the position one step using the vector field
                    float2 lastPos = currentPos;
                    currentPos += (tex2D(_VelocityField, currentPos).rg - 0.5) * _Velocity;

                    // get the point along the way from the last sample to use
                    float2 samplePos = lerp(lastPos, currentPos, t);

                    // sample the texture and weight the contribution
                    half3 sample = tex2D(_Clouds, samplePos).r;
                    half weight = -mad(abs(0.5 - ((s + t) / sampleCount)), 2.0, -1.0);
                    clouds += sample * weight;
                }
                clouds *= _CloudsIntensity;

                // city lights
                half3 lights = saturate((dot(-normal, lightDir) + 0.025) * 2) * _CityLightsColor * tex2D(_CityLights, i.uv).r;
                lights *= saturate(-mad(clouds.r, 2.5, -1.0));

                // finalize the atmospheric calculation
                float3 atmosphere =  mad(i.c1, 0.25, i.c0);
                atmosphere = 1.0 - exp(atmosphere * -fHdrExposure);

                // combine the surface with the atmosphere
                half3 result = lerp(diffuse + spec, clouds.rgb, clouds.r);
                result *= (1 - _NightIntensity) + (_NightIntensity * (atmosphere.b / _AtmosphereIntesity));
                return mad(atmosphere, _AtmosphereIntesity, result + lights);
            }
            ENDCG
        }
    }
}