using CodeWalker.GameFiles;
using CodeWalker.World;
using SharpDX;
using SharpDX.Direct3D;
using SharpDX.Direct3D11;
using SharpDX.DXGI;
using Device = SharpDX.Direct3D11.Device;
using MapFlags = SharpDX.Direct3D11.MapFlags;

namespace CodeWalker.Rendering.LiDAR
{
    public class CubemapRenderer
    {
        public static void RenderCubemap(ShaderManager shaderManager, GameFileCache gameFileCache, RenderableCache renderableCache, Weather weather, ShaderGlobalLights globalLights)
        {
            int width = 1024;
            int height = 1024;

            Device device = new Device(DriverType.Hardware, DeviceCreationFlags.Debug);
            device.DebugName = "cubemap-device";
            DeviceContext context = device.ImmediateContext;
            context.DebugName = "cubemap-context";

            var textureDesc = new Texture2DDescription()
            {
                Width = width,
                Height = height,
                ArraySize = 1,
                BindFlags = BindFlags.RenderTarget,
                Usage = ResourceUsage.Default,
                CpuAccessFlags = CpuAccessFlags.None,
                Format = Format.R8G8B8A8_UNorm,
                MipLevels = 1,
                OptionFlags = ResourceOptionFlags.None,
                SampleDescription = new SampleDescription(1, 0),
            };
            Texture2D texture = new Texture2D(device, textureDesc);

            var depthStencilDesc = new Texture2DDescription
            {
                Width = width,
                Height = height,
                ArraySize = 1,
                BindFlags = BindFlags.DepthStencil,
                Usage = ResourceUsage.Default,
                CpuAccessFlags = CpuAccessFlags.None,
                Format = Format.D32_Float,
                MipLevels = 1,
                OptionFlags = ResourceOptionFlags.None,
                SampleDescription = new SampleDescription(1, 0)
            };
            var depthStencilBuffer = new Texture2D(device, depthStencilDesc);

            RenderTargetView renderTargetView = new RenderTargetView(device, texture);
            DepthStencilView depthStencilView = new DepthStencilView(device, depthStencilBuffer);

            context.OutputMerger.SetRenderTargets(depthStencilView, renderTargetView);
            context.Rasterizer.SetViewport(0, 0, width, height, 0.0f, 1.0f);
            context.ClearRenderTargetView(renderTargetView, Color.CornflowerBlue);
            context.ClearDepthStencilView(depthStencilView, DepthStencilClearFlags.Depth, 0.0f, 0);

            Camera camera = new Camera(0f, 0f, 60f)
            {
                Position = new Vector3(0f, 0f, 0f),
                ViewDirection = new Vector3(0f, 0f, 1f)
            };
            SimpleRenderer.RenderSky(context, camera, shaderManager, gameFileCache, renderableCache, weather, globalLights);

            var textureStagingDesc = new Texture2DDescription
            {
                Width = textureDesc.Width,
                Height = textureDesc.Height,
                ArraySize = textureDesc.ArraySize,
                BindFlags = BindFlags.None,
                Usage = ResourceUsage.Staging,
                CpuAccessFlags = CpuAccessFlags.Read,
                Format = textureDesc.Format,
                MipLevels = textureDesc.MipLevels,
                OptionFlags = textureDesc.OptionFlags,
                SampleDescription = textureDesc.SampleDescription
            };
            using (var textureStaging = new Texture2D(device, textureStagingDesc))
            {
                context.CopyResource(texture, textureStaging);

                var textureData = context.MapSubresource(textureStaging, 0, MapMode.Read, MapFlags.None);
                using (var bitmap = new System.Drawing.Bitmap(textureStagingDesc.Width, textureStagingDesc.Height, System.Drawing.Imaging.PixelFormat.Format32bppArgb))
                {
                    var bitmapData = bitmap.LockBits(
                        new System.Drawing.Rectangle(0, 0, textureStagingDesc.Width, textureStagingDesc.Height),
                        System.Drawing.Imaging.ImageLockMode.WriteOnly,
                        bitmap.PixelFormat);

                    Utilities.CopyMemory(bitmapData.Scan0, textureData.DataPointer, textureData.RowPitch * textureStagingDesc.Height);

                    bitmap.UnlockBits(bitmapData);
                    bitmap.Save("cubemap.png", System.Drawing.Imaging.ImageFormat.Png);
                }
                context.UnmapSubresource(textureStaging, 0);
            }

            renderTargetView.Dispose();
            texture.Dispose();
            context.Dispose();
            device.Dispose();
        }

        public static void Foo()
        {
            var device = new Device(DriverType.Hardware, DeviceCreationFlags.Debug);
            var context = device.ImmediateContext;

            var textureDesc = new Texture2DDescription()
            {
                Width = 512,
                Height = 512,
                ArraySize = 1,
                BindFlags = BindFlags.RenderTarget,
                Usage = ResourceUsage.Default,
                CpuAccessFlags = CpuAccessFlags.None,
                Format = Format.R8G8B8A8_UNorm,
                MipLevels = 1,
                OptionFlags = ResourceOptionFlags.None,
                SampleDescription = new SampleDescription(1, 0)
            };
            var texture = new Texture2D(device, textureDesc);

            var textureRenderTargetView = new RenderTargetView(device, texture);

            context.OutputMerger.SetRenderTargets(textureRenderTargetView);

            context.ClearRenderTargetView(textureRenderTargetView, Color.CornflowerBlue);

            // Render to the texture here...

            var textureStagingDesc = new Texture2DDescription
            {
                Width = textureDesc.Width,
                Height = textureDesc.Height,
                ArraySize = textureDesc.ArraySize,
                BindFlags = BindFlags.None,
                Usage = ResourceUsage.Staging,
                CpuAccessFlags = CpuAccessFlags.Read,
                Format = textureDesc.Format,
                MipLevels = textureDesc.MipLevels,
                OptionFlags = textureDesc.OptionFlags,
                SampleDescription = textureDesc.SampleDescription
            };
            using (var textureStaging = new Texture2D(device, textureStagingDesc))
            {
                context.CopyResource(texture, textureStaging);

                var textureData = context.MapSubresource(textureStaging, 0, MapMode.Read, MapFlags.None);
                using (var bitmap = new System.Drawing.Bitmap(textureStagingDesc.Width, textureStagingDesc.Height, System.Drawing.Imaging.PixelFormat.Format32bppArgb))
                {
                    var bitmapData = bitmap.LockBits(
                        new System.Drawing.Rectangle(0, 0, textureStagingDesc.Width, textureStagingDesc.Height),
                        System.Drawing.Imaging.ImageLockMode.WriteOnly,
                        bitmap.PixelFormat);

                    Utilities.CopyMemory(bitmapData.Scan0, textureData.DataPointer, textureData.RowPitch * textureStagingDesc.Height);

                    bitmap.UnlockBits(bitmapData);
                    bitmap.Save("output.png", System.Drawing.Imaging.ImageFormat.Png);
                }
                context.UnmapSubresource(textureStaging, 0);
            }

            textureRenderTargetView.Dispose();
            texture.Dispose();
            context.Dispose();
            device.Dispose();
        }

        public static void Foo2()
        {
            int width = 1024;
            int height = 1024;

            Configuration.EnableObjectTracking = true;
            var device = new Device(DriverType.Hardware, DeviceCreationFlags.Debug);
            var context = device.ImmediateContext;

            var textureDesc = new Texture2DDescription
            {
                ArraySize = 6,
                BindFlags = BindFlags.RenderTarget,
                Usage = ResourceUsage.Default,
                CpuAccessFlags = CpuAccessFlags.None,
                Format = Format.R8G8B8A8_UNorm,
                Width = width,
                Height = height,
                MipLevels = 1,
                OptionFlags = ResourceOptionFlags.TextureCube,
                SampleDescription = new SampleDescription(1, 0)
            };
            var texture = new Texture2D(device, textureDesc);

            var depthStencilDesc = new Texture2DDescription
            {
                ArraySize = 6,
                BindFlags = BindFlags.DepthStencil,
                Usage = ResourceUsage.Default,
                CpuAccessFlags = CpuAccessFlags.None,
                Format = Format.D24_UNorm_S8_UInt,
                Width = width,
                Height = height,
                MipLevels = 1,
                OptionFlags = ResourceOptionFlags.TextureCube,
                SampleDescription = new SampleDescription(1, 0)
            };
            var depthStencilBuffer = new Texture2D(device, depthStencilDesc);

            var textureRenderTargetView = new RenderTargetView(device, texture, new RenderTargetViewDescription
            {
                Dimension = RenderTargetViewDimension.Texture2DArray,
                Format = Format.R8G8B8A8_UNorm,
                Texture2DArray = new RenderTargetViewDescription.Texture2DArrayResource { MipSlice = 0, FirstArraySlice = 0, ArraySize = 6 }
            });

            var depthStencilView = new DepthStencilView(device, depthStencilBuffer, new DepthStencilViewDescription
            {
                Dimension = DepthStencilViewDimension.Texture2DArray,
                Format = Format.D24_UNorm_S8_UInt,
                Texture2DArray = new DepthStencilViewDescription.Texture2DArrayResource { MipSlice = 0, FirstArraySlice = 0, ArraySize = 6 }
            });

            context.OutputMerger.SetRenderTargets(depthStencilView, textureRenderTargetView);
            context.ClearRenderTargetView(textureRenderTargetView, Color.Magenta);
            context.ClearDepthStencilView(depthStencilView, DepthStencilClearFlags.Depth | DepthStencilClearFlags.Stencil, 1.0f, 0);

            // Render to the cubemap here...

            var textureStagingDesc = new Texture2DDescription
            {
                Width = textureDesc.Width,
                Height = textureDesc.Height,
                ArraySize = textureDesc.ArraySize,
                BindFlags = BindFlags.None,
                Usage = ResourceUsage.Staging,
                CpuAccessFlags = CpuAccessFlags.Read,
                Format = textureDesc.Format,
                MipLevels = textureDesc.MipLevels,
                OptionFlags = textureDesc.OptionFlags,
                SampleDescription = textureDesc.SampleDescription
            };
            using (var textureStaging = new Texture2D(device, textureStagingDesc))
            {
                context.CopyResource(texture, textureStaging);

                for (int faceIndex = 0; faceIndex < 6; faceIndex++)
                {
                    var mappedSubresource = context.MapSubresource(textureStaging, 0, faceIndex, MapMode.Read, MapFlags.None, out DataStream faceData);
                    using (var bitmap = new System.Drawing.Bitmap(textureStagingDesc.Width, textureStagingDesc.Height, System.Drawing.Imaging.PixelFormat.Format32bppArgb))
                    {
                        var bitmapData = bitmap.LockBits(new System.Drawing.Rectangle(0, 0, textureStagingDesc.Width, textureStagingDesc.Height), System.Drawing.Imaging.ImageLockMode.WriteOnly, bitmap.PixelFormat);
                        Utilities.CopyMemory(bitmapData.Scan0, faceData.DataPointer, textureStagingDesc.Width * textureStagingDesc.Height);
                        bitmap.UnlockBits(bitmapData);
                        bitmap.Save($"output_face{faceIndex}.png", System.Drawing.Imaging.ImageFormat.Png);
                    }
                    context.UnmapSubresource(texture, faceIndex);
                }
            }

            textureRenderTargetView.Dispose();
            texture.Dispose();
            depthStencilView.Dispose();
            depthStencilBuffer.Dispose();
            context.Dispose();
            device.Dispose();
        }
    }
}
