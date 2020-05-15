#ifWinActive Remnant
#SingleInstance Force
#MaxHotkeysPerInterval 9999
#CommentFlag //
#InstallKeybdHook
#Persistent

//Set this to the minimum  FPS you hit during gameplay. Most should be 50-60. Being a little high or low should not change too much,
//though it may make it less smooth.
minFps := 90

//Set these to your forward movement key. W is default.
forwardKey := "w"

frameTime := % Floor(1000 / minFps) + 1

Process, Priority, , H
SetKeyDelay -1, -1
SendMode Input

sprintState := new SprintState(forwardKey, frameTime)

sprintTimer := sprintState.resetTimer


$*LShift::
	SendInput {LShift Down}
	sprintState.isSprinting := A_TickCount
	//sprintState.shiftUpTime(-frameTime)
	SetTimer % sprintTimer, 550
	KeyWait LShift, "P"
	if (GetKeyState(forwardKey, "P") || GetKeyState("a", "P") || GetKeyState("d", "P")) {
		sprintState.resetStateAndWalk()
	} else {
		sprintState.resetState()
	}
	SetTimer % sprintTimer, off
	SendInput {LShift Up}
	//long max
	 sprintState.isSprinting := 9223372036854775807
return


class SprintState {
	__New(forwardKey, frameTime) {
		this.isSprinting := 9223372036854775807
		this.resetTimer := ObjBindMethod(this, "resetStateAndSprint")
		this.shiftUpTimer := ObjBindMethod(this, "shiftUp")
		this.startWalkTimer := ObjBindMethod(this, "startWalk")
		this.startSprintTimer := ObjBindMethod(this, "startSprint")
		this.strafeTimer := ObjBindMethod(this, "setStrafe")
		this.forwardKey := forwardKey
		this.frameTime := frameTime
		resetTimer := ObjBindMethod(this, "checkToRun")
		
	}
	
	setSprinting() {
		this.isSprinting := 1
		SetTimer % this.shiftUpTimer, % -frameTime
	}
	
	resetState() {
		forwardKey := this.forwardKey
		SendInput {%forwardKey% Up}
		SendInput {LShift Up}
		SendInput {a Up}
		SendInput {d Up}
	}
	
	resetStateAndWalk() {
		this.resetState()
		DllCall("Sleep", UInt, this.frameTime)
		this.startWalk()
	}
	
	resetStateAndSprint() {
		SoundBeep 1000, 25
		if (GetKeyState("LShift", "P") && (GetKeyState("w", "P") || GetKeyState("a", "P") || GetKeyState("d", "P"))
		&& WinActive("ahk_exe Remnant-Win64-Shipping.exe")) {
			this.resetState()
			this.startSprintTime(-this.frameTime)
		}
	}
	
	startSprint() {
		forwardKey := this.forwardKey
		if (GetKeyState(forwardKey, "P")) {
			SendInput {%forwardKey% Down}
		}
		this.setStrafe()
		SendInput {LShift Down}
		//this.setStrafeTime(-frameTime)
		//this.shiftUpTime(-(this.frameTime + 2))
	}
	
	startSprintTime(time) {
		//MsgBox %time%
		startSprintTimer := this.startSprintTimer
		SetTimer % startSprintTimer, % time
	}
	
	
	
	resetStateTime(time) {
		resetTimer := this.resetTimer
		SetTimer % resetTimer, % time
	}
	
	shiftUp() {
		SendInput {LShift Up}
	}
	
	shiftUpTime(time) {
		shiftUp := this.shiftUpTimer
		SetTimer % shiftUp, % time
	}
	
	startWalk() {
		forwardKey := this.forwardKey
		if (GetKeyState(forwardKey, "P")) {
			SendInput {%forwardKey% Down}
		}
		this.setStrafe()
	}
	
	startWalkTimer(time) {
		startWalk := this.startWalkTimer
		SetTimer % startWalk, % time
	}
	
	setStrafe() {
		if (GetKeyState("A", "P")) {
			SendInput {A Down}
		} else {
			SendInput {A Up}
		}
		if (GetKeyState("D", "P")) {
			SendInput {D Down}
		} else {
			SendInput {D Up}
		}
	}
	
	setStrafeTime(time) {
		strafeTimer := this.strafeTimer
		SetTimer % strafeTimer, % time
	}
	
	checkToRun() {
	
		current := A_TickCount
		sprinting = % this.isSprinting
		
		if ((current - 450) > this.isSprinting) {
			this.resetStateAndSprint()
		}
	}
}


