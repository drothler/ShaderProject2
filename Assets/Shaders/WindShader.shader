Shader "Custom/WindShader"
{
    Properties
    {
		_Color("Color", COLOR) = (1,1,1,1)
		_Radius("Radius", float) = 1.0
		_SmallestRadius("SmallestRadius", float) = 0
		_Angle("Angle", float) = 90.0
		_SpiralCount("SpiralCount", int) = 1
		_WindWidth("WindWidth", Range(0,1)) = 0.8
		_MeshSize("MeshSize", float) = 100
		_MeshOffset("MeshOffset", float) = 40
		_OffsetDivision("OffsetDivision", float) = 8
		_MeshRotationSpeed("MeshRotationSpeed", float) = 1
		_WindSpeed("WindSpeed", float) = 10
    }

    SubShader
    {
        Pass
        {	
			Tags {"RenderType" = "Transparent" "Queue" = "Transparent"}
            Blend SrcAlpha OneMinusSrcAlpha
			Cull Off

            HLSLPROGRAM


            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"
 
			struct appdata
			{
				float4 vertex : POSITION;

			};

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float offset : TEXCOORD0;
            };



			float4 _Color;
			float _Angle;
			float _Radius;
			float _SmallestRadius;
			int _SpiralCount;
			float _WindWidth;
			float _MeshSize;
			float _MeshRotationSpeed;
			float _WindSpeed;
			float _OffsetDivision;
			float _MeshOffset;
			
           
            v2f vert (appdata v)
            {
                v2f o;
				//Offset depends on mesh size (from 0 to 1)
				float xOffset = ((v.vertex.x +_MeshSize)/(_MeshSize*2));
				o.offset = xOffset;
				//Radius gets smaller with distance --> Spiral. Mesh Rotation to mask mesh
				v.vertex.y += (_Radius*xOffset+_SmallestRadius) * cos(_SpiralCount * 2 * UNITY_PI * xOffset - _Time.y * _MeshRotationSpeed);
				v.vertex.z += (_Radius*xOffset+_SmallestRadius) * sin(_SpiralCount * 2 * UNITY_PI * xOffset - _Time.y * _MeshRotationSpeed);
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

           
            fixed4 frag (v2f i) : SV_Target
            {	//Windband is the transparency at specific intervals, with falloff. No texture needed
				float animTerm = max(sin((_Time.y*_WindSpeed + i.offset * _MeshOffset)/_OffsetDivision)-_WindWidth, 0.0f) * (1.0 / (1.0 - _WindWidth));
				_Color.a = animTerm *_Color.a; 
				return _Color;
            }

            ENDHLSL
        }
    }
}
