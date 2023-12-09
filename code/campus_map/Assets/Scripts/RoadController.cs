using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RoadController : MonoBehaviour
{
    public void GenerateRoad(GeoNode[] nodes, float width)
    {
        LineRenderer road = GetComponent<LineRenderer>();

        Vector3[] points = new Vector3[nodes.Length];
        for (int i = 0; i < nodes.Length; i++)
        {
            points[i] = nodes[i].GetPosition();
        }

        road.startWidth = width;
        road.endWidth = width;
        road.positionCount = points.Length;
        road.SetPositions(points);
    }
}
