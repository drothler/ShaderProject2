Shader "Custom/RainShader"
{
	Properties
	{
		_Color ("Rain Color", Color) = (0.5, 0.5, 0.5, 1.0)
	}

	SubShader 
	{
		Pass 
		{
			HLSLPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom
			
			#include "UnityCG.cginc"

			StructuredBuffer<float3> _raindrops;
			
			struct v2g
			{
				float4 pos : SV_POSITION;
			};

			struct g2f
			{
				float4 pos : SV_POSITION;
			};
			
			float4 _Color;
			float _difference;
			
			v2g vert(uint instance_id : SV_InstanceID)
			{
				v2g o;

				o.pos = UnityObjectToClipPos(mul(unity_WorldToObject ,float4(_raindrops[instance_id], 1.0f)));
			
				return o;
			}

			[maxvertexcount (4)]
			void geom(point v2g IN[1], inout TriangleStream<g2f> tristream)
			{
				v2g one = IN[0];

				g2f o;
				o.pos = one.pos + float4(_difference,0,0,0);
				tristream.Append(o);

				o.pos = one.pos + float4(0, _difference,0,0);
				tristream.Append(o);

				o.pos = one.pos + float4(0, -_difference,0,0);
				tristream.Append(o);

				o.pos = one.pos + float4(-_difference,0,0,0);
				tristream.Append(o);

			}

			fixed4 frag(g2f i) : COLOR
			{
				return _Color;
			}
			
			ENDHLSL
		}
	}
}
