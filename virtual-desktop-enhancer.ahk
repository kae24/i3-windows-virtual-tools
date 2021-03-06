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
    WinGet, id, list, , , , Program Manager
    Loop, %id%
    {
        this_win := id%A_Index%
        WinGetTitle, this_title, ahk_id %this_win%
        desktop := DllCall(GetWindowDesktopNumberProc, Uint, this_win)
        if (desktop = current)
            windows.Push(this_win)
    }
    WinGet, id, list, ahk_class mintty
    Loop, %id%
    {
        this_win := id%A_Index%
        desktop := DllCall(GetWindowDesktopNumberProc, Uint, this_win)
        if (desktop = current)
            windows.Push(this_win)
    }

    return windows
}

calcDistance(x1,y1,x2,y2) {
    distance := sqrt((y2-y1)**2+(x2-x1)**2)
    return distance
}


findLeftWindow()
{
    WinGetActiveTitle, OutputVar
    UniqueID := WinActive(OutputVar)
    WinGetPos, x, y,,, ahk_id %UniqueID%
    
    posWin :=
    minDist := 9999999
    
    winlist := getWindowsList()
    for index, win in winlist {
        WinGetPos, px, py,,, ahk_id %win%
        WinGetTitle, title, ahk_id %win%
        
        if (x > px) {
            if (minDist > calcDistance(x,y,px,py)) {
                minDist := calcDistance(x,y,px,py)
                posWin := win
            }
        }
    }
    WinActivate, ahk_id %posWin%
}

findRightWindow()
{
    WinGetActiveTitle, OutputVar
    UniqueID := WinActive(OutputVar)
    WinGetPos, x, y,,, ahk_id %UniqueID%
    
    posWin :=
    minDist := 9999999
    
    winlist := getWindowsList()
    for index, win in winlist {
        WinGetPos, px, py,,, ahk_id %win%
        WinGetTitle, title, ahk_id %win%
        
        if (x < px) {
            if (minDist > calcDistance(x,y,px,py)) {
                minDist := calcDistance(x,y,px,py)
                posWin := win
            }
        }
    }
    WinActivate, ahk_id %posWin%
}

findUpWindow() {
    WinGetActiveTitle, OutputVar
    UniqueID := WinActive(OutputVar)
    WinGetPos, x, y,,, ahk_id %UniqueID%
    
    posWin :=
    minDist := 9999999
    
    winlist := getWindowsList()
    for index, win in winlist {
        WinGetPos, px, py,,, ahk_id %win%
        WinGetTitle, title, ahk_id %win%
        
        if (y > py) {
            if (minDist > calcDistance(x,y,px,py)) {
                minDist := calcDistance(x,y,px,py)
                posWin := win
            }
        }
    }
    WinActivate, ahk_id %posWin%
}

findDownWindow() {
    WinGetActiveTitle, OutputVar
    UniqueID := WinActive(OutputVar)
    WinGetPos, x, y, width, height, ahk_id %UniqueID%
    
    y := y + height - 15
    posWin :=
    minDist := 9999999
    winlist := getWindowsList()
    for index, win in winlist {
        WinGetPos, px, py,,, ahk_id %win%
        WinGetTitle, title, ahk_id %win%
        
        if (y < py) {
            if (minDist > calcDistance(x,y,px,py)) {
                minDist := calcDistance(x,y,px,py)
                posWin := win
            }
        }
    }
    WinActivate, ahk_id %posWin%
}
    

;findLeftWindow()
~LWin & h::findLeftWindow()
~LWin & j::findDownWindow()
~LWin & k::findUpWindow()
~LWin & l::findRightWindow()

