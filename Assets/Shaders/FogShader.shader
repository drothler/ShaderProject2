Shader "Custom/FogShader"
{
//Screen Space Fog Effect, multiplies Scene with depth fog
    Properties
    {
		_MainTex("Texture", 2D) = "white" {} //Input Image
        _FogTex ("Fog Detail", 2D) = "white" {} // Fog Distortion (look at fogdistort.png)
		_FogColor("Fog Color", Color) = (0.4,0.4,0.4,1)
		_FogStrength("Fog Strength", float) = 4

    }
    SubShader
    {
        LOD 100
        Pass
        {
			ZWrite Off
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float4 screenPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

			sampler2D _FogTex;
			float4 _FogTex_ST;

			float4 _FogColor;
			float _FogStrength;
			float _FogMax;

			sampler2D _CameraDepthNormalsTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float depth;
				depth = DecodeFloatRG(tex2D(_CameraDepthNormalsTexture, i.screenPos.xy / i.screenPos.w).zw); //get depth from camera
				depth = clamp(_FogStrength * pow(depth,2),0,1); //calculate how near the fog should appear
				//return lerp(float4(0,0,0,0), float4(1,1,1,1), depth);
                return lerp(tex2D(_MainTex, i.uv), _FogColor * tex2D(_FogTex, float2((i.uv.x + _Time.x) % 1, i.uv.y)), 0.8 * depth); //add fog detail/highlights to main image depending on depth 
            }
            ENDHLSL
        }
	}
}
