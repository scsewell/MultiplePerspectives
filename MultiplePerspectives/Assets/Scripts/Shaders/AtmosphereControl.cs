using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Renderer))]
public class AtmosphereControl : MonoBehaviour
{
    [SerializeField]
    private PlanetConfig m_config;

    private Renderer m_renderer;
    private Renderer Renderer
    {
        get
        {
            if (!m_renderer)
            {
                m_renderer = GetComponent<Renderer>();
            }
            return m_renderer;
        }
    }
    
    private void OnWillRenderObject()
    {
        if (m_config)
        {
            m_config.ApplyTo(Renderer, Camera.current);
        }
    }
}
