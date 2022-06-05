#NoEnv
#SingleInstance, force
CoordMode, Mouse, Client
SendMode, Input

; QOL Variables ========
configFile := A_ScriptDir . "\crafter_config.ini"
imgFile := A_ScriptDir . "\crafter_img.png"
keysText = 
    (
        Hotkeys & Buttons:
        > Numpad 0 : Stop Crafting
        > RCtrl : Start Crafting (If toggled)
        > Alt Gr : Exit program
        > Left Click : Confirm mouse position after selecting "Set"
        > Test Button : Run a slow sequence demo without left clicks
        > Start Button : Starts the crafting sequence
    )

; Exposed variables ========
seq1CraftPosX := 0
seq1CraftPosY := 0
seq2ItemPosX := 0
seq2ItemPosY := 0
seq3InventSlotPosX := 0
seq3InventSlotPosY := 0
seq4AssistSinglePosX := 0
seq4AssistSinglePosY := 0
seq5AssistMultiPosX := 0
seq5AssistMultiPosY := 0
seq6CreateItemPosX := 0
seq6CreateItemPosY := 0
seq7CraftedItemPosX := 0
seq7CraftedItemPosY := 0

isBeepStartEnabled := True
isBeepEndEnabled := True
isStartHotkeyEnabled := False

; Functional variables ========
tracker := new CursorTracker
sequenceRunner := new CraftSequenceRunner

; Load data from config ========
CreateConfigIfNoneExists()
ReadFromConfig()

; Create GUI elements ========
Gui MainG: Font, s12
Gui MainG: Add, Text, x40 y5, Mouse positions
Gui MainG: Font, s8

Gui MainG: Add, Text, x5 w85 h16, Crafting table
Gui MainG: Add, Text, x+0 w60 h16 vSeq1Var, % seq1CraftPosX ", " seq1CraftPosY
Gui MainG: Add, Button, x+5 w40 h16 gSetButton, Set

Gui MainG: Add, Text, x5 w85 h16, Item to craft
Gui MainG: Add, Text, x+0 w60 h16 vSeq2Var, % seq2ItemPosX ", " seq2ItemPosY
Gui MainG: Add, Button, x+5 w40 h16 gSetButton, Set

Gui MainG: Add, Text, x5 w85 h16, Free invent slot
Gui MainG: Add, Text, x+0 w60 h16 vSeq3Var, % seq3InventSlotPosX ", " seq3InventSlotPosY
Gui MainG: Add, Button, x+5 w40 h16 gSetButton, Set

Gui MainG: Add, Text, x5 w85 h16, Single assist
Gui MainG: Add, Text, x+0 w60 h16 vSeq4Var, % seq4AssistSinglePosX ", " seq4AssistSinglePosY
Gui MainG: Add, Button, x+5 w40 h16 gSetButton, Set

Gui MainG: Add, Text, x5 w85 h16, Multi assist
Gui MainG: Add, Text, x+0 w60 h16 vSeq5Var, % seq5AssistMultiPosX ", " seq5AssistMultiPosY
Gui MainG: Add, Button, x+5 w40 h16 gSetButton, Set

Gui MainG: Add, Text, x5 w85 h16, Create item
Gui MainG: Add, Text, x+0 w60 h16 vSeq6Var, % seq6CreateItemPosX ", " seq6CreateItemPosY
Gui MainG: Add, Button, x+5 w40 h16 gSetButton, Set

Gui MainG: Add, Text, x5 w85 h16, Crafted item
Gui MainG: Add, Text, x+0 w60 h16 vSeq7Var, % seq7CraftedItemPosX ", " seq7CraftedItemPosY
Gui MainG: Add, Button, x+5 w40 h16 gSetButton, Set

Gui MainG: Add, Text, x5 y+10 w190 0x10 ; Horizontal Etched line

Gui MainG: Add, Button, x45 y215 w50 h18 gDemoSequence, Test
Gui MainG: Add, Button, x+10 w50 h18 gStartSequence vStartButton, Start

Gui MainG: Add, Text, x5 y+5 w190 0x10 ; Horizontal Etched line

Gui MainG: Add, Checkbox, x5 y+0 w150 h16 gToggleBeepOnStop vIsBeepEndEnabledVar Checked%isBeepEndEnabled%, Play BEEP when stopped
Gui MainG: Add, Button, x+0 w40 h16 gPlayEndBeepDemo, Demo
Gui MainG: Add, Checkbox, x5 w150 h16 gToggleBeepOnStart vIsBeepStartEnabledVar Checked%isBeepStartEnabled%, Play BEEPs when starting
Gui MainG: Add, Button, x+0 w40 h16 gPlayStartBeepDemo, Demo
Gui MainG: Add, Checkbox, x5 h16 gToggleStartHotkey vIsStartHotkeyEnabledVar Checked%isStartHotkeyEnabled%, Allow hotkey to start sequence
Gui MainG: Add, Button, x19 w80 h18 gDisplayHotkeys, Hotkeys
Gui MainG: Add, Button, x+2 w80 h18 gDisplayHelp, Help


Gui MainG: +AlwaysOnTop
Gui MainG: Show, w200 h350 x1700 y680, Crafter
Return

; Labels ========
MainGGuiClose:
    ExitApp
    Return

ToggleBeepOnStart:
    Gui, Submit, NoHide
    isBeepStartEnabled := IsBeepStartEnabledVar
    WriteToConfig()
    return

ToggleBeepOnStop:
    Gui, Submit, NoHide
    isBeepEndEnabled := IsBeepEndEnabledVar
    WriteToConfig()
    return

ToggleStartHotkey:
    Gui, Submit, NoHide
    isStartHotkeyEnabled := IsStartHotkeyEnabledVar
    WriteToConfig()
    return

PlayEndBeepDemo:
    SoundBeep, 888, 128
    return

PlayStartBeepDemo:
    PlayBeepStartSequence(sequenceRunner.actionDelay)
    return

DisplayHotkeys:
    MsgBox, % keysText
    return

DisplayHelp:
    if (FileExist(imgFile))
        Run %imgFile%
    Else
        MsgBox, MISSING IMAGE !@`nPlease return "crafter_img.png" to the local directory!
    return

SetButton:
    if (WinExist("Minecraft")) {
        MouseGetPos,,,, buttonControlClass
        WinActivate, Minecraft

        Switch buttonControlClass {
            case "Button1":
                GuiControlGet, output, Name, Seq1Var
                tracker.Start(output, buttonControlClass, "seq1CraftPosX", "seq1CraftPosY")
            case "Button2":
                GuiControlGet, output, Name, Seq2Var
                tracker.Start(output, buttonControlClass, "seq2ItemPosX", "seq2ItemPosY")
            case "Button3":
                GuiControlGet, output, Name, Seq3Var
                tracker.Start(output, buttonControlClass, "seq3InventSlotPosX", "seq3InventSlotPosY")
            case "Button4":
                GuiControlGet, output, Name, Seq4Var
                tracker.Start(output, buttonControlClass, "seq4AssistSinglePosX", "seq4AssistSinglePosY")
            case "Button5":
                GuiControlGet, output, Name, Seq5Var
                tracker.Start(output, buttonControlClass, "seq5AssistMultiPosX", "seq5AssistMultiPosY")
            case "Button6":
                GuiControlGet, output, Name, Seq6Var
                tracker.Start(output, buttonControlClass, "seq6CreateItemPosX", "seq6CreateItemPosY")
            case "Button7":
                GuiControlGet, output, Name, Seq7Var
                tracker.Start(output, buttonControlClass, "seq7CraftedItemPosX", "seq7CraftedItemPosY")
        }
    }
    Else {
        MsgBox, % "No window found with the name: Minecraft"
    }
    return

StartSequence:
    if (WinExist("Minecraft")) {
        GuiControlGet, output, Name, StartButton
        sequenceRunner.Start(output)

        WinActivate, Minecraft
        MouseMove, seq1CraftPosX, seq1CraftPosY
        if (isBeepStartEnabled)
            PlayBeepStartSequence(sequenceRunner.actionDelay)
        SendInput, {Esc}
    }
    Else {
        MsgBox, % "No window found with the name: Minecraft"
    }
    return

DemoSequence:
    if (WinExist("Minecraft")) {
        speed := 300

        WinActivate, Minecraft
        MouseMove, seq1CraftPosX, seq1CraftPosY
        SendInput, {Esc}
        Sleep 500

        SendMouseMove(-200, 0)
        SendMouseMove(-200, 0)
        Sleep % speed
        SendInput, {Rbutton}
        Sleep % speed

        MouseMove, seq2ItemPosX, seq2ItemPosY
        Sleep % speed
        MouseMove, seq2ItemPosX, seq2ItemPosY + 32
        Sleep % speed
        MouseMove, seq3InventSlotPosX, seq3InventSlotPosY
        Sleep % speed
        SendInput, {Esc}
        Sleep % speed

        SendMouseMove(200, 0)
        SendMouseMove(200, 0)
        Sleep % speed
        SendInput, {RButton}
        Sleep % speed

        MouseMove, seq4AssistSinglePosX, seq4AssistSinglePosY
        Sleep % speed
        MouseMove, seq6CreateItemPosX, seq6CreateItemPosY
        Sleep % speed

        MouseMove, seq5AssistMultiPosX, seq5AssistMultiPosY
        Sleep % speed
        MouseMove, seq6CreateItemPosX, seq6CreateItemPosY
        Sleep % speed

        MouseMove, seq5AssistMultiPosX, seq5AssistMultiPosY
        Sleep % speed
        MouseMove, seq6CreateItemPosX, seq6CreateItemPosY
        Sleep % speed
        SendInput, {Esc}
        Sleep % speed

        SendMouseMove(200, 0)
        SendMouseMove(200, 0)
        Sleep % speed
        SendInput, {RButton}
        Sleep % speed

        MouseMove, seq7CraftedItemPosX, seq7CraftedItemPosY
        Sleep % speed
        MouseMove, seq7CraftedItemPosX + 32, seq7CraftedItemPosY
        Sleep % speed
        MouseMove, seq7CraftedItemPosX + 64, seq7CraftedItemPosY
        Sleep % speed
        SendInput, {Esc}
        Sleep % speed

        ; Move back to centre ----
        SendMouseMove(-200, 0)
        SendMouseMove(-200, 0)
        Sleep % speed
        SendInput, {Esc}
    }
    Else {
        MsgBox, % "No window found with the name: Minecraft"
    }
    return

; Functions ========

CreateConfigIfNoneExists() {
    global configFile
    if not (FileExist(configFile)) {
        FileAppend,
        (
            [Locations]
            craftingTablePosX = 0
            craftingTablePosY = 0
            itemToCraftPosX = 0
            itemToCraftPosY = 0
            inventorySlotPosX = 0
            inventorySlotPosY = 0
            craftAssistSinglePosX = 0
            craftAssistSinglePosY = 0
            craftAssistMultiPosX = 0
            craftAssistMultiPosY = 0
            createItemPosX = 0
            createItemPosY = 0
            craftedItemPosX = 0
            craftedItemPosY = 0
            [Settings]
            isBeepOnStartEnabled =1
            isBeepOnEndEnabled =1
            isStartHotkeyEnabled = 0
        ), % configFile, utf-16
    }
    return
}

ReadFromConfig() {
    global
    IniRead, seq1CraftPosX, % configFile, Locations, craftingTablePosX
    IniRead, seq1CraftPosY, % configFile, Locations, craftingTablePosY

    IniRead, seq2ItemPosX, % configFile, Locations, itemToCraftPosX
    IniRead, seq2ItemPosY, % configFile, Locations, itemToCraftPosY

    IniRead, seq3InventSlotPosX, % configFile, Locations, inventorySlotPosX
    IniRead, seq3InventSlotPosY, % configFile, Locations, inventorySlotPosY

    IniRead, seq4AssistSinglePosX, % configFile, Locations, craftAssistSinglePosX
    IniRead, seq4AssistSinglePosY, % configFile, Locations, craftAssistSinglePosY

    IniRead, seq5AssistMultiPosX, % configFile, Locations, craftAssistMultiPosX
    IniRead, seq5AssistMultiPosY, % configFile, Locations, craftAssistMultiPosY

    IniRead, seq6CreateItemPosX, % configFile, Locations, createItemPosX
    IniRead, seq6CreateItemPosY, % configFile, Locations, createItemPosY

    IniRead, seq7CraftedItemPosX, % configFile, Locations, craftedItemPosX
    IniRead, seq7CraftedItemPosY, % configFile, Locations, craftedItemPosY

    IniRead, isBeepStartEnabled, % configFile, Settings, isBeepOnStartEnabled
    IniRead, isBeepEndEnabled, % configFile, Settings, isBeepOnEndEnabled
    IniRead, isStartHotkeyEnabled, % configFile, Settings, isStartHotkeyEnabled
}

WriteToConfig() {
    global
    IniWrite, % seq1CraftPosX, % configFile, Locations, craftingTablePosX
    IniWrite, % seq1CraftPosY, % configFile, Locations, craftingTablePosY

    IniWrite, % seq2ItemPosX, % configFile, Locations, itemToCraftPosX
    IniWrite, % seq2ItemPosY, % configFile, Locations, itemToCraftPosY

    IniWrite, % seq3InventSlotPosX, % configFile, Locations, inventorySlotPosX
    IniWrite, % seq3InventSlotPosY, % configFile, Locations, inventorySlotPosY

    IniWrite, % seq4AssistSinglePosX, % configFile, Locations, craftAssistSinglePosX
    IniWrite, % seq4AssistSinglePosY, % configFile, Locations, craftAssistSinglePosY

    IniWrite, % seq5AssistMultiPosX, % configFile, Locations, craftAssistMultiPosX
    IniWrite, % seq5AssistMultiPosY, % configFile, Locations, craftAssistMultiPosY

    IniWrite, % seq6CreateItemPosX, % configFile, Locations, createItemPosX
    IniWrite, % seq6CreateItemPosY, % configFile, Locations, createItemPosY

    IniWrite, % seq7CraftedItemPosX, % configFile, Locations, craftedItemPosX
    IniWrite, % seq7CraftedItemPosY, % configFile, Locations, craftedItemPosY

    IniWrite, % isBeepStartEnabled, % configFile, Settings, isBeepOnStartEnabled
    IniWrite, % isBeepEndEnabled, % configFile, Settings, isBeepOnEndEnabled
    IniWrite, % isStartHotkeyEnabled, % configFile, Settings, isStartHotkeyEnabled
}

SendMouseMove(x, y) {
    DllCall("mouse_event","UInt", 0x01, "UInt", x, "UInt", y)
}

PlayBeepStartSequence(delay) {
    val := delay * 8
    Sleep % val
    SoundBeep, 444, 80
    Sleep % val
    SoundBeep, 333, 90
    Sleep % val
    SoundBeep, 222, 100
    Sleep % val
    SoundBeep, 111, 128
}

; Classes ========
class CursorTracker {
    __New() {
        this.isCursorTracking := False
        this.timer := ObjBindMethod(this, "Tick")
    }
    Start(outputVar, buttonControlClass, x, y) {
        if (this.isCursorTracking = False) {
            this._px := x
            this._py := y
            this.isCursorTracking := True
            this.outputVar := outputVar
            this.activeSetButton := buttonControlClass
            timer := this.timer

            SetTimer % timer, 60
            GuiControl, MainG:Disable, % this.activeSetButton
        }
    }
    Stop() {
        if (this.isCursorTracking) {
            this.isCursorTracking := False
            timer := this.timer
            SetTimer % timer, Off
            GuiControl, MainG:Enable, % this.activeSetButton
            
            Sleep 50
            WriteToConfig()
        }
    }
    Tick() {
        MouseGetPos, x, y
        GuiControl MainG:, % this.outputVar, % x ", " y
        this.px := x
        this.py := y
        Sleep 50
    }

    px {
        get {
            local v := this._px
            return (%v%)
        }
        set {
            local v := this._px
            return (%v% := value)
        }
    }
    py {
        get {
            local v := this._py
            return (%v%)
        }
        set {
            local v := this._py
            return (%v% := value)
        }
    }
}

class CraftSequenceRunner {
    __New() {
        this.isCraftSequenceRunning := False
        this.actionDelay := 140
        this.timer := ObjBindMethod(this, "Tick")
    }
    Start(targetButton) {
        if (this.isCraftSequenceRunning = False) {
            this.activeButton := targetButton
            this.isCraftSequenceRunning := True
            this.isFirstMovement := True
            GuiControl, MainG:Disable, % this.activeButton

            timer := this.timer
            frequency := 33 * this.actionDelay + 1000
            SetTimer % timer, % frequency
        }
    }
    Stop() {
        if (this.isCraftSequenceRunning) {
            this.isCraftSequenceRunning := False
            this.isFirstMovement := True
            timer := this.timer
            SetTimer % timer, Off

            Sleep 500
            GuiControl, MainG:Enable, % this.activeButton
        }
    }
    Tick() {
        global
        
        ; Open left shulker ----
        ; For some stupid reason first move command never works upon start, hence the double calls elsewhere
        SendMouseMove(-200, 0)
        if (this.isFirstMovement) {
            SendMouseMove(-200, 0)
            this.isFirstMovement := False
        }
        Sleep % this.actionDelay
        SendInput, {Rbutton}
        Sleep % this.actionDelay

        ; Take out all craftables into inventory ----
        MouseMove, seq2ItemPosX, seq2ItemPosY
        Sleep % this.actionDelay
        SendInput, {LButton}
        Sleep % this.actionDelay
        MouseMove, seq2ItemPosX, seq2ItemPosY + 32
        Sleep % this.actionDelay
        SendInput, {Shift down}
        SendInput, {LButton 2}
        SendInput, {Shift up}
        Sleep % this.actionDelay
        MouseMove, seq3InventSlotPosX, seq3InventSlotPosY
        Sleep % this.actionDelay
        SendInput, {LButton}
        Sleep 500
        SendInput, {Esc}
        Sleep % this.actionDelay

        ; Open crafting table ----
        SendMouseMove(200, 0)
        SendMouseMove(200, 0)
        Sleep % this.actionDelay
        SendInput, {RButton}
        Sleep % this.actionDelay

        ; Craft all items ----
        MouseMove, seq4AssistSinglePosX, seq4AssistSinglePosY
        Sleep % this.actionDelay
        SendInput, {Shift down}
        
        SendInput, {LButton}
        Sleep % this.actionDelay
        MouseMove, seq6CreateItemPosX, seq6CreateItemPosY
        Sleep % this.actionDelay
        SendInput, {LButton}
        Sleep % this.actionDelay

        MouseMove, seq5AssistMultiPosX, seq5AssistMultiPosY
        Sleep % this.actionDelay
        SendInput, {LButton}
        Sleep % this.actionDelay
        MouseMove, seq6CreateItemPosX, seq6CreateItemPosY
        Sleep % this.actionDelay
        SendInput, {LButton}
        Sleep % this.actionDelay

        MouseMove, seq5AssistMultiPosX, seq5AssistMultiPosY
        Sleep % this.actionDelay
        SendInput, {LButton}
        Sleep % this.actionDelay
        MouseMove, seq6CreateItemPosX, seq6CreateItemPosY
        Sleep % this.actionDelay
        SendInput, {LButton}
        Sleep % this.actionDelay

        SendInput, {Shift up}
        SendInput, {Esc}
        Sleep % this.actionDelay

        ; Open right shulker ----
        SendMouseMove(200, 0)
        SendMouseMove(200, 0)
        Sleep % this.actionDelay
        SendInput, {RButton}
        Sleep % this.actionDelay

        ; Put crafted items into shulker and close ----
        SendInput, {Shift down}
        MouseMove, seq7CraftedItemPosX, seq7CraftedItemPosY
        Sleep % this.actionDelay
        SendInput, {LButton}
        Sleep % this.actionDelay

        MouseMove, seq7CraftedItemPosX + 32, seq7CraftedItemPosY
        Sleep % this.actionDelay
        SendInput, {LButton}
        Sleep % this.actionDelay

        MouseMove, seq7CraftedItemPosX + 64, seq7CraftedItemPosY
        Sleep % this.actionDelay
        SendInput, {LButton}
        Sleep % this.actionDelay

        SendInput, {Shift up}
        SendInput, {Esc}
        Sleep % this.actionDelay

        ; Move back to centre ----
        SendMouseMove(-200, 0)
        SendMouseMove(-200, 0)
        Sleep 300
    }
}

; Hotkeys ========
~LButton::
    if (tracker.isCursorTracking) {
        tracker.Stop()
    }
    return

NumPad0::
    if (sequenceRunner.isCraftSequenceRunning) {
        if (isBeepEndEnabled)
            SoundBeep, 888, 128
        sequenceRunner.Stop()
    }
    return

#if (isStartHotkeyEnabled = True)
RControl::
    if (sequenceRunner.isCraftSequenceRunning = False) {
        Gosub, StartSequence
    }
    return

LControl & RAlt::ExitApp