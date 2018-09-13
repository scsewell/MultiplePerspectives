using UnityEngine;

[ExecuteInEditMode]
public class Atmosphere : MonoBehaviour
{
    [SerializeField]
    private GameObject m_sun;
    [SerializeField]
    private MeshRenderer m_ground;
    [SerializeField]
    private MeshRenderer m_atmosphere;

    [SerializeField]
    [Range(0, 5.0f)]
    private float m_hdrExposure = 0.8f;

    [SerializeField]
    [Tooltip("Wave length of sun light.")]
    private Vector3 m_waveLength = new Vector3(0.65f, 0.57f, 0.475f);

    [SerializeField]
    [Range(0, 100.0f)]
    private float m_sunBrightness = 20.0f;

    [SerializeField]
    [Range(0, 0.01f)]
    [Tooltip("The Rayleigh scattering constant.")]
    private float m_kr = 0.0025f;

    [SerializeField]
    [Range(0, 0.01f)]
    [Tooltip("The Mie scattering constant.")]
    private float m_km = 0.001f;
    
    [SerializeField]
    [Range(-0.999f, 0.999f)]
    [Tooltip("The Mie phase asymmetry factor.")]
    private float m_g = -0.990f;
    
    [SerializeField]
    [Range(1.0f, 1.1f)]
    [Tooltip("Difference in scale between the sufrace mesh and atmosphere mesh.")]
    private float m_outerScaleFactor = 1.025f;

    [SerializeField]
    [Range(0.0f, 1.0f)]
    [Tooltip("The altitude at which the atmosphere's average density is found.")]
    private float m_scaleDepth = 0.25f;

    [SerializeField]
    [Range(1, 32)]
    [Tooltip("The number of samples to take when computing the atmospheric effects.")]
    private int m_sampleCount = 6;

    private void LateUpdate()
    {
        InitMaterial(m_ground.sharedMaterial);
        InitMaterial(m_atmosphere.sharedMaterial);
    }

    private void InitMaterial(Material mat)
    {
        // Get the radius of the sphere. This presumes that the sphere mesh is a unit sphere (radius of 1) with uniform scaling
        float innerRadius = m_ground.transform.localScale.x;
        float outerRadius = m_outerScaleFactor * innerRadius;
        m_atmosphere.transform.localScale = m_ground.transform.localScale * m_outerScaleFactor;

        Vector3 invWaveLength4 = new Vector3(
            1.0f / Mathf.Pow(m_waveLength.x, 4.0f),
            1.0f / Mathf.Pow(m_waveLength.y, 4.0f),
            1.0f / Mathf.Pow(m_waveLength.z, 4.0f)
        );

        float scale = 1.0f / (outerRadius - innerRadius);

        mat.SetVector("v3LightPos", -m_sun.transform.forward);
        mat.SetVector("v3Translate", transform.localPosition);
        mat.SetVector("v3LightPos", m_sun.transform.forward * -1.0f);
        mat.SetVector("v3InvWavelength", invWaveLength4);
        mat.SetFloat("fOuterRadius", outerRadius);
        mat.SetFloat("fOuterRadius2", outerRadius * outerRadius);
        mat.SetFloat("fInnerRadius", innerRadius);
        mat.SetFloat("fInnerRadius2", innerRadius * innerRadius);
        mat.SetFloat("fKrESun", m_kr * m_sunBrightness);
        mat.SetFloat("fKmESun", m_km * m_sunBrightness);
        mat.SetFloat("fKr4PI", m_kr * 4.0f * Mathf.PI);
        mat.SetFloat("fKm4PI", m_km * 4.0f * Mathf.PI);
        mat.SetFloat("fScale", scale);
        mat.SetFloat("fScaleDepth", m_scaleDepth);
        mat.SetFloat("fScaleOverScaleDepth", scale / m_scaleDepth);
        mat.SetFloat("fHdrExposure", m_hdrExposure);
        mat.SetFloat("g", m_g);
        mat.SetFloat("g2", m_g * m_g);
        mat.SetFloat("sampleCount", m_sampleCount);
    }
}
