using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Renderer))]
public class AtmosphereControl : MonoBehaviour
{
    [SerializeField]
    private PlanetConfig m_planet;
    public PlanetConfig Planet
    {
        get { return m_planet; }
        set { m_planet = value; }
    }

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
        if (Planet)
        {
            Planet.ApplyTo(Renderer, Camera.current);
        }
    }
}
