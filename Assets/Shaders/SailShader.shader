
//Sail shader deforms sail of boat with respect to wind direction
//90 degree angle to sail means most speed, 0 degree angle means zero speed

Shader "Custom/SailShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        _DisplacementStrength ("Displacement Strength", float) = 1.0
        _WindDirection ("Wind Direction", Vector) = (1,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 vertexcolor : COLOR;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 vertexcolor : COLOR;
                float2 uv : TEXCOORD0;
            };

            float _DisplacementStrength;
            float3 _WindDirection;

            v2f vert(appdata v)
            {
                //displacement intensity is based on vertex color, white=maximum disp, black = minimal disp and wind direction
                float intensity = dot(v.normal, _WindDirection) * v.vertexcolor.x;
                v2f output;
                output.vertex = UnityObjectToClipPos(v.vertex.xyz + v.normal*intensity);
                output.vertexcolor = v.vertexcolor;
                output.uv = v.uv;
                return output;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return fixed4(i.vertexcolor.x, i.vertexcolor.y, i.vertexcolor.z, 1);
            }

            ENDCG
        }
        
    }
  
}
