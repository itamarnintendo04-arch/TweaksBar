using Microsoft.Win32;
using System.Collections.ObjectModel;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Windows;
using System.Windows.Controls;

namespace TweaksBar.Client;

public partial class MainWindow : Window
{
    private const string AppleSupportUrl = "https://support.apple.com/en-us/HT210384";
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

    private void Navigate(string page, string subtitle)
    {
        OverviewPage.Visibility = page == "Overview" ? Visibility.Visible : Visibility.Collapsed;
        InstallPage.Visibility = page == "Install IPA" ? Visibility.Visible : Visibility.Collapsed;
        DevicesPage.Visibility = page == "Device support" ? Visibility.Visible : Visibility.Collapsed;
        SettingsPage.Visibility = page == "Settings" ? Visibility.Visible : Visibility.Collapsed;
        PageTitle.Text = page;
        PageSubtitle.Text = subtitle;

        OverviewNav.Background = page == "Overview" ? new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromRgb(26, 49, 84)) : System.Windows.Media.Brushes.Transparent;
        InstallNav.Background = page == "Install IPA" ? new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromRgb(26, 49, 84)) : System.Windows.Media.Brushes.Transparent;
        DevicesNav.Background = page == "Device support" ? new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromRgb(26, 49, 84)) : System.Windows.Media.Brushes.Transparent;
        SettingsNav.Background = page == "Settings" ? new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromRgb(26, 49, 84)) : System.Windows.Media.Brushes.Transparent;
    }

    private void OverviewNav_Click(object sender, RoutedEventArgs e) => Navigate("Overview", "Your iPhone workspace, all in one place.");
    private void InstallNav_Click(object sender, RoutedEventArgs e) => Navigate("Install IPA", "Import and prepare an IPA package for installation.");
    private void DevicesNav_Click(object sender, RoutedEventArgs e) => Navigate("Device support", "Check the Windows components required for iPhone connectivity.");
    private void SettingsNav_Click(object sender, RoutedEventArgs e) => Navigate("Settings", "Application preferences and security information.");

    private void CheckDriversButton_Click(object sender, RoutedEventArgs e)
    {
        bool supportInstalled =
            Registry.LocalMachine.OpenSubKey(@"SOFTWARE\Apple Inc.\Apple Mobile Device Support") is not null ||
            Registry.LocalMachine.OpenSubKey(@"SOFTWARE\WOW6432Node\Apple Inc.\Apple Mobile Device Support") is not null;
        bool serviceRegistered =
            Registry.LocalMachine.OpenSubKey(@"SYSTEM\CurrentControlSet\Services\Apple Mobile Device Service") is not null;

        bool ready = supportInstalled && serviceRegistered;
        DriverStatus.Text = ready
            ? "Apple Mobile Device Support and its service appear to be installed."
            : "Apple device support was not detected. Install or repair it using Apple's official installer.";
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
            ImportStatus.Text = "The selected ZIP is invalid or damaged.";
            MessageBox.Show(ex.Message, "Could not read package", MessageBoxButton.OK, MessageBoxImage.Warning);
        }
        catch (IOException ex)
        {
            ImportStatus.Text = "The package could not be read.";
            MessageBox.Show(ex.Message, "Import failed", MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }

    private void ImportZip(string zipPath)
    {
        int imported = 0;
        using var archive = ZipFile.OpenRead(zipPath);
        foreach (var entry in archive.Entries.Where(e =>
                     e.FullName.EndsWith(".ipa", StringComparison.OrdinalIgnoreCase) &&
                     !e.FullName.Contains('/') && !e.FullName.Contains('\\')))
        {
            if (entry.Length == 0 || entry.Length > 2L * 1024 * 1024 * 1024) continue;
            string safeName = Path.GetFileName(entry.Name);
            if (string.IsNullOrWhiteSpace(safeName)) continue;
            string destination = Path.Combine(_packageDirectory, $"{Guid.NewGuid():N}_{safeName}");
            using var input = entry.Open();
            using var output = new FileStream(destination, FileMode.CreateNew, FileAccess.Write, FileShare.None);
            input.CopyTo(output);
            AddPackage(destination, $"Extracted from {Path.GetFileName(zipPath)}");
            imported++;
        }

        ImportStatus.Text = imported > 0
            ? $"Extracted {imported} IPA file(s) from {Path.GetFileName(zipPath)}."
            : "No IPA files were found at the ZIP root. Choose a ZIP containing TweaksBar IPA assets.";
        if (imported == 0)
            MessageBox.Show(ImportStatus.Text, "No IPA files found", MessageBoxButton.OK, MessageBoxImage.Information);
    }

    private void AddPackage(string path, string source)
    {
        var info = new FileInfo(path);
        if (!info.Exists || info.Length == 0) return;
        var existing = _packages.FirstOrDefault(p => string.Equals(p.Path, path, StringComparison.OrdinalIgnoreCase));
        if (existing is not null) return;
        _packages.Add(new PackageItem(Path.GetFileName(path), $"{FormatSize(info.Length)}  •  {source}", path));
        PackageMetric.Text = $"{_packages.Count} package(s)";
        PackageList.SelectedIndex = _packages.Count - 1;
    }

    private void LoadExistingPackages()
    {
        foreach (var file in Directory.EnumerateFiles(_packageDirectory, "*.ipa"))
            AddPackage(file, "Local package library");
    }

    private void PackageList_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        bool selected = PackageList.SelectedItem is PackageItem;
        SelectedPackageStatus.Text = selected
            ? "IPA package selected. Signing and device installation are not enabled in this preview."
            : "Select a package to see its status.";
        InstallButton.IsEnabled = false;
    }

    private void InstallButton_Click(object sender, RoutedEventArgs e)
    {
        MessageBox.Show(
            "The IPA is ready in your local package library. Device installation is not available yet because the Apple signing and USB installation bridge has not been integrated.",
            "Installation not available", MessageBoxButton.OK, MessageBoxImage.Information);
    }

    private static string FormatSize(long bytes) =>
        bytes >= 1024 * 1024 ? $"{bytes / 1024d / 1024d:0.0} MB" : $"{bytes / 1024d:0.0} KB";

    private static void OpenUrl(string url) =>
        Process.Start(new ProcessStartInfo(url) { UseShellExecute = true });

    private sealed record PackageItem(string Name, string Detail, string Path);
}