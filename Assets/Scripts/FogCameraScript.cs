using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FogCameraScript : MonoBehaviour
{

    public Material material;


    // Start is called before the first frame update
    void OnEnable()
    {

    }

    void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        Graphics.Blit(src, dst, material);
    }
}
