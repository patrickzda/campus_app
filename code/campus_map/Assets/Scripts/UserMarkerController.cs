using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UserMarkerController : MonoBehaviour
{
    public float actionSpeed;

    private Vector3 targetPosition;
    private Quaternion targetRotation;
    private bool isLocationMode = true;
    private bool isInitialized = false;

    private void Start()
    {
        transform.GetChild(0).gameObject.SetActive(isLocationMode);
        transform.GetChild(1).gameObject.SetActive(!isLocationMode);
        targetPosition = transform.position;
        isInitialized = true;
    }

    void FixedUpdate()
    {
        transform.position = Vector3.Lerp(transform.position, targetPosition, Time.deltaTime * actionSpeed);
        transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, Time.deltaTime * actionSpeed);
    }
    
    //AUS FLUTTER, Parameter: Koordinaten des Zielstandortes der Kamera im Format lat, lon
    public void SetUserLocationFromString(string userCoordinates)
    {
        string[] coordinateData = userCoordinates.Replace(" ", "").Split(",");
        targetPosition = NavigationController.CoordinatesToVector3(NavigationController.ParseFloat(coordinateData[0]), NavigationController.ParseFloat(coordinateData[1]));
        transform.position = targetPosition;
    }
    
    //AUS FLUTTER, Parameter: Koordinaten des Zielstandortes der Kamera im Format lat, lon
    public void AnimateToUserLocationFromString(string userCoordinates)
    {
        string[] coordinateData = userCoordinates.Replace(" ", "").Split(",");
        targetPosition = NavigationController.CoordinatesToVector3(NavigationController.ParseFloat(coordinateData[0]), NavigationController.ParseFloat(coordinateData[1]));
    }

    public void AnimateToUserLocation(Vector3 userLocation)
    {
        targetPosition = userLocation;
    }
    
    public void RotateTo(float rotationAngle)
    {
        targetRotation = Quaternion.Euler(Vector3.up * -rotationAngle);
    }

    //AUS FLUTTER, Parameter: Boolean, auf welchen isLocationMode gesetzt werden soll im String-Format "true" oder "false"
    public void SetLocationModeFromString(string value)
    {
        isLocationMode = StringToBool(value);
        transform.GetChild(0).gameObject.SetActive(isLocationMode);
        transform.GetChild(1).gameObject.SetActive(!isLocationMode);
    }

    public void SetLocationMode(bool locationMode)
    {
        isLocationMode = locationMode;
        transform.GetChild(0).gameObject.SetActive(isLocationMode);
        transform.GetChild(1).gameObject.SetActive(!isLocationMode);
    }

    private bool StringToBool(string value)
    {
        return value == "true";
    }
    
    public bool IsInitialized()
    {
        return isInitialized;
    }

}
