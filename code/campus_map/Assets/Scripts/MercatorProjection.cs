using System;

//Based on C implementation of https://wiki.openstreetmap.org/wiki/Mercator#C_implementation

public static class MercatorProjection
{
    private const double Deg2Rad = Math.PI / 180.0;
    private const double EarthRadius = 6378137;

    public static double LonToX(double lon)
    {
        return DegToRad(lon) * EarthRadius;
    }

    public static double LatToY(double lat)
    {
        return Math.Log(Math.Tan(DegToRad(lat) / 2 + Math.PI / 4)) * EarthRadius * 1.65;
    }

    private static double DegToRad(double deg)
    {
        return deg * Deg2Rad;
    }
}