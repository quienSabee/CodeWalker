#include "BasicVS.hlsli"

struct VS_INPUT
{
    float4 Position : POSITION;
    float3 Normal : NORMAL;
    float4 Colour0 : COLOR0;
    float2 Texcoord0 : TEXCOORD0;
    float2 Texcoord1 : TEXCOORD1;
    float2 Texcoord2 : TEXCOORD2;
};

VS_OUTPUT main(VS_INPUT input, uint iid : SV_InstanceID)
{
    VS_OUTPUT output;
    float3 opos = ModelTransform(input.Position.xyz, input.Colour0.xyz, input.Colour0.xyz, iid);
    float4 cpos = ScreenTransform(opos);
    float3 bnorm = NormalTransform(input.Normal);
    float3 btang = 0.5; // NormalTransform(float3(1, 0, 0)); //no tangent to use on this vertex type...

    float4 tnt = ColourTint(input.Colour0.b, 0, iid); //colour tinting if enabled

    float4 lightspacepos;
    float shadowdepth = ShadowmapSceneDepth(opos, lightspacepos);
    output.LightShadow = lightspacepos;
    output.Shadows = float4(shadowdepth, 0, 0, 0);

    output.Position = cpos;
    output.CamRelPos = opos;
    output.Normal = bnorm;
    output.Texcoord0 = GlobalUVAnim(input.Texcoord0);
    output.Texcoord1 = input.Texcoord1;
    output.Texcoord2 = input.Texcoord2;
    output.Colour0 = input.Colour0;
    output.Colour1 = float4(0.5, 0.5, 0.5, 1); //input.Colour
    output.Tint = tnt;
    output.Tangent = float4(btang, 1);
    output.Bitangent = float4(cross(btang, bnorm), 0);
    return output;
}