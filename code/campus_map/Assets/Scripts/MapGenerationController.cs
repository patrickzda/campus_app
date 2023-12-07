using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using SimpleJSON;
using UnityEngine;

public class MapGenerationController : MonoBehaviour
{
    public TextAsset mainRoadData, mediumRoadData, smallRoadData, universityBuildingData;
    public GameObject osmRoadPrefab, osmBuildingPrefab;
    private readonly float mapCenterLatitude = 52.5126624f, mapCenterLongitude = 13.3231489f;
    
    void Start()
    {
        GenerateRoads(mainRoadData.text, 6.0f);
        GenerateRoads(mediumRoadData.text, 6.0f);
        GenerateRoads(smallRoadData.text, 2.0f);
        GenerateBuildings(universityBuildingData.text);
    }

    void GenerateBuildings(String buildingData)
    {
        float buildingHeight = 1.0f;
        
        JSONNode jsonData = JSON.Parse(buildingData);
        JSONNode[] buildings = jsonData["features"].Children.ToArray();

        for (int i = 0; i < buildings.Length; i++)
        {
            JSONNode currentCoordinates = buildings[i]["geometry"]["coordinates"][0][0];
            OsmNode[] osmNodes = new OsmNode[currentCoordinates.Count];

            for (int j = 0; j < currentCoordinates.Count; j++)
            {
                osmNodes[j] = new OsmNode(currentCoordinates[j][1] - mapCenterLatitude, currentCoordinates[j][0] - mapCenterLongitude);
            }

            GameObject currentBuilding = Instantiate(osmBuildingPrefab);
            currentBuilding.GetComponent<OsmBuildingController>().GenerateBuilding(osmNodes, buildingHeight);
        }
    }
    
    void GenerateRoads(String roadData, float roadWidth)
    {
        JSONNode jsonData = JSON.Parse(roadData);
        JSONNode[] roads = jsonData["features"].Children.ToArray();

        for (int i = 0; i < roads.Length; i++)
        {
            JSONNode currentCoordinates = roads[i]["geometry"]["coordinates"];
            OsmNode[] osmNodes = new OsmNode[currentCoordinates.Count];
            
            for (int j = 0; j < currentCoordinates.Count; j++)
            {
                osmNodes[j] = new OsmNode(currentCoordinates[j][1] - mapCenterLatitude, currentCoordinates[j][0] - mapCenterLongitude);
            }

            GameObject currentRoad = Instantiate(osmRoadPrefab);
            currentRoad.GetComponent<OsmRoadController>().GenerateRoad(osmNodes, roadWidth);
        }
    }
}
