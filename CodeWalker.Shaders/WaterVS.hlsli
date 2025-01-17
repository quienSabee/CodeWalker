#include "Quaternion.hlsli"
#include "Shadowmap.hlsli"

cbuffer VSSceneVars : register(b0)
{
    float4x4 ViewProj;
    float4 WaterVector;
    float ScaledTime;
    float ScnPad0;
    float ScnPad1;
    float ScnPad2;
}
cbuffer VSEntityVars : register(b2)
{
    float4 CamRel;
    float4 Orientation;
    float3 Scale;
    uint EntPad0;
}
cbuffer VSGeomVars : register(b3)
{
    float4 WaterParams;
    uint EnableFlow;
    uint ShaderMode;
    uint GeoPad1;
    uint GeoPad2;
    float RippleSpeed;
    float GeoPad3;
    float GeoPad4;
    float GeoPad5;
}

struct VS_OUTPUT
{
    float4 Position  : SV_POSITION;
    float3 Normal    : NORMAL;
    float2 Texcoord0 : TEXCOORD0;
    float4 Flow      : TEXCOORD1;
    float4 Shadows   : TEXCOORD3;
    float4 LightShadow : TEXCOORD4;
    float4 Colour0   : COLOR0;
    float4 Tangent   : TEXCOORD5;
    float4 Bitangent : TEXCOORD6;
    float3 CamRelPos : TEXCOORD7;
};

Texture2D<float4> FlowSampler : register(t0);
SamplerState TextureSS : register(s0);

float3 ModelTransform(float3 ipos)
{
    float3 tpos = ipos;
    float3 spos = tpos * Scale;
    float3 bpos = mulvq(spos, Orientation);
    return CamRel.xyz + bpos;
}
float4 ScreenTransform(float3 opos)
{
    float4 pos = float4(opos, 1);
    float4 cpos = mul(pos, ViewProj);
    cpos.z = DepthFunc(cpos.zw);
    return cpos;
}
float3 NormalTransform(float3 inorm)
{
    float3 tnorm = inorm;
    float3 bnorm = normalize(mulvq(tnorm, Orientation));
    return bnorm;
}

float2 GetWaterTexcoords(float2 tc)
{
    if (ShaderMode == 1)
    {
        return tc + float2(ScaledTime * RippleSpeed, 0);
    }
    else
    {
        return tc;
    }
}

float4 GetWaterFlow(float2 tc, float4 vc)
{
    float4 f = float4(vc.g, 0, 0.02, 0.03);
    if (EnableFlow)
    {
        float4 fv = FlowSampler.SampleLevel(TextureSS, tc, 0);
        f.zw = fv.xy * 2 - 1;
        f.x = vc.g;
        f.y = 0;
        //sample_l r0.xyzw, v2.xyxx, t2.xyzw, s2, l(0.000000)
        //mad o5.zw, r0.xxxy, l(0.000000, 0.000000, 2.000000, 2.000000), l(0.000000, 0.000000, -1.000000, -1.000000)
        //mov o5.x, v1.y
        //mov o5.y, l(0)
    }
    return f;
}

/*
water_terrainfoam.fxc_VSFoam

//
// Generated by Microsoft (R) HLSL Shader Compiler 9.29.952.3111
//
//
// Buffer Definitions: 
//
// cbuffer rage_matrices
// {
//
//   row_major float4x4 gWorld;         // Offset:    0 Size:    64
//   row_major float4x4 gWorldView;     // Offset:   64 Size:    64 [unused]
//   row_major float4x4 gWorldViewProj; // Offset:  128 Size:    64
//   row_major float4x4 gViewInverse;   // Offset:  192 Size:    64 [unused]
//
// }
//
// cbuffer water_globals
// {
//
//   float2 gWorldBaseVS;               // Offset:    0 Size:     8
//   float4 gFlowParams;                // Offset:   16 Size:    16 [unused]
//   float4 gFlowParams2;               // Offset:   32 Size:    16 [unused]
//   float4 gWaterAmbientColor;         // Offset:   48 Size:    16 [unused]
//   float4 gWaterDirectionalColor;     // Offset:   64 Size:    16 [unused]
//   float4 gScaledTime;                // Offset:   80 Size:    16 [unused]
//   float4 gOceanParams0;              // Offset:   96 Size:    16 [unused]
//   float4 gOceanParams1;              // Offset:  112 Size:    16 [unused]
//   row_major float4x4 gReflectionWorldViewProj;// Offset:  128 Size:    64 [unused]
//   float4 gFogLight_Debugging;        // Offset:  192 Size:    16 [unused]
//   row_major float4x4 gRefractionWorldViewProj;// Offset:  208 Size:    64 [unused]
//
// }
//
//
// Resource Bindings:
//
// Name                                 Type  Format         Dim      HLSL Bind  Count
// ------------------------------ ---------- ------- ----------- -------------- ------
// rage_matrices                     cbuffer      NA          NA            cb1      1 
// water_globals                     cbuffer      NA          NA            cb4      1 
//
//
//
// Input signature:
//
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// POSITION                 0   xyz         0     NONE   float   xyz 
// NORMAL                   0   xyz         1     NONE   float   xyz 
// TANGENT                  0   xyz         2     NONE   float   xyz 
// TEXCOORD                 0   xy          3     NONE   float   xy  
// COLOR                    0   xyzw        4     NONE   float      w
//
//
// Output signature:
//
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Position              0   xyzw        0      POS   float   xyzw
// TEXCOORD                 0   xyzw        1     NONE   float   xyzw
// TEXCOORD                 1   xyz         2     NONE   float   xyz 
// TEXCOORD                 2   xyz         3     NONE   float   xyz 
// TEXCOORD                 3   xyz         4     NONE   float   xyz 
// TEXCOORD                 4   xyzw        5     NONE   float   xyzw
//
vs_4_0
dcl_constantbuffer CB1[12], immediateIndexed
dcl_constantbuffer CB4[1], immediateIndexed
dcl_input v0.xyz
dcl_input v1.xyz
dcl_input v2.xyz
dcl_input v3.xy
dcl_input v4.w
dcl_output_siv o0.xyzw, position
dcl_output o1.xyzw
dcl_output o2.xyz
dcl_output o3.xyz
dcl_output o4.xyz
dcl_output o5.xyzw
dcl_temps 1
mul r0.xyzw, v0.yyyy, cb1[9].xyzw
mad r0.xyzw, v0.xxxx, cb1[8].xyzw, r0.xyzw
mad r0.xyzw, v0.zzzz, cb1[10].xyzw, r0.xyzw
add o0.xyzw, r0.xyzw, cb1[11].xyzw
mul r0.xyz, v0.yyyy, cb1[1].xyzx
mad r0.xyz, v0.xxxx, cb1[0].xyzx, r0.xyzx
mad r0.xyz, v0.zzzz, cb1[2].xyzx, r0.xyzx
add r0.xyz, r0.xyzx, cb1[3].xyzx
mov o1.xyz, r0.xyzx
add r0.xy, r0.xyxx, -cb4[0].xyxx
mul o5.zw, r0.xxxy, l(0.000000, 0.000000, 0.001953, 0.001953)
mov o1.w, v4.w
mov o2.xyz, v1.xyzx
mov o3.xyz, v2.xyzx
mul r0.xyz, v1.zxyz, v2.yzxy
mad r0.xyz, v1.yzxy, v2.zxyz, -r0.xyzx
dp3 r0.w, r0.xyzx, r0.xyzx
rsq r0.w, r0.w
mul o4.xyz, r0.wwww, r0.xyzx
mov o5.xy, v3.xyxx
ret 
// Approximately 21 instruction slots used

*/

/*
water_riverfoam.fxc_VS

vs_4_0
dcl_constantbuffer CB1[12], immediateIndexed
dcl_constantbuffer CB2[13], immediateIndexed
dcl_constantbuffer CB3[47], immediateIndexed
dcl_constantbuffer CB4[6], immediateIndexed
dcl_constantbuffer CB10[1], immediateIndexed
dcl_input v0.xyz
dcl_input v1.y
dcl_input v2.xy
dcl_input v3.xyz
dcl_output_siv o0.xyzw, position
dcl_output o1.xyzw
dcl_output o2.xyzw
dcl_output o3.xy
dcl_output o4.xyz
dcl_output o5.xyz
dcl_temps 2
mul r0.xyzw, v0.yyyy, gWorldViewProj[1].xyzw
mad r0.xyzw, v0.xxxx, gWorldViewProj[0].xyzw, r0.xyzw
mad r0.xyzw, v0.zzzz, gWorldViewProj[2].xyzw, r0.xyzw
add r0.xyzw, r0.xyzw, gWorldViewProj[3].xyzw
mul r1.xyzw, r0.xyzw, l(1.000000, 1.000000, 0.999995, 1.000000)
mov o0.xyzw, r1.xyzw
mov o2.zw, r1.wwww
add o1.xyz, v0.xyzx, gWorld[3].xyzx
mov o1.w, v1.y
mul r0.xyz, r0.xwyx, l(0.500000, 0.500000, 0.500000, 0.000000)
mad o2.y, r0.w, l(0.500000), -r0.z
add o2.x, r0.y, r0.x

mul r0.x, gScaledTime.x, RippleSpeed
mov r0.y, l(0)
add o3.xy, r0.xyxx, v2.xyxx     ///TEXCOORD OUT

add r0.x, v3.z, gLightNaturalAmbient0.w
mul r0.x, r0.x, gLightNaturalAmbient1.w
max r0.x, r0.x, l(0.000000)
mad r0.yzw, gLightArtificialIntAmbient0.xxyz, r0.xxxx, gLightArtificialIntAmbient1.xxyz
mad r1.xyz, gLightNaturalAmbient0.xyzx, r0.xxxx, gLightNaturalAmbient1.xyzx
mad o4.xyz, r0.yzwy, globalScalars2.zzzz, r1.xyzx
dp3_sat r0.x, v3.xyzx, -gDirectionalLight.xyzx
mul o5.xyz, r0.xxxx, gDirectionalColour.xyzx

ret 
// Approximately 24 instruction slots used

//
// cbuffer water_globals
// {
//
//   float2 gWorldBaseVS;               // Offset:    0 Size:     8 [unused]
//   float4 gFlowParams;                // Offset:   16 Size:    16 [unused]
//   float4 gFlowParams2;               // Offset:   32 Size:    16 [unused]
//   float4 gWaterAmbientColor;         // Offset:   48 Size:    16 [unused]
//   float4 gWaterDirectionalColor;     // Offset:   64 Size:    16 [unused]
//   float4 gScaledTime;                // Offset:   80 Size:    16
//   float4 gOceanParams0;              // Offset:   96 Size:    16 [unused]
//   float4 gOceanParams1;              // Offset:  112 Size:    16 [unused]
//   row_major float4x4 gReflectionWorldViewProj;// Offset:  128 Size:    64 [unused]
//   float4 gFogLight_Debugging;        // Offset:  192 Size:    16 [unused]
//   row_major float4x4 gRefractionWorldViewProj;// Offset:  208 Size:    64 [unused]
//
// }
//
// cbuffer water_common_locals
// {
//
//   float RippleBumpiness;             // Offset:    0 Size:     4 [unused]
//   float RippleSpeed;                 // Offset:    4 Size:     4
//   float RippleScale;                 // Offset:    8 Size:     4 [unused]
//   float SpecularIntensity;           // Offset:   12 Size:     4 [unused]
//   float SpecularFalloff;             // Offset:   16 Size:     4 [unused]
//   float ParallaxIntensity;           // Offset:   20 Size:     4 [unused]
//
// }
//
//
// Resource Bindings:
//
// Name                                 Type  Format         Dim      HLSL Bind  Count
// ------------------------------ ---------- ------- ----------- -------------- ------
// rage_matrices                     cbuffer      NA          NA            cb1      1 
// misc_globals                      cbuffer      NA          NA            cb2      1 
// lighting_globals                  cbuffer      NA          NA            cb3      1 
// water_globals                     cbuffer      NA          NA            cb4      1 
// water_common_locals               cbuffer      NA          NA           cb10      1 
//
//
//
// Input signature:
//
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// POSITION                 0   xyz         0     NONE   float   xyz 
// COLOR                    0   xyzw        1     NONE   float    y  
// TEXCOORD                 0   xy          2     NONE   float   xy  
// NORMAL                   0   xyz         3     NONE   float   xyz 
// TANGENT                  0   xyz         4     NONE   float       
//
//
// Output signature:
//
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Position              0   xyzw        0      POS   float   xyzw
// TEXCOORD                 0   xyzw        1     NONE   float   xyzw
// TEXCOORD                 1   xyzw        2     NONE   float   xyzw
// TEXCOORD                 2   xy          3     NONE   float   xy  
// TEXCOORD                 3   xyz         4     NONE   float   xyz 
// TEXCOORD                 4   xyz         5     NONE   float   xyz 
//

*/

/*
water_river.fxc_VS

//
// Generated by Microsoft (R) HLSL Shader Compiler 9.29.952.3111
//
//
// Buffer Definitions: 
//
// cbuffer rage_matrices
// {
//
//   row_major float4x4 gWorld;         // Offset:    0 Size:    64
//   row_major float4x4 gWorldView;     // Offset:   64 Size:    64 [unused]
//   row_major float4x4 gWorldViewProj; // Offset:  128 Size:    64
//   row_major float4x4 gViewInverse;   // Offset:  192 Size:    64 [unused]
//
// }
//
// cbuffer water_globals
// {
//
//   float2 gWorldBaseVS;               // Offset:    0 Size:     8
//   float4 gFlowParams;                // Offset:   16 Size:    16 [unused]
//   float4 gFlowParams2;               // Offset:   32 Size:    16 [unused]
//   float4 gWaterAmbientColor;         // Offset:   48 Size:    16
//   float4 gWaterDirectionalColor;     // Offset:   64 Size:    16 [unused]
//   float4 gScaledTime;                // Offset:   80 Size:    16 [unused]
//   float4 gOceanParams0;              // Offset:   96 Size:    16 [unused]
//   float4 gOceanParams1;              // Offset:  112 Size:    16 [unused]
//   row_major float4x4 gReflectionWorldViewProj;// Offset:  128 Size:    64 [unused]
//   float4 gFogLight_Debugging;        // Offset:  192 Size:    16 [unused]
//   row_major float4x4 gRefractionWorldViewProj;// Offset:  208 Size:    64 [unused]
//
// }
//
//
// Resource Bindings:
//
// Name                                 Type  Format         Dim      HLSL Bind  Count
// ------------------------------ ---------- ------- ----------- -------------- ------
// FlowSampler                       sampler      NA          NA             s2      1 
// FlowSampler                       texture  float4          2d             t2      1 
// rage_matrices                     cbuffer      NA          NA            cb1      1 
// water_globals                     cbuffer      NA          NA            cb4      1 
//
//
//
// Input signature:
//
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// POSITION                 0   xyz         0     NONE   float   xyz 
// COLOR                    0   xyzw        1     NONE   float   xy  
// TEXCOORD                 0   xy          2     NONE   float   xy  
// NORMAL                   0   xyz         3     NONE   float   xyz 
//
//
// Output signature:
//
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Position              0   xyzw        0      POS   float   xyzw
// TEXCOORD                 0   xyzw        1     NONE   float   xyzw
// TEXCOORD                 1   xyzw        2     NONE   float   xyzw
// TEXCOORD                 2   xyzw        3     NONE   float   xyzw
// TEXCOORD                 3   xyzw        4     NONE   float   xyzw
// TEXCOORD                 4   xyzw        5     NONE   float   xyzw
//
vs_4_0
dcl_constantbuffer CB1[12], immediateIndexed
dcl_constantbuffer CB4[4], immediateIndexed
dcl_sampler s2, mode_default
dcl_resource_texture2d (float,float,float,float) t2
dcl_input v0.xyz
dcl_input v1.xy
dcl_input v2.xy
dcl_input v3.xyz
dcl_output_siv o0.xyzw, position
dcl_output o1.xyzw
dcl_output o2.xyzw
dcl_output o3.xyzw
dcl_output o4.xyzw
dcl_output o5.xyzw
dcl_temps 2
mul r0.xyzw, v0.yyyy, cb1[9].xyzw
mad r0.xyzw, v0.xxxx, cb1[8].xyzw, r0.xyzw
mad r0.xyzw, v0.zzzz, cb1[10].xyzw, r0.xyzw
add r0.xyzw, r0.xyzw, cb1[11].xyzw
mov o0.xyzw, r0.xyzw
mul r0.xyz, r0.xwyx, l(0.500000, 0.500000, 0.500000, 0.000000)
mad o1.y, r0.w, l(0.500000), -r0.z
add o1.x, r0.y, r0.x
mov o4.w, r0.w
add r0.xyz, v0.xyzx, cb1[3].xyzx
add r1.xy, r0.xyxx, -cb4[0].xyxx
mad o1.zw, r1.xxxy, l(0.000000, 0.000000, 0.001953, 0.001953), l(0.000000, 0.000000, 0.001953, 0.001953)
mov o2.xyz, r0.xyzx
mul o3.zw, r0.xxxy, cb4[3].wwww
mov o2.w, v1.x
mov o3.xy, v2.xyxx
dp3 r0.x, v3.xyzx, v3.xyzx
rsq r0.x, r0.x
mul o4.xyz, r0.xxxx, v3.xyzx
sample_l r0.xyzw, v2.xyxx, t2.xyzw, s2, l(0.000000)
mad o5.zw, r0.xxxy, l(0.000000, 0.000000, 2.000000, 2.000000), l(0.000000, 0.000000, -1.000000, -1.000000)
mov o5.x, v1.y
mov o5.y, l(0)
ret 
// Approximately 24 instruction slots used

*/

