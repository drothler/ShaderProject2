﻿Shader "Custom/LowPolyWaterShader"
{
    Properties
    {
		_DropTex ("Drop Texture (autogenerated, do not set)", 2D) = "black" {} //raindrop texture, set from drop compute shader

		_BaseColor("Water Base Color", Color) = (0,0,120,255) //color of water
		_FoamColor("Water Foam Color", Color) = (1,1,1,1) //color of water foam
		_IntersectColor("Intersection Color", Color) = (1,1,1,1) //color of intersections with objects and the water

		_NLIntensity("Normal * Lighting Intensity", float) = 1.5 //to control the intensities of wave shadows

		_Ambient ("Ambient", Range (0, 1)) = 0.25
		_DiffuseColor ("Diffuse Color", Color) = (1,1,1,1)
		
		//Specular color and exponent are added
		_SpeColor ("Specular Color", Color) = (1,1,1,1) 
        _SpecExp ("Specular Exponent", Float) = 10

		_IntersectIntensity("Intersection Intensity", float) = 10.0
		_IntersectExponent("Intersection Falloff Exponent", float) = 6.0

		_WaveA("Wave 1 (Direction, Steepness, Wavelength)", Vector) = (1,0,0.6,10) //for gerstner waves, first direction (dir x, dir y), then steepness (best below 1), then Wavelength (1 to 5ish)
		_WaveB("Wave 2 (Direction, Steepness, Wavelength)", Vector) = (0,1,0.3,8)
		_WaveC("Wave 3 (Direction, Steepness, Wavelength)", Vector) = (1,1,0.4,10)
    }
    SubShader
    {
		//Tags {"RenderType" = "Opaque"}
        ZWrite On
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma geometry geom

            #include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"



            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2g
            {
				float2 dropuv : TEXCOORD5;
                float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
				float4 screenPos : TEXCOORD1;
				float depth : TEXCOORD2; 
				float3 worldNormal : TEXCOORD3;
				float4 vertexWorld : TEXCOORD4;
            };

			struct g2f
            {
                float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
				float4 screenPos : TEXCOORD1;
				float depth : TEXCOORD2;
				float4 diffuseTerm : TEXCOORD3;
				float4 specularTerm : TEXCOORD4;
				float2 dropuv : TEXCOORD5;
            };



			sampler2D _DropTex;
			float4 _DropTex_ST;

			float _NLIntensity;

			float _Ambient;
			float4 _DiffuseColor;
			float _SpecExp;
			float4 _SpeColor;

			sampler2D _CameraDepthNormalsTexture;
			float _IntersectIntensity;
			float _IntersectExponent;


			float4 _BaseColor;
			float4 _FoamColor;
			float4 _IntersectColor;

			float _Steepness;
			float _Wavelength;
			float2 _Direction;

			float4 _WaveA;
			float4 _WaveB;
			float4 _WaveC;


			float2 random2(float2 p) {
				return frac(sin(float2(dot(p,float2(127.1,311.7)),dot(p,float2(269.5,183.3))))*43758.5453);
			}

			//calculates the waves every frame for every vertex; Gerstner Waves, Trochoidal Waves
			float3 GerstnerWave (float4 wave, float3 p, inout float3 tangent, inout float3 binormal) {
				float steepness = wave.z;
				float wavelength = wave.w;
				float k = 2 * UNITY_PI / wavelength;
				float c = sqrt(9.8 / k);
				float2 d = normalize(wave.xy);
				float f = k * (dot(d, p.xz) - c * _Time.y);
				float a = steepness / k;

				tangent += float3(-d.x * d.x * (steepness * sin(f)), d.x * (steepness * cos(f)),-d.x * d.y * (steepness * sin(f)));
				binormal += float3(-d.x * d.y * (steepness * sin(f)), d.y * (steepness * cos(f)), -d.y * d.y * (steepness * sin(f)));
				return float3(d.x * (a * cos(f)), a * sin(f), d.y * (a * cos(f)));
			}


            v2g vert (appdata v)
            {
                v2g o;

				float3 gridpoint = v.vertex.xyz;
				float3 tangent = float3(1, 0, 0);
				float3 binormal = float3(0 ,0, 1);
				float3 p = mul(unity_ObjectToWorld,gridpoint);
				//additive wave calculations in worldspace, so it can be recalculated outside of shader
				p += GerstnerWave(_WaveA, gridpoint, tangent, binormal);
				p += GerstnerWave(_WaveB, gridpoint, tangent, binormal);
				p += GerstnerWave(_WaveC, gridpoint, tangent, binormal);

				p = mul(unity_WorldToObject, p);

				float3 normal = normalize(cross(binormal, tangent));

                o.vertex = UnityObjectToClipPos(p);
				o.dropuv = TRANSFORM_TEX(v.uv, _DropTex);
				o.normal = normal;
				o.screenPos = ComputeScreenPos(o.vertex);
				o.depth = -mul(UNITY_MATRIX_MV, v.vertex).z * _ProjectionParams.w;

				o.worldNormal = UnityObjectToWorldNormal(normal);
				o.vertexWorld = mul(unity_ObjectToWorld, v.vertex);
                
                return o;
            }


			//For low poly, we take three vertices and make one triangle out of them and give the whole triangle the same color
			[maxvertexcount (3)]
			void geom(triangle v2g IN[3], inout TriangleStream<g2f> tristream)
			{
				v2g one = IN[0];
				v2g two = IN[1];
				v2g three = IN[2];

				float4 mid = (one.vertex + two.vertex + three.vertex) / 3;
				float3 normal = normalize((one.normal + two.normal + three.normal) / 3);
				float3 worldNormal = (one.worldNormal + two.worldNormal + three.worldNormal) / 3;
				float4 vertexWorld = (one.vertexWorld + two.vertexWorld + three.vertexWorld) / 3;

				float4 col = _BaseColor; //Color calculation in geom so we calculate it one time for all three

            	float3 normalDirection = normalize(worldNormal);
            	float3 viewDirection = normalize(UnityWorldSpaceViewDir(vertexWorld));
				float3 lightDirection = normalize(UnityWorldSpaceLightDir(vertexWorld));

				float nl = max(_Ambient + (float4(0, 0, random2(mid.xy * _Time.x).x - 0.5 , 0)), dot(normalDirection, _WorldSpaceLightPos0.xyz) * _NLIntensity);
				float4 diffuseTerm = nl * _DiffuseColor * col * _LightColor0;

				float3 reflectionDirection = -lightDirection - 2.0f * normalDirection * dot(normalDirection, -lightDirection);
				float3 specularDot = max(0.0, dot(viewDirection, reflectionDirection));
				float3 specular = pow(specularDot, _SpecExp);
				float4 specularTerm = float4(specular, 1) * _SpecColor * _LightColor0; 

				g2f o;
				o.vertex = one.vertex;
				o.depth = one.depth;
				o.normal = normal;
				o.dropuv = one.dropuv;
				o.screenPos = one.screenPos;
				o.diffuseTerm = diffuseTerm;
				o.specularTerm = specularTerm;
				tristream.Append(o);

				o.vertex = two.vertex;
				o.depth = two.depth;
				o.normal = normal;
				o.dropuv = two.dropuv;
				o.screenPos = two.screenPos;
				o.diffuseTerm = diffuseTerm;
				o.specularTerm = specularTerm;
				tristream.Append(o);

				o.vertex = three.vertex;
				o.depth = three.depth;
				o.normal = normal;
				o.dropuv = three.dropuv;
				o.screenPos = three.screenPos;
				o.diffuseTerm = diffuseTerm;
				o.specularTerm = specularTerm;
				tristream.Append(o);

			}

            fixed4 frag (g2f i) : SV_Target
            {
				float diff = DecodeFloatRG(tex2D(_CameraDepthNormalsTexture, i.screenPos.xy / i.screenPos.w).zw) - i.depth;
				float intersectGradient = 1 - min(diff / _ProjectionParams.w, 1.0f);
				fixed4 intersectTerm = _IntersectColor * pow(intersectGradient, _IntersectExponent) * _IntersectIntensity;
				
                return fixed4(i.diffuseTerm.xyz + i.specularTerm.xyz + intersectTerm.xyz + tex2D(_DropTex, i.dropuv).xyz, _BaseColor.a); //Intersect and Drop in Fragment: if in geom, whole triangle gets the color of the intersect/drop

            }
            ENDHLSL
        }
    }
	FallBack "Standard"
}
