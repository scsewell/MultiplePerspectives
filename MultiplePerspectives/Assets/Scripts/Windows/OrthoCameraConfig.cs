using UnityEngine;

[CreateAssetMenu(fileName = "OrthoCameraConfig", menuName = "Ortho Camera Config", order = 7)]
public class OrthoCameraConfig : CameraConfig
{
    public float orthoSize = 0.5f;
    public bool tightBound = true;
    public float minZoom = 0.5f;
    public float maxZoom = 2.0f;
}
