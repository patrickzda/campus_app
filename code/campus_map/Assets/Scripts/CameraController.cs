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

    private float minZoom = 3f, maxZoom = 7.5f;
    private float minX = -5f, maxX = 15f;
    private float minZ = -9f, maxZ = 16f;
    
    //Position: x: -5 bis 15, z: -9 bis 16

    void Start()
    {
        targetPosition = transform.position;
        targetRotation = transform.rotation;
        cameraTransform = transform.GetChild(0);
        targetZoom = cameraTransform.localPosition;
    }

    void FixedUpdate()
    {
        HandleGestureInput();
        HandleKeyboardInput();
        
        transform.position = Vector3.Lerp(transform.position, targetPosition, Time.deltaTime * actionSpeed);
        transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, Time.deltaTime * actionSpeed);
        cameraTransform.localPosition = Vector3.Lerp(cameraTransform.localPosition, targetZoom, Time.deltaTime * actionSpeed);
        //transform.position = targetPosition;
        //transform.rotation = targetRotation;
        //cameraTransform.localPosition = targetZoom;
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
            targetZoom = new Vector3(targetZoom.x, Mathf.Clamp(targetZoom.y, minZoom, maxZoom),Mathf.Clamp(targetZoom.z, -maxZoom, -minZoom));
            
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

        if(Input.GetKey(KeyCode.W)){
            targetZoom += zoomStrength;
            targetZoom = new Vector3(targetZoom.x, Mathf.Clamp(targetZoom.y, minZoom, maxZoom),Mathf.Clamp(targetZoom.z, -maxZoom, -minZoom));
        }
        if(Input.GetKey(KeyCode.S)){
            targetZoom -= zoomStrength;
            targetZoom = new Vector3(targetZoom.x, Mathf.Clamp(targetZoom.y, minZoom, maxZoom),Mathf.Clamp(targetZoom.z, -maxZoom, -minZoom));
        }
        
    }
    
}
