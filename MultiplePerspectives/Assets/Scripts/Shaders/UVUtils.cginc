#ifndef UVUTILS_INCLUDE_
#define UVUTILS_INCLUDE_

struct UVGrad
{
    float2 uv;
#if defined(CLAMP_UV)
    float2 gradu;
    float2 gradv;
#endif
};

UVGrad GetUV(float2 uv)
{
    UVGrad uvg;
#if defined(CLAMP_UV)
    uvg.uv = frac(uv);
    uvg.gradu = float2(ddx(uvg.uv.x), ddy(uvg.uv.x));
    uvg.gradv = float2(ddx(uvg.uv.y), ddy(uvg.uv.y));

    const float gradientTreshold = 0.4;
    const float mipScale = 0.001;

    UNITY_FLATTEN
    if (length(uvg.gradu) > gradientTreshold)
    {
        uvg.gradu = normalize(uvg.gradu) * mipScale;
    }

    UNITY_FLATTEN
    if (length(uvg.gradv) > gradientTreshold)
    {
        uvg.gradv = normalize(uvg.gradv) * mipScale;
    }
#else
    uvg.uv = uv;
#endif
    return uvg;
}

half4 Sample(sampler2D tex, UVGrad uv)
{
#if defined(CLAMP_UV)
    return tex2Dgrad(tex, uv.uv, uv.gradu, uv.gradv);
#else
    return tex2D(tex, uv.uv);
#endif
}

#endif // UVUTILS_INCLUDE_
