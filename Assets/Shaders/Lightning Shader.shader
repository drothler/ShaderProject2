Shader "Custom/Lightning Shader"
{
    Properties
    {
        _ThunderOffsetTex ("ThunderOffset Texture", 2D) = "white" {} //determines movement of the lightning, look at texture in project
		_ThunderColor("Thunder Color", Color) = (1,1,1,1)
		_ThunderGlow("ThunderGlow", float) = 1 //intensity of the color
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent"}
        LOD 100
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off

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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _ThunderOffsetTex;
			float4 _ThunderOffsetTex_ST;
			float4 _ThunderColor;
			float _ThunderGlow;



            v2f vert (appdata v)
            {
                v2f o;
				float zoffset = tex2Dlod(_ThunderOffsetTex, float4(v.uv.x, (v.uv.y + _Time.y),0,1)) - 0.5; //scrolls through the offset texture
                o.vertex = UnityObjectToClipPos(v.vertex + float4(zoffset,0,zoffset,0));
                o.uv = TRANSFORM_TEX(v.uv, _ThunderOffsetTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                
                return _ThunderColor * _ThunderGlow;
            }
            ENDHLSL
        }
    }
}
