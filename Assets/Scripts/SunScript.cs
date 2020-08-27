using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SunScript : MonoBehaviour
{
    public float dayLengthInMinutes = 0.5f;
    public Light sun;
    float anglePerCall;
    public float callFreq;

    // Start is called before the first frame update
    void Start()
    {
        anglePerCall = 180f / (dayLengthInMinutes * (60 / callFreq));
        InvokeRepeating("MoveSun",1.0f, callFreq);
    }

    // Update is called once per frame
    void Update()
    {
       
    }

    void MoveSun()
    {
        sun.transform.Rotate(anglePerCall, 0f, 0f);
    }
}
