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
    private readonly float lineWidth = 0.05f;
    
    private void Start()
    {
        routeLineRenderer = transform.GetChild(0).GetComponent<LineRenderer>();
        progressLineRenderer = transform.GetChild(1).GetComponent<LineRenderer>();
        
        CreatePolyline("52.5104297, 13.3279265, 52.51044437447374, 13.328046784629038, 52.5107588, 13.3270214, 52.5108799, 13.3269617, 52.5109198, 13.3269965, 52.511063, 13.3271077, 52.511179, 13.3271027, 52.5112455, 13.3270873, 52.5113273, 13.3270607, 52.5114039, 13.3270201, 52.5116144, 13.326844, 52.5116946, 13.3267925, 52.5117153, 13.3267896, 52.5123414, 13.326959, 52.5126033, 13.3268155, 52.5126347, 13.3268115, 52.512666, 13.3268084, 52.5127285, 13.3267976, 52.5131254, 13.3267295, 52.5131316, 13.3267285, 52.5133376, 13.3266947, 52.5133561, 13.3266917, 52.5133439, 13.3265038, 52.5135481, 13.3264573, 52.5135844, 13.3264728, 52.5137085, 13.3266107, 52.5137642, 13.3266333, 52.5137981, 13.3266341, 52.5138403, 13.326628, 52.5138566, 13.3266239, 52.5139109, 13.3265982, 52.5139601, 13.3265723, 52.5142941, 13.3264931, 52.514309, 13.3265473, 52.5143749, 13.326624, 52.5153263, 13.3269248, 52.5153186, 13.3270485, 52.5155019, 13.3268708, 52.515671, 13.3266975, 52.5157118, 13.326651, 52.51583798329214, 13.326496143511648, 52.5158210080464, 13.32641675019029, 52.5159412, 13.3262515, 52.5162467, 13.3257903, 52.51635758235166, 13.325590826133343, 52.51649972794277, 13.325289286589529, 52.516521753554905, 13.325234816715279, 52.51663153524102, 13.32492970425358, 52.5167537, 13.32456, 52.516772, 13.3244238, 52.51689085385574, 13.32411159671043, 52.51649502018123, 13.323789611544383, 52.5165159, 13.3237179");
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

        routeLineRenderer.startWidth = lineWidth;
        routeLineRenderer.endWidth = lineWidth;
        routeLineRenderer.positionCount = nodes.Length;
        routeLineRenderer.SetPositions(nodes);
        
        progressLineRenderer.startWidth = lineWidth;
        progressLineRenderer.endWidth = lineWidth;
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
