#NoEnv
#SingleInstance, force
CoordMode, Mouse, Client
SendMode, Input

tracker := new CursorTracker
posX := 0
posY := 0

Gui MainG: Add, Text, x5 y+5 w240 0x10 ; Horizontal Etched line
Gui MainG: Add, Text, x20 y+0 w85 h18, Position
Gui MainG: Add, Text, x+0 w60 h18 vSeq1Var, % posX ", " posY
Gui MainG: Add, Button, x+5 w40 h14 gSetButton, Track
Gui MainG: Add, Text, x5 y+5 w240 0x10 ; Horizontal Etched line

Gui MainG: +AlwaysOnTop
Gui MainG: Show, w250 h100 x1650 y850, M Coordinates
return


SetButton:
    if (WinExist("Minecraft")) {
        MouseGetPos,,,, buttonControlClass
        WinActivate, Minecraft

        GuiControlGet, output, Name, Seq1Var
        tracker.Start(output, buttonControlClass, "posX", "posY")
    }
    Else {
        MsgBox, % "No window found with the name: Minecraft"
    }
    return


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

~LButton::
    if (tracker.isCursorTracking) {
        tracker.Stop()
    }
    return