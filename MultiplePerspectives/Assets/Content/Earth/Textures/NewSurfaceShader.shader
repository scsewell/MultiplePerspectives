Shader "Custom/NewSurfaceShader"
{
	Properties
    {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
        _timeScale ("Time Scale", Range(0, 10)) = 1.0
        _Steps ("Steps", Range(0, 16)) = 5.0
        _Velocity ("Velocity", Range(0, 1)) = 0.15
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

		    sampler2D _MainTex;
            float _timeScale;
            float _Steps;
            float _Velocity;

            struct v2f
            {
                float4 pos      : SV_POSITION;
                float3 localPos : TEXCOORD0;
                float2 uv       : TEXCOORD1;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.pos = mul(UNITY_MATRIX_VP, float4(worldPos, 1.0));
                o.localPos = v.vertex;
                o.uv = v.texcoord.xy;
                return o;
            }

            half3 frag(v2f i) : SV_Target
            {
                float t = (_Time.x * _timeScale) % 1.0;

                float foreTime = (_Steps * t) % 1.0;
                float backTime = 1 - foreTime;

                float2 foreSamplePrev = i.localPos;
                float2 backSamplePrev = i.localPos;

                float2 foreSample = foreSamplePrev;
                float2 backSample = backSamplePrev;

                for (int j = 0; j < ceil(foreTime); j++)
                {
                    foreSamplePrev = foreSample;
                    foreSample -= float2(0.1, 0) * _Velocity;
                    //foreSample -= float2(-foreSample.y, foreSample.x) * _Velocity;
                }
                for (int i = 0; i < ceil(backTime); i++)
                {
                    backSamplePrev = backSample;
                    backSample += float2(0.1, 0) * _Velocity;
                    //backSample += float2(-backSample.y, backSample.x) * _Velocity;
                }

                foreSample = lerp(foreSamplePrev, foreSample, foreTime);
                backSample = lerp(backSamplePrev, backSample, backTime);

                half3 diffuse = lerp(tex2D(_MainTex, foreSample + 0.5).rgb, tex2D(_MainTex, backSample + 0.5).rgb, foreTime);
                return diffuse;
            }
		    ENDCG
        }
	}
}
