﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class ChangeSceneScript : MonoBehaviour
{
    public void ChangeScene(string name)
    {
        SceneManager.LoadSceneAsync(name);
    }
}