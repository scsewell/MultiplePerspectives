Shader "Custom/Atmosphere"
{
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
            "IgnoreProjector" = "True"
        }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Front

            CGPROGRAM
            #pragma target 4.0
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Planet.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 localPos : TEXCOORD5;
            };

            v2f vert(float4 vertex : POSITION)
            {
                v2f o;
                o.localPos = vertex;
                o.pos = UnityObjectToClipPos(vertex);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                return ComputeAtmosphere(normalize(i.localPos), _CamPos);
            }
            ENDCG
        }
    }
}