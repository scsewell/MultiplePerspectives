#ifndef PROJECTION_INCLUDE_
#define PROJECTION_INCLUDE_

float LatitudeToZenith(float latitude)
{
    return UNITY_HALF_PI - latitude;
}

float ZenithToLatitude(float zenith)
{
    return UNITY_HALF_PI - zenith;
}

#endif // PROJECTION_INCLUDE_
