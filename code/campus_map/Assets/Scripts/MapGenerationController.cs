using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using SimpleJSON;
using UnityEngine;
using UnityEngine.Serialization;

public class MapGenerationController : MonoBehaviour
{
    public TextAsset mainRoadData, mediumRoadData, smallRoadData, universityBuildingData, greenAreaData, waterData;
    public GameObject roadPrefab, buildingPrefab, greenAreaPrefab, waterPrefab;
    private readonly float mapCenterLatitude = 52.5126624f, mapCenterLongitude = 13.3231489f;
    
    void Start()
    {
        GenerateRoads(mainRoadData.text, 0.1f, "Main");
        GenerateRoads(mediumRoadData.text, 0.1f, "Medium");
        GenerateRoads(smallRoadData.text, 0.025f, "Small");
        GenerateBuildings(universityBuildingData.text);
        GenerateGreenAreas(greenAreaData.text);
        GenerateWater(waterData.text);
        FlutterCommunicationController.SendMapLoaded();
    }

    void GenerateBuildings(String buildingData)
    {
        JSONNode jsonData = JSON.Parse(buildingData);
        JSONNode[] buildings = jsonData["features"].Children.ToArray();

        for (int i = 0; i < buildings.Length; i++)
        {
            JSONNode currentCoordinates = buildings[i]["geometry"]["coordinates"][0][0];
            GeoNode[] geoNodes = new GeoNode[currentCoordinates.Count];

            for (int j = 0; j < currentCoordinates.Count; j++)
            {
                geoNodes[j] = new GeoNode(currentCoordinates[j][1] - mapCenterLatitude, currentCoordinates[j][0] - mapCenterLongitude);
            }

            GameObject currentBuilding = Instantiate(buildingPrefab);
            currentBuilding.name = buildings[i]["properties"]["name"];
            currentBuilding.GetComponent<BuildingController>().GenerateBuilding(geoNodes, float.Parse(buildings[i]["properties"]["building:levels"]) * 0.05f, buildings[i]["generateFlippedRoof"], buildings[i]["properties"]["name"]);
        }
    }
    
    void GenerateRoads(String roadData, float roadWidth, string type)
    {
        JSONNode jsonData = JSON.Parse(roadData);
        JSONNode[] roads = jsonData["features"].Children.ToArray();

        for (int i = 0; i < roads.Length; i++)
        {
            JSONNode currentCoordinates = roads[i]["geometry"]["coordinates"];
            GeoNode[] geoNodes = new GeoNode[currentCoordinates.Count];
            
            for (int j = 0; j < currentCoordinates.Count; j++)
            {
                geoNodes[j] = new GeoNode(currentCoordinates[j][1] - mapCenterLatitude, currentCoordinates[j][0] - mapCenterLongitude);
            }

            GameObject currentRoad = Instantiate(roadPrefab);
            currentRoad.GetComponent<RoadController>().GenerateRoad(geoNodes, roadWidth, type, i);
        }
    }

    void GenerateGreenAreas(String greenData)
    {
        JSONNode jsonData = JSON.Parse(greenData);
        JSONNode[] greenAreas = jsonData["features"].Children.ToArray();
        
        for (int i = 0; i < greenAreas.Length; i++)
        {
            JSONNode currentCoordinates = greenAreas[i]["geometry"]["coordinates"][0][0];
            GeoNode[] geoNodes = new GeoNode[currentCoordinates.Count];

            for (int j = 0; j < currentCoordinates.Count; j++)
            {
                geoNodes[j] = new GeoNode(currentCoordinates[j][1] - mapCenterLatitude, currentCoordinates[j][0] - mapCenterLongitude);
            }

            GameObject currentGreenArea = Instantiate(greenAreaPrefab);
            currentGreenArea.GetComponent<GreenAreaController>().GenerateGreenArea(geoNodes, greenAreas[i]["generateFlippedGreenArea"], i);
        }
    }
    
    void GenerateWater(String greenData)
    {
        JSONNode jsonData = JSON.Parse(greenData);
        JSONNode[] waterAreas = jsonData["features"].Children.ToArray();
        
        for (int i = 0; i < waterAreas.Length; i++)
        {
            JSONNode currentCoordinates = waterAreas[i]["geometry"]["coordinates"][0][0];
            GeoNode[] geoNodes = new GeoNode[currentCoordinates.Count];

            for (int j = 0; j < currentCoordinates.Count; j++)
            {
                geoNodes[j] = new GeoNode(currentCoordinates[j][1] - mapCenterLatitude, currentCoordinates[j][0] - mapCenterLongitude);
            }

            GameObject currentWater = Instantiate(waterPrefab);
            currentWater.GetComponent<WaterController>().GenerateWater(geoNodes, waterAreas[i]["generateFlippedWater"], i);
        }
    }
    
}
