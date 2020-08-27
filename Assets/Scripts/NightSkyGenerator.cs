using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using System.Text.RegularExpressions;

public class NightSkyGenerator : MonoBehaviour
{
    // Start is called before the first frame update
    public struct Star{
        public float rad;
        public float dec;
        public float mag;
    }


    

    
    //Render Stuff
    
    public int skymap_res;
    public float radius;
    public Vector3 origin;
    public Material sky_mat;

    public float star_radius;




    //Shader Stuff


    public Shader skyVertexShader;
    public ComputeShader sky_shader;        //Computing stars' world position
    public ComputeBuffer outputBuffer;      //Used for star position calculations
    public ComputeBuffer stardata;          //Input Buffer for Compute shader
    public Star[] starArray;                //Storing data for the input buffer     


    //JSON Stuff
    public static string JSONPath = "/BSC.json";
    public string json;
    public StarMapInfo stars;


    void Start()
    {
        //read json file and parse to StarMapInfo object
        
        string path = Application.streamingAssetsPath+JSONPath;
        json = File.ReadAllText(path);
        stars = JsonUtility.FromJson<StarMapInfo>(json);
        
        
        sky_mat = new Material(skyVertexShader);
        

        int kernelHandle = sky_shader.FindKernel("CSMain");
        //set ComputeShader StarMapGenerator variables 
        sky_shader.SetFloat("radius", radius);
        sky_shader.SetFloats("origin", new float[]{0,0,0});
        sky_shader.SetFloats("zAxis", new float[]{0,0,-1});
        
        //Initialize Star Array which only stores rad, dec and mag of each star in floats
        starArray = convertStarData(stars.starmap); 
        sky_shader.SetInt("length", starArray.Length);

        
        //Initialize input data buffer, passing radiants, decline, magnitude and color
        stardata = new ComputeBuffer(starArray.Length, 3*sizeof(float));
        stardata.SetData(starArray);

        outputBuffer = new ComputeBuffer(starArray.Length, 4*sizeof(float));
        sky_shader.SetBuffer(kernelHandle, "stardata", stardata);
        sky_shader.SetBuffer(kernelHandle, "outputBuffer", outputBuffer);
        sky_mat.SetFloat("_StarSize", star_radius);
        sky_mat.SetBuffer("outputBuffer", outputBuffer);
        //Initialize Shaders, principle:
        //Compute Shader calculates every world position for each star
        //Writes World Pos in outputBuffer
        //Surface Shader uses outputBuffer to render Stars
        InitShader(kernelHandle);

        releaseBuffers(stardata);
        

    }
    //When GameObject is rendered, we set our sky material's render pass and call DrawProceduralNow to render the Stars
    void OnRenderObject()
    {
        sky_mat.SetPass(0);
        Graphics.DrawProceduralNow(MeshTopology.Points, skymap_res);
    }

    void OnApplicationQuit()
    {
        releaseBuffers(outputBuffer);
    }

    Star[] convertStarData(StarValues[] inArray){
        Star[] output = new Star[inArray.Length];
        int i=0;
        foreach(StarValues s in inArray){
            Vector2 angles = getDegreeValues(s.RA, s.DEC);
            output[i].rad = angles.x;
            output[i].dec = angles.y;
            output[i].mag =float.Parse( s.MAG);
            i++;
        }


        return output;
    }

    void InitShader(int kernel){
        sky_shader.Dispatch(kernel, starArray.Length/128+1, 1, 1);
    }

    void releaseBuffers(ComputeBuffer buffer){
        buffer.Release();
    }
    Vector2 getDegreeValues(string right, string decl){

        //Split string for rad
        string[] rads = Regex.Split(right, @"\D+");
        float[] rad_ints = new float[4];

        //Split string for dec
        string[] decs = Regex.Split(decl, @"\D+");
        float[] dec_ints = new float[4];

        //check for negative value
        int sign = decl.IndexOf("-");
        
        //Parse ints into array
        for(int i=1; i<5; i++){
            if(!string.IsNullOrEmpty(rads[i-1])){
                rad_ints[i-1] = int.Parse(rads[i-1]);
            }
            if(!string.IsNullOrEmpty(decs[i])){
                dec_ints[i-1] = int.Parse(decs[i]);
            }
        }
        
         
        //calculate angle in degrees
        //RA  in hours:minutes:seconds:milliseconds
        //DEC in degrees:arcminutes:arseconds:arcmilliseconds

        //deg in float is: +-degrees+1/60 degree+1/3600 degree + 1/3600000 degree
        float deg = dec_ints[0]+(dec_ints[1]*(1/60.0f))+(dec_ints[2]*(1/3600.0f))+(dec_ints[3]*(1/3600000.0f));
        if(sign!=-1){
            deg*=-1;
        }
        //rad in float is: (hours + minutes*1/60 + seconds*1/3600 + milliseconds*1/3600000)*15
        float rad = (rad_ints[0]+rad_ints[1]/60.0f+rad_ints[2]/3600.0f+rad_ints[3]/3600000.0f)*15;
        return new Vector2(rad,deg);

       
    }
}

    