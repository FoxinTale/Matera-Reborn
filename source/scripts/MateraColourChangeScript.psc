Scriptname MateraColourChangeScript extends ReferenceAlias

import NiOverride

Actor Property PlayerRef Auto
MateraRaceMenuScript Property mrms auto hidden  ;Abbreviation of the script name, Matera Race Menu Script
Armor Property MateraBody Auto

Race Property MateraRace Auto
Race Property MateraVampireRace Auto

Formlist Property MateraTailList Auto
FormList Property MateraEarsList Auto

Bool IsMale = true ; I decided on leaving this in instead of using the "mrms.GetIsMale()" repeatedly to hopefully have things be a little bit faster.
Bool IsMatera = false

Event OnInit()
    Form RaceMenuFunctionality = Game.GetFormFromFile(0x81E, "MateraReborn_RaceMenu.esp")

    If(RaceMenuFunctionality)
        mrms = RaceMenuFunctionality as MateraRaceMenuScript ; This actually works!!
    Else
        Log("Unable to get form from file.")
    EndIf

    RegisterForMenu("RaceSex Menu")
    CheckValues()
EndEvent


Event OnPlayerLoadGame()
    Utility.Wait(0.2)

    If(IsMatera)
		If(IsMale)
			mrms.SetMaleBodyColour()
		Else
			mrms.SetFemaleBodyColour()
		EndIf

        mrms.SetTailColour()
        mrms.SetEarColour()
        
		PlayerRef.QueueNiNodeUpdate()
	EndIf
EndEvent


Event OnMenuClose(String menuname)
	If(MenuName == "RaceSex Menu")
        ;Utility.Wait(15.0)
        CheckValues()
    EndIf
EndEvent


; 0 = Feet, 1 = Torso, 2 = Hands
Event OnObjectEquipped(Form BaseObject, ObjectReference Ref)
    If(IsMatera)
        If(BaseObject as Armor)
            Armor arm = BaseObject as Armor

            If(arm.GetSlotMask() == 4)
                If(IsMale)
                    SearchAndSetBody(false, arm, mrms.GetMaleBodyTex())
                Else
                    SearchAndSetBody(true, arm, mrms.GetFemaleBodyTex())
                EndIf

            ElseIf(arm.GetSlotMask() == 8)
                If(IsMale)
                   mrms.SearchAndSet(false, arm, "Hands", 3) ; I have no idea if this is the correct node for male hands. I don't think it is.
                Else
                    mrms.SearchAndSet(true, arm, "Hands", 1)
                EndIf

            ElseIf(arm.GetSlotMask() == 80) ; Slot 128 temporarily removed.
                If(IsMale)
                    mrms.SearchAndSet(false, arm, "Feet", 2)
                Else
                   mrms.SearchAndSet(true, arm, "Feet", 0)
                EndIf

            ElseIf(arm.GetSlotMask() == 1024)
                ; Nothing. It's a tail.

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
                    AddOverrideTextureSet(PlayerRef, true, MateraBody, mrms.GetMateraTorso(), "", 6, -1, mrms.GetFemaleBodyTex(), true)
                EndIf

            ElseIf(arm.GetSlotMask() == 8) ; Hands, slot 33
               If(IsMale)
                    SetColour(mrms.GetMateraHands(), "Hands", mrms.GetMaleHandsTex())
               Else
                    SetColour(mrms.GetMateraHands(), "Hands", mrms.GetFemaleHandsTex())
               EndIf

            ElseIf(arm.GetSlotMask() == 80 || arm.GetSlotMask() == 128) ; Feet, Slot 37
                If(IsMale)
                    SetColour(mrms.GetMateraFeet(), "Feet", mrms.GetMaleBodyTex())
                Else
                    SetColour(mrms.GetMateraFeet(), "Feet", mrms.GetFemaleBodyTex())
                EndIf

            ElseIf(arm.GetSlotMask() == 1024)
                ; Just here to prevent debug logs from the tail being unequipped when it is switched. 

            ElseIf(arm.GetSlotMask() == 4098)
                ; Hood, or hat.

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
    RaceCheck()

    If(IsMatera)
        If(mrms.GetIsFirstRun())
            Armor Tail = MateraTailList.GetAt(mrms.GetTailType()) as Armor
            Armor Ears = MateraEarsList.GetAt(mrms.GetEarsType()) as Armor

            PlayerRef.Additem(Tail, 1, true)
            PlayerRef.AddItem(Ears, 1, true)

            PlayerRef.EquipItem(Tail, true, true)
            PlayerRef.EquipItem(Ears, true, true)
            
;            mrms.SetEarColour()
;            mrms.SetTailColour()

            PlayerRef.QueueNiNodeUpdate()
        EndIf
    EndIf
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
        AddOverrideTextureSet(PlayerRef, !IsMale, MateraBody, bodypart, node, 6, -1, tex, true)
    Else
        AddOverrideTextureSet(PlayerRef, !IsMale, MateraBody, bodypart, "", 6, -1, tex, true)
    EndIf
EndFunction


Function CheckValues()
    RaceCheck()

    IsMale = mrms.GetIsMale()
    
    If(PlayerRef == None)
        PlayerRef = Game.GetPlayer()
    EndIf
EndFunction


;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Utility functions 

Function SearchAndSetBody(bool IsFemale, Armor arm, TextureSet tex)
	int i = 0 
	int addoncount = arm.GetNumArmorAddons()

	While(i < addoncount)
        If(HasArmorAddonNode(PlayerRef, false, arm, Arm.GetNthArmorAddon(i), "CBBE", true))
            AddOverrideTextureSet(PlayerRef, true, arm, Arm.GetNthArmorAddon(i), "CBBE", 6, -1, mrms.GetFemaleBodyTex(), true)
            i = addoncount ; Break out of the loop, we've found the node.

        ElseIf(HasArmorAddonNode(PlayerRef, false, arm, Arm.GetNthArmorAddon(i), "3BBB", true))
            AddOverrideTextureSet(PlayerRef, true, arm, Arm.GetNthArmorAddon(i), "3BBB", 6, -1, mrms.GetFemaleBodyTex(), true)
            i = addoncount

        ElseIf(HasArmorAddonNode(PlayerRef, false, arm, Arm.GetNthArmorAddon(i), "UNP", true))
            AddOverrideTextureSet(PlayerRef, true, arm, Arm.GetNthArmorAddon(i), "UNP", 6, -1, mrms.GetFemaleBodyTex(), true)
            i = addoncount

        ElseIf(HasArmorAddonNode(PlayerRef, false, arm, Arm.GetNthArmorAddon(i), "BaseShape", true))
            AddOverrideTextureSet(PlayerRef, true, arm, Arm.GetNthArmorAddon(i), "BaseShape", 6, -1, mrms.GetFemaleBodyTex(), true)
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
