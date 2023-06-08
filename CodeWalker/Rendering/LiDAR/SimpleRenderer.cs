using CodeWalker.GameFiles;
using CodeWalker.World;
using SharpDX;
using SharpDX.Direct3D11;
using System.Linq;
using Quaternion = SharpDX.Quaternion;

namespace CodeWalker.Rendering.LiDAR
{
    public static class SimpleRenderer
    {
        private static readonly uint HASH_SKYDOME = 2640562617;
        private static readonly uint HASH_STARFIELD = 1064311147;
        private static readonly uint HASH_MOON = 234339206;

        public static void RenderSky (
            DeviceContext context, 
            Camera camera, 
            ShaderManager shaderManager, 
            GameFileCache gameFileCache, 
            RenderableCache renderableCache, 
            Weather weather, 
            ShaderGlobalLights globalLights)
        {
            SkydomeShader skydomeShader = shaderManager.Skydome;
            skydomeShader.UpdateSkyLocals(weather, globalLights);

            YddFile ydd = gameFileCache.GetYdd(HASH_SKYDOME);
            DrawableBase skydome = null;
            if (ydd != null && ydd.Loaded && ydd.Dict != null)
            {
                skydome = ydd.Dict.Values.FirstOrDefault();
            }

            Texture starfieldTexture = null;
            Texture moonTexture = null;
            YtdFile skydomeYtd = gameFileCache.GetYtd(HASH_SKYDOME);
            if ((skydomeYtd != null) && (skydomeYtd.Loaded) && (skydomeYtd.TextureDict != null) && (skydomeYtd.TextureDict.Dict != null))
            {
                skydomeYtd.TextureDict.Dict.TryGetValue(HASH_STARFIELD, out starfieldTexture);
                skydomeYtd.TextureDict.Dict.TryGetValue(HASH_MOON, out moonTexture);
            }

            Renderable skydomeRenderable = null;
            if (skydome != null) skydomeRenderable = renderableCache.GetRenderable(skydome);

            RenderableTexture starfieldRenderableTexture = null;
            if (starfieldTexture != null) starfieldRenderableTexture = renderableCache.GetRenderableTexture(starfieldTexture);

            RenderableTexture moonRenderableTexture = null;
            if (moonTexture != null) moonRenderableTexture = renderableCache.GetRenderableTexture(moonTexture);

            if ((skydomeRenderable != null) && (skydomeRenderable.IsLoaded) && (starfieldRenderableTexture != null) && (starfieldRenderableTexture.IsLoaded))
            {
                shaderManager.SetDepthStencilMode(context, DepthStencilMode.DisableAll);
                shaderManager.SetRasterizerMode(context, RasterizerMode.Solid);

                RenderableInst renderableInstance = new RenderableInst();
                renderableInstance.Position = Vector3.Zero;
                renderableInstance.CamRel = Vector3.Zero;
                renderableInstance.Distance = 0.0f;
                renderableInstance.BBMin = skydome.BoundingBoxMin;
                renderableInstance.BBMax = skydome.BoundingBoxMax;
                renderableInstance.BSCenter = Vector3.Zero;
                renderableInstance.Radius = skydome.BoundingSphereRadius;
                renderableInstance.Orientation = Quaternion.Identity;
                renderableInstance.Scale = Vector3.One;
                renderableInstance.TintPaletteIndex = 0;
                renderableInstance.CastShadow = false;
                renderableInstance.Renderable = skydomeRenderable;
                skydomeShader.SetShader(context);
                skydomeShader.SetInputLayout(context, VertexType.PTT);
                skydomeShader.SetSceneVars(context, camera, null, globalLights);
                skydomeShader.SetEntityVars(context, ref renderableInstance);

                RenderableModel renderableModel = ((skydomeRenderable.HDModels != null) && (skydomeRenderable.HDModels.Length > 0)) ? skydomeRenderable.HDModels[0] : null;
                RenderableGeometry renderableGeometry = ((renderableModel != null) && (renderableModel.Geometries != null) && (renderableModel.Geometries.Length > 0)) ? renderableModel.Geometries[0] : null;

                if (renderableGeometry != null && renderableGeometry.VertexType == VertexType.PTT)
                {
                    skydomeShader.SetModelVars(context, renderableModel);
                    skydomeShader.SetTextures(context, starfieldRenderableTexture);

                    renderableGeometry.Render(context);
                }

                skydomeShader.RenderSun(context, camera, weather, globalLights);
                if (moonRenderableTexture != null && moonRenderableTexture.IsLoaded)
                {
                    skydomeShader.RenderMoon(context, camera, weather, globalLights, moonRenderableTexture);
                }
                skydomeShader.UnbindResources(context);
            }
        }
    }
}
