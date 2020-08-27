using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlyingCamera : MonoBehaviour
{

    //Flycam attributes
    public GameObject focus;    //sets the object the camera should focus on -> usually boat
    public float distance;      //sets standard distance between camera and boat
    public float angle;         //sets standard viewing angle between camera and boat

    public float timeToReset;    //sets the time it takes for the boat camera to reset after lack of input

    private float max_angle;

    public float rotation_speed;
    private Vector2 oldStickPos;


    // Start is called before the first frame update
    void Start()
    {
        
        max_angle = Mathf.Rad2Deg*Mathf.Acos(focus.transform.position.y/distance);
        oldStickPos = new Vector2(Screen.height/2, Screen.width/2);
        transform.LookAt(focus.transform);
        
    }

    // Update is called once per frame
    void Update()
    {
        float newStickPosX = Input.GetAxis("ControllerX");
        float newStickPosY = Input.GetAxis("ControllerY");



        float angleX = newStickPosX*Time.deltaTime*rotation_speed;
        float angleY = -newStickPosY*Time.deltaTime*rotation_speed;
        focus.transform.Rotate(Vector3.up, angleX,Space.World);
        if(focus.transform.rotation.eulerAngles.x  + angleY>-20 && focus.transform.rotation.eulerAngles.x + angleY<70){
            focus.transform.Rotate(Vector3.right, angleY,Space.Self);
        }

        //Debug.Log("x: "+newStickPosX+" - y "+newStickPosY);



        
        
        



        oldStickPos= new Vector2(newStickPosX, newStickPosY);
    }
}
