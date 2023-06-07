using System;
using System.Windows.Forms;

namespace CodeWalker.RPFExplorer
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            //Process.Start("CodeWalker.exe", "explorer");

            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new ExploreForm());

            GTAFolder.UpdateSettings();
        }
    }
}
