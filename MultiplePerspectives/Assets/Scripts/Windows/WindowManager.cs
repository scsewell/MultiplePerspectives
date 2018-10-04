using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class WindowManager : MonoBehaviour
{
    private const int MAX_WINDOWS = 16;
    
    [SerializeField]
    private GameObject m_windowPrefab;
    [SerializeField]
    private WindowUI m_windowUIPrefab;

    [SerializeField]
    private ProjectionConfig[] m_projectionConfigs;

    [SerializeField]
    private PlanetConfig m_defaultPlanet;
    [SerializeField]
    private Transform m_earthRotation;

    private readonly Dictionary<Window.Mode, CameraConfig> m_modeToCamera = new Dictionary<Window.Mode, CameraConfig>();
    private readonly List<Window> m_windows = new List<Window>();
    private Transform m_uiParent;

    private void Awake()
    {
        foreach (ProjectionConfig config in m_projectionConfigs)
        {
            m_modeToCamera.Add(config.mode, config.camera);
        }

        m_uiParent = GetComponentInChildren<Canvas>(true).transform;

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
                GameObject window = Instantiate(m_windowPrefab);
                WindowUI ui = Instantiate(m_windowUIPrefab, m_uiParent, true);
                
                Window w = new Window(i,
                    window.GetComponent<Camera>(),
                    window.GetComponentInChildren<MeshRenderer>(),
                    ui
                );

                w.SetMode(mode, m_modeToCamera[mode]);
                w.SetPlanet(m_defaultPlanet);
                m_windows.Add(w);
                return w;
            }
        }
        return null;
    }
}
