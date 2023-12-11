using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Splines;

public class RoadController : MonoBehaviour
{
    public void GenerateRoad(GeoNode[] nodes, float width)
    {
        Vector3[] points = new Vector3[nodes.Length];
        for (int i = 0; i < nodes.Length; i++)
        {
            points[i] = new Vector3(nodes[i].GetPosition().x, -0.03f, nodes[i].GetPosition().z);
        }

        List<Vector3> roadVertices = new List<Vector3>();
        for (int i = 0; i < points.Length - 1; i++)
        {
            Vector3 right = Vector3.Cross(points[i + 1] - points[i], Vector3.up).normalized;
            roadVertices.Add(points[i] + right * width);
            roadVertices.Add(points[i] - right * width);
        }
        Vector3 lastRight = Vector3.Cross(points[^1] - points[^2], Vector3.up).normalized;
        roadVertices.Add(points[^1] + lastRight * width);
        roadVertices.Add(points[^1] - lastRight * width);

        List<int> roadTriangles = new List<int>();
        for (int i = 0; i < roadVertices.Count - 3; i += 2)
        {
            roadTriangles.Add(i + 2);
            roadTriangles.Add(i + 1);
            roadTriangles.Add(i);
        
            roadTriangles.Add(i + 2);
            roadTriangles.Add(i + 3);
            roadTriangles.Add(i + 1);
        }

        Mesh mesh = GetComponent<MeshFilter>().mesh;
        mesh.vertices = roadVertices.ToArray();
        mesh.triangles = roadTriangles.ToArray();
        mesh.RecalculateNormals();
    }
}
