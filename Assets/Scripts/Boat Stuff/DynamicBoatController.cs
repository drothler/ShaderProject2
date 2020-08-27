using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DynamicBoatController : MonoBehaviour
{

    

    public GameObject sail;     //sets the sail, which needs to be rotated
    public GameObject rotator;
    public float speed;         //driving speed, should be dependent on angle of wind to sail
    

    public float rotation_speed;

    public float sail_rotation_speed;

    public float wiggle_intensity;

    public float wiggle_speed;

    private Rigidbody rb;

    private GameObject windmanager;

    private GameObject anchor;
    private Vector3 winddirection;




    // Start is called before the first frame update
    void Start()
    {
        /*rb = gameObject.GetComponent<Rigidbody>();
        if(rb==null){
            gameObject.AddComponent<Rigidbody>();
        }*/
        windmanager = GameObject.Find("WindManager");
        winddirection=windmanager.GetComponent<Wind>().windDir;
        anchor = GameObject.FindGameObjectWithTag("Anchor");
    }

    // Update is called once per frame
    void Update()
    {
        moveBoat();
        rotateBoat();
        rotateSail();

    }

    void moveBoat(){
        float translation = Input.GetAxis("Vertical");
        float wiggle = addWaterTurbulence()*wiggle_intensity;


        gameObject.transform.Translate(0,0,calculateWindPower()*translation*speed*Time.deltaTime);


        


        gameObject.transform.position = new Vector3(transform.position.x,wiggle , transform.position.z);    
        anchor.transform.position = new Vector3(anchor.transform.position.x,-wiggle, anchor.transform.position.z);   
        
    }

    float calculateWindPower(){
        Vector3 referenceForward = sail.transform.forward;
        Vector3 referenceRight = Vector3.Cross(sail.transform.up, referenceForward);
         // Get the angle in degrees between 0 and 180
        float angle = Vector3.Angle(winddirection, referenceForward);
        // Determine if the degree value should be negative.  Here, a positive value
        // from the dot product means that our vector is on the right of the reference vector   
        // whereas a negative value means we're on the left.
        float sign = Mathf.Sign(Vector3.Dot(winddirection, referenceRight));
        float finalAngle = sign * angle;


        //Debug.Log(finalAngle);
        //Debug.Log(Mathf.Sin(Mathf.Deg2Rad*finalAngle));
        return Mathf.Sin(Mathf.Deg2Rad*finalAngle);
    }

    void rotateBoat(){
        float rotation = Input.GetAxis("Horizontal");
        
        transform.Rotate(new Vector3(0,rotation*rotation_speed*Time.deltaTime,0), Space.Self);
        rotator.transform.rotation = Quaternion.Euler(0,-rotation*40, 0);
    }

    void rotateSail(){
        float leftTrigger = Input.GetAxis("Left Trigger");
        float rightTrigger = Input.GetAxis("Right Trigger");

        if(leftTrigger != rightTrigger){
            sail.transform.Rotate(new Vector3(0,Time.deltaTime*sail_rotation_speed*(rightTrigger-leftTrigger),0), Space.Self);
        }
        
    }

    float addWaterTurbulence(){
        float yOffset = wiggle_speed * Mathf.Sin(Time.time) +Mathf.Cos(Time.time+2);
        return yOffset;
    }

    void focusOn(){

    }
}
