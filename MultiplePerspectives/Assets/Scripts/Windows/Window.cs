using UnityEngine;
using UnityEngine.Rendering.PostProcessing;
using Framework;

public class Window
{
    private const int LAYER_OFFSET = 16;

    public enum Mode
    {
        Globe,
        Equirectangular,
    }

    private Camera m_cam;
    private PostProcessLayer m_postProcessing;
    private GameObject m_quad;
    private Material m_projMat;
    private Mode m_mode;
    private CameraConfig m_config;

    private Vector2 m_rotation = Vector2.zero;
    private Vector2 m_offset = Vector2.zero;
    private float m_targetZoom = 0.5f;
    private float m_currentZoom;

    public readonly int windowID;

    public Rect Rect => m_cam.rect;
    public Mode CurrentMode => m_mode;

    public Window(int id, Camera cam, MeshRenderer quad)
    {
        windowID = id;

        // add a camera for this window
        m_cam = cam;
        m_cam.name = "Window-" + id;
        m_cam.backgroundColor = Color.black;
        m_cam.allowMSAA = false;
        m_cam.GetOrAddComponent<FlareLayer>();
        m_postProcessing = m_cam.GetOrAddComponent<PostProcessLayer>();
        m_postProcessing.volumeLayer = 1 << LayerMask.NameToLayer("PostProcessing");

        // create a quad to draw projection onto
        m_quad = quad.gameObject;
        m_quad.transform.SetParent(cam.transform, false);
        m_quad.transform.localPosition = Vector3.forward;
        m_quad.layer = id + LAYER_OFFSET;
        m_projMat = m_quad.GetOrAddComponent<Renderer>().material;
        m_quad.GetOrAddComponent<AtmosphereControl>();

        m_currentZoom = m_targetZoom;
    }

    public void Update(Quaternion earthRotation)
    {
        bool isFocused = true;
        bool isOrtho = m_config is OrthoCameraConfig;

        if (isFocused)
        {
            // handle zooming and panning
            Vector2 mouseDisp = Input.GetKey(KeyCode.Mouse0) ? new Vector2(-Input.GetAxis("Mouse X"), -Input.GetAxis("Mouse Y")) : Vector2.zero;
            float mouseScroll = -Input.mouseScrollDelta.y;
            
            // transform view
            if (Input.GetKeyDown(KeyCode.R))
            {
                m_rotation = Vector2.zero;
                m_offset = Vector2.zero;
            }

            float sensitivityScale = Mathf.Lerp(0.25f, 1.0f, m_currentZoom);
            m_targetZoom = Mathf.Clamp01(m_targetZoom + (m_config.zoomSensitivity * sensitivityScale * mouseScroll));
            m_currentZoom = Mathf.Lerp(m_currentZoom, m_targetZoom, Time.deltaTime / m_config.zoomSmoothing);

            if (isOrtho)
            {
                if (Input.GetKey(KeyCode.LeftControl))
                {
                    m_rotation += 0.01f * m_config.panSensitivity * sensitivityScale * mouseDisp;
                }
                else
                {
                    m_offset += 0.01f * m_config.panSensitivity * sensitivityScale * mouseDisp;
                }
            }
            else
            {
                m_rotation += 0.01f * m_config.panSensitivity * sensitivityScale * mouseDisp;
            }
        }

        // configure rendering
        if (isOrtho)
        {
            OrthoCameraConfig c = m_config as OrthoCameraConfig;

            Quaternion rotation =
                    Quaternion.AngleAxis(-m_rotation.x * 2 * Mathf.PI * Mathf.Rad2Deg, Vector3.forward) *
                    Quaternion.AngleAxis(m_rotation.y * Mathf.PI * Mathf.Rad2Deg, Vector3.right);

            m_projMat.SetMatrix("_Rotation", Matrix4x4.Rotate(rotation));
            m_projMat.SetVector("_CoordOffset", m_offset);
            m_projMat.SetFloat("_Zoom", Mathf.Lerp(c.minZoom, c.maxZoom, m_currentZoom));

            if (c.tightBound)
            {
                m_quad.transform.localScale = Vector3.one * (m_cam.aspect < 1.0f ? 1.0f : m_cam.aspect);
            }
            else
            {
                m_quad.transform.localScale = Vector3.one * (m_cam.aspect < 1.0f ? m_cam.aspect : 1.0f);
            }

            m_cam.transform.localPosition = Vector3.zero;
            m_cam.transform.rotation = earthRotation;
        }
        else
        {
            PerspectiveCameraConfig c = m_config as PerspectiveCameraConfig;

            m_cam.fieldOfView = Mathf.Lerp(c.nearFieldOfView, c.farFieldOfView, m_currentZoom);
            m_cam.transform.rotation =
                    Quaternion.AngleAxis(-m_rotation.x * 2 * Mathf.PI * Mathf.Rad2Deg, Vector3.up) *
                    Quaternion.AngleAxis(m_rotation.y * Mathf.PI * Mathf.Rad2Deg, Vector3.right);
            m_cam.transform.localPosition = m_cam.transform.forward * -Mathf.Lerp(c.nearDistance, c.farDistance, m_currentZoom);
        }
    }

    public void SetPlanet(PlanetConfig planet)
    {
        m_quad.GetComponent<AtmosphereControl>().Planet = planet;
    }

    public void SetMode(Mode mode, CameraConfig config)
    {
        if (m_mode != mode || config != m_config)
        {
            m_mode = mode;
            m_config = config;

            if (config is OrthoCameraConfig)
            {
                OrthoCameraConfig c = config as OrthoCameraConfig;
                m_cam.orthographic = true;
                m_cam.orthographicSize = c.orthoSize;
                m_cam.clearFlags = CameraClearFlags.SolidColor;
                m_quad.SetActive(true);
            }
            else
            {
                PerspectiveCameraConfig c = config as PerspectiveCameraConfig;
                m_cam.orthographic = false;
                m_cam.clearFlags = CameraClearFlags.Skybox;
                m_quad.SetActive(false);
            }

            m_cam.nearClipPlane = config.nearClip;
            m_cam.farClipPlane = config.farClip;
            m_postProcessing.antialiasingMode = config.antialiasing;
            m_cam.cullingMask = 1 << (mode == Mode.Globe ? 0 : windowID + LAYER_OFFSET);
        }
    }

    public void SetRect(Rect rect)
    {
        const float pixelMargin = 4f;
        Vector2 margin = 0.5f * new Vector2(pixelMargin / Screen.width, pixelMargin / Screen.height);
        rect.min += margin;
        rect.max -= margin;
        m_cam.rect = rect;
    }
}
