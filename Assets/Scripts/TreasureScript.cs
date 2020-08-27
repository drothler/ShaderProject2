using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TreasureScript : MonoBehaviour
{

    CapsuleCollider coll;

    // Start is called before the first frame update
    void Start()
    {
        coll = gameObject.GetComponent<CapsuleCollider>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnCollisionEnter(Collision collision)
    {
        if(collision.collider.gameObject.tag == "Player")
        {
            GameManager.instance.Points += 1;
            Destroy(gameObject);
        }
    }

}
