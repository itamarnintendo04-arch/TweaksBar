using Microsoft.Win32;
using System.Collections.ObjectModel;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Net.Http;
using System.Text.Json;
using System.Windows;
using System.Windows.Controls;

namespace TweaksBar.Client;

public partial class MainWindow : Window
{
    private const string AppleSupportUrl = "https://support.apple.com/en-us/HT210384";
    private const string LatestReleaseApi = "https://api.github.com/repos/itamarnintendo04-arch/TweaksBar/releases/latest";
    private const long MaximumPackageBytes = 2L * 1024 * 1024 * 1024;
    private static readonly HttpClient Http = CreateHttpClient();
    private readonly ObservableCollection<PackageItem> _packages = new();
    private readonly string _packageDirectory = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
        "TweaksBar", "Packages");

    public MainWindow()
    {
        InitializeComponent();
        PackageList.ItemsSource = _packages;
        Directory.CreateDirectory(_packageDirectory);
        LoadExistingPackages();
    }

    private static HttpClient CreateHttpClient()
    {
        var client = new HttpClient { Timeout = TimeSpan.FromMinutes(5) };
        client.DefaultRequestHeaders.UserAgent.ParseAdd("TweaksBar-Windows/0.3");
        client.DefaultRequestHeaders.Accept.ParseAdd("application/vnd.github+json");
        return client;
    }

    private void Navigate(string page, string subtitle)
    {
        OverviewPage.Visibility = page == "Overview" ? Visibility.Visible : Visibility.Collapsed;
        InstallPage.Visibility = page == "Install IPA" ? Visibility.Visible : Visibility.Collapsed;
        DevicesPage.Visibility = page == "Device support" ? Visibility.Visible : Visibility.Collapsed;
        SettingsPage.Visibility = page == "Settings" ? Visibility.Visible : Visibility.Collapsed;
        PageTitle.Text = page;
        PageSubtitle.Text = subtitle;

        OverviewNav.Background = NavBrush(page == "Overview");
        InstallNav.Background = NavBrush(page == "Install IPA");
        DevicesNav.Background = NavBrush(page == "Device support");
        SettingsNav.Background = NavBrush(page == "Settings");
        OverviewNav.Foreground = NavForeground(page == "Overview");
        InstallNav.Foreground = NavForeground(page == "Install IPA");
        DevicesNav.Foreground = NavForeground(page == "Device support");
        SettingsNav.Foreground = NavForeground(page == "Settings");
    }

    private static System.Windows.Media.Brush NavBrush(bool active) =>
        active ? new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromRgb(26, 49, 84))
               : System.Windows.Media.Brushes.Transparent;

    private static System.Windows.Media.Brush NavForeground(bool active) =>
        active ? new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromRgb(130, 182, 255))
               : new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromRgb(170, 183, 202));

    private void OverviewNav_Click(object sender, RoutedEventArgs e) => Navigate("Overview", "Your iPhone workspace, all in one place.");
    private void InstallNav_Click(object sender, RoutedEventArgs e) => Navigate("Install IPA", "Import, validate, and prepare an IPA package.");
    private void DevicesNav_Click(object sender, RoutedEventArgs e) => Navigate("Device support", "Check USB connectivity and Apple device support.");
    private void SettingsNav_Click(object sender, RoutedEventArgs e) => Navigate("Settings", "Application preferences and security information.");

    private void CheckDriversButton_Click(object sender, RoutedEventArgs e)
    {
        using var support64 = Registry.LocalMachine.OpenSubKey(@"SOFTWARE\Apple Inc.\Apple Mobile Device Support");
        using var support32 = Registry.LocalMachine.OpenSubKey(@"SOFTWARE\WOW6432Node\Apple Inc.\Apple Mobile Device Support");
        using var service = Registry.LocalMachine.OpenSubKey(@"SYSTEM\CurrentControlSet\Services\Apple Mobile Device Service");
        bool ready = support64 is not null || support32 is not null;
        ready &= service is not null;

        DriverStatus.Text = ready
            ? "Apple Mobile Device Support and its service appear to be installed."
            : "Apple device support was not detected. Install or repair it using Apple's official software.";
        DriverMetric.Text = ready ? "Ready" : "Needs setup";
        DriverStatus.Foreground = ready
            ? System.Windows.Media.Brushes.LightGreen
            : System.Windows.Media.Brushes.Orange;
    }

    private void InstallDriversButton_Click(object sender, RoutedEventArgs e) => OpenUrl(AppleSupportUrl);

    private void WifiHelpButton_Click(object sender, RoutedEventArgs e)
    {
        MessageBox.Show(
            "1. Connect your iPhone to this PC with USB.\n" +
            "2. Unlock the iPhone and approve Trust This Computer.\n" +
            "3. Open Apple Devices or iTunes on Windows.\n" +
            "4. Select your iPhone and enable 'Show this iPhone when on Wi-Fi' (wording may vary).\n" +
            "5. Apply the setting, then keep both devices on the same Wi-Fi network.",
            "Enable Wi-Fi Sync", MessageBoxButton.OK, MessageBoxImage.Information);
    }

    private async void RefreshDeviceButton_Click(object sender, RoutedEventArgs e)
    {
        RefreshDeviceButton.IsEnabled = false;
        ConnectionStatus.Text = "Checking Windows device list…";
        try
        {
            var start = new ProcessStartInfo
            {
                FileName = "powershell.exe",
                Arguments = "-NoProfile -NonInteractive -ExecutionPolicy Bypass -Command \"Get-PnpDevice -PresentOnly | Where-Object { $_.FriendlyName -match 'iPhone|Apple Mobile Device USB' } | Select-Object -ExpandProperty FriendlyName\"",
                UseShellExecute = false,
                CreateNoWindow = true,
                RedirectStandardOutput = true,
                RedirectStandardError = true
            };
            using var process = Process.Start(start);
            if (process is null) throw new InvalidOperationException("Windows device enumeration could not start.");
            string output = await process.StandardOutput.ReadToEndAsync();
            await process.WaitForExitAsync();
            string[] devices = output.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
            bool found = devices.Length > 0;

            ConnectionStatus.Text = found
                ? string.Join(Environment.NewLine, devices.Distinct())
                : "No iPhone detected. Connect it by USB, unlock it, and tap Trust This Computer.";
            DeviceMetric.Text = found ? "Device detected" : "Not connected";
            HeaderDeviceStatus.Text = found ? "DEVICE DETECTED" : "NO DEVICE";
            HeaderDeviceStatus.Foreground = found
                ? System.Windows.Media.Brushes.LightGreen
                : new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromRgb(215, 228, 248));
        }
        catch (Exception ex)
        {
            ConnectionStatus.Text = "Device detection failed: " + ex.Message;
            DeviceMetric.Text = "Check failed";
        }
        finally
        {
            RefreshDeviceButton.IsEnabled = true;
        }
    }

    private void BrowsePackageButton_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new OpenFileDialog
        {
            Title = "Import an IPA or TweaksBar ZIP release",
            Filter = "IPA or ZIP package (*.ipa;*.zip)|*.ipa;*.zip|IPA files (*.ipa)|*.ipa|ZIP files (*.zip)|*.zip",
            Multiselect = false
        };
        if (dialog.ShowDialog(this) != true) return;

        try
        {
            if (Path.GetExtension(dialog.FileName).Equals(".ipa", StringComparison.OrdinalIgnoreCase))
            {
                AddPackage(dialog.FileName, "Imported IPA");
                ImportStatus.Text = $"Imported {Path.GetFileName(dialog.FileName)}";
            }
            else
            {
                ImportZip(dialog.FileName);
            }
        }
        catch (InvalidDataException ex)
        {
            ImportStatus.Text = "The selected package is invalid or damaged.";
            MessageBox.Show(ex.Message, "Could not read package", MessageBoxButton.OK, MessageBoxImage.Warning);
        }
        catch (IOException ex)
        {
            ImportStatus.Text = "The package could not be read.";
            MessageBox.Show(ex.Message, "Import failed", MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }

    private async void DownloadLatestReleaseButton_Click(object sender, RoutedEventArgs e)
    {
        var button = (Button)sender;
        button.IsEnabled = false;
        ImportStatus.Text = "Checking the latest TweaksBar release…";
        try
        {
            using var response = await Http.GetAsync(LatestReleaseApi, HttpCompletionOption.ResponseHeadersRead);
            response.EnsureSuccessStatusCode();
            await using var stream = await response.Content.ReadAsStreamAsync();
            using var document = await JsonDocument.ParseAsync(stream);
            if (!document.RootElement.TryGetProperty("assets", out var assets))
                throw new InvalidDataException("The GitHub release did not contain an assets list.");

            int imported = 0;
            foreach (var asset in assets.EnumerateArray())
            {
                string name = asset.GetProperty("name").GetString() ?? "";
                if (!name.EndsWith(".ipa", StringComparison.OrdinalIgnoreCase)) continue;
                string url = asset.GetProperty("browser_download_url").GetString() ?? "";
                if (!Uri.TryCreate(url, UriKind.Absolute, out var uri) || uri.Scheme != Uri.UriSchemeHttps ||
                    uri.Host != "github.com" && uri.Host != "objects.githubusercontent.com" && !uri.Host.EndsWith(".githubusercontent.com", StringComparison.Ordinal))
                    continue;

                using var download = await Http.GetAsync(uri, HttpCompletionOption.ResponseHeadersRead);
                download.EnsureSuccessStatusCode();
                if (download.Content.Headers.ContentLength is > MaximumPackageBytes)
                    throw new InvalidDataException($"{name} exceeds the 2 GB package limit.");

                string safeName = Path.GetFileName(name);
                string destination = Path.Combine(_packageDirectory, $"{Guid.NewGuid():N}_{safeName}");
                await using (var input = await download.Content.ReadAsStreamAsync())
                await using (var output = new FileStream(destination, FileMode.CreateNew, FileAccess.Write, FileShare.None))
                    await input.CopyToAsync(output);

                if (!IsValidIpa(destination))
                {
                    File.Delete(destination);
                    continue;
                }
                AddPackage(destination, "Downloaded from latest GitHub Release");
                imported++;
            }

            ImportStatus.Text = imported > 0
                ? $"Downloaded and checked {imported} IPA package(s) from the latest release."
                : "No direct IPA assets were found in the latest release.";
        }
        catch (Exception ex)
        {
            ImportStatus.Text = "Could not download the latest release.";
            MessageBox.Show(ex.Message, "Release download failed", MessageBoxButton.OK, MessageBoxImage.Warning);
        }
        finally
        {
            button.IsEnabled = true;
        }
    }

    private void ImportZip(string zipPath)
    {
        int imported = 0;
        long totalBytes = 0;
        using var archive = ZipFile.OpenRead(zipPath);

        foreach (var entry in archive.Entries.Where(e =>
                     e.FullName.EndsWith(".ipa", StringComparison.OrdinalIgnoreCase)))
        {
            if (entry.Length == 0 || entry.Length > MaximumPackageBytes) continue;
            if (totalBytes + entry.Length > MaximumPackageBytes * 2) break;

            string safeName = Path.GetFileName(entry.Name);
            if (string.IsNullOrWhiteSpace(safeName)) continue;

            string destination = Path.Combine(_packageDirectory, $"{Guid.NewGuid():N}_{safeName}");
            using (var input = entry.Open())
            using (var output = new FileStream(destination, FileMode.CreateNew, FileAccess.Write, FileShare.None))
                input.CopyTo(output);

            if (!IsValidIpa(destination))
            {
                File.Delete(destination);
                continue;
            }

            totalBytes += new FileInfo(destination).Length;
            AddPackage(destination, $"Extracted from {Path.GetFileName(zipPath)}");
            imported++;
            if (imported >= 10) break;
        }

        ImportStatus.Text = imported > 0
            ? $"Extracted and validated {imported} IPA file(s) from {Path.GetFileName(zipPath)}."
            : "No valid IPA files were found. The ZIP should contain IPA release assets.";
        if (imported == 0)
            MessageBox.Show(ImportStatus.Text, "No valid IPA files found", MessageBoxButton.OK, MessageBoxImage.Information);
    }

    private static bool IsValidIpa(string path)
    {
        try
        {
            using var archive = ZipFile.OpenRead(path);
            return archive.Entries.Any(e =>
                e.FullName.StartsWith("Payload/", StringComparison.Ordinal) &&
                e.FullName.EndsWith(".app/Info.plist", StringComparison.Ordinal));
        }
        catch (InvalidDataException)
        {
            return false;
        }
    }

    private void AddPackage(string path, string source)
    {
        var info = new FileInfo(path);
        if (!info.Exists || info.Length == 0 || !IsValidIpa(path)) return;
        if (_packages.Any(p => string.Equals(p.Path, path, StringComparison.OrdinalIgnoreCase))) return;

        _packages.Add(new PackageItem(Path.GetFileName(path), $"{FormatSize(info.Length)}  •  {source}", path));
        PackageMetric.Text = $"{_packages.Count} package(s)";
        PackageList.SelectedIndex = _packages.Count - 1;
    }

    private void LoadExistingPackages()
    {
        foreach (var file in Directory.EnumerateFiles(_packageDirectory, "*.ipa"))
            AddPackage(file, "Local package library");
        PackageMetric.Text = _packages.Count == 0 ? "No package" : $"{_packages.Count} package(s)";
    }

    private void PackageList_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        bool selected = PackageList.SelectedItem is PackageItem;
        SelectedPackageStatus.Text = selected
            ? "Valid IPA selected. Signing and installation still require a supported Apple signing bridge."
            : "Select a package to see its status.";
        InstallButton.IsEnabled = false;
    }

    private void InstallButton_Click(object sender, RoutedEventArgs e)
    {
        MessageBox.Show(
            "This IPA has been validated and imported. Direct installation is not enabled yet: TweaksBar still needs a supported Apple ID signing integration and a tested USB installation service. No Apple ID password is collected by this app.",
            "Installation is not available yet", MessageBoxButton.OK, MessageBoxImage.Information);
    }

    private static string FormatSize(long bytes) =>
        bytes >= 1024 * 1024 ? $"{bytes / 1024d / 1024d:0.0} MB" : $"{bytes / 1024d:0.0} KB";

    private static void OpenUrl(string url) =>
        Process.Start(new ProcessStartInfo(url) { UseShellExecute = true });

    private sealed record PackageItem(string Name, string Detail, string Path);
}
