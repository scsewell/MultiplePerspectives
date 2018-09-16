using UnityEngine;

[CreateAssetMenu(fileName = "PerspectiveCameraConfig", menuName = "Perspective Camera Config", order = 6)]
public class PerspectiveCameraConfig : CameraConfig
{
    [Range(0.0f, 50.0f)]
    public float nearFieldOfView = 6.0f;

    [Range(0.0f, 50.0f)]
    public float farFieldOfView = 25.0f;

    [Range(0.0f, 50.0f)]
    public float nearDistance = 10.0f;

    [Range(0.0f, 50.0f)]
    public float farDistance = 15.0f;
}
