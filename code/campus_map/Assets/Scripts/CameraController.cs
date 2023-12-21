using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    public float actionSpeed;
    public float movementStrength;
    public float rotationStrength;
    public Vector3 zoomStrength;

    private Vector3 targetPosition;
    private Quaternion targetRotation;
    private Vector3 targetZoom;
    private Transform cameraTransform;
    private Vector3 dragStartPosition;
    private Vector3 dragCurrentPosition;
    private Quaternion cameraTargetRotation;
    private bool is3d = true;

    private float minZoom = 3f, maxZoom = 7.5f;
    private float minX = -5f, maxX = 15f;
    private float minZ = -9f, maxZ = 16f;
    
    
    void Start()
    {
        targetPosition = transform.position;
        targetRotation = transform.rotation;
        cameraTransform = transform.GetChild(0);
        targetZoom = cameraTransform.localPosition;
        cameraTargetRotation = cameraTransform.localRotation;
    }

    void FixedUpdate()
    {
        HandleGestureInput();
        HandleKeyboardInput();
        
        transform.position = Vector3.Lerp(transform.position, targetPosition, Time.deltaTime * actionSpeed);
        transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, Time.deltaTime * actionSpeed);
        cameraTransform.localPosition = Vector3.Lerp(cameraTransform.localPosition, targetZoom, Time.deltaTime * actionSpeed);
        cameraTransform.localRotation = Quaternion.Lerp(cameraTransform.localRotation, cameraTargetRotation, Time.deltaTime * actionSpeed);
        
        //Direct approach
        //transform.position = targetPosition;
        //transform.rotation = targetRotation;
        //cameraTransform.localPosition = targetZoom;
        
        //SmoothDamp approach
        //transform.position = Vector3.SmoothDamp(transform.position, targetPosition, ref positionVelocity, 0.3f);
        //transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, Time.deltaTime * actionSpeed);
        //cameraTransform.localPosition = Vector3.SmoothDamp(cameraTransform.localPosition, targetZoom, ref zoomVelocity, 0.3f);
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
            }
            if(Input.GetTouch(0).phase == TouchPhase.Moved){
                Plane plane = new Plane(Vector3.up, Vector3.zero);
                Ray ray = Camera.main.ScreenPointToRay(Input.GetTouch(0).position);

                float entry;
                if(plane.Raycast(ray, out entry)){
                    dragCurrentPosition = ray.GetPoint(entry);

                    targetPosition = transform.position + (dragStartPosition - dragCurrentPosition) * 1.5f;
                    targetPosition = new Vector3(Mathf.Clamp(targetPosition.x, minX, maxX), targetPosition.y,Mathf.Clamp(targetPosition.z, minZ, maxZ));
                }
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
    
}
