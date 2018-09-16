using UnityEngine;

[CreateAssetMenu(fileName ="Planet", menuName = "Planet Config", order = 5)]
public class PlanetConfig : ScriptableObject
{
    [Header("Atmosphere")]

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
    [Tooltip("The Rayleigh scattering constant.")]
    [Range(0, 0.01f)]
    private float m_kr = 0.0025f;

    [SerializeField]
    [Tooltip("The Mie scattering constant.")]
    [Range(0, 0.01f)]
    private float m_km = 0.001f;

    [SerializeField]
    [Tooltip("The Mie phase asymmetry factor.")]
    [Range(-0.999f, 0.999f)]
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

    [Header("Surface")]

    [SerializeField]
    [Range(0.0f, 1.0f)]
    private float m_atmosphereIntensity = 0.5f;

    [SerializeField]
    [Range(0.0f, 1.0f)]
    private float m_nightIntensity = 1.0f;

    [SerializeField]
    private Texture2D m_diffuse = null;

    [SerializeField]
    private Texture2D m_specular = null;

    [SerializeField]
    private Color m_specularColor = Color.white;

    [SerializeField]
    [Range(0.0f, 10.0f)]
    private float m_glossiness = 0.5f;

    [SerializeField]
    private Texture2D m_cityLights = null;

    [SerializeField]
    [ColorUsage(false, true)]
    private Color m_cityLightsColor = Color.white;

    [SerializeField]
    private Texture2D m_clouds = null;

    [SerializeField]
    [Range(0.0f, 2.0f)]
    private float m_cloudIntenstiy = 1.0f;

    [SerializeField]
    [Range(0.0f, 0.5f)]
    private float m_cloudDriftSpeed = 0.05f;

    [SerializeField]
    private Texture2D m_cloudVelocity = null;

    [SerializeField]
    [Range(0.0f, 0.1f)]
    private float m_cloudVelocityScale = 1.0f;

    [SerializeField]
    [Range(0.0f, 50.0f)]
    private float m_cloudTimeScale = 4.0f;

    [SerializeField]
    [Range(0, 16)]
    private int m_cloudSamples = 2;


    public void ApplyTo(Renderer r, Camera camera)
    {
        Transform t = r.transform;
        Transform cam = camera.transform;
        
        Vector3 sunDir = -(RenderSettings.sun != null ? RenderSettings.sun.transform.forward : Vector3.forward);

        Vector3 oldScale = t.localScale;

        Vector3 invWaveLength = new Vector3(
            1.0f / Mathf.Pow(m_waveLength.x, 4.0f),
            1.0f / Mathf.Pow(m_waveLength.y, 4.0f),
            1.0f / Mathf.Pow(m_waveLength.z, 4.0f)
        );

        float kr4PI = m_kr * 4.0f * Mathf.PI;
        float km4PI = m_km * 4.0f * Mathf.PI;
        Vector3 scatterScale = (invWaveLength * kr4PI) + (km4PI * Vector3.one);

        float krESun = m_kr * m_sunBrightness;
        float kmESun = m_km * m_sunBrightness;
        Vector3 frontColorScale = (invWaveLength * krESun) + (kmESun * Vector3.one);

        float innerRadius = 1.0f;
        float outerRadius = innerRadius * m_outerScaleFactor;
        float scale = 1.0f / (outerRadius - innerRadius);

        foreach (Material mat in r.sharedMaterials)
        {
            mat.SetVector("_CamPos", t.InverseTransformPoint(cam.position));
            mat.SetVector("_LightPos", t.InverseTransformDirection(sunDir));
            mat.SetVector("_InvWavelength", invWaveLength);
            mat.SetVector("_ScatterScale", scatterScale);
            mat.SetVector("_FrontColorScale", frontColorScale);
            mat.SetFloat("_KrESun", krESun);
            mat.SetFloat("_KmESun", kmESun);
            mat.SetFloat("_OuterRadius", outerRadius);
            mat.SetFloat("_OuterRadius2", outerRadius * outerRadius);
            mat.SetFloat("_InnerRadius", innerRadius);
            mat.SetFloat("_InnerRadius2", innerRadius * innerRadius);
            mat.SetFloat("_Scale", scale);
            mat.SetFloat("_ScaleDepth", m_scaleDepth);
            mat.SetFloat("_ScaleOverScaleDepth", scale / m_scaleDepth);
            mat.SetFloat("_HdrExposure", m_hdrExposure);
            mat.SetFloat("_G", m_g);
            mat.SetFloat("_G2", m_g * m_g);
            mat.SetFloat("_SampleCount", m_sampleCount);
            
            mat.SetTexture("_PlanetDiffuse", m_diffuse);
            mat.SetTexture("_PlanetSpecular", m_specular);
            mat.SetTexture("_PlanetLights", m_cityLights);
            mat.SetTexture("_PlanetClouds", m_clouds);
            mat.SetTexture("_PlanetCloudVelocity", m_cloudVelocity);
            mat.SetColor("_PlanetSpecularColor", m_specularColor);
            mat.SetColor("_PlanetLightsColor", m_cityLightsColor);
            mat.SetFloat("_PlanetAtmosphereIntesity", m_atmosphereIntensity);
            mat.SetFloat("_PlanetNightIntensity", m_nightIntensity);
            mat.SetFloat("_PlanetGlossiness", m_glossiness);
            mat.SetFloat("_PlanetCloudIntensity", m_cloudIntenstiy);
            mat.SetFloat("_PlanetCloudDriftSpeed", m_cloudDriftSpeed);
            mat.SetFloat("_PlanetCloudVelocityScale", m_cloudVelocityScale);
            mat.SetFloat("_PlanetCloudTimeScale", m_cloudTimeScale);
            mat.SetFloat("_PlanetCloudSamples", m_cloudSamples);
        }

        t.localScale = oldScale;
    }
}