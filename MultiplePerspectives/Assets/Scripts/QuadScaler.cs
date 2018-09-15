using UnityEngine;

public class QuadScaler : MonoBehaviour
{
    [SerializeField]
    private bool m_tightBound = true;

    private Camera m_cam;

	private void Start()
    {
        m_cam = GetComponentInParent<Camera>();
    }
	
	private void Update()
    {
        if (m_tightBound)
        {
            transform.localScale = Vector3.one * (m_cam.aspect < 1.0f ? 1.0f : m_cam.aspect);
        }
        else
        {
            transform.localScale = Vector3.one * (m_cam.aspect < 1.0f ? m_cam.aspect : 1.0f);
        }

        Renderer r = GetComponent<Renderer>();
        if (r != null)
        {
            Material mat = r.material;
            mat.SetVector("_CoordOffset", new Vector2(Mathf.Sin(Time.time), 0.5f));
            mat.SetFloat("_Zoom", 0.25f * Mathf.Sin(Time.time * Mathf.PI / 2) + 0.5f);
        }
    }
}
