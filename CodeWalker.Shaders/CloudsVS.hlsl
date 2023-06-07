#include "Common.hlsli"
#include "Quaternion.hlsli"
#include "Clouds.hlsli"

cbuffer VSSceneVars : register(b1)
{
    float4x4 ViewProj;
    float4x4 ViewInv;
}
cbuffer VSEntityVars : register(b2)
{
    float4 CamRel;
    float4 Orientation;
    float4 Scale;
}
cbuffer VSModelVars : register(b3)
{
    float4x4 Transform;
}

struct VS_INPUT
{
    float4 Position  : POSITION;
    float3 Normal    : NORMAL;
    float2 Texcoord0 : TEXCOORD0;
    float4 Colour0   : COLOR0;
    float4 Tangent   : TANGENT;
};

struct VS_OUTPUT
{
    float4 Position : SV_POSITION; //         0   xyzw        0      POS   float   xyzw
    float4 o0 : TEXCOORD0; //                 0   xyzw        0     NONE   float       
    float4 o1 : TEXCOORD1; //                 1   xyzw        1     NONE   float   xyzw
    float4 o2 : TEXCOORD2; //                 2   xyzw        2     NONE   float   xyzw
    float4 o3 : TEXCOORD3; //                 3   xyzw        3     NONE   float   xyzw
    float2 o4 : TEXCOORD4; //                 4   xy          4     NONE   float   xy  
    float4 o5 : TEXCOORD5; //                 5   xyzw        5     NONE   float   xyzw
    float4 o6 : TEXCOORD6; //                 6   xyzw        6     NONE   float   xy w
    float4 o7 : TEXCOORD7; //                 7   xyzw        7     NONE   float   xyzw
    float3 o8 : TEXCOORD8; //                 8   xyz         8     NONE   float   xyz 
    float4 o9 : TEXCOORD9; //                 9   xyzw        9     NONE   float   xyzw
};

VS_OUTPUT main(VS_INPUT input)
{
    VS_OUTPUT output;

    float3 spos = input.Position.xyz * Scale.xyz*0.05;
    float3 bpos = mulvq(spos, Orientation);
    float3 opos = CamRel.xyz + bpos;
    float4 cpos = mul(float4(opos, 1), ViewProj);

    float3 tnorm = input.Normal;
    float3 bnorm = normalize(mulvq(tnorm, Orientation));

    float4 vc = input.Colour0;
    float2 tc = input.Texcoord0;

    float2 o4xy = (gUVOffset[0].xy * cloudLayerAnimScale1) + (tc * gRescaleUV1) + gUVOffset1;
    float2 o5xy = (gUVOffset[0].zw * cloudLayerAnimScale2) + (tc * gRescaleUV2) + gUVOffset2;
    float2 o5zw = (gUVOffset[1].xy * cloudLayerAnimScale3) + (tc * gRescaleUV3) + gUVOffset3;

    output.Position = cpos;
    output.o0 = 0;
    output.o1 = float4(bnorm, vc.w);
    output.o2 = float4(0, 0, 0, vc.y);
    output.o3 = float4(0, 0, 0, vc.z);
    output.o4 = o4xy;
    output.o5 = float4(o5xy, o5zw);
    output.o6 = 0;
    output.o7 = 0;
    output.o8 = 0;
    output.o9 = 0;

	return output;
}

/*
//clouds_animsoft.fxc_VSCloudsVertScatterPiercing

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
// cbuffer rage_clipplanes
// {
//
//   float4 ClipPlanes;                 // Offset:    0 Size:    16
//
// }
//
// cbuffer lighting_globals
// {
//
//   float4 gDirectionalLight;          // Offset:    0 Size:    16 [unused]
//   float4 gDirectionalColour;         // Offset:   16 Size:    16 [unused]
//   int gNumForwardLights;             // Offset:   32 Size:     4 [unused]
//   float4 gLightPositionAndInvDistSqr[8];// Offset:   48 Size:   128 [unused]
//   float4 gLightDirectionAndFalloffExponent[8];// Offset:  176 Size:   128 [unused]
//   float4 gLightColourAndCapsuleExtent[8];// Offset:  304 Size:   128 [unused]
//   float gLightConeScale[8];          // Offset:  432 Size:   116 [unused]
//   float gLightConeOffset[8];         // Offset:  560 Size:   116 [unused]
//   float4 gLightNaturalAmbient0;      // Offset:  688 Size:    16 [unused]
//   float4 gLightNaturalAmbient1;      // Offset:  704 Size:    16 [unused]
//   float4 gLightArtificialIntAmbient0;// Offset:  720 Size:    16 [unused]
//   float4 gLightArtificialIntAmbient1;// Offset:  736 Size:    16 [unused]
//   float4 gLightArtificialExtAmbient0;// Offset:  752 Size:    16 [unused]
//   float4 gLightArtificialExtAmbient1;// Offset:  768 Size:    16 [unused]
//   float4 gDirectionalAmbientColour;  // Offset:  784 Size:    16 [unused]
//   float4 globalFogParams[5];         // Offset:  800 Size:    80
//   float4 globalFogColor;             // Offset:  880 Size:    16
//   float4 globalFogColorE;            // Offset:  896 Size:    16
//   float4 globalFogColorN;            // Offset:  912 Size:    16
//   float4 globalFogColorMoon;         // Offset:  928 Size:    16
//   float4 gReflectionTweaks;          // Offset:  944 Size:    16 [unused]
//
// }
//
// cbuffer clouds_locals
// {
//
//   float3 gSkyColor;                  // Offset:    0 Size:    12 [unused]
//   float3 gEastMinusWestColor;        // Offset:   16 Size:    12 [unused]
//   float3 gWestColor;                 // Offset:   32 Size:    12 [unused]
//   float3 gSunDirection;              // Offset:   48 Size:    12
//   float3 gSunColor;                  // Offset:   64 Size:    12
//   float3 gCloudColor;                // Offset:   80 Size:    12 [unused]
//   float3 gAmbientColor;              // Offset:   96 Size:    12 [unused]
//   float3 gBounceColor;               // Offset:  112 Size:    12 [unused]
//   float4 gDensityShiftScale;         // Offset:  128 Size:    16 [unused]
//   float4 gScatterG_GSquared_PhaseMult_Scale;// Offset:  144 Size:    16
//   float4 gPiercingLightPower_Strength_NormalStrength_Thickness;// Offset:  160 Size:    16
//   float3 gScaleDiffuseFillAmbient;   // Offset:  176 Size:    12 [unused]
//   float3 gWrapLighting_MSAARef;      // Offset:  192 Size:    12 [unused]
//   float4 gNearFarQMult;              // Offset:  208 Size:    16 [unused]
//   float3 gAnimCombine;               // Offset:  224 Size:    12 [unused]
//   float3 gAnimSculpt;                // Offset:  240 Size:    12 [unused]
//   float3 gAnimBlendWeights;          // Offset:  256 Size:    12 [unused]
//   float4 gUVOffset[2];               // Offset:  272 Size:    32
//   row_major float4x4 gCloudViewProj; // Offset:  304 Size:    64
//   float4 gCameraPos;                 // Offset:  368 Size:    16
//   float2 gUVOffset1;                 // Offset:  384 Size:     8
//   float2 gUVOffset2;                 // Offset:  392 Size:     8
//   float2 gUVOffset3;                 // Offset:  400 Size:     8
//   float2 gRescaleUV1;                // Offset:  408 Size:     8
//   float2 gRescaleUV2;                // Offset:  416 Size:     8
//   float2 gRescaleUV3;                // Offset:  424 Size:     8
//   float gSoftParticleRange;          // Offset:  432 Size:     4 [unused]
//   float gEnvMapAlphaScale;           // Offset:  436 Size:     4 [unused]
//   float2 cloudLayerAnimScale1;       // Offset:  440 Size:     8
//   float2 cloudLayerAnimScale2;       // Offset:  448 Size:     8
//   float2 cloudLayerAnimScale3;       // Offset:  456 Size:     8
//
// }
//
//
// Resource Bindings:
//
// Name                                 Type  Format         Dim      HLSL Bind  Count
// ------------------------------ ---------- ------- ----------- -------------- ------
// rage_clipplanes                   cbuffer      NA          NA            cb0      1 
// rage_matrices                     cbuffer      NA          NA            cb1      1 
// lighting_globals                  cbuffer      NA          NA            cb3      1 
// clouds_locals                     cbuffer      NA          NA           cb12      1 
//
//
//
// Input signature:
//
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// POSITION                 0   xyzw        0     NONE   float   xyzw
// COLOR                    0   xyzw        1     NONE   float   xyzw
// NORMAL                   0   xyz         2     NONE   float   xyz 
// TEXCOORD                 0   xy          3     NONE   float   xy  
// TANGENT                  0   xyzw        4     NONE   float   xyzw
//
//
// Output signature:
//
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// TEXCOORD                 0   xyzw        0     NONE   float   xyzw
// TEXCOORD                 1   xyzw        1     NONE   float   xyzw
// TEXCOORD                 2   xyzw        2     NONE   float   xyzw
// TEXCOORD                 3   xyzw        3     NONE   float   xyzw
// TEXCOORD                 4   xy          4     NONE   float   xy  
// TEXCOORD                 5   xyzw        5     NONE   float   xyzw
// TEXCOORD                 6   xyzw        6     NONE   float   xyzw
// TEXCOORD                 7   xyzw        7     NONE   float   xyzw
// TEXCOORD                 8   xyz         8     NONE   float   xyz 
// TEXCOORD                 9   xyzw        9     NONE   float   xyzw
// SV_Position              0   xyzw       10      POS   float   xyzw
// SV_ClipDistance          0   xyzw       11  CLIPDST   float   xyzw
//
vs_4_0
dcl_constantbuffer CB1[12], immediateIndexed
dcl_constantbuffer CB0[1], immediateIndexed
dcl_constantbuffer CB3[59], immediateIndexed
dcl_constantbuffer CB12[29], immediateIndexed
dcl_input v0.xyzw
dcl_input v1.xyzw
dcl_input v2.xyz
dcl_input v3.xy
dcl_input v4.xyzw
dcl_output o0.xyzw
dcl_output o1.xyzw
dcl_output o2.xyzw
dcl_output o3.xyzw
dcl_output o4.xy
dcl_output o5.xyzw
dcl_output o6.xyzw
dcl_output o7.xyzw
dcl_output o8.xyz
dcl_output o9.xyzw
dcl_output_siv o10.xyzw, position
dcl_output_siv o11.xyzw, clip_distance
dcl_temps 5
mul r0.xyz, v0.yyyy, gWorld[1].xyzx
mad r0.xyz, v0.xxxx, gWorld[0].xyzx, r0.xyzx
mad r0.xyz, v0.zzzz, gWorld[2].xyzx, r0.xyzx
mad r0.xyz, v0.wwww, gWorld[3].xyzx, r0.xyzx
dp3 r0.w, r0.xyzx, r0.xyzx
sqrt r1.w, r0.w
rsq r0.w, r0.w
mul r2.xyz, r0.wwww, r0.xyzx
div r1.xyz, r0.xyzx, r1.wwww
mov o0.xyzw, r1.xyzw

mul r3.xyz, v2.yyyy, gWorld[1].xyzx
mad r3.xyz, v2.xxxx, gWorld[0].xyzx, r3.xyzx
mad r3.xyz, v2.zzzz, gWorld[2].xyzx, r3.xyzx
dp3 r0.w, r3.xyzx, r3.xyzx
rsq r0.w, r0.w
mul o1.xyz, r0.wwww, r3.xyzx
mov o1.w, v1.w

mul r3.xyz, v4.yyyy, gWorld[1].xyzx
mad r3.xyz, v4.xxxx, gWorld[0].xyzx, r3.xyzx
mad r3.xyz, v4.zzzz, gWorld[2].xyzx, r3.xyzx
dp3 r0.w, r3.xyzx, r3.xyzx
rsq r0.w, r0.w
mul o2.xyz, r0.wwww, r3.xyzx
mov o2.w, v1.y

mul r3.xyz, v2.yzxy, v4.zxyz
mad r3.xyz, v4.yzxy, v2.zxyz, -r3.xyzx
mul r3.xyz, r3.xyzx, v4.wwww
mul r4.xyz, r3.yyyy, gWorld[1].xyzx
mad r3.xyw, r3.xxxx, gWorld[0].xyxz, r4.xyxz
mad r3.xyz, r3.zzzz, gWorld[2].xyzx, r3.xywx
dp3 r0.w, r3.xyzx, r3.xyzx
rsq r0.w, r0.w
mul o3.xyz, r0.wwww, r3.xyzx
mov o3.w, v1.z

mad r3.xy, v3.xyxx, gRescaleUV1.xyxx, gUVOffset1.xyxx
mad o4.xy, gUVOffset[0].xyxx, cloudLayerAnimScale1.xyxx, r3.xyxx

mad r3.xy, v3.xyxx, gRescaleUV2.xyxx, gUVOffset2.xyxx
mad o5.xy, gUVOffset[0].zwzz, cloudLayerAnimScale2.xyxx, r3.xyxx

mad r3.xy, v3.xyxx, gRescaleUV3.xyxx, gUVOffset3.xyxx
mad o5.zw, gUVOffset[1].xxxy, cloudLayerAnimScale3.xxxy, r3.xxxy

mul r3.xyzw, r0.yyyy, gCloudViewProj[1].xyzw
mad r3.xyzw, r0.xxxx, gCloudViewProj[0].xyzw, r3.xyzw
mad r3.xyzw, r0.zzzz, gCloudViewProj[2].xyzw, r3.xyzw
add r3.xyzw, r3.xyzw, gCloudViewProj[3].xyzw
mul r0.xyw, r3.xwxy, l(0.500000, 0.500000, 0.000000, 0.500000)
mad o6.y, r3.w, l(0.500000), -r0.w
add o6.x, r0.y, r0.x
mov o6.zw, r3.wwww

dp3 r0.x, -r1.xyzx, gSunDirection.xyzx
mad r0.xyw, -r0.xxxx, gSunDirection.xyxz, -r1.xyxz
dp3 r1.x, r1.xyzx, gSunDirection.xyzx
dp3 r1.y, r0.xywx, r0.xywx
rsq r1.y, r1.y
mul o7.xyz, r0.xywx, r1.yyyy

mov_sat r0.x, r1.x
log r0.x, r0.x
mul r0.x, r0.x, gPiercingLightPower_Strength_NormalStrength_Thickness.x
exp o7.w, r0.x

dp2 r0.x, r1.xxxx, gScatterG_GSquared_PhaseMult_Scale.xxxx
mad r0.y, r1.x, r1.x, l(1.000000)
add r0.w, gScatterG_GSquared_PhaseMult_Scale.y, l(1.000000)
add r0.x, -r0.x, r0.w
log r0.x, |r0.x|
mul r0.x, r0.x, l(1.500000)
exp r0.x, r0.x
div r0.x, r0.y, r0.x
mul r0.x, r0.x, gScatterG_GSquared_PhaseMult_Scale.z
mul r0.xyw, r0.xxxx, gSunColor.xyxz
mul o8.xyz, r0.xywx, gScatterG_GSquared_PhaseMult_Scale.wwww

dp3_sat r0.x, r2.xyzx, globalFogParams[3].xyzx
dp3_sat r0.y, r2.xyzx, globalFogParams[4].xyzx
log r0.y, r0.y
mul r0.y, r0.y, globalFogParams[4].w
exp r0.y, r0.y
log r0.x, r0.x
mul r0.x, r0.x, globalFogParams[3].w
exp r0.x, r0.x
add r1.xyz, -globalFogColorE.xyzx, globalFogColorMoon.xyzx
mad r1.xyz, r0.yyyy, r1.xyzx, globalFogColorE.xyzx
add r2.xyz, -r1.xyzx, globalFogColor.xyzx
mad r0.xyw, r0.xxxx, r2.xyxz, r1.xyxz
add r0.xyw, r0.xyxw, -globalFogColorN.xyxz
add r1.x, r1.w, -globalFogParams[0].x
max r1.x, r1.x, l(0.000000)
mul r1.y, r1.x, -globalFogParams[1].z
mul r1.y, r1.y, l(1.442695)
exp r1.y, r1.y
add r1.y, -r1.y, l(1.000000)
mad r0.xyw, r1.yyyy, r0.xyxw, globalFogColorN.xyxz
div r1.y, r1.x, r1.w
mul r1.x, r1.x, globalFogParams[1].w
mul r0.z, r0.z, r1.y
lt r1.y, l(0.010000), |r0.z|
mul r0.z, r0.z, globalFogParams[2].z
mul r1.z, r0.z, l(-1.442695)
exp r1.z, r1.z
add r1.z, -r1.z, l(1.000000)
div r0.z, r1.z, r0.z
movc r0.z, r1.y, r0.z, l(1.000000)
mul r0.z, r0.z, r1.x
min r0.z, r0.z, l(1.000000)
mul r0.z, r0.z, l(1.442695)
exp r0.z, r0.z
min r0.z, r0.z, l(1.000000)
add r0.z, -r0.z, l(1.000000)
mul_sat r0.z, r0.z, globalFogParams[2].y
add r1.x, -v1.x, l(1.000000)
max r0.z, r0.z, r1.x
mul r0.xyw, r0.zzzz, r0.xyxw
add r0.z, -r0.z, l(1.000000)
mul r1.y, r1.x, globalFogParams[2].w
mad r1.x, -r1.x, globalFogParams[2].w, l(1.000000)
mul r2.x, r1.y, globalFogColor.w
mul r2.y, r1.y, globalFogColorE.w
mul r2.z, r1.y, globalFogColorN.w
mad o9.xyz, r0.xywx, r1.xxxx, r2.xyzx
mul o9.w, r0.z, r1.x

lt r0.x, r3.z, l(0.000000)
div r0.y, l(0.100000), r3.w
movc r0.x, r0.x, r0.y, r3.z
lt r0.y, r3.w, r3.z
add r0.z, r3.w, l(-0.100000)
movc r0.y, r0.y, r0.z, r3.z
ne r0.z, l(0.000000, 0.000000, 0.000000, 0.000000), gCameraPos.w
movc r0.x, r0.z, r0.x, r0.y
lt r0.y, l(0.000000), r3.w
movc o10.z, r0.y, r0.x, r3.z
mov o10.xyw, r3.xyxw

mul r0.xyzw, v0.yyyy, gWorldViewProj[1].xyzw
mad r0.xyzw, v0.xxxx, gWorldViewProj[0].xyzw, r0.xyzw
mad r0.xyzw, v0.zzzz, gWorldViewProj[2].xyzw, r0.xyzw
add r0.xyzw, r0.xyzw, gWorldViewProj[3].xyzw
dp4 o11.x, r0.xyzw, ClipPlanes.xyzw
mov o11.yzw, l(0,0,0,0)

ret 
// Approximately 135 instruction slots used

*/