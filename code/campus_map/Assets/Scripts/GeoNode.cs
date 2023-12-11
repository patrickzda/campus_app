using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GeoNode
{
    private readonly float latitude, longitude, xCoordinate, zCoordinate;
    private readonly Vector3 position;

    public GeoNode(float latitude, float longitude)
    {
        this.latitude = latitude;
        this.longitude = longitude;
        xCoordinate = (float) MercatorProjection.LonToX(longitude) / 100f;
        zCoordinate = (float) MercatorProjection.LatToY(latitude) / 100f;
        position = new Vector3(xCoordinate, 0f, zCoordinate);
    }

    public float GetLatitude()
    {
        return latitude;
    }
    
    public float GetLongitude()
    {
        return longitude;
    }
    
    public float GetX()
    {
        return xCoordinate;
    }
    
    public float GetZ()
    {
        return zCoordinate;
    }

    public Vector3 GetPosition()
    {
        return position;
    }
    
}
