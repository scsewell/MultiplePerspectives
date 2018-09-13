using UnityEngine;

public class Rotator : MonoBehaviour
{
    [SerializeField]
    [Tooltip("The rotation speed in degrees per second.")]
    private float m_rotationSpeed = 1.0f;
    
	private void Update()
    {
        transform.Rotate(Vector3.up, Time.deltaTime * m_rotationSpeed, Space.Self);
	}
}
