using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.UIElements;

public class BuildingController : MonoBehaviour
{
    public Material roofMaterial, wallMaterial;

    public void GenerateBuilding(GeoNode[] nodes, float height, bool isFlippedRoof)
    {
        List<Vector3> polygonVertices = new List<Vector3>();
        for (int i = 0; i < nodes.Length; i++)
        {
            polygonVertices.Add(new Vector3(nodes[i].GetPosition().x, height, nodes[i].GetPosition().z));
        }

        polygonVertices.Reverse();
        Poly2Mesh.Polygon polygon = new Poly2Mesh.Polygon {outside = polygonVertices};
        GameObject roof = new GameObject("Roof");
        roof.transform.SetParent(gameObject.transform);
        MeshFilter roofMeshFilter = roof.AddComponent<MeshFilter>();
        MeshRenderer roofMeshRenderer = roof.AddComponent<MeshRenderer>();
        roofMeshFilter.mesh = Poly2Mesh.CreateMesh(polygon, isFlippedRoof);
        roofMeshRenderer.material = roofMaterial;

        List<Vector3> wallVertices = new List<Vector3>();
        for (int i = 0; i < polygonVertices.Count; i++)
        {
            wallVertices.Add(polygonVertices[i]);
        }
        for (int i = 0; i < polygonVertices.Count; i++)
        {
            wallVertices.Add(new Vector3(polygonVertices[i].x, 0f, polygonVertices[i].z));
        }
        
        List<int> frontWallTriangles = new List<int>();
        for (int i = 1; i < nodes.Length; i++)
        {
            frontWallTriangles.Add(i - 1);
            frontWallTriangles.Add(i);
            frontWallTriangles.Add(i + nodes.Length - 1);

            frontWallTriangles.Add(i + nodes.Length);
            frontWallTriangles.Add(i + nodes.Length - 1);
            frontWallTriangles.Add(i);
        }

        GameObject frontWalls = new GameObject("Front Walls");
        frontWalls.transform.SetParent(gameObject.transform);
        MeshFilter frontWallMeshFilter = frontWalls.AddComponent<MeshFilter>();
        MeshRenderer fromWallMeshRenderer = frontWalls.AddComponent<MeshRenderer>();
        frontWallMeshFilter.mesh.vertices = wallVertices.ToArray();
        frontWallMeshFilter.mesh.triangles = frontWallTriangles.ToArray();
        frontWallMeshFilter.mesh.RecalculateNormals();
        fromWallMeshRenderer.material = wallMaterial;
        
        List<int> backWallTriangles = new List<int>();
        for (int i = 1; i < nodes.Length; i++)
        {
            backWallTriangles.Add(i + nodes.Length - 1);
            backWallTriangles.Add(i);
            backWallTriangles.Add(i - 1);

            backWallTriangles.Add(i);
            backWallTriangles.Add(i + nodes.Length - 1);
            backWallTriangles.Add(i + nodes.Length);
        }

        GameObject backWalls = new GameObject("Back Walls");
        backWalls.transform.SetParent(gameObject.transform);
        MeshFilter backWallMeshFilter = backWalls.AddComponent<MeshFilter>();
        MeshRenderer backWallMeshRenderer = backWalls.AddComponent<MeshRenderer>();
        backWallMeshFilter.mesh.vertices = wallVertices.ToArray();
        backWallMeshFilter.mesh.triangles = backWallTriangles.ToArray();
        backWallMeshFilter.mesh.RecalculateNormals();
        backWallMeshRenderer.material = wallMaterial;
    }

    private Vector3 GetCenter(GeoNode[] baseNodes)
    {
        Vector3 center = new Vector3(0f, 0f, 0f);
        for (int i = 0; i < baseNodes.Length; i++)
        {
            center += baseNodes[i].GetPosition();
        }

        return center / baseNodes.Length;
    }

}
