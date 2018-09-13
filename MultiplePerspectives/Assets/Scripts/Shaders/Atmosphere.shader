Shader "Custom/Atmosphere"
{
    SubShader
    {
        Pass
        {
            Tags
            {
                "Queue" = "Transparent" 
                "RenderType" = "Transparent"
                "IgnoreProjector" = "True"
            }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Front

            CGPROGRAM
            #pragma target 4.0
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "Atmospherics.cginc"
            
            struct v2f
            {
                float4 pos  : SV_POSITION;
                float2 uv   : TEXCOORD0;
                float3 t0   : TEXCOORD1;
                float3 c0   : COLOR0;
                float3 c1   : COLOR1;
            };

            v2f vert(appdata_base v)
            {
                ATMOSPHERICS_SETUP

                // Calculate the ray's start and end positions in the atmosphere, then calculate its scattering offset
                float startAngle = dot(ray, start) / fOuterRadius;
                float startOffset = exp(-1.0 / fScaleDepth) * Scale(startAngle);

                ATMOSPHERICS_LOOP_START
                float lightAngle = dot(v3LightPos, samplePoint) / height;
                float camAngle = dot(ray, samplePoint) / height;
                float scatter = mad(Scale(lightAngle) - Scale(camAngle), depth, startOffset);
                ATMOSPHERICS_LOOP_END

                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord.xy;

                // Scale the Mie and Rayleigh colors and set up the varying variables for the pixel shader
                o.c0 = frontColor * (v3InvWavelength * fKrESun);
                o.c1 = frontColor * fKmESun;
                o.t0 = camPos - pos;

                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                float fCos = dot(v3LightPos, i.t0) / length(i.t0);
                float fCos2 = fCos * fCos;
                float3 col = mad(RayleighPhase(fCos2), i.c0, MiePhase(fCos, fCos2, g, g2) * i.c1);
                col = 1.0 - exp(col * -fHdrExposure);
                return float4(col, col.b);
            }
            ENDCG
        }
    }
}