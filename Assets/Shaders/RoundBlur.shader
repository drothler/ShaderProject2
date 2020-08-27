Shader "Custom/RoundBlur"
{
    Properties
    {
		[HideInInspector]_MainTex ("Texture", 2D) = "white" {}
		_ScopeOutlineColor ("Scope Outline Color", COLOR) = (0,0,0,1)
		_Radius ("Radius", float) = 0.4
		_BlurStrength("Blur Strength", Range(0, 1)) = 0.1
		_BlurDistanceFactor("Blur Distance Factor", float) = 1.5
		_BlurDistanceFactorPOW("Blur Distance Factor POW", float) = 2
		_Sigma("Sigma", Range(0.01, 0.3)) = 0.02
    }

    SubShader
    {	
		Cull Off
		ZWrite Off
		ZTest Always

		//Scope circle pass
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
				float2 uv : TEXCOORD0;

			};

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 screenPos : TEXCOORD1;
            };



			sampler2D _MainTex;
			float4 _ScopeOutlineColor;
			float _Radius;
			
           
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
				fixed4 textureCol = tex2D(_MainTex, i.uv);
				float2 middle = float2(0.5, 0.5);
				
				
				float2 screenPos = i.screenPos.xy / i.screenPos.w;
				float2 circlePos = screenPos - middle;

				circlePos.x *= _ScreenParams.x / _ScreenParams.y;
				
				float dist = length(circlePos);
				//Black circle scope in first pass rendertexture
                if(dist > _Radius) {
					textureCol = _ScopeOutlineColor;
				}
				
				
				return textureCol;
            }

            ENDHLSL
        }
		//Gaussian blur pass, horizontal and vertical
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
			float _BlurStrength;
			float _BlurDistanceFactor;
			float _BlurDistanceFactorPOW;
			float _Sigma;

			
           
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
				
				float4 textureCol = 0;
				//Higher size = stronger blur, needs to be constant
				const int kernelSize = 30;

				float invAspect = _ScreenParams.y / _ScreenParams.x;

				float2 middle = float2(0.5, 0.5);
				
				float2 screenPos = i.screenPos.xy / i.screenPos.w;
				float2 circlePos = screenPos - middle;

				circlePos.x *= _ScreenParams.x / _ScreenParams.y;
				
				float dist = length(circlePos);
				
				float sum = 0;

				//Blur stronger at higher mid distance, distance factor configurable
				_BlurStrength *= dist*pow(_BlurDistanceFactor, _BlurDistanceFactorPOW);

				for(float k = 0; k< kernelSize; ++k) {
					for(float l = 0; l< kernelSize; ++l) {
						
						float offsetX = (k/(kernelSize-1) -0.5) * _BlurStrength * invAspect;
						float offsetY = (l/(kernelSize-1) -0.5) * _BlurStrength;

						float stDevSquared = _Sigma*_Sigma;
						//Gauss in two dimensions
						float gauss = (1 / sqrt(2*UNITY_PI*stDevSquared)) * pow(EULER, -((offsetX*offsetX + offsetY*offsetY)/(2*stDevSquared)));
						sum += gauss;
						float2 uv = i.uv;
						uv += float2(offsetX, offsetY);
						textureCol += tex2D(_MainTex, uv) * gauss; 
					}
				}
				textureCol /= sum;
				
				return textureCol;
            }

            ENDHLSL
        }
    }
}
