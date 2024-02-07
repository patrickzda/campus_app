using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    public float actionSpeed;
    public float movementStrength;
    public float rotationStrength;
    public Vector3 zoomStrength;
    public NavigationController navigationController;

    private Vector3 targetPosition;
    private Quaternion targetRotation;
    private Vector3 targetZoom;
    private Transform cameraTransform;
    private Vector3 dragStartPosition;
    private Vector3 dragCurrentPosition;
    private Quaternion cameraTargetRotation;
    private bool is3d = true;
    private bool isInitialized = false;

    private float minZoom = 2f, maxZoom = 8f;
    private float minX = -5f, maxX = 15f;
    private float minZ = -9f, maxZ = 16f;

    void Start()
    {
        targetPosition = transform.position;
        targetRotation = transform.rotation;
        cameraTransform = transform.GetChild(0);
        targetZoom = cameraTransform.localPosition;
        cameraTargetRotation = cameraTransform.localRotation;
        isInitialized = true;
    }

    void FixedUpdate()
    {
        HandleGestureInput();
        HandleKeyboardInput();
        
        transform.position = Vector3.Lerp(transform.position, targetPosition, Time.deltaTime * actionSpeed);
        transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, Time.deltaTime * actionSpeed);
        cameraTransform.localPosition = Vector3.Lerp(cameraTransform.localPosition, targetZoom, Time.deltaTime * actionSpeed);
        cameraTransform.localRotation = Quaternion.Lerp(cameraTransform.localRotation, cameraTargetRotation, Time.deltaTime * actionSpeed);
    }

    //AUS FLUTTER
    public void Toggle3dView()
    {
        is3d = !is3d;
        if (is3d)
        {
            Vector3 currentRotation = cameraTransform.localRotation.eulerAngles;
            cameraTargetRotation = Quaternion.Euler(45f, currentRotation.y, currentRotation.z);
            targetZoom = new Vector3(0f, cameraTransform.position.y, -cameraTransform.position.y);
        }
        else
        {
            Vector3 currentRotation = cameraTransform.localRotation.eulerAngles;
            cameraTargetRotation = Quaternion.Euler(90f, currentRotation.y, currentRotation.z);
            targetZoom = new Vector3(0f, cameraTransform.position.y, 0f);
        }
    }

    //AUS FLUTTER
    public void Set3dView(string value)
    {
        if (is3d != (value == "true"))
        {
            Toggle3dView();
        }
    }

    //AUS FLUTTER
    public void ResetCamera()
    {
        MoveTo(new Vector3(2f, targetPosition.y, 0f));
        ZoomTo(5);
    }

    //AUS FLUTTER, Parameter: Koordinaten des Zielstandortes der Kamera im Format lat, lon
    public void MoveToFromString(string coordinates)
    {
        string[] coordinateData = coordinates.Replace(" ", "").Split(",");
        targetPosition = NavigationController.CoordinatesToVector3(NavigationController.ParseFloat(coordinateData[0]), NavigationController.ParseFloat(coordinateData[1]));
    }

    public void MoveTo(Vector3 position)
    {
        targetPosition = position;
    }

    //AUS FLUTTER, Parameter: Zoomlevel als float im String-Format
    public void ZoomToFromString(string zoomLevelString)
    {
        float zoomLevel = Mathf.Clamp(NavigationController.ParseFloat(zoomLevelString), minZoom, maxZoom);
        targetZoom = new Vector3(targetZoom.x, zoomLevel,is3d ? -zoomLevel : 0f);
    }
    
    public void ZoomTo(float zoomLevel)
    {
        zoomLevel = Mathf.Clamp(zoomLevel, minZoom, maxZoom);
        targetZoom = new Vector3(targetZoom.x, zoomLevel,is3d ? -zoomLevel : 0f);
    }

    public void RotateTo(float rotationAngle)
    {
        targetRotation = Quaternion.Euler(Vector3.up * -rotationAngle);
    }

    void HandleGestureInput(){
        if (Input.touchCount == 1)
        {
            if(Input.GetTouch(0).phase == TouchPhase.Began){
                Plane plane = new Plane(Vector3.up, Vector3.zero);
                Ray ray = Camera.main.ScreenPointToRay(Input.GetTouch(0).position);

                float entry;
                if(plane.Raycast(ray, out entry)){
                    dragStartPosition = ray.GetPoint(entry);
                }
                
                navigationController.SetFocusOnUserPosition(false);
            }
            if(Input.GetTouch(0).phase == TouchPhase.Moved){
                Plane plane = new Plane(Vector3.up, Vector3.zero);
                Ray ray = Camera.main.ScreenPointToRay(Input.GetTouch(0).position);

                float entry;
                if(plane.Raycast(ray, out entry)){
                    dragCurrentPosition = ray.GetPoint(entry);

                    targetPosition = transform.position + (dragStartPosition - dragCurrentPosition) * 5f;
                    targetPosition = new Vector3(Mathf.Clamp(targetPosition.x, minX, maxX), targetPosition.y,Mathf.Clamp(targetPosition.z, minZ, maxZ));
                }
                
                navigationController.SetFocusOnUserPosition(false);
            }
        }
        else if(Input.touchCount == 2)
        {
            Touch first = Input.GetTouch(0);
            Touch second = Input.GetTouch(1);

            Vector2 lastFirstTouchPosition = first.position - first.deltaPosition;
            Vector2 lastSecondTouchPosition = second.position - second.deltaPosition;
            
            float lastMagnitude = (lastFirstTouchPosition - lastSecondTouchPosition).magnitude;
            float currentMagnitude = (first.position - second.position).magnitude;
            
            float difference = currentMagnitude - lastMagnitude;
            targetZoom += difference * zoomStrength;        
            targetZoom = new Vector3(targetZoom.x, Mathf.Clamp(targetZoom.y, minZoom, maxZoom),is3d ? Mathf.Clamp(targetZoom.z, -maxZoom, -minZoom) : 0f);
            
            Vector2 lastPositionDifference = (lastFirstTouchPosition - lastSecondTouchPosition);
            Vector2 currentPositionDifference = (first.position - second.position);

            float angle = Vector2.SignedAngle(lastPositionDifference, currentPositionDifference);
            targetRotation *= Quaternion.Euler(Vector3.up * (angle * 0.5f));
            
            navigationController.SetFocusOnUserPosition(false);
        }
    }
    
    void HandleKeyboardInput()
    {
        if(Input.GetKey(KeyCode.UpArrow)){
            targetPosition += (transform.forward * movementStrength);
            targetPosition = new Vector3(Mathf.Clamp(targetPosition.x, minX, maxX), targetPosition.y,Mathf.Clamp(targetPosition.z, minZ, maxZ));
        }
        if(Input.GetKey(KeyCode.DownArrow)){
            targetPosition += (transform.forward * -movementStrength);
            targetPosition = new Vector3(Mathf.Clamp(targetPosition.x, minX, maxX), targetPosition.y,Mathf.Clamp(targetPosition.z, minZ, maxZ));
        }
        if(Input.GetKey(KeyCode.RightArrow)){
            targetPosition += (transform.right * movementStrength);
            targetPosition = new Vector3(Mathf.Clamp(targetPosition.x, minX, maxX), targetPosition.y,Mathf.Clamp(targetPosition.z, minZ, maxZ));
        }
        if(Input.GetKey(KeyCode.LeftArrow)){
            targetPosition += (transform.right * -movementStrength);
            targetPosition = new Vector3(Mathf.Clamp(targetPosition.x, minX, maxX), targetPosition.y,Mathf.Clamp(targetPosition.z, minZ, maxZ));
        }
        
        if(Input.GetKey(KeyCode.A)){
            targetRotation *= Quaternion.Euler(Vector3.up * rotationStrength);
        }
        if(Input.GetKey(KeyCode.D)){
            targetRotation *= Quaternion.Euler(Vector3.up * -rotationStrength);
        }
        
        if(Input.GetKeyDown(KeyCode.T)){
            Toggle3dView();
        }
        
        if(Input.GetKey(KeyCode.W)){
            targetZoom += zoomStrength;
            targetZoom = new Vector3(targetZoom.x, Mathf.Clamp(targetZoom.y, minZoom, maxZoom),is3d ? Mathf.Clamp(targetZoom.z, -maxZoom, -minZoom) : 0f);
        }
        if(Input.GetKey(KeyCode.S)){
            targetZoom -= zoomStrength;
            targetZoom = new Vector3(targetZoom.x, Mathf.Clamp(targetZoom.y, minZoom, maxZoom),is3d ? Mathf.Clamp(targetZoom.z, -maxZoom, -minZoom) : 0f);
        }
    }
    
    public bool Is3d()
    {
        return is3d;
    }

    public bool IsInitialized()
    {
        return isInitialized;
    }
    
}
