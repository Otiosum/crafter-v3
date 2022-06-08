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
        > Numpad End : Stop Crafting
        > RCtrl : Start Crafting (If toggled)
        > Alt Gr : Exit program
        > Test Button : Run a slow sequence demo without left clicks
        > Start Button : Starts the crafting sequence
    )

; TODO: Shulker box crafting mode (dropping items instead of deposit into box)

; Exposed variables ========
; Sequence vars
sequenceList := ""
sequenceCount := 2
selectedSequence := 0
SelectedCraftCategory := 0

seqIsDropCraft := False
seqIsFixedCategory := False

; Settings
isBeepStartEnabled := True
isBeepEndEnabled := True
isStartHotkeyEnabled := False
isServerModeEnabled := False
guiScale := 2
selectedCraftCategory := 1

; Class variables ========
tracker := new CursorTracker
sequenceRunner := new CraftSequenceRunner

; Load data from config ========
CreateConfigIfNoneExists()
ReadFromConfig()

; Create GUI elements ========
Gui MainG: Add, Text, x20 y+10, Select sequence
Gui MainG: Add, DropDownList, x+10 r5 AltSubmit vSelectedSequence gUpdateSelection Choose%selectedSequence%, %sequenceList%

Gui MainG: Add, Text, x20 y+5 w80, Crafting category
Gui MainG: Add, DropDownList, x+10 r5 w70 AltSubmit gSelectCraftCategory vSelectedCraftCategory Choose%selectedCraftCategory%, Weapons|Blocks|Misc|Redstone

Gui MainG: Add, Text, x20 y+5 w80, GUI scaling
Gui MainG: Add, DropDownList, x+10 r5 w50 gSelectGuiScale vGuiScaleVar Choose%guiScale%, 1|2||3|4|

Gui MainG: Add, Text, x5 y+5 w240 0x10 ; Horizontal Etched line
Gui MainG: Add, Button, x70 y+0 w50 h18 gDemoSequence, Test
Gui MainG: Add, Button, x+10 w50 h18 gStartSequence vStartButton, Start
Gui MainG: Add, Text, x5 y+10 w240 0x10 ; Horizontal Etched line

Gui MainG: Add, Checkbox, x20 y+0 w150 h16 gToggleBeepOnStop vIsBeepEndEnabledVar Checked%isBeepEndEnabled%, Play BEEP when stopped
Gui MainG: Add, Button, x+0 w40 h18 gPlayEndBeepDemo, Demo
Gui MainG: Add, Checkbox, x20 y+2 w150 h16 gToggleBeepOnStart vIsBeepStartEnabledVar Checked%isBeepStartEnabled%, Play BEEPs when starting
Gui MainG: Add, Button, x+0 w40 h18 gPlayStartBeepDemo, Demo
Gui MainG: Add, Checkbox, x20 y+2 h16 gToggleStartHotkey vIsStartHotkeyEnabledVar Checked%isStartHotkeyEnabled%, Allow hotkey to start sequence
Gui MainG: Add, Checkbox, x20 y+2 h16 gToggleServerMode vIsServerModeEnabledVar Checked%isServerModeEnabled%, Server mode

Gui MainG: Add, Button, x44 y320 w80 h18 gDisplayHotkeys, Hotkeys
Gui MainG: Add, Button, x+2 w80 h18 gDisplayHelp, Help

Gui MainG: +AlwaysOnTop
Gui MainG: Show, w250 h350 x1650 y650, Crafter
Return

; Labels ========
MainGGuiClose:
    ExitApp
    Return

ToggleBeepOnStart:
    Gui MainG:Submit, NoHide
    isBeepStartEnabled := isBeepStartEnabledVar
    WriteToConfig()
    return

ToggleBeepOnStop:
    Gui MainG:Submit, NoHide
    isBeepEndEnabled := isBeepEndEnabledVar
    WriteToConfig()
    return

ToggleStartHotkey:
    Gui MainG:Submit, NoHide
    isStartHotkeyEnabled := isStartHotkeyEnabledVar
    WriteToConfig()
    return

ToggleServerMode:
    Gui MainG:Submit, NoHide
    isServerModeEnabled := isServerModeEnabledVar
    WriteToConfig()
    return

SelectGuiScale:
    Gui MainG:Submit, NoHide
    guiScale := guiScaleVar
    WriteToConfig()
    return

SelectCraftCategory:
    Gui MainG:Submit, NoHide
    return

UpdateSelection:
    Gui MainG:Submit, NoHide
    WriteToConfig()
    ReadSelectedSequenceDataFromConfig()

    GuiControlGet, output, Name, Seq1Var
    GuiControl, MainG:, % output, % seqCraftPosX ", " seqCraftPosY
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

StartSequence:
    if (WinExist("Minecraft")) {
        GuiControlGet, output, Name, StartButton
        sequenceRunner.Start(output)

        WinActivate, Minecraft
        MouseMove, seqCraftPosX, seqCraftPosY
        if (isBeepStartEnabled)
            PlayBeepStartSequence(sequenceRunner.actionDelay)
        Send, {Esc}
    }
    Else {
        MsgBox, % "No window found with the name: Minecraft"
    }
    return

DemoSequence:
    if (WinExist("Minecraft")) {
        speed := 300

        WinActivate, Minecraft
        MouseMove, seqCraftPosX, seqCraftPosY
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
        ( LTrim
        [1]
        sequenceName =Simple craft
        isDropCraft =0
        fixedCategory =0
        [2]
        sequenceName = Shulker box craft
        isDropCraft =1
        fixedCategory =3
        [Settings]
        isBeepOnStartEnabled =1
        isBeepOnEndEnabled =1
        isStartHotkeyEnabled =0
        isServerModeEnabled =0
        guiScale =2
        LastUsedSequenceId =1
        ), % configFile, utf-16
    }
    return
}

ReadFromConfig() {
    global

    ; Load sequence names
    tempSeqName := ""
    Loop %sequenceCount% {
        IniRead, tempSeqName, % configFile, % A_Index, sequenceName
        sequenceList .= tempSeqName "|"
    }

    ; Load settings
    IniRead, isBeepStartEnabled, % configFile, Settings, isBeepOnStartEnabled
    IniRead, isBeepEndEnabled, % configFile, Settings, isBeepOnEndEnabled
    IniRead, isStartHotkeyEnabled, % configFile, Settings, isStartHotkeyEnabled
    IniRead, isServerModeEnabled, % configFile, Settings, isServerModeEnabled
    IniRead, guiScale, % configFile, Settings, guiScale
    IniRead, selectedSequence, % configFile, Settings, LastUsedSequenceId

    ReadSelectedSequenceDataFromConfig()
}

ReadSelectedSequenceDataFromConfig() {
    global

    IniRead, seqCraftPosX, % configFile, % selectedSequence, craftingTablePosX
    IniRead, seqCraftPosY, % configFile, % selectedSequence, craftingTablePosY
    IniRead, seqIsDropCraft, % configFile, % selectedSequence, isDropCraft
}

WriteToConfig() {
    global

    IniWrite, % isBeepStartEnabled, % configFile, Settings, isBeepOnStartEnabled
    IniWrite, % isBeepEndEnabled, % configFile, Settings, isBeepOnEndEnabled
    IniWrite, % isStartHotkeyEnabled, % configFile, Settings, isStartHotkeyEnabled
    IniWrite, % isServerModeEnabled, % configFile, Settings, isServerModeEnabled
    IniWrite, % guiScale, % configFile, Settings, guiScale
    IniWrite, % selectedSequence, % configFile, Settings, LastUsedSequenceId
}

WriteSelectedSequenceDataToConfig() {
    global

    IniWrite, % seqCraftPosX, % configFile, % selectedSequence, craftingTablePosX
    IniWrite, % seqCraftPosY, % configFile, % selectedSequence, craftingTablePosY
    IniWrite, % seqIsDropCraft, % configFile, % selectedSequence, isDropCraft
}

SendMouseMove(x, y) {
    DllCall("mouse_event","UInt", 0x01, "UInt", x, "UInt", y)
}

PlayBeepStartSequence(delay) {
    ; TODO: Fix this race condition garbage (the beeps can take longer than timer, if timer is made shorter)
    val := delay * 2
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
class CraftSequenceRunner {
    __New() {
        this.isCraftSequenceRunning := False
        this.actionDelay := 100
        this.timer := ObjBindMethod(this, "Tick")
    }
    Start(targetButton) {
        if (this.isCraftSequenceRunning = False) {
            this.activeButton := targetButton
            this.isCraftSequenceRunning := True
            this.isFirstMovement := True
            (isServerModeEnabled) ? this.frequencyCoef := 20 : this.frequencyCoef := 10
            GuiControl, MainG:Disable, % this.activeButton

            ; WinGetPos,,,width, height
            ; SysGet, borderSize, 32
            ; this.winWidth := width - borderSize
            ; this.winHeight := height - borderSize
            ; OutputDebug, % this.winWidth "," this.winHeight

            timer := this.timer
            frequency := this.frequencyCoef * this.actionDelay + 1000
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

        Switch selectedSequence {
            case 1:
                this.RunSingleCraftSequence()
                return
            case 2:
                this.RunDoubleDropCraftSequence()
                return
        }
    }

    ; Single craft
    RunSingleCraftSequence() {
        global
        ; multiply these by the gui scale to get needed offset
        baseSelectFirstItemX := -70
        baseSelectFirstItemY := -60
        baseMoveToItemY := 20

        baseCategoryX := -170
        baseCategoryY := [-40, -20, 20, 40]

        baseSelectCraftItemX := -140
        baseSelectCraftItemY := -40
        baseCraftItemX := 120
        baseSelectRightItemX := 70

        ; Open left shulker ====
        ; For some stupid reason first move command never works upon start, hence the double calls elsewhere
        SendMouseMove(-200, 0)
        if (this.isFirstMovement) {
            SendMouseMove(-200, 0)
            this.isFirstMovement := False
        }
        SendInput, {Rbutton}
        Sleep % this.actionDelay

        ; Take out all items into inventory ====
        MouseMove, baseSelectFirstItemX * guiScale, baseSelectFirstItemY * guiScale,, R
        Sleep % this.actionDelay
        SendInput, {LButton}
        MouseMove, 0, baseMoveToItemY * guiScale,, R
        Sleep % this.actionDelay
        SendInput, {Shift down}
        SendInput, {LButton 2}
        SendInput, {Shift up}
        SendInput, {Esc}
        Sleep % this.actionDelay

        ; Open crafting table ====
        Sleep % this.actionDelay
        SendMouseMove(200, 0)
        SendMouseMove(200, 0)
        SendInput, {RButton}
        Sleep % this.actionDelay
        if (isServerModeEnabled)
            Sleep % this.actionDelay

        ; Craft all items ====
        MouseGetPos, x, y
        MouseMove, baseCategoryX * guiScale, baseCategoryY[selectedCraftCategory] * guiScale,, R
        SendInput, {LButton}
        MouseMove, x, y

        this.CraftItemStack(x, y)
        this.CraftItemStack(x, y)
        this.CraftItemStack(x, y)
        Sleep % this.actionDelay
        SendInput, {Esc}
        Sleep % this.actionDelay

        ; Open right shulker ====
        SendMouseMove(200, 0)
        SendMouseMove(200, 0)
        SendInput, {RButton}
        Sleep % this.actionDelay
        Sleep % this.actionDelay

        ; Deposit all items ====
        MouseMove, baseSelectRightItemX * guiScale, 0,, R
        Sleep % this.actionDelay
        SendInput, {Shift down}
        SendInput, {LButton}
        MouseMove, 0, baseMoveToItemY * guiScale,, R
        SendInput, {LButton}
        MouseMove, 0, baseMoveToItemY * guiScale,, R
        SendInput, {LButton}
        SendInput, {Shift up}
        Sleep % this.actionDelay
        SendInput, {Esc}
        Sleep % this.actionDelay

        ; Move back to centre ====
        SendMouseMove(-200, 0)
        SendMouseMove(-200, 0)
        Sleep % this.actionDelay
    }

    RunDoubleDropCraftSequence() {
        global
        ; Open left shulker

        ; Take out 18 stacks of items

        ; Open right shulker

        ; Take out 9 stacks of items

        ; Open crafting table

        ; Craft all items

    }

    CraftItemStack(x, y) {
        global
        MouseMove, baseSelectCraftItemX * guiScale, baseSelectCraftItemY * guiScale,, R
        SendInput, {Shift down}
        SendInput, {LButton}
        MouseMove, x, y

        MouseMove, baseCraftItemX * guiScale, baseSelectCraftItemY * guiScale,, R
        if (isServerModeEnabled)
            Sleep % this.actionDelay
        SendInput, {LButton}
        SendInput, {Shift up}
        MouseMove, x, y
        Sleep % this.actionDelay
    }
}

; Hotkeys ========

; NumpadEnd
vk23::
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
#if
LControl & RAlt::ExitApp