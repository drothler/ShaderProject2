Shader "Custom/StarSpriteShader"
{
    Properties
    {
        _StarTex("Star Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _StarSize ("Star Size", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        LOD 100
        Blend One One

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            float3 playerPos;
            uniform StructuredBuffer<float4> outputBuffer;
            sampler2D _StarTex;
            float4 _StarTex_ST;
            float _StarSize;

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            

            v2f vert (uint id : SV_VertexID)
            {
                
                
                
                v2f o;
                o.worldPos = float3(outputBuffer[id].xyz);
                o.vertex =UnityWorldToClipPos(o.worldPos);
                o.uv = TRANSFORM_TEX(float2(0.5,0.5), _StarTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_StarTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
