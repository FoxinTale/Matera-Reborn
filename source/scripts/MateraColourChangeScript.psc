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

ArmorAddon[] BodyParts ; Body, Hands, Feet
TextureSet[] BodyTextures ; Female Body, Female Hands, Male Body, Male Hands

Bool IsMale = true
Bool IsMatera = false
Bool processing = false


Event OnInit()
    RegisterForMenu("RaceSex Menu")
    BodyParts = new ArmorAddon[4]
    BodyTextures = new TextureSet[5]
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
;                   mrms.SearchAndSetBody(false, arm, mrms.GetMaleBodyTex())
                    SearchAndSetBody(false, arm, BodyTextures[2])
                Else
;                   mrms.SearchAndSetBody(true, arm, mrms.GetFemaleBodyTex())
                    SearchAndSetBody(true, arm, BodyTextures[0])
                EndIf

            ElseIf(arm.GetSlotMask() == 8)
                If(IsMale)
;                   mrms.SearchAndSet(false, arm, "Hands", mrms.GetMaleHandsTex()) ; I have no idea if this is the correct node for male hands. I don't think it is.
                    SearchAndSet(false, arm, "Hands", BodyTextures[3])
                Else
;                   mrms.SearchAndSet(true, arm, "Hands", mrms.GetFemaleHandsTex())
                    SearchAndSet(true, arm, "Hands", BodyTextures[1])
                EndIf

            ElseIf(arm.GetSlotMask() == 80) ; Slot 128 temporarily removed.
                If(IsMale)
;                   mrms.SearchAndSet(false, arm, "Feet", mrms.GetMaleBodyTex()) ; I have no idea if this is the correct node for male feet. I don't think it is.
                    SearchAndSet(false, arm, "Feet", BodyTextures[2])
                Else
;                  mrms.SearchAndSet(true, arm, "Feet", mrms.GetFemaleBodyTex())
                   SearchAndSet(true, arm, "Feet", BodyTextures[0])
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
;                   SetColour(mrms.GetMateraHands(), "Hands", mrms.GetMaleHandsTex())
                    SetColour(BodyParts[1], "Hands", BodyTextures[3])
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
    SetArrays()

    If(PlayerRef == None)
        PlayerRef = Game.GetPlayer()
    EndIf
EndFunction


;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Repeated code from Matera Race Menu Script, because the damn thing won't let me use shared scripts for some damn reason.
; It's literally copied from the Matera Race Menu Script. Comments and all. If someone can get the two scripts to talk, you can remove this entire segment.


; I do have plans for multiple tail types.
Function SetTailColour()
	; Beta Matera (Tail type 0) node: "TailM", Original Matera (Tail Type 1)Node: "Albino"
	; Maybe other tail types in the future. If I can figure out how to have swappable tails, that would be fantastic.

	If(TailType == 0)		
        AddOverrideTextureSet(PlayerRef, true, MateraBody, BodyParts[3], "TailM", 6, -1, BodyTextures[4], true)
		
	ElseIf(TailType == 1)
		AddOverrideTextureSet(PlayerRef, true, MateraBody, BodyParts[3], "Albino", 6, -1, BodyTextures[4], true)
	EndIf
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


Function SetFemaleBodyColour()
	processing = true
	
	If(PlayerRef.GetEquippedArmorInSlot(32) != None)
		Armor body = PlayerRef.GetEquippedArmorInSlot(32)
		SearchAndSet(!IsMale, body, "CBBE", BodyTextures[0])
		SearchAndSet(!IsMale, body, "3BBB", BodyTextures[0])
	Else
		; I discovered via netimmerse debug logs that if the part passed in is just a body part, then the root node is what it is looking for.
		; If the node I pass in is the *only* node there, it fails to find it. However, if a blank string is passed in, it has no issues finding it.
		; This also means that the player's body is naked.
		AddOverrideTextureSet(PlayerRef, true, MateraBody, BodyParts[0], "", 6, -1, BodyTextures[0], true) ; Nodes are the same name on CBBE, CBBE 3BBB, UNP, and BHUNP!
	EndIf
	

	If(PlayerRef.GetEquippedArmorInSlot(33) != None) ; Hands
		Armor hands = PlayerRef.GetEquippedArmorInSlot(33)
		SearchAndSet(true, hands, "Hands", BodyTextures[1])
	Else
		; Player is wearing nothing on their hands.
		PartCheck(true, BodyParts[1], "Hands", BodyTextures[1])
	EndIf
	

	If(PlayerRef.GetEquippedArmorInSlot(37) != None) ; Feet
		Armor feet = PlayerRef.GetEquippedArmorInSlot(37)
		SearchAndSet(true, feet, "Feet", BodyTextures[0])
	Else
		; The player has (literal) cold feet because they're wearing nothing there.
		PartCheck(true, BodyParts[2], "Feet", BodyTextures[0])
	EndIf

	processing = false
EndFunction
	
	
Function SetMaleBodyColour()
	; Not implemented yet. Awating to make female body work first. CBBE mainly works, UNP is totally untested.
EndFunction
	

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Utility functions 

Function SetArrays()
    BodyTextures[0] = FemaleBodyColour_List.GetAt(BodyColour) as TextureSet
	BodyTextures[1] = FemaleHandsColour_List.GetAt(BodyColour) as TextureSet
	BodyTextures[2] = MaleBodyColourList.GetAt(BodyColour) as TextureSet
	BodyTextures[3] = MaleHandscolourList.GetAt(BodyColour) as TextureSet
    BodyTextures[4] = TailColourList.GetAt(BodyColour) as TextureSet

    BodyParts[0] = MateraBody.GetNthArmorAddon(1) ; Body
    BodyParts[1] = MateraBody.GetNthArmorAddon(2) ; Hands
    BodyParts[2] = MateraBody.GetNthArmorAddon(3) ; Feet
    BodyParts[3] = MateraBody.GetNthArmorAddon(0) ; Tail
EndFunction


Function SearchAndSet(bool isFemale, Armor arm, String node, TextureSet tex) ; Full name would be SearchForNodeAndSetColourIfNodeExists, but that's too damn long.
	int i = 0 
	int addoncount = arm.GetNumArmorAddons()

	While(i < addoncount)
		If(HasArmorAddonNode(PlayerRef, false, arm, arm.GetNthArmorAddon(i), node, true))
			AddOverrideTextureSet(PlayerRef, isFemale, arm, arm.GetNthArmorAddon(i), node, 6, -1, tex, true)
			i = addoncount ; Break out of the loop.
		Else
			Log("Node " + node + " not found on armor piece " + arm.GetName() + ".")
		EndIf
		i += 1
	EndWhile
EndFunction



Function SearchAndSetBody(bool IsFemale, Armor arm, TextureSet tex)
	int i = 0 
	int addoncount = arm.GetNumArmorAddons()

	While(i < addoncount)
        If(HasArmorAddonNode(PlayerRef, false, arm, Arm.GetNthArmorAddon(i), "CBBE", true))
            AddOverrideTextureSet(PlayerRef, true, arm, Arm.GetNthArmorAddon(i), "CBBE", 6, -1, BodyTextures[0], true)
            i = addoncount ; Break out of the loop, we've found the node.

        ElseIf(HasArmorAddonNode(PlayerRef, false, arm, Arm.GetNthArmorAddon(i), "3BBB", true))
            AddOverrideTextureSet(PlayerRef, true, arm, Arm.GetNthArmorAddon(i), "3BBB", 6, -1, BodyTextures[0], true)
            i = addoncount

        ElseIf(HasArmorAddonNode(PlayerRef, false, arm, Arm.GetNthArmorAddon(i), "UNP", true))
            AddOverrideTextureSet(PlayerRef, true, arm, Arm.GetNthArmorAddon(i), "UNP", 6, -1, BodyTextures[0], true)
            i = addoncount

        ElseIf(HasArmorAddonNode(PlayerRef, false, arm, Arm.GetNthArmorAddon(i), "BaseShape", true))
            AddOverrideTextureSet(PlayerRef, true, arm, Arm.GetNthArmorAddon(i), "BaseShape", 6, -1, BodyTextures[0], true)
            i = addoncount

		Else
			Log("Node not found on armor piece" + arm.GetName() + ".")
		EndIf
		i += 1
	EndWhile
    PlayerRef.QueueNiNodeUpdate()
EndFunction


Function CheckSex()
    ActorBase PlayerBase = PlayerRef.GetActorBase()

	If(PlayerBase.GetSex() == 0)
		IsMale = true
	Else
		IsMale = false
	EndIf
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
