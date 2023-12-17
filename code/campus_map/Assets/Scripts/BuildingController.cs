using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.UIElements;

public class BuildingController : MonoBehaviour
{
    public Material roofMaterial, wallMaterial;

    public void GenerateBuilding(GeoNode[] nodes, float height, bool isFlippedRoof, string name)
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
        
        Vector3[] roofMeshVertices = roofMeshFilter.mesh.vertices;
        Vector2[] roofUvs = new Vector2[roofMeshVertices.Length];
        for (int i = 0; i < roofUvs.Length; i++)
        {
            roofUvs[i] = new Vector2(roofMeshVertices[i].x, roofMeshVertices[i].z);
        }
        
        roofMeshFilter.mesh.uv = roofUvs;

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
        
        Vector3[] frontMeshVertices = frontWallMeshFilter.mesh.vertices;
        Vector2[] frontUvs = new Vector2[frontMeshVertices.Length];
        for (int i = 0; i < frontUvs.Length; i++)
        {
            frontUvs[i] = new Vector2(frontMeshVertices[i].x, frontMeshVertices[i].z);
        }
        
        frontWallMeshFilter.mesh.uv = frontUvs;
        
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
        
        Vector3[] backMeshVertices = backWallMeshFilter.mesh.vertices;
        Vector2[] backUvs = new Vector2[backMeshVertices.Length];
        for (int i = 0; i < backUvs.Length; i++)
        {
            backUvs[i] = new Vector2(backMeshVertices[i].x, backMeshVertices[i].z);
        }
        
        backWallMeshFilter.mesh.uv = backUvs;
        
        //AssetDatabase.CreateAsset(roofMeshFilter.mesh, "Assets/Meshes/Buildings/" + name + " Roof" + ".asset");
        //AssetDatabase.CreateAsset(frontWallMeshFilter.mesh, "Assets/Meshes/Buildings/" + name + " Front" + ".asset");
        //AssetDatabase.CreateAsset(backWallMeshFilter.mesh, "Assets/Meshes/Buildings/" + name + " Back" + ".asset");
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
