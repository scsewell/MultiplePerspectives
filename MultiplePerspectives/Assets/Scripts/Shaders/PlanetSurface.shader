Shader "Custom/PlanetSurface"
{
    Properties
    {
        _MainTex("Main", 2D) = "white" {}

        _Specular("Spec Color", Color) = (1,1,1,1)
        _Glossiness("Smoothness", Range(0, 10)) = 0.5
        _SpecularMap("Specular Map", 2D) = "white" {}

        [HDR]_CityLightsColor("City Light Color", Color) = (1,1,1,1)
        _CityLights("City Lights", 2D) = "white" {}

        _Clouds("Clouds", 2D) = "white" {}
        _CloudSpeed("Cloud Speed", Range(-1, 1)) = 0.05
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
            fixed4 _Specular;
            half _Glossiness;
            sampler2D _SpecularMap;
            half4 _CityLightsColor;
            sampler2D _CityLights;
            sampler2D _Clouds;
            half _CloudSpeed;

            struct v2f
            {
                float4 pos      : SV_POSITION;
                float3 worldPos : TEXCOORD1;
                float3 normal   : NORMAL0;
                float3 lightDir : NORMAL1;
                float2 uv       : TEXCOORD2;
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
                half3 spec = _Specular * tex2D(_SpecularMap, i.uv) * pow(nh, _Glossiness * 128.0);

                // clouds 
                fixed4 mainCol = tex2D(_MainTex, i.uv);
                fixed4 clouds = tex2D(_Clouds, i.uv + float2(_Time.x * _CloudSpeed, 0));

                // city lights
                half3 lights = saturate(dot(-normal, lightDir) * 10) * _CityLightsColor * tex2D(_CityLights, i.uv);

                // finalize the atmospheric calculation
                float3 atmosphere =  mad(i.c1, 0.25, i.c0);
                atmosphere = 1.0 - exp(atmosphere * -fHdrExposure);

                // combine the surface with the atmosphere
                half3 result = lerp(diffuse + spec, clouds.rgb, clouds.r);
                result *= atmosphere.b * 1.5;
                return result + (atmosphere * 0.75) + (lights * (1 - clouds.r));
            }
            ENDCG
        }
    }
}