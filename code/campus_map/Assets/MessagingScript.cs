using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using UnityEngine;
using UnityEngine.SceneManagement;

public class MessagingScript : MonoBehaviour
{
    void OnEnable()
    {
        SceneManager.sceneLoaded += OnSceneLoaded;
    }

    void OnSceneLoaded(Scene scene, LoadSceneMode mode)
    {
        Debug.Log("Szene wurde geladen!");
        SendToFlutter.Send("scene_was_loaded");
    }
    
    public void SetCubeColor(string data)
    {
        float red = float.Parse(data, CultureInfo.InvariantCulture);
        gameObject.GetComponent<Renderer>().material.color = new Color(red, 0f, 0f);
    }
}
