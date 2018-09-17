Shader "Custom/Projection"
{
    Properties
    {
        [Toggle(_DEBUG_ON)] _Debug ("Debug", Float) = 0.0
    }

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

            #pragma multi_compile __ _DEBUG_ON

            #define CLAMP_UV

            #include "UnityCG.cginc"
            #include "Planet.cginc"
            #include "Projection.cginc"

            float4x4 _Rotation;
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
                o.uv = mad(texcoord - 0.5, _Zoom, _CoordOffset) + 0.5;
                return o;
            }

            half3 frag(v2f i) : SV_Target
            {
                float longitude = (i.uv.x * UNITY_TWO_PI) - UNITY_PI;
                float zenith = UNITY_PI - (i.uv.y * UNITY_PI);

                longitude = WrapLongitudeAlternatingMirrorShifted(longitude, zenith);
                zenith = WrapZenithAlternatingMirror(zenith);

#if defined( _DEBUG_ON)
                // check that the texture coords will match the point on the sphere, otherwise the lighting
                // in the projection will not be aligned with the textures
                if (zenith < 0 || UNITY_PI < zenith || longitude < 0 || UNITY_TWO_PI < longitude)
                {
                    return half3(1, 0, 1);
                }
#endif

                float3 localPos = mul(_Rotation, SphericalToCartesian(longitude, zenith));
                float2 rotatedSphere = CartesianToSpherical(localPos);
                longitude = rotatedSphere.x;
                zenith = rotatedSphere.y;

                // transform the spherical coords to texture space
                float2 texPos = float2((longitude + UNITY_PI) / UNITY_TWO_PI, (UNITY_PI - zenith) / UNITY_PI);
                
                // sample the planet sphere
                return ComputePlanetSurfaceColor(GetUV(texPos), localPos);
            }
            ENDCG
        }
    }
}
