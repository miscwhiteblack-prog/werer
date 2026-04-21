@echo off
:: ============================================================================
:: RE-ENABLE HVCI / VBS / Hypervisor Security
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
echo   RE-ENABLING HVCI / VBS / HYPERVISOR SECURITY
echo  =====================================================
echo.

echo  [1/7] Enabling Memory Integrity (HVCI)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /t REG_DWORD /d 1 /f >nul 2>&1
echo       Done.

echo  [2/7] Enabling Virtualization Based Security (VBS)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v "RequirePlatformSecurityFeatures" /t REG_DWORD /d 1 /f >nul 2>&1
echo       Done.

echo  [3/7] Enabling Credential Guard...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v "LsaCfgFlags" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "LsaCfgFlags" /t REG_DWORD /d 1 /f >nul 2>&1
echo       Done.

echo  [4/7] Enabling Hyper-V hypervisor launch...
bcdedit /set hypervisorlaunchtype auto >nul 2>&1
echo       Done.

echo  [5/7] Enabling Hyper-V and VM Platform features...
dism /online /enable-feature /featurename:Microsoft-Hyper-V-All /norestart >nul 2>&1
dism /online /enable-feature /featurename:HypervisorPlatform /norestart >nul 2>&1
dism /online /enable-feature /featurename:VirtualMachinePlatform /norestart >nul 2>&1
echo       Done.

echo  [6/7] Enabling Windows Sandbox...
dism /online /enable-feature /featurename:Containers-DisposableClientVM /norestart >nul 2>&1
echo       Done.

echo  [7/7] Enabling Vulnerable Driver Blocklist...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CI\Config" /v "VulnerableDriverBlocklistEnable" /t REG_DWORD /d 1 /f >nul 2>&1
echo       Done.

echo.
echo  =====================================================
echo   ALL DONE - REBOOT REQUIRED
echo  =====================================================
echo.

set /p REBOOT="  Reboot now? (Y/N): "
if /i "%REBOOT%"=="Y" (
    shutdown /r /t 3 /c "Re-enabling HVCI/VBS security"
) else (
    echo.
    echo  [!] Reboot to apply changes.
)
echo.
pause
