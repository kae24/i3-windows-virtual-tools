#SingleInstance, force
#WinActivateForce
#HotkeyInterval 20
#MaxHotkeysPerInterval 20000
#MenuMaskKey vk07
#UseHook
; Credits to Ciantic: https://github.com/Ciantic/VirtualDesktopAccessor

#Include, %A_ScriptDir%\libraries\read-ini.ahk
#Include, %A_ScriptDir%\libraries\tooltip.ahk

; ======================================================================
; Set Up Library Hooks
; ======================================================================

DetectHiddenWindows, On
hwnd := WinExist("ahk_pid " . DllCall("GetCurrentProcessId","Uint"))
hwnd += 0x1000 << 32

hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", A_ScriptDir . "\libraries\virtual-desktop-accessor.dll", "Ptr")

global GetCurrentDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GetCurrentDesktopNumber", "Ptr")
global GetWindowDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GetWindowDesktopNumber", "Ptr")
global IsWindowOnCurrentVirtualDesktopProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "IsWindowOnCurrentVirtualDesktop", "Ptr")

current := DllCall(GetCurrentDesktopNumberProc, Uint)

getWindowsList()
{
    ; find current desktop
    current := DllCall(GetCurrentDesktopNumberProc, Uint)

    windows := []
    WinGet, id, list, , , , Program Manager]
    Loop, %id%
    {
        this_win := id%A_Index%
        WinGetTitle, this_title, ahk_id %this_win%
        desktop := DllCall(GetWindowDesktopNumberProc, Uint, this_win)
        if (desktop = current)
            windows.Push(this_win)
    }

    return windows
}

findLeftWindow()
{
    
}

getWindowsList()