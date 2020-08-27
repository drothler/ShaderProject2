Shader "Custom/EventHorizon"
{
    Properties
    {
		[HideInInspector]_MainTex ("Texture", 2D) = "white" {}
		_Brightness("Brightness", float) = 1
		
    }

    SubShader
    {	
		Cull Off
		ZWrite Off
		ZTest Always

		
		//Postprocessing distortion effect
		Pass
        {	
            HLSLPROGRAM


            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"
			#define EULER 2.71828182846
 
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;

			};

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 screenPos : TEXCOORD1;
            };



			sampler2D _MainTex;
			float _Brightness;
			
           
            v2f vert (appdata v)
            {
                v2f o;
				
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }

			           
            fixed4 frag (v2f i) : SV_Target
            {	


				float invAspect = _ScreenParams.y / _ScreenParams.x;

				float2 middle = float2(0.5, 0.5);
				
				
				float2 screenPos = i.screenPos.xy / i.screenPos.w;
				float2 circlePos = screenPos - middle;

				circlePos.x *= _ScreenParams.x / _ScreenParams.y;
				
				float dist = length(circlePos);
       
				//Inverted color space with darkened middle (distances < 1)
				//Distortion through distance
				return _Brightness * dist-tex2D(_MainTex, i.uv * dist);
            }

            ENDHLSL
        }
    }
}
