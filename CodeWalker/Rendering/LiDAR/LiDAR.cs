using CodeWalker.GameFiles;
using CodeWalker.Properties;
using CodeWalker.World;
using SharpDX;
using SharpDX.Direct3D;
using SharpDX.Direct3D11;
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Threading;

namespace CodeWalker.Rendering.LiDAR
{
    public static class LiDAR
    {
        [DllImport("kernel32.dll")]
        public static extern bool AllocConsole();

        [DllImport("kernel32.dll")]
        public static extern bool FreeConsole();

        private static void WriteInfo(string s)
        {
            Console.ForegroundColor = ConsoleColor.White;
            Console.WriteLine($"[INFO] {s}");
        }

        private static void WriteError(string s)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine($"[ERROR] {s}");
        }

        public static void Run()
        {
            AllocConsole();

            GTA5Keys.LoadFromPath(GTAFolder.CurrentGTAFolder, Settings.Default.Key);

            Device device = new Device(DriverType.Hardware, DeviceCreationFlags.Debug);
            DeviceContext context = device.ImmediateContext;

            GameFileCache gameFileCache = GameFileCacheFactory.Create();
            gameFileCache.Init(WriteInfo, WriteError);

            RenderableCache renderableCache = new RenderableCache();
            renderableCache.OnDeviceCreated(device);

            Space space = new Space();
            space.Init(gameFileCache, WriteInfo);

            Settings settings = Settings.Default;
            Camera camera = new Camera(settings.CameraSmoothing, settings.CameraSensitivity, settings.CameraFieldOfView);
            camera.Position = new Vector3(0f, -1f, 100f);
            MetaHash weatherHash = new MetaHash(0);
            Dictionary<MetaHash, YmapFile> ymaps = new Dictionary<MetaHash, YmapFile>();

            while (true)
            {
                while (renderableCache.ContentThreadProc()) 
                {
                };
                space.GetVisibleYmaps(camera, 0, weatherHash, ymaps);
                Console.WriteLine(ymaps.Count);
                Thread.Sleep(100);
            }

            Console.ReadLine();
            FreeConsole();
        }
    }
}
