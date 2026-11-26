using Microsoft.Win32;
using System.Diagnostics;
using System.Windows;

namespace TweaksBar.Client;

public partial class MainWindow : Window
{
    private const string AppleSupportUrl = "https://support.apple.com/en-us/HT210384";

    public MainWindow()
    {
        InitializeComponent();
    }

    private void CheckDriversButton_Click(object sender, RoutedEventArgs e)
    {
        bool supportInstalled =
            Registry.LocalMachine.OpenSubKey(@"SOFTWARE\Apple Inc.\Apple Mobile Device Support") is not null ||
            Registry.LocalMachine.OpenSubKey(@"SOFTWARE\WOW6432Node\Apple Inc.\Apple Mobile Device Support") is not null;

        bool serviceRegistered =
            Registry.LocalMachine.OpenSubKey(@"SYSTEM\CurrentControlSet\Services\Apple Mobile Device Service") is not null;

        DriverStatus.Text = supportInstalled && serviceRegistered
            ? "Apple Mobile Device Support appears to be installed."
            : "Apple device support was not detected. Install or repair it using Apple's official installer.";

        DriverStatus.Foreground = supportInstalled && serviceRegistered
            ? System.Windows.Media.Brushes.LightGreen
            : System.Windows.Media.Brushes.Orange;
    }

    private void InstallDriversButton_Click(object sender, RoutedEventArgs e)
    {
        OpenUrl(AppleSupportUrl);
        DriverStatus.Text = "Follow Apple's official instructions, complete installation, then check again.";
    }

    private void WifiHelpButton_Click(object sender, RoutedEventArgs e)
    {
        MessageBox.Show(
            "1. Connect your iPhone to this PC with USB.\n" +
            "2. Unlock the iPhone and approve Trust This Computer.\n" +
            "3. Open Apple Devices or iTunes on Windows.\n" +
            "4. Select your iPhone and enable 'Show this iPhone when on Wi-Fi' (wording may vary).\n" +
            "5. Apply the setting, then keep both devices on the same Wi-Fi network.",
            "Enable Wi-Fi Sync",
            MessageBoxButton.OK,
            MessageBoxImage.Information);
    }

    private void DiscoverButton_Click(object sender, RoutedEventArgs e)
    {
        ConnectionStatus.Text = "iPhone discovery will be enabled when the companion app and authenticated device bridge are ready.";
    }

    private static void OpenUrl(string url)
    {
        Process.Start(new ProcessStartInfo(url) { UseShellExecute = true });
    }
}
