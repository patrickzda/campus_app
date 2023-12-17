using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class GreenAreaController : MonoBehaviour
{
    public void GenerateGreenArea(GeoNode[] nodes, bool isFlippedGreenArea, int index)
    {
        List<Vector3> polygonVertices = new List<Vector3>();
        for (int i = 0; i < nodes.Length; i++)
        {
            polygonVertices.Add(new Vector3(nodes[i].GetPosition().x, -0.02f, nodes[i].GetPosition().z));
        }

        polygonVertices.Reverse();
        Poly2Mesh.Polygon polygon = new Poly2Mesh.Polygon {outside = polygonVertices};
        
        GetComponent<MeshFilter>().mesh = Poly2Mesh.CreateMesh(polygon, isFlippedGreenArea);
        
        Vector3[] meshVertices = GetComponent<MeshFilter>().mesh.vertices;
        Vector2[] uvs = new Vector2[meshVertices.Length];
        for (int i = 0; i < uvs.Length; i++)
        {
            uvs[i] = new Vector2(meshVertices[i].x, meshVertices[i].z);
        }
        
        GetComponent<MeshFilter>().mesh.uv = uvs;
        
        //Mesh persistentMesh = new Mesh();
        //persistentMesh.vertices = GetComponent<MeshFilter>().mesh.vertices;
        //persistentMesh.triangles = GetComponent<MeshFilter>().mesh.triangles;
        //persistentMesh.normals = GetComponent<MeshFilter>().mesh.normals;
        //persistentMesh.uv = GetComponent<MeshFilter>().mesh.uv;
        //AssetDatabase.CreateAsset(persistentMesh, "Assets/Meshes/Green Areas/" + "Green Area " + index + ".asset");
    }
}
