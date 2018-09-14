using UnityEngine;

public class CameraRotate : MonoBehaviour
{
    [SerializeField]
    [Range(0.0f, 10.0f)]
    private float m_panSensitivity = 1.0f;

    [SerializeField]
    [Range(0.0f, 2.0f)]
    private float m_zoomSensitivity = 1.0f;

    [SerializeField]
    [Range(0.0f, 50.0f)]
    private float m_nearFieldOfView = 15.0f;

    [SerializeField]
    [Range(0.0f, 50.0f)]
    private float m_farFieldOfView = 25.0f;

    [SerializeField]
    [Range(0.0f, 50.0f)]
    private float m_nearDistance = 10.0f;

    [SerializeField]
    [Range(0.0f, 50.0f)]
    private float m_farDistance = 10.0f;

    [SerializeField]
    [Range(0.01f, 2.0f)]
    private float m_zoomSmoothing = 0.5f;

    private Camera m_cam;
    private float m_currentZoom = 0;
    private float m_targetZoom = 0;
    
    private void Awake()
    {
        m_cam = GetComponentInChildren<Camera>(true);

        m_currentZoom = 0;
        m_targetZoom = m_currentZoom;
    }

    private void Update()
    {
        if (Input.GetKey(KeyCode.Mouse0))
        {
            transform.Rotate(Vector3.up, Input.GetAxis("Mouse X") * m_panSensitivity, Space.World);
            transform.Rotate(Vector3.right, -Input.GetAxis("Mouse Y") * m_panSensitivity, Space.Self);
        }
        m_targetZoom = Mathf.Clamp01(m_targetZoom + (-Input.mouseScrollDelta.y * m_zoomSensitivity));

        m_cam.fieldOfView = Mathf.Lerp(m_nearFieldOfView, m_farFieldOfView, m_currentZoom);
        m_cam.transform.localPosition = Vector3.forward * -Mathf.Lerp(m_nearDistance, m_farDistance, m_currentZoom);

        m_currentZoom = Mathf.Lerp(m_currentZoom, m_targetZoom, Time.deltaTime / m_zoomSmoothing);
    }
}
