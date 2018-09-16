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

/*
 *  Wrapping Functions
 */

float Wrap(float x, float range)
{
    return ((x % range) + range) % range;
}

float WrapLongitudeToroidal(float longitude)
{
    return Wrap(longitude, UNITY_TWO_PI);
}

float WrapZenithToroidal(float zenith)
{
    return Wrap(zenith, UNITY_PI);
}

float WrapLongitudeAlternatingMirror(float longitude)
{
    return UNITY_TWO_PI - abs(UNITY_TWO_PI - Wrap(longitude, UNITY_FOUR_PI));
}

float WrapZenithAlternatingMirror(float zenith)
{
    return UNITY_PI - abs(UNITY_PI - Wrap(zenith, UNITY_TWO_PI));
}

float WrapLongitudeAlternatingMirrorShifted(float longitude, float zenith)
{
    UNITY_FLATTEN
    if (UNITY_PI < Wrap(zenith, UNITY_TWO_PI))
    {
        return longitude;
    }
    else
    {
        return (longitude + UNITY_PI) % UNITY_TWO_PI;
    }
}

#endif // PROJECTION_INCLUDE_
