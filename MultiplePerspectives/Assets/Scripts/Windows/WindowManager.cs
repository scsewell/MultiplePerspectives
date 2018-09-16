using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class WindowManager : MonoBehaviour
{
    private const int MAX_WINDOWS = 16;

    [Serializable]
    private class ProjectionConfig
    {
        public Window.Mode mode;
        public CameraConfig camera;
    }

    [SerializeField]
    private GameObject m_windowPrefab;

    [SerializeField]
    private PlanetConfig m_defaultPlanet;

    [SerializeField]
    private Transform m_earthRotation;

    [SerializeField]
    private ProjectionConfig[] m_projectionConfigs;
    
    private readonly Dictionary<Window.Mode, CameraConfig> m_modeToCamera = new Dictionary<Window.Mode, CameraConfig>();
    private readonly List<Window> m_windows = new List<Window>();

    private void Awake()
    {
        foreach (ProjectionConfig config in m_projectionConfigs)
        {
            m_modeToCamera.Add(config.mode, config.camera);
        }

        CreateWindow(Window.Mode.Globe);
    }

    private void LateUpdate()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            Window.Mode mode = m_windows[0].CurrentMode == Window.Mode.Globe ? Window.Mode.Equirectangular : Window.Mode.Globe;
            m_windows[0].SetMode(mode, m_modeToCamera[mode]);
        }

        foreach (Window w in m_windows)
        {
            w.Update(m_earthRotation.rotation);
        }
    }

    private Window CreateWindow(Window.Mode mode)
    {
        for (int i = 0; i < MAX_WINDOWS; i++)
        {
            if (!m_windows.Any(w => w.windowID == i))
            {
                GameObject instance = Instantiate(m_windowPrefab);
                Window w = new Window(i, instance.GetComponent<Camera>(), instance.GetComponentInChildren<MeshRenderer>());
                w.SetMode(mode, m_modeToCamera[mode]);
                w.SetPlanet(m_defaultPlanet);
                m_windows.Add(w);
                return w;
            }
        }
        return null;
    }
}
