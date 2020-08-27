using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DropScript : MonoBehaviour
{

    struct Drop
    {
        public Vector2 pos;
        public float radius;
        public float maxradius;
    }


    public Material mat;
    public ComputeShader compute;

    ComputeBuffer buffer;
    private int kernelID;

    RenderTexture render;
    public int resolution = 512; //tex resolution
    public float maxradius = 10; //drop max radius
    public float deviation = 1; //drop deviation from radius (thickness of line)
    public float step = 1; //drop speed
    public int dropcount;
    Drop[] drops;

    void Awake()
    {
        render = new RenderTexture(resolution,resolution, 0);
        render.enableRandomWrite = true;
        render.wrapMode = TextureWrapMode.Repeat;
        render.Create();
        //ComputeShader setup
        kernelID = compute.FindKernel("CSMain");
        compute.SetTexture(kernelID, "Result", render);

        drops = new Drop[dropcount];
        for(int i = 0; i < dropcount; i++)
        {
            drops[i] = new Drop();
            drops[i].pos.x = Random.value * resolution;
            drops[i].pos.y = Random.value * resolution;
            drops[i].radius = 0f;
            drops[i].maxradius = maxradius + (Random.value * 2f - 1) * deviation;
        }

        buffer = new ComputeBuffer(dropcount, 16);
        buffer.SetData(drops);

        //First Dispatch to have a Texture asap
        compute.SetFloat("deviation", deviation);
        compute.SetFloat("scale", resolution);
        compute.SetInt("dropcount", dropcount);
        compute.SetBuffer(kernelID, "drops", buffer);
        compute.Dispatch(kernelID, resolution / 8, resolution / 8, 1);
    }

    // Update is called once per frame
    void Update()
    {
        for (int i = 0; i < dropcount; i++)
        {
            drops[i].radius += step + Mathf.Clamp01(Random.value - 0.5f) * step;
            if(drops[i].radius >= drops[i].maxradius)
            {
                drops[i].pos.x = Random.value * resolution;
                drops[i].pos.y = Random.value * resolution;
                drops[i].radius = 0f;
                drops[i].maxradius = maxradius + (Random.value * 2f - 1) * deviation;
            }
        }
        buffer.SetData(drops);
        compute.SetBuffer(kernelID, "drops", buffer);
        compute.Dispatch(kernelID, resolution / 8, resolution / 8, 1);
        mat.SetTexture("_DropTex", render);
    }

    private void OnApplicationQuit()
    {
        buffer.Release();
    }
}
