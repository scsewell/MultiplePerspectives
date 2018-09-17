Shader "Custom/PlanetSurface"
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

            struct v2f
            {
                float4 pos      : SV_POSITION;
                float3 localPos : TEXCOORD0;
                float2 uv       : TEXCOORD1;
            };

            v2f vert(float4 vertex : POSITION, float2 texcoord : TEXCOORD0)
            {
                v2f o;
                o.localPos = vertex;
                o.pos = mul(UNITY_MATRIX_VP, mul(unity_ObjectToWorld, vertex));
                o.uv = texcoord;
                return o;
            }

            half3 frag(v2f i) : SV_Target
            {
                return ComputePlanetSurfaceColor(GetUV(i.uv), normalize(i.localPos), _CamPos);
            }
            ENDCG
        }
    }
}