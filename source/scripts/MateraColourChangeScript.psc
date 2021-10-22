Scriptname MateraColourChangeScript extends ReferenceAlias

import NiOverride

Actor Property PlayerRef Auto
Armor Property MateraBody Auto 
GlobalVariable Property BodyColorGlobal Auto

Race Property MateraRace Auto
Race Property MateraVampireRace Auto

Int BodyColour
Int TailType = 0

;Bool IsMale = true
Bool IsMatera = false
Bool Property processing


Event OnInit()
    RegisterForMenu("RaceSex Menu")
    processing = false
    CheckValues()
EndEvent


Event OnPlayerLoadGame()
    Log("Game has been loaded.")
    CheckValues()

    Utility.Wait(0.2)

    If(IsMatera)
		If(MateraRaceMenuScript.GetIsMale())
			SetMaleBodyColour()
		Else
			SetFemaleBodyColour()
		EndIf

		While(processing) ; It may take a little bit to process through the armor and addon nodes, so wait until that is done before moving on.
			Utility.Wait(0.1)
		EndWhile

		SetTailColour()
		PlayerRef.QueueNiNodeUpdate()
	EndIf
EndEvent


Event OnMenuClose(String menuname)
	If(MenuName == "RaceSex Menu")
        CheckValues()
    EndIf
EndEvent


Event OnObjectEquipped(Form BaseObject, ObjectReference Ref)
    If(IsMatera)
        If(BaseObject as Armor)
            Armor arm = BaseObject as Armor

            If(arm.GetSlotMask() == 4)
                If(MateraRaceMenuScript.GetIsMale())
                   SearchAndSetBody(false, arm, MateraRaceMenuScript.GetMaleBodyTex())
                Else
                    SearchAndSetBody(true, arm, MateraRaceMenuScript.GetFemaleBodyTex())
                EndIf

            ElseIf(arm.GetSlotMask() == 8)
                If(MateraRaceMenuScript.GetIsMale())
                    SearchAndSet(false, arm, "Hands", MateraRaceMenuScript.GetMaleHandsTex()) ; I have no idea if this is the correct node for male hands. I don't think it is.
                Else
                    SearchAndSet(true, arm, "Hands", MateraRaceMenuScript.GetFemaleHandsTex())
                EndIf

            ElseIf(arm.GetSlotMask() == 80) ; Slot 128 temporarily removed.
                If(MateraRaceMenuScript.GetIsMale())
                   SearchAndSet(false, arm, "Feet", MateraRaceMenuScript.GetMaleBodyTex()) ; I have no idea if this is the correct node for male feet. I don't think it is.
                Else
                   SearchAndSet(true, arm, "Feet", MateraRaceMenuScript.GetFemaleBodyTex())
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
                If(MateraRaceMenuScript.GetIsMale())
                    ;aaaaaaaa
                Else
                   AddOverrideTextureSet(PlayerRef, true, MateraBody, MateraRaceMenuScript.GetMateraTorso(), "", 6, -1, MateraRaceMenuScript.GetFemaleBodyTex(), true)
                EndIf

            ElseIf(arm.GetSlotMask() == 8) ; Hands, slot 33
;               AddOverrideTextureSet(PlayerRef, true, MateraBody, BodyParts[1], "", 6, -1, BodyTextures[1], true)
               If(MateraRaceMenuScript.GetIsMale())
                   SetColour(MateraRaceMenuScript.GetMateraHands(), "Hands", MateraRaceMenuScript.GetMaleHandsTex())
               Else
                   SetColour(MateraRaceMenuScript.GetMateraHands(), "Hands", MateraRaceMenuScript.GetFemaleHandsTex())
               EndIf

            ElseIf(arm.GetSlotMask() == 80 || arm.GetSlotMask() == 128) ; Feet, Slot 37
                If(MateraRaceMenuScript.GetIsMale())
                   SetColour(MateraRaceMenuScript.GetMateraFeet(), "Feet", MateraRaceMenuScript.GetMaleBodyTex())
                Else
                   SetColour(MateraRaceMenuScript.GetMateraFeet(), "Feet",  MateraRaceMenuScript.GetFemaleBodyTex())
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
        AddOverrideTextureSet(PlayerRef, !MateraRaceMenuScript.GetIsMale(), MateraBody, bodypart, node, 6, -1, tex, true)
    Else
        AddOverrideTextureSet(PlayerRef, !MateraRaceMenuScript.GetIsMale(), MateraBody, bodypart, "", 6, -1, tex, true)
    EndIf
EndFunction


Function CheckValues()
    BodyColour = BodyColorGlobal.GetValueInt()
    RaceCheck()

    If(PlayerRef == None)
        PlayerRef = Game.GetPlayer()
    EndIf
EndFunction


;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Colour changing functions.


Function SetFemaleBodyColour() Global
	processing = true
	
	If(PlayerRef.GetEquippedArmorInSlot(32) != None)
		Armor body = PlayerRef.GetEquippedArmorInSlot(32)
		SearchAndSet(!MateraRaceMenuScript.GetIsMale(), body, "CBBE", MateraRaceMenuScript.GetFemaleBodyTex())
		SearchAndSet(!MateraRaceMenuScript.GetIsMale(), body, "3BBB", MateraRaceMenuScript.GetFemaleBodyTex())
	Else
		; I discovered via netimmerse debug logs that if the part passed in is just a body part, then the root node is what it is looking for.
		; If the node I pass in is the *only* node there, it fails to find it. However, if a blank string is passed in, it has no issues finding it.
		; This also means that the player's body is naked.
		AddOverrideTextureSet(PlayerRef, true, MateraBody, MateraRaceMenuScript.GetMateraTorso(), "", 6, -1, MateraRaceMenuScript.GetFemaleBodyTex(), true) ; Nodes are the same name on CBBE, CBBE 3BBB, UNP, and BHUNP!
	EndIf
	

	If(PlayerRef.GetEquippedArmorInSlot(33) != None) ; Hands
		Armor hands = PlayerRef.GetEquippedArmorInSlot(33)
		SearchAndSet(true, hands, "Hands", MateraRaceMenuScript.GetFemaleHandsTex())
	Else
		; Player is wearing nothing on their hands.
		PartCheck(true, MateraRaceMenuScript.GetMateraHands(), "Hands", MateraRaceMenuScript.GetFemaleBodyTex())
	EndIf
	

	If(PlayerRef.GetEquippedArmorInSlot(37) != None) ; Feet
		Armor feet = PlayerRef.GetEquippedArmorInSlot(37)
		SearchAndSet(true, feet, "Feet", MateraRaceMenuScript.GetFemaleBodyTex())
	Else
		; The player has (literal) cold feet because they're wearing nothing there.
		PartCheck(true, MateraRaceMenuScript.GetMateraFeet(), "Feet", MateraRaceMenuScript.GetFemaleBodyTex())
	EndIf

	processing = false
EndFunction


Function SetMaleBodyColour()
	; Not implemented yet. Awating to make female body work first. CBBE mainly works, UNP is totally untested.
EndFunction



; I do have plans for multiple tail types.
Function SetTailColour() Global
	; Beta Matera (Tail type 0) node: "TailM", Original Matera (Tail Type 1)Node: "Albino"
	; Maybe other tail types in the future. If I can figure out how to have swappable tails, that would be fantastic.

	If(TailType == 0)		
        AddOverrideTextureSet(PlayerRef, true, MateraBody, MateraRaceMenuScript.GetMateraTail(), "TailM", 6, -1, MateraRaceMenuScript.GetTailTex(), false)
		
	ElseIf(TailType == 1)
		AddOverrideTextureSet(PlayerRef, true, MateraBody, MateraRaceMenuScript.GetMateraTail(), "Albino", 6, -1, MateraRaceMenuScript.GetTailTex(), false)
	EndIf
EndFunction


	
	
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Utility functions 


; Searches an armor piece for the passed in node.
Function SearchAndSet(bool isFemale, Armor arm, String node, TextureSet tex) Global; Full name would be SearchForNodeAndSetColourIfNodeExists, but that's too damn long.
	int i = 0 
	int addoncount = arm.GetNumArmorAddons()

	While(i < addoncount)
		If(HasArmorAddonNode(Game.GetPlayer(), false, arm, arm.GetNthArmorAddon(i), node, true))
			AddOverrideTextureSet(Game.GetPlayer(), isFemale, arm, arm.GetNthArmorAddon(i), node, 6, -1, tex, false)
			i = addoncount ; Break out of the loop once the node has been found.
		Else
			Log("Node " + node + " not found on armor piece " + arm.GetName() + ".")
		EndIf
		i += 1
	EndWhile
EndFunction



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



; This checks the body part for a node. I mentioned in an earlier comment that if it's the only node, it won't find it. 
; However, there are mods that add nodes to the hands and/or feet in the shape of nails or claws. This handles that scenario.
Function PartCheck(Bool female, ArmorAddon bodypart, String node, TextureSet tex)
	If(HasArmorAddonNode(PlayerRef, false, MateraBody, bodypart, node, true))
		AddOverrideTextureSet(PlayerRef, female, MateraBody, bodypart, node, 6, -1, tex, true)
	Else
		AddOverrideTextureSet(PlayerRef, female, MateraBody, bodypart, "" , 6, -1, tex, true)
	EndIf
EndFunction




;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;"Debug" functions.

Function Log(String s) Global
	Debug.Trace("(Matera Reborn CC) |  " + s) ; CC = Colour Change, so I know which script is logging this.
EndFunction


; Does exactly what it says. This is meant for my usage, so I know if a armor piece isn't working, what the issue is.
Function ArmorDebug(Armor arm)
    Debug.Trace("Armor name: " + arm.GetName())
    Debug.Trace("Armor Item Slot: " + arm.GetSlotMask())
    Debug.Trace("Armor addon count: " + arm.GetNumArmorAddons())
    Debug.Trace("-------------")
EndFunction
