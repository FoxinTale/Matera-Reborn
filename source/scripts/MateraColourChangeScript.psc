Scriptname MateraColourChangeScript extends ReferenceAlias

import NiOverride
; There's a lot of repeated code in here. Blame the game for being a stupid piece of shit and not recognising the goddamn script properties.
; I had hoped to simply reference it, and just use the below "mrms.FunctionName()", but apparently the game is too damn stupid to realize this is what I'm telling it to do.
Actor Property PlayerRef Auto
MateraRaceMenuScript Property mrms Auto  ;Abbreviation of the script name, Matera Race Menu Script
Armor Property MateraBody Auto
GlobalVariable Property BodyColorGlobal Auto

Race Property MateraRace Auto
Race Property MateraVampireRace Auto

FormList Property FemaleBodyColour_List Auto
FormList Property FemaleHandsColour_List Auto
FormList Property MaleBodyColourList Auto
FormList Property MaleHandsColourList Auto
FormList Property TailColourList Auto

Int BodyColour
Int TailType = 0

Bool IsMale = true
Bool IsMatera = false
Bool processing = false


Event OnInit()
    RegisterForMenu("RaceSex Menu")
    CheckValues()
EndEvent


Event OnPlayerLoadGame()
    Log("Game has been loaded.")
    CheckValues()

    Utility.Wait(0.2)

    If(IsMatera)
		If(IsMale)
			SetMaleBodyColour()
		Else
			mrms.SetFemaleBodyColour()
		EndIf

		While(processing) ; It may take a little bit to process through the armor and addon nodes, so wait until that is done before moving on.
			Utility.Wait(0.1)
		EndWhile

		MateraRaceMenuScript.SetTailColour()
		PlayerRef.QueueNiNodeUpdate()
	EndIf
EndEvent


Event OnMenuClose(String menuname)
	If(MenuName == "RaceSex Menu")
        ;Utility.Wait(15.0)
        CheckValues()
    EndIf
EndEvent


Event OnObjectEquipped(Form BaseObject, ObjectReference Ref)
    If(IsMatera)
        If(BaseObject as Armor)
            Armor arm = BaseObject as Armor

            If(arm.GetSlotMask() == 4)
                If(IsMale)
                   SearchAndSetBody(false, arm, MateraRaceMenuScript.GetMaleBodyTex())
                Else
                    SearchAndSetBody(true, arm, MateraRaceMenuScript.GetFemaleBodyTex())
                EndIf

            ElseIf(arm.GetSlotMask() == 8)
                If(IsMale)
                    MateraRaceMenuScript.SearchAndSet(false, arm, "Hands", MateraRaceMenuScript.GetMaleHandsTex()) ; I have no idea if this is the correct node for male hands. I don't think it is.
                Else
                    MateraRaceMenuScript.SearchAndSet(true, arm, "Hands", MateraRaceMenuScript.GetFemaleHandsTex())
                EndIf

            ElseIf(arm.GetSlotMask() == 80) ; Slot 128 temporarily removed.
                If(IsMale)
                   MateraRaceMenuScript.SearchAndSet(false, arm, "Feet", MateraRaceMenuScript.GetMaleBodyTex()) ; I have no idea if this is the correct node for male feet. I don't think it is.
;                    SearchAndSet(false, arm, "Feet", BodyTextures[2])
                Else
                    MateraRaceMenuScript.SearchAndSet(true, arm, "Feet", MateraRaceMenuScript.GetFemaleBodyTex())
;                   SearchAndSet(true, arm, "Feet", BodyTextures[0])
                EndIf

            Else
                Debug.Trace("Something was equipped by the player!")
                ArmorDebug(arm)
            EndIf
        EndIf
    EndIf
EndEvent



; This should actually work for both males and females.
Event OnObjectUnEquipped(Form BaseObject, ObjectReference Ref)
    If(IsMatera)
        If(BaseObject as Armor)
            
            Armor arm  = BaseObject as Armor
            
            If(arm.GetSlotMask() == 4) ; Just the body, slot 32.
                If(IsMale)
                    ;aaaaaaaa
                Else
;                   AddOverrideTextureSet(PlayerRef, true, MateraBody, mrms.GetMateraTorso(), "", 6, -1, mrms.GetFemaleBodyTex(), true)
                    AddOverrideTextureSet(PlayerRef, true, MateraBody, BodyParts[0], "", 6, -1, BodyTextures[0], true)
                EndIf

            ElseIf(arm.GetSlotMask() == 8) ; Hands, slot 33
;               AddOverrideTextureSet(PlayerRef, true, MateraBody, BodyParts[1], "", 6, -1, BodyTextures[1], true)
               If(IsMale)
                   SetColour(MateraRaceMenuScript.GetMateraHands(), "Hands", MateraRaceMenuScript.GetMaleHandsTex())
               Else
;                   SetColour(mrms.GetMateraHands(), "Hands", mrms.GetFemaleHandsTex())
                    SetColour(BodyParts[1], "Hands", BodyTextures[1])
               EndIf

            ElseIf(arm.GetSlotMask() == 80 || arm.GetSlotMask() == 128) ; Feet, Slot 37
                If(IsMale)
;                   SetColour(mrms.GetMateraFeet(), "Feet", mrms.GetMaleBodyTex())
                    SetColour(BodyParts[2], "Feet", BodyTextures[2])
                Else
;                   SetColour(mrms.GetMateraFeet(), "Feet", mrms.GetFemaleBodyTex())
                    SetColour(BodyParts[2], "Feet", BodyTextures[0])
                EndIf

            ElseIf(arm.GetSlotMask() == 4098)
                Debug.Trace("Player unequipped a hood, or hat.")

            Else
                Debug.Trace("Something was unequipped by the player!")
                ArmorDebug(arm)
            EndIf
            
            Utility.Wait(0.1)
            PlayerRef.QueueNiNodeUpdate()
        EndIf
    EndIf
EndEvent


Event OnRaceSwitchComplete()
	Log("Race switch complete.")
EndEvent


Function RaceCheck()
    If(PlayerRef.GetRace() == MateraRace || PlayerRef.GetRace() == MateraVampireRace)
        IsMatera = true
    Else
        IsMatera = false    
    EndIf
EndFunction


; This is done this way because there are mods that exist that add claws or nails to the feet/hands.
; Were this not taken into account, it is possible that the feet texture gets applied to the claws or nails, and we don't want that.
Function SetColour(ArmorAddon bodypart, String node, TextureSet tex)
    If(HasArmorAddonNode(PlayerRef, false, MateraBody, bodypart, node, true))
;        AddOverrideTextureSet(PlayerRef, !mrms.GetIsMale(), MateraBody, bodypart, node, 6, -1, tex, true)
        AddOverrideTextureSet(PlayerRef, !IsMale, MateraBody, bodypart, node, 6, -1, tex, true)
    Else
        AddOverrideTextureSet(PlayerRef, !IsMale, MateraBody, bodypart, "", 6, -1, tex, true)
    EndIf
EndFunction


Function CheckValues()
    BodyColour = BodyColorGlobal.GetValueInt()

    CheckSex()
    RaceCheck()

    If(PlayerRef == None)
        PlayerRef = Game.GetPlayer()
    EndIf
EndFunction


;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Repeated code from Matera Race Menu Script, because the damn thing won't let me use shared scripts for some damn reason.
; It's literally copied from the Matera Race Menu Script. Comments and all. If someone can get the two scripts to talk, you can remove this entire segment.



; This checks the body part for a node. I mentioned in an earlier comment that if it's the only node, it won't find it. 
; However, there are mods that add nodes to the hands and/or feet in the shape of nails or claws. This handles that scenario.
Function PartCheck(Bool female, ArmorAddon bodypart, String node, TextureSet tex)
	If(HasArmorAddonNode(PlayerRef, false, MateraBody, bodypart, node, true))
		AddOverrideTextureSet(PlayerRef, female, MateraBody, bodypart, node, 6, -1, tex, true)
	Else
		AddOverrideTextureSet(PlayerRef, female, MateraBody, bodypart, "" , 6, -1, tex, true)
	EndIf
EndFunction
	

Function SetMaleBodyColour()
	; Not implemented yet. Awating to make female body work first. CBBE mainly works, UNP is totally untested.
EndFunction
	

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Utility functions 

Function SearchAndSetBody(bool IsFemale, Armor arm, TextureSet tex)
	int i = 0 
	int addoncount = arm.GetNumArmorAddons()
    TextureSet femalebody = MateraRaceMenuScript.GetFemaleBodyTex()

	While(i < addoncount)
        If(HasArmorAddonNode(PlayerRef, false, arm, Arm.GetNthArmorAddon(i), "CBBE", true))
            AddOverrideTextureSet(PlayerRef, true, arm, Arm.GetNthArmorAddon(i), "CBBE", 6, -1, femalebody, true)
            i = addoncount ; Break out of the loop, we've found the node.

        ElseIf(HasArmorAddonNode(PlayerRef, false, arm, Arm.GetNthArmorAddon(i), "3BBB", true))
            AddOverrideTextureSet(PlayerRef, true, arm, Arm.GetNthArmorAddon(i), "3BBB", 6, -1, femalebody, true)
            i = addoncount

        ElseIf(HasArmorAddonNode(PlayerRef, false, arm, Arm.GetNthArmorAddon(i), "UNP", true))
            AddOverrideTextureSet(PlayerRef, true, arm, Arm.GetNthArmorAddon(i), "UNP", 6, -1, femalebody, true)
            i = addoncount

        ElseIf(HasArmorAddonNode(PlayerRef, false, arm, Arm.GetNthArmorAddon(i), "BaseShape", true))
            AddOverrideTextureSet(PlayerRef, true, arm, Arm.GetNthArmorAddon(i), "BaseShape", 6, -1, femalebody, true)
            i = addoncount

		Else
			Log("Node not found on armor piece" + arm.GetName() + ".")
		EndIf
		i += 1
	EndWhile
    PlayerRef.QueueNiNodeUpdate()
EndFunction


;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;"Debug" functions.

Function Log(String s)
	Debug.Trace("(Matera Reborn CC) |  " + s) ; CC = Colour Change, so I know which script is logging this.
EndFunction


; Does exactly what it says. This is meant for my usage, so I know if a armor piece isn't working, what the issue is.
Function ArmorDebug(Armor arm)
    Debug.Trace("Armor name: " + arm.GetName())
    Debug.Trace("Armor Item Slot: " + arm.GetSlotMask())
    Debug.Trace("Armor addon count: " + arm.GetNumArmorAddons())
    Debug.Trace("-------------")
EndFunction
