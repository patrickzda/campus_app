using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using Unity.VisualScripting;
using UnityEngine;

public class NavigationController : MonoBehaviour
{
    private LineRenderer routeLineRenderer, progressLineRenderer;
    private readonly float mapCenterLatitude = 52.5126624f, mapCenterLongitude = 13.3231489f;

    private Vector3 userPosition;
    private int progressLineVertexCount;
    
    private void Start()
    {
        routeLineRenderer = transform.GetChild(0).GetComponent<LineRenderer>();
        progressLineRenderer = transform.GetChild(1).GetComponent<LineRenderer>();
    }

    //AUS FLUTTER, Parameter: Koordinaten der Polyline im Format lat0, lon0, lat1, long1, ...
    public void CreatePolyline(string coordinates)
    {
        string[] coordinateData = coordinates.Split(",");
        Vector3[] nodes = new Vector3[coordinateData.Length / 2];
        int nodeIndex = 0;
        
        for (int i = 0; i < nodes.Length; i++)
        {
            Vector3 currentPosition = CoordinatesToVector3(ParseFloat(coordinateData[nodeIndex]),ParseFloat(coordinateData[nodeIndex + 1]));
            nodes[i] = new Vector3(currentPosition.x, 0.01f, currentPosition.z);
            nodeIndex += 2;
        }

        routeLineRenderer.startWidth = 0.15f;
        routeLineRenderer.endWidth = 0.15f;
        routeLineRenderer.positionCount = nodes.Length;
        routeLineRenderer.SetPositions(nodes);
        
        progressLineRenderer.startWidth = 0.15f;
        progressLineRenderer.endWidth = 0.15f;
        progressLineRenderer.positionCount = 0;
    }

    //AUS FLUTTER, Parameter: Koordinaten des Nutzerstandortes im Format lat, lon
    public void UpdatePolylineProgress(string userCoordinates)
    {
        string[] coordinateData = userCoordinates.Split(",");
        Vector3 convertedPosition = CoordinatesToVector3(ParseFloat(coordinateData[0]), ParseFloat(coordinateData[1]));
        ProjectUserPositionOntoPolyline(convertedPosition);

        Vector3[] progressLineVertices = new Vector3[progressLineVertexCount];
        for (int i = 0; i < progressLineVertices.Length - 1; i++)
        {
            progressLineVertices[i] = routeLineRenderer.GetPosition(i);
        }
        progressLineVertices[^1] = userPosition;

        progressLineRenderer.positionCount = progressLineVertexCount;
        progressLineRenderer.SetPositions(progressLineVertices);
    }
    
    //AUS FLUTTER
    public void DeletePolyline()
    {
        routeLineRenderer.positionCount = 0;
        progressLineRenderer.positionCount = 0;
    }

    private void ProjectUserPositionOntoPolyline(Vector3 currentUserPosition)
    {
        Vector3 closestPoint = Vector3.zero;
        float minDistance = float.PositiveInfinity;
        int closestsIndex = 0;
        for (int i = 0; i < routeLineRenderer.positionCount - 1; i++)
        {
            Vector3 currentPoint = GetClosestPointOnLineSegment(routeLineRenderer.GetPosition(i), routeLineRenderer.GetPosition(i + 1), currentUserPosition);
            if ((currentUserPosition - currentPoint).magnitude <= minDistance)
            {
                minDistance = (currentUserPosition - currentPoint).magnitude;
                closestPoint = currentPoint;
                closestsIndex = i + 1;
            }
        }

        userPosition = closestPoint;
        progressLineVertexCount = closestsIndex + 1;
    }

    private Vector3 GetClosestPointOnLineSegment(Vector3 lineStart, Vector3 lineEnd, Vector3 point)
    {
        Vector3 lineHeading = lineEnd - lineStart;
        float lineMagnitude = lineHeading.magnitude;
        lineHeading.Normalize();
        
        float clampedDotProduct = Mathf.Clamp(Vector3.Dot(point - lineStart, lineHeading), 0f, lineMagnitude);
        return lineStart + lineHeading * clampedDotProduct;
    }

    private Vector3 CoordinatesToVector3(float latitude, float longitude)
    {
        return new GeoNode(latitude - mapCenterLatitude, longitude - mapCenterLongitude).GetPosition();
    }
    
    private float ParseFloat(string value)
    {
        return float.Parse(value, CultureInfo.InvariantCulture);
    }
    
}
