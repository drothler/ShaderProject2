

//Star positions are realistic, in our code they are read from a json database, and can therefore be parametrically changed to add and take out stars
//Shader gets output buffer from compute shader and uses the vertex data to create a quad for each vertex. 
//Each quad is rotated towards the camera and gets rendered with a star texture and one of three colors from a pre computed colormap
Shader "Custom/StarShader"
{
    Properties
    {
        _StarTex("Star Texture", 2D) = "white" {}
        _ColorMap("Star Colors", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _StarSize ("Star Size", float) = 100

    }
    SubShader
    {
        
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        Cull Off
        Blend One One
        LOD 100
        Zwrite Off
        Pass
        {
            CGPROGRAM
            #pragma target 5.0
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

                #include "UnityCG.cginc"

                struct appdata
                {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                    uint id : SV_VertexID;
                };

                float3 playerPos;
                uniform StructuredBuffer<float4> outputBuffer;
                sampler2D _StarTex;
                sampler2D _ColorMap;
                float4 _StarTex_ST;
                float _StarSize;

                struct v2g
                {
                    float3 worldPos : TEXCOORD1;
                    float2 uv : TEXCOORD0;
                    fixed4 magnitude : TEXCOORD2;
                    float color : COLOR;
                    
                };
                struct g2f
                {
                    float4 vertex : SV_POSITION;
                    float2 uv : TEXCOORD0;
                    fixed4 magnitude : TEXCOORD1;
                    float color : COLOR;
                };
            
                //Vertex shader gets world position of every star, writes it to struct and calculates color id
                v2g vert(uint id : SV_VertexID){
                    v2g v;
                    v.worldPos = float3(outputBuffer[id].xyz);
                    v.uv =TRANSFORM_TEX(float2(0.5,0.5),_StarTex);
                    

                    v.magnitude = outputBuffer[id].w;

                    //color id gets calculated in relation to vertex id
                    v.color = (id%3)/2.0;
                    return v;
                }



                //Geom shader creates quads with vertex position as center
                //Quads face camera at all times
                [maxvertexcount(4)]
                void geom(point v2g input[1], inout TriangleStream<g2f> tristream)
                {
                    float3 forward=normalize(_WorldSpaceCameraPos-input[0].worldPos);
                    float3 right = normalize(cross(forward,float3(0,1,0)));
                    float3 up = normalize(cross(forward,right));
                    float4 points[4];
                    float size = _StarSize*input[0].magnitude/10;
                    points[0] =UnityWorldToClipPos( float3(input[0].worldPos+(-1)*(size/2*right)+(size/2*up)));
                    points[1] =UnityWorldToClipPos(  float3(input[0].worldPos+(size/2*right)+(size/2*up)));
                    points[2] =UnityWorldToClipPos( float3( input[0].worldPos+(-1)*(size/2*right)-(size/2*up)));
                    points[3] =UnityWorldToClipPos(  float3(input[0].worldPos+(size/2*right)-(size/2*up)));
                    
                    g2f output;
                    output.vertex = points[0];
                    output.uv = TRANSFORM_TEX(float2(0,1),_StarTex);
                    output.magnitude = input[0].magnitude;
                    output.color = input[0].color;
                    tristream.Append(output);
                    output.vertex = points[1];
                    output.uv = TRANSFORM_TEX(float2(1,1),_StarTex);
                    output.magnitude = input[0].magnitude;
                    output.color = input[0].color;
                    tristream.Append(output);
                    output.vertex =points[2];
                    output.uv = TRANSFORM_TEX(float2(0,0),_StarTex);
                    output.magnitude = input[0].magnitude;
                    output.color = input[0].color;
                    tristream.Append(output);
                    output.vertex =points[3];
                    output.uv = TRANSFORM_TEX(float2(1,0),_StarTex);
                    output.magnitude = input[0].magnitude;
                    output.color = input[0].color;
                    tristream.Append(output);


                }
                //Frag function samples star sprite and color map and draws stars
                fixed4 frag(g2f i) : SV_TARGET
                {
                    fixed4 color = tex2D(_ColorMap, float2(i.color,0.5));
                    float glow = i.magnitude;
                    fixed4 tex = tex2D( _StarTex,i.uv);
                    return fixed4(3*tex.rgb*color.rgb, glow);
                }

                
            ENDCG
        }
    }
    
}
