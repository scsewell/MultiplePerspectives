using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

public abstract class CameraConfig : ScriptableObject
{
    public float nearClip = 0.3f;
    public float farClip = 1000.0f;
    
    [Range(0.0f, 25.0f)]
    public float panSensitivity = 2.0f;
    
    [Range(0.0f, 2.0f)]
    public float zoomSensitivity = 0.1f;
    
    [Range(0.01f, 2.0f)]
    public float zoomSmoothing = 0.5f;
    
    public PostProcessLayer.Antialiasing antialiasing = PostProcessLayer.Antialiasing.SubpixelMorphologicalAntialiasing;
}
