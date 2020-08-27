using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager
{

    public static GameManager instance;

    private int points;

    public int Points { get => points; set => points = value; }

    void Awake()
    {
        if (instance == null)
        {
            instance = this;
        }
        else
        {
            Debug.Log("Warning: multiple " + this + " in scene!");
        }
    }

    void Update()
    {
        if(Points >= 3)
        {
            Win();
        }
    }

    void Win()
    {
        SceneManager.LoadSceneAsync("Win");
    }

}
