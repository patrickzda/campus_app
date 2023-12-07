using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.UIElements;

public class OsmBuildingController : MonoBehaviour
{

    public void GenerateBuilding(OsmNode[] baseNodes, float height)
    {
        //Mesh mesh = new Mesh();
        //GetComponent<MeshFilter>().mesh = mesh;
        //Vector3[] vertices = new Vector3[baseNodes.Length + 1];
        //
        //for (int i = 0; i < baseNodes.Length; i++)
        //{
        //    vertices[i] = baseNodes[i].GetPosition();
        //}
        //vertices[baseNodes.Length] = GetCenter(baseNodes);

        //List<int> triangles = new List<int>();
        //for (int i = 1; i < baseNodes.Length; i++)
        //{
        //    triangles.Add(i - 1);
        //    triangles.Add(i);
        //    triangles.Add(baseNodes.Length);
        //    triangles.Add(baseNodes.Length);
        //    triangles.Add(i);
        //    triangles.Add(i - 1);
        //}

        //mesh.Clear();
        //mesh.vertices = vertices;
        //mesh.triangles = triangles.ToArray();
        //mesh.RecalculateNormals();

        List<Vector3> vertices = new List<Vector3>();
        
        for (int i = 0; i < baseNodes.Length; i++)
        {
            vertices.Add(baseNodes[i].GetPosition());
        }

        Poly2Mesh.Polygon polygon = new Poly2Mesh.Polygon
        {
            outside = vertices
        };
        
        Mesh mesh = Poly2Mesh.CreateMesh(polygon);
        GetComponent<MeshFilter>().mesh = mesh;
    }

    private Vector3 GetCenter(OsmNode[] baseNodes)
    {
        Vector3 center = new Vector3(0f, 0f, 0f);
        for (int i = 0; i < baseNodes.Length; i++)
        {
            center += baseNodes[i].GetPosition();
        }

        return center / baseNodes.Length;
    }

}
