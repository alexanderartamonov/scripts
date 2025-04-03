cls
Set-ExecutionPolicy Bypass -Scope Process -Force

function Uninstall-ChocoPython {
    $chocoPython = choco list --local-only | Where-Object { $_ -match "python" }
    if ($chocoPython) {
        Write-Host "Found Python versions installed via Chocolatey:"
        $chocoPython | ForEach-Object { Write-Host $_ }
        Write-Host "Uninstalling Python versions via Chocolatey..."
        choco uninstall python --all --force -y
    } else {
        Write-Host "No Python versions found via Chocolatey."
    }
}

function Uninstall-Chocolatey {
    Write-Host "Uninstalling Chocolatey..."
    if (Test-Path "C:\ProgramData\chocolatey") {
        Write-Host "Removing Chocolatey directories..."
        Remove-Item -Recurse -Force "C:\ProgramData\chocolatey"
        Remove-Item -Recurse -Force "$env:SystemDrive\ProgramData\chocolatey"
        Remove-Item -Recurse -Force "$env:ChocolateyInstall"
    }
    $envPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $newPath = $envPath -replace ";C:\ProgramData\chocolatey", ""
    [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
    Write-Host "Chocolatey uninstalled and cleaned up."
}

function UninstallPython($uninstallString) {
    $uninstallCommand = “$uninstallString /quiet”
    Write-Host “Uninstalling Python…”
    Start-Process -Wait -FilePath cmd.exe -ArgumentList “/C”, $uninstallCommand -WindowStyle Hidden
}
$pythonVersions = Get-ChildItem -Path “HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall”, “HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall” -Recurse -ErrorAction SilentlyContinue |
Get-ItemProperty | Where-Object { $_.DisplayName -like ‘Python*’ }
foreach ($version in $pythonVersions) {
    $uninstallString = $version.UninstallString
    UninstallPython $uninstallString
}
$registryPath = "HKLM:\SOFTWARE\Python"
if (Test-Path $registryPath) {
    try {
        # Remove the registry key and all its subkeys
        Remove-Item -Path $registryPath -Recurse -Force
        Write-Host "Registry key $registryPath has been removed successfully."
    } catch {
        Write-Host "Error removing the registry key: $_"
    }
} else {
    Write-Host "Registry key $registryPath does not exist."
}
function Uninstall-ManualPython {
    $pythonRegistryPaths = @(
        "HKLM:\SOFTWARE\Python\PythonCore",
        "HKCU:\SOFTWARE\Python\PythonCore"
    )
    foreach ($path in $pythonRegistryPaths) {
        if (Test-Path $path) {
            $pythonVersions = Get-ChildItem $path
            if ($pythonVersions) {
                Write-Host "Found manually installed Python versions:"
                $pythonVersions | ForEach-Object { Write-Host $_.PSChildName }
                foreach ($version in $pythonVersions) {
                    $uninstallString = (Get-ItemProperty "$path\$($version.PSChildName)\InstallPath").UninstallString
                    if ($uninstallString) {
                        Write-Host "Uninstalling Python version: $($version.PSChildName)"
                        & $uninstallString /quiet
                    } else {
                        Write-Host "No uninstall string found for version: $($version.PSChildName)"
                    }
                }
            } else {
                Write-Host "No manually installed Python versions found in $path."
            }
        }
    }
}

function CleanUp-PythonDirectories {
    $pythonFolders = @(
        "$env:ProgramFiles\Python*",
        "$env:ProgramFiles(x86)\Python*",
        "$env:LocalAppData\Programs\Python*",
        "$env:AppData\Local\Programs\Python*",
        "$env:AppData\Local\Python*"
    )
    foreach ($folder in $pythonFolders) {
        if (Test-Path $folder) {
            Write-Host "Removing Python directory: $folder"
            Remove-Item -Recurse -Force $folder
        } else {
            Write-Host "Python directory not found: $folder"
        }
    }
}

function Uninstall-PythonMSI {
  $pythonMsiPackages = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*Python*" }
  if ($pythonMsiPackages) {
      Write-Host "Found Python-related MSI packages:"
      $pythonMsiPackages | ForEach-Object { Write-Host "$($_.Name) - $($_.IdentifyingNumber)" }
      foreach ($package in $pythonMsiPackages) {
          $productCode = $package.IdentifyingNumber
          $packageName = $package.Name
          Write-Host "Uninstalling $packageName with product code: $productCode..."
          $process = Start-Process "msiexec.exe" -ArgumentList "/x $productCode REINSTALLMODE=vomus /quiet /norestart" -Wait -PassThru
          if ($process.ExitCode -eq 0) {
              Write-Host "$packageName has been uninstalled successfully."
          } else {
              Write-Host "Failed to uninstall $packageName. Exit code: $($process.ExitCode)"
          }
      }
  } else {
      Write-Host "No Python-related MSI packages found."
  }
}

function Remove-PythonFromPackageCache {
    $usersPath = "C:\Users\*"
    $pythonPaths = @()

    foreach ($userDir in Get-ChildItem -Path $usersPath -Directory) {
        $packageCachePath = "$($userDir.FullName)\AppData\Local\Package Cache\*"
        if (Test-Path $packageCachePath) {
            # Search for Python executable within the Package Cache directory
            $pythonPaths += Get-ChildItem -Path $packageCachePath -Recurse -ErrorAction SilentlyContinue -Filter "*python*" |
            Select-Object -ExpandProperty DirectoryName
        }
    }

    if ($pythonPaths) {
        foreach ($path in $pythonPaths | Select-Object -Unique) {
            try {
                # Remove the entire directory containing the Python executable
                Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
                Write-Host "Removed Python directory: $path"
            } catch {
                Write-Host "Failed to remove directory: $path. Error: $_"
            }
        }
    } else {
        Write-Host "No Python installations found in AppData\Local\Package Cache."
    }
}

function Remove-PythonFromPrograms {
    param (
        [string]$regPath
    )
    Get-ChildItem -Path $regPath | ForEach-Object {
        $keyPath = $_.PsPath
        $displayName = (Get-ItemProperty -Path $keyPath -ErrorAction SilentlyContinue).DisplayName

        if ($displayName -like "*python*") {
            try {
                # Remove the Python-related registry key
                Remove-Item -Path $keyPath -Recurse -Force
                Write-Host "Removed Python from Programs and Features: $displayName"
            } catch {
                Write-Host "Failed to remove registry entry: $keyPath. Error: $_"
            }
        }
    }
}


Write-Host "Uninstalling python installed via Chocolatey"
Uninstall-ChocoPython
Write-Host "Uninstalling Chocolatey..."
Uninstall-Chocolatey
Write-Host "Cleaning up Python directories..."
CleanUp-PythonDirectories
Write-Host "Cleaning up Python msi packages..."
Uninstall-PythonMSI
Write-Host "Cleaning up Python packages cache..."
Remove-PythonFromPackageCache
Write-Host "Cleaning up registry entries for python..."
$uninstallRegistryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
)
foreach ($path in $uninstallRegistryPaths) {
    Remove-PythonFromPrograms -regPath $path
} 
Write-Host "Python uninstallation and cleanup completed."
