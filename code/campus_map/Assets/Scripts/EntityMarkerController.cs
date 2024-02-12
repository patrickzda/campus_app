using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class EntityMarkerController : MonoBehaviour
{
    public GameObject cameraRig;
    public string markerText;
    private CameraController cameraController;

    private void Start()
    {
        cameraController = cameraRig.GetComponent<CameraController>();
        transform.GetChild(1).GetComponent<TextMeshProUGUI>().text = markerText;
    }

    void FixedUpdate()
    {
        Vector3 currentRotation = transform.rotation.eulerAngles;
        transform.rotation = Quaternion.Euler(cameraController.Is3d() ? 45 : 90, cameraRig.transform.rotation.eulerAngles.y, currentRotation.z);
    }

}
