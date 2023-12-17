using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class FlutterCommunicationController
{
    public static void SendMapLoaded()
    {
        SendToFlutter.Send("MAP_LOADED");
    }
    
}
