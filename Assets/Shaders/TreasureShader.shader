Shader "Custom/TreasureShader"
{

//shader for treasures, changes transparency based on distance to player/camera
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Color", Color) = (1,0,0,1)
		_Ambient ("Ambient", Range (0, 1)) = 0.25
		_DiffuseColor ("Diffuse Color", Color) = (1,1,1,1)

		_SpecColor ("Specular Color", Color) = (1,1,1,1) 
        _SpecExp ("Specular Exponent", Float) = 10

		_DistanceModifier("Distance Modifier", float) = 0 //modifies at what distance the object gets rendered, very fickle, best range aroung 0.05
		_TransparentCutoff("Transparency Cutoff", Range(0,1)) = 0.8 //at what alpha value the transparency just gets to 1
	}
	SubShader
	{
		Tags { "RenderType" = "Transparent" "Queue"="Transparent"}
		LOD 100
		Blend SrcAlpha OneMinusSrcAlpha


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
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float4 vertexWorld : TEXCOORD2;
			};
				
			sampler2D _MainTex;
            float4 _MainTex_ST;
			float4 _Color;
			float _Ambient;
			float _SpecExp;
			float4 _DiffuseColor;
			float _DistanceModifier;
			float _TransparentCutoff;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.vertexWorld = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				//standard nl
            	float3 normalDirection = normalize(i.worldNormal);
            	float3 viewDirection = normalize(UnityWorldSpaceViewDir(i.vertexWorld));
				float3 lightDirection = normalize(UnityWorldSpaceLightDir(i.vertexWorld));

				fixed4 tex = tex2D(_MainTex, i.uv);

				float nl = max(_Ambient, dot(normalDirection, _WorldSpaceLightPos0.xyz));
				float4 diffuseTerm = nl * _DiffuseColor * _Color * tex * _LightColor0;
				
				float3 reflectionDirection = -lightDirection - 2.0f * normalDirection * dot(normalDirection, -lightDirection);
				float3 specularDot = max(0.0, dot(viewDirection, reflectionDirection));

				float3 specular = pow(specularDot, _SpecExp);
				float4 specularTerm = float4(specular, 1) * _SpecColor * _LightColor0;


				//takes distance and calculates alpha off of that
				float alpha = smoothstep(1,0, distance(_WorldSpaceCameraPos, i.vertexWorld) * _DistanceModifier);
				alpha = alpha > _TransparentCutoff ? 1 : alpha;

				return float4(diffuseTerm.xyz + specularTerm.xyz, alpha);
			}

			ENDHLSL
		}
	}
	Fallback "Standard"
}
