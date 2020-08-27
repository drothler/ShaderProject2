Shader "Custom/MonochromeToon"
{
    Properties
    {
		_Color("Color", COLOR) = (1,1,1,1)
		_RampTex ("Texture", 2D) = "white" {}
		
    }
	//Simple color band cel shader
    SubShader
    {
        Pass
        {	
            HLSLPROGRAM


            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"
 
			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;

			};

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
            };



			float4 _Color;
			sampler2D _RampTex;
			
           
            v2f vert (appdata v)
            {
                v2f o;
				
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

           
            fixed4 frag (v2f i) : SV_Target
            {	
				float3 normal = normalize(i.worldNormal);
				float nl = dot(normal, _WorldSpaceLightPos0.xyz);
				float4 intensity = tex2D(_RampTex, float2(nl, 0));
				return intensity* _Color;
            }

            ENDHLSL
        }
    }
}
