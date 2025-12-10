Shader "Custom/Portal"
{
    Properties
    {
        [MainTexture]_MainTex ("Portal Texture", 2D) = "black" {}
        [MainColor]_InactiveColour ("Inactive Colour", Color) = (1, 1, 1, 1)
        _DisplayMask ("Display Mask (0=Inactive, 1=Portal)", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "Queue"="Geometry"
            "IgnoreProjector"="True"
        }
        LOD 100
        Cull Off
        ZWrite On
        ZTest LEqual
        Blend One Zero

        Pass
        {
            Name "ForwardUnlit"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex   Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float4 screenPos   : TEXCOORD0;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _InactiveColour;
                float  _DisplayMask;
            CBUFFER_END

            Varyings Vert(Attributes IN)
            {
                Varyings OUT;
                // 수정됨: float3 타입을 인자로 전달
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS);
                OUT.screenPos   = ComputeScreenPos(OUT.positionHCS);
                return OUT;
            }

            half4 Frag(Varyings IN) : SV_Target
            {
                float2 uv = IN.screenPos.xy / IN.screenPos.w;
                half4 portalCol = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);

                return lerp(_InactiveColour, portalCol, saturate(_DisplayMask));
            }
            ENDHLSL
        }
    }
}