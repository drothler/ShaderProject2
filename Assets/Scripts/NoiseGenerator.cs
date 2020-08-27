using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NoiseGenerator : MonoBehaviour
{

    public Material mat;
    public ComputeShader compute;
    //init variables for the noise texture
    public float rippleScale = 0.005f; //rippleScale around 0.005 to 0.01 works best
    public int textureSize = 2096;

    //variables needed for Compute Shader
    RenderTexture renderTexture;
    private int kernelID;

    // Start is called before the first frame update
    void Start()
    {
        //RenderTexture setup
        renderTexture = new RenderTexture(textureSize, textureSize, 0);
        renderTexture.enableRandomWrite = true;
        renderTexture.Create();
        //ComputeShader setup
        kernelID = compute.FindKernel("CSMain");
        compute.SetTexture(kernelID, "noiseRes", renderTexture);
        //First Dispatch to have a Texture asap
        compute.SetFloat("time", Time.fixedTime);
        compute.SetFloat("scale", rippleScale);
        compute.Dispatch(kernelID, textureSize / 8, textureSize / 8, 1);
    }

    // Update is called once per frame
    void Update()
    {
        compute.SetFloat("time", Time.fixedTime);
        compute.SetFloat("scale", rippleScale);
        compute.Dispatch(kernelID, textureSize/8, textureSize/8, 1);
        mat.SetTexture("_NoiseTex", renderTexture);
    }
}
