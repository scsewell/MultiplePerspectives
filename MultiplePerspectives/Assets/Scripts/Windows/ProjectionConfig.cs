using UnityEngine;

[CreateAssetMenu(fileName = "ProjectionConfig", menuName = "Projection Config", order = 3)]
public class ProjectionConfig : ScriptableObject
{
    public string displayName;
    public Window.Mode mode = Window.Mode.Globe;
    public CameraConfig camera;
}
