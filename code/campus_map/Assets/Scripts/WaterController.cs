using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterController : MonoBehaviour
{
    public void GenerateWater(GeoNode[] nodes, bool isFlippedWater)
    {
        List<Vector3> polygonVertices = new List<Vector3>();
        for (int i = 0; i < nodes.Length; i++)
        {
            polygonVertices.Add(new Vector3(nodes[i].GetPosition().x, -0.01f, nodes[i].GetPosition().z));
        }

        polygonVertices.Reverse();
        Poly2Mesh.Polygon polygon = new Poly2Mesh.Polygon {outside = polygonVertices};
        
        GetComponent<MeshFilter>().mesh = Poly2Mesh.CreateMesh(polygon, isFlippedWater);
    }
}
