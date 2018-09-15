Shader "Custom/Projection"
{
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
        }

        Pass
        {
            Cull Back

            CGPROGRAM
            #pragma target 4.0
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Planet.cginc"
            #include "Projection.cginc"

            float2 _CoordOffset;
            float _Zoom;
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(float4 vertex : POSITION, float2 texcoord : TEXCOORD0)
            {
                v2f o;
                o.pos = mul(UNITY_MATRIX_VP, mul(unity_ObjectToWorld, vertex));
                o.uv = mad(texcoord, _Zoom, _CoordOffset);
                return o;
            }

            half3 frag(v2f i) : SV_Target
            {
                float longitude = (i.uv.x * UNITY_TWO_PI) - UNITY_PI;
                float zenith = UNITY_PI - (i.uv.y * UNITY_PI);

                // transform the spherical coords to texture space
                float2 texPos = float2((longitude + UNITY_PI) / UNITY_TWO_PI, (UNITY_PI - zenith) / UNITY_PI);

                // transform the spherical coords to cartesian coords
                float3 localPos = float3(
                    sin(zenith) * cos(longitude),
                    cos(zenith),
                    sin(zenith) * sin(longitude)
                );

                // sample the planet sphere
                return ComputePlanetSurfaceColor(texPos, localPos);
            }
            ENDCG
        }
    }
}
