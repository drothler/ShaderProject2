using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ThunderScript : MonoBehaviour
{
    public Material mat;

    int thunderOne;
    int thunderTwo;
    public float timeBetween = 0.5f;
    float time;
    int thunderCount = 1;
    // Start is called before the first frame update
    void Start()
    {
        time = Time.time;
        thunderOne = Random.Range(0,4);
        thunderTwo = Random.Range(0, 4);
        while (thunderTwo == thunderOne)
        {
            thunderTwo = Random.Range(0, 4);
        }
        mat.SetFloat("_ThunderNumber", (float) thunderOne);
    }

    // Update is called once per frame
    void Update()
    {
        if (Time.time - time > timeBetween)
        {
            switch (thunderCount)
            {
                case 3:
                    Destroy(this.gameObject);
                    break;
                case 1:
                    mat.SetFloat("_ThunderNumber", thunderTwo);
                    thunderCount++;
                    time = Time.time;
                    break;
                case 2:
                    mat.SetFloat("_ThunderNumber", thunderOne);
                    thunderCount++;
                    time = Time.time;
                    break;
            }
        }
    }
}
