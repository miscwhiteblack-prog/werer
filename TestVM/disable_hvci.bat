@echo off
:: ============================================================================
:: DISABLE HVCI / VBS / Hypervisor Security
:: Run as Administrator, then REBOOT
:: ============================================================================

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  [!] ERROR: Run as Administrator!
    echo.
    pause
    exit /b 1
)

echo.
echo  =====================================================
echo   DISABLING HVCI / VBS / HYPERVISOR SECURITY
echo  =====================================================
echo.

echo  [1/7] Disabling Memory Integrity (HVCI)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
echo       Done.

echo  [2/7] Disabling Virtualization Based Security (VBS)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v "RequirePlatformSecurityFeatures" /t REG_DWORD /d 0 /f >nul 2>&1
echo       Done.

echo  [3/7] Disabling Credential Guard...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v "LsaCfgFlags" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "LsaCfgFlags" /t REG_DWORD /d 0 /f >nul 2>&1
echo       Done.

echo  [4/7] Disabling Hyper-V hypervisor launch...
bcdedit /set hypervisorlaunchtype off >nul 2>&1
echo       Done.

echo  [5/7] Disabling Hyper-V and VM Platform features...
dism /online /disable-feature /featurename:Microsoft-Hyper-V-All /norestart >nul 2>&1
dism /online /disable-feature /featurename:Microsoft-Hyper-V-Hypervisor /norestart >nul 2>&1
dism /online /disable-feature /featurename:Microsoft-Hyper-V /norestart >nul 2>&1
dism /online /disable-feature /featurename:HypervisorPlatform /norestart >nul 2>&1
dism /online /disable-feature /featurename:VirtualMachinePlatform /norestart >nul 2>&1
echo       Done.

echo  [6/7] Disabling Windows Sandbox...
dism /online /disable-feature /featurename:Containers-DisposableClientVM /norestart >nul 2>&1
echo       Done.

echo  [7/7] Disabling Vulnerable Driver Blocklist...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CI\Config" /v "VulnerableDriverBlocklistEnable" /t REG_DWORD /d 0 /f >nul 2>&1
echo       Done.

echo.
echo  =====================================================
echo   ALL DONE - REBOOT REQUIRED
echo  =====================================================
echo.
echo  After reboot, check Windows Security ^> Device Security
echo  ^> Core Isolation - Memory Integrity should be OFF
echo.

set /p REBOOT="  Reboot now? (Y/N): "
if /i "%REBOOT%"=="Y" (
    shutdown /r /t 3 /c "Applying HVCI/VBS changes"
) else (
    echo.
    echo  [!] Reboot before using the loader!
)
echo.
pause
