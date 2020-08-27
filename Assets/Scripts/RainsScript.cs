using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RainsScript : MonoBehaviour
{
    public Material mat;
    public ComputeShader compute;
    public int maxParticleCount;
    public float rainSpeed;
    public float lowerBoundary;
    public float spawnRadius;

    public float dropSize;
    Vector3 windDirection;
    public Transform spawnPoint;


    ComputeBuffer buffer;
    //ComputeBuffer countBuffer;
    int kernelID;
    //int[] particleCount = new int[] { 0 }; //FOR SPAWNING IN COMPUTE SHADER CHANGE ALL COMMENTED OUT THINGS WITH PARTICLECOUNT BACK TO CODE
    Vector3[] particles = new Vector3[100];

    // Start is called before the first frame update
    void Start()
    {
        windDirection = GameObject.Find("WindManager").GetComponent<Wind>().windDir;
        kernelID = compute.FindKernel("CSMain");
        //particleCount[0] = 0;
        //Setup particle array 
        Vector3[] particles = new Vector3[maxParticleCount];
        //create first few or all rain drops
        for (int i = 0; i < maxParticleCount; ++i) //CHANGE MAXPARTICLECOUNT FOR AROUND 40 FOR SPAWNING IN COMPUTE SHADER
        {
            particles[i].x = spawnPoint.position.x + (spawnRadius * Random.value) - spawnRadius;
            particles[i].y = spawnPoint.position.y + Random.value * (lowerBoundary - spawnPoint.position.y);
            particles[i].z = spawnPoint.position.z + (spawnRadius * Random.value) - spawnRadius;
            //particleCount[0] += 1;
        }
        buffer = new ComputeBuffer(maxParticleCount, 12);
        buffer.SetData(particles);
        Debug.Log(particles[0]);

        //countBuffer = new ComputeBuffer(1, 4);
        //countBuffer.SetData(particleCount);


        compute.SetBuffer(kernelID, "raindrops", buffer);
        //compute.SetBuffer(kernelID, "particleCount", countBuffer);
        compute.SetFloat("rainSpeed", rainSpeed);
        //compute.SetInt("maxParticleCount", maxParticleCount);
        compute.SetFloat("lowerBoundary", lowerBoundary);
        compute.SetFloat("deltaTime", Time.deltaTime);
        compute.SetFloat("radius", spawnRadius);
        compute.SetVector("windDirection", windDirection);
        compute.SetVector("spawnPoint", spawnPoint.position);
        mat.SetBuffer("_raindrops", buffer);
        mat.SetFloat("_difference", dropSize);
    }

    // Update is called once per frame
    void Update()
    {
        compute.SetFloat("deltaTime", Time.deltaTime);
        compute.Dispatch(kernelID, Mathf.CeilToInt(maxParticleCount / 128.0f), 1, 1);
    }

    void OnRenderObject()
    {
        mat.SetPass(0);
        Graphics.DrawProceduralNow(MeshTopology.Points, 1, maxParticleCount);
    }

    private void OnApplicationQuit()
    {
        buffer.Release();
        //countBuffer.Release();
    }

}
