Scriptname MateraRaceMenuScript extends RaceMenuBase

import NiOverride

; I have thought of a new method to do the ear swapping. I will have to do some testing to see if it works, but if it does, then we'll be avoiding all of the head part nonsense.

;I'm leaving this as more a nopte to myself at just shy of 2:30 in the morning so I do not forget. However, this is why it is on the re-write brance. I had this idea earlier, but only now remembered to write it dowm.

; So, I add a default ear (Elin) to the MateraBody, and that ArmorAddon is gotten.  There is also a default int variable indicating which ear type. 
; Within the editor, exists one ear of each type, and they are within a formlist property. When the ear style is changed, the nmodel path of the ear in the formlist corresponding to the selected number is gotten.
; the model path from this ear is then passed in to a  function which then sets the new armor addon path, it updates the texture then queues a NiNode update. 

; If this methods works, I can also use it to do tail swapping real easily. I really hope I can use this method instead. I want multiple tail options. I hated the absolute nonsense with headparts. 
; I need to check the node of all the ears, see what their names are. Do a "If armoraddonnodeexists.. if/else chain", and for the love of all that is holy, remember to pass in a blank string as the node.

; Ears could be slot 43 "Ears", or slot 58 "Unnamed". Tails are always slot 40. This will also allow me to strip out a lot of the fairly complex and slow head part changing code.
; While that took a while to write, if this method works so much better, I'll do it. I essentially took the really long and painful way first, then discovered a theoretically much better way to do it.
; I actually tried to do it this way initially, but I had not yet begun the descent to madness trying to understand NiOverride.

;/
New ear changing "pseudocode"

Within the InitialiseValues() function, the ears is also set. 
When the slider is changed, a function is called.
Define (if not already done) an Integer "EarType"
Define an ArmorAddon "CurrentEar", and ""

Function ChangeEarType()
	String CurrentEarsModel
	String NewEarsModel
	ArmorAddon NewEar
	
	If(IsMale)
		CurrentEarsModel = MateraEars.GetModelPath(false, false)

		NewEar = MateraEarsList.GetAt(EarType) as ArmorAddon
		NewEarsModel = NewEar.GetModelPath(false, false)

		MateraEar.SetModelPath(NewEars, false, false)
		AddOverrideTextureSet()
		
	Else
		CurrentEarsModel = MateraEars.GetModelPath(false, true)
	EndIf

	PlayerRef.QueueNiNodeUpdate()
EndFunction



I will also need to construct a new colour changing function on the ears.
/;

; To fix (what is known to not work):
; Currently, nothing majorly broken.


;To test:
;	- 

; New things to add/ or to change:
;	- Multiple tails? (Beta, HDT Beta, Original, Original HDT, Inari[maybe, if retexture is possible], Magic, Magic HDT)
;	- UNP body support once CBBE is complete. That's not going to be fun. (for the naked body parts, this is functional, but for armoured, it is not)
;	- Male body support. This will be even worse. 

Int Property RM_MATERA_VERSION = 1 AutoReadOnly
Int Property Version = 0 Auto
String Property CATEGORY_KEY = "racemenu_matera" AutoReadOnly
;MateraColourChangeScript Property mccs Auto ; Abbreviated. Matera Colour Change Script.

Actor Property PlayerRef Auto
ActorBase PB ; PlayerBase, but since it's "defined elsewhere", I have to abbreviate it.
Armor Property MateraBody Auto

Race Property MateraRace Auto
Race Property MateraVampireRace Auto


; I treat the formlists as arrays, because that's what they look like to me...and how they behave.

FormList Property EarsAddonList Auto ; This formlist contains one of each ear type.

FormList Property FemaleBodyColour_List Auto
FormList Property FemaleHandsColour_List Auto
FormList Property MaleBodyColourList Auto
FormList Property MaleHandsColourList Auto
FormList Property TailColourList Auto
FormList Property MainEarsColourList Auto

TextureSet[] Property Textures Global
ArmorAddon[] BodyParts

; Possible global variables. If I can be clever, I want to use as little as possible.
; For Is male and is Matera. Possible values include: 00 (Not male, not Matera), 01 (Not male, Is Matera), 10 (Is male, is not Matera), and 11 (Is male, Is Matera)

Float MateraEar = 0.0
Float MateraColour = 10.0
Float MateraBodyColour = 10.0
Float MateraEarsColour = 10.0
Float MateraTailColour = 10.0
;Float MateraTailType = 0.0

Int CurrentEar = 0
Int DefaultColour = 10
Int CurrentColour = 10
Int TailType = 0
Int EarsPosition = 1 ; Default.
Int DefaultPos = 1 ; Default
Int BodyType = 0 ; Default

GlobalVariable Property BodyColor Auto

; There will be a light plugin that sets this value, and the user is asked during installation. 0 = Base game, 1 = CBBE, 2 = 3BBB, 3 = UNP, 4 = UUNP.
; I cannot use plugin index checking, as while at least CBBE and 3BBB have plugins, they're both light plugins, and I haven't figured out how to check for those, if it's even possible.
; I think I can only use light plugin checking in the FOMOD mod installer.
GlobalVariable Property BodyTypeGlobal Auto

Bool IsMale = true ; Because the player character is usually male by default, unless they have Skyrim Unbound's "Female by Default" installed.
Bool IsMatera = false
Bool FirstRun = true
Bool processing = false

String FemaleBodyNode ; This is what the BodyType global variable determines.

;---------------------------------------------------------------------------------------------------------------------
; Events.

; Runs when the script initialises for the very first time.
Event OnInit()
	Parent.OnInit()
	Version = RM_MATERA_VERSION
	InitialiseValues()
	CheckSex()
	RaceCheck()
	CheckBodyType()
	RegisterForMenu("RaceSex Menu")
EndEvent


; When RaceMenu is loaded and the category is requested, create the new "Matera" category.
Event OnCategoryRequest()
	AddCategory(CATEGORY_KEY, "MATERA", -750)
EndEvent


Event OnMenuOpen(String MenuName)
	If(MenuName == "RaceSex Menu")
		CheckSex()
		RaceCheck()
	EndIf
EndEvent


Event OnMenuClose(String MenuName)
	If(MenuName == "RaceSex Menu")
		If(FirstRun)
			FirstRun = false
		EndIf
		
		RaceCheck()
	EndIf
EndEvent


; When it is time for slider creations, create them and set their appropriate values.
Event OnSliderRequest(Actor player, ActorBase playerBase, Race actorRace, bool isFemale)
	AddSliderEx("Fur Colour", CATEGORY_KEY, "matera_body_colour", 0.0, 29.0, 1.0, MateraBodyColour)
	AddSliderEx("Ear Style", CATEGORY_KEY, "matera_ear_style", 0.0, 7.0, 1.0, MateraEar)
;	AddSliderEx("Tail Type", CATEGORY_KEY, "matera_tail_type", 0.0, 1.0, 1.0, MateraTailType)
EndEvent


; when the RaceMenu slider is changed...
Event OnSliderChanged(string callback, float value)
	If(callback == "matera_ear_style")
		If(value <= 9.0)
			MateraEar = value
;			SetEarType(value)
		EndIf

	ElseIf(callback == "matera_body_colour")
		If(value <= 29.0)
			MateraBodyColour = value
			BodyColor.SetValue(value)
			FindColour(value)
		EndIf

	;ElseIf(callback == "matera_tail_type")
	;	If(value <= 1.0)
			;MateraTailType = value
			;SetTailType()
	;	Endif
	EndIf
EndEvent


;---------------------------------------------------------------------------------------------------------------------
; Variable and property initialisation functions. They pretty much do what they say.

Function InitialiseValues()
	Textures = new TextureSet[6] ; 0 = Female Body, 1 = Female Hands, 2 = Male Body, 3 = Male Hands, 4 = Tail (There may be more added.)
	BodyParts = new ArmorAddon[5] ; 0 = Tail, 1 = Torso, 2 = Hands, 3 = Feet, 4 = Ears
	HeadParts = new HeadPart[8]

	Textures[0] = FemaleBodyColour_List.GetAt(DefaultColour) as TextureSet
	Textures[1] = FemaleHandsColour_List.GetAt(DefaultColour) as TextureSet
	Textures[2] = MaleBodyColourList.GetAt(DefaultColour) as TextureSet
	Textures[3] = MaleHandscolourList.GetAt(DefaultColour) as TextureSet
	Textures[4] = TailColourList.GetAt(DefaultColour) as TextureSet
	Textures[5] = MainEarsColourList.GetAt(DefaultColour) as TextureSet	
	
	If(PlayerRef == None)
		PlayerRef = Game.GetPlayer()
	EndIf

	PB = PlayerRef.GetActorBase()

	InitialiseBodyParts()
EndFunction


; One of the more unusual functions I've named, but it does exactly what it says. 
Function InitialiseBodyParts() 
	BodyParts[0] = MateraBody.GetNthArmorAddon(0) ; Tail
	BodyParts[1] = MateraBody.GetNthArmorAddon(1) ; Torso
	BodyParts[2] = MateraBody.GetNthArmorAddon(2) ; Hands 
	BodyParts[3] = MateraBody.GetNthArmorAddon(3) ; Feet
	BodyParts[4] = MateraBody.GetNthArmorAddon(4) ; Ears

; I have no idea if I actually need to do this, but things work with it in, so I'll leave it until I've confirmed they are not needed.
	BodyParts[0].RegisterForNiNodeUpdate()
	BodyParts[1].RegisterForNiNodeUpdate()
	BodyParts[2].RegisterForNiNodeUpdate()
	BodyParts[3].RegisterForNiNodeUpdate()
	BodyParts[4].RegisterForNiNodeUpdate()
	Log("Initialisation complete")
EndFunction


;---------------------------------------------------------------------------------------------------------------------
; Checking functions. 

Function RaceCheck()
	If(Game.GetPlayer().GetRace() == MateraRace || Game.GetPlayer().GetRace() == MateraVampireRace)
		IsMatera = true
	Else
		IsMatera = false
	EndIf
EndFunction


;This one isn't currently used, but I'm keeping it around because it is useful if/when I do use it.
; However, If/when I determine it will not be used, then it will be removed.
Function CheckBodyType()
	BodyType = BodyTypeGlobal.GetValueInt()
	Debug.Trace("Body Type global: " + BodyTypeGlobal)
	Debug.Trace("Body Type Int: " + BodyType)

	If(BodyType == 0) ; Default value. Could have been either the base game (ew) or what I'm using it as. No option was selected.
		Debug.MessageBox("No body type was selected during installation. Please reinstall MaTera Reborn, otherwise this will not work.")
		; Been having issues with this getting falsely triggered.

	ElseIf(BodyType == 1) ; These names kind of explain themselves.
		 FemaleBodyNode = "CBBE"

	ElseIf(BodyType == 2) 
		 FemaleBodyNode = "3BBB"

	ElseIf(BodyType == 3) 
		 FemaleBodyNode = "UNP"

	ElseIf(BodyType == 4) ; BHUNP / UUNP Next Generation
		 FemaleBodyNode = "BaseShape" ; What is this name even?
	Else
		Log("Somehow, the body type is not valid.")
	EndIf
EndFunction


Function CheckSex() Global
	If(PB.GetSex() == 0)
		IsMale = true
	Else
		IsMale = false
	EndIf
EndFunction
;---------------------------------------------------------------------------------------------------------------------

; This searches the colour formlists for their appropriate colour, then sets the textures to what it finds. 
Function FindColour(Float ColourOption) 
	Int ColourChoice = ColourOption as int
	CurrentColour = ColourChoice

	 If(ColourChoice <= 29 ) ; Sanity check, should never exceed 29 but you never know.
		Textures[0] = FemaleBodyColour_List.GetAt(ColourChoice) as TextureSet
		Textures[1] = FemaleHandsColour_List.GetAt(ColourChoice) as TextureSet
		Textures[2] = MaleBodyColourList.GetAt(ColourChoice) as TextureSet
		Textures[3] = MaleHandscolourList.GetAt(ColourChoice) as TextureSet
		Textures[5] = TailColourList.GetAt(ColourChoice) as TextureSet
		Textures[6] = MainEarsColourList.GetAt(ColourChoice) as TextureSet		
	EndIf

	If(IsMale)
		SetMaleBodyColour()
	Else
		SetFemaleBodyColour()	
	EndIf

	While(processing)
		Utility.Wait(0.1)
	EndWhile

;	SetEarColour()
	SetTailColour()

	Utility.Wait(0.1)
	PlayerRef.QueueNiNodeUpdate()
EndFunction


; The colour changing functions. 
; I would have loved to offload these to the "MateraColourChangeScript", but the creation kit had a stick up its ass and wouldn't let me set the property.
Function SetFemaleBodyColour() Global
	processing = true
	
	If(PlayerRef.GetEquippedArmorInSlot(32) != None)
		Armor body = PlayerRef.GetEquippedArmorInSlot(32)
		SearchAndSet(!IsMale, body, "CBBE", Textures[0])
		SearchAndSet(!IsMale, body, "3BBB", Textures[0])
	Else
		; I discovered via netimmerse debug logs that if the part passed in is just a body part, then the root node is what it is looking for.
		; If the node I pass in is the *only* node there, it fails to find it. However, if a blank string is passed in, it has no issues finding it.
		; This also means that the player's body is naked.
		AddOverrideTextureSet(PlayerRef, true, MateraBody, BodyParts[1], "", 6, -1, Textures[0], true) ; Nodes are the same name on CBBE, CBBE 3BBB, UNP, and BHUNP!
	EndIf
	

	If(PlayerRef.GetEquippedArmorInSlot(33) != None) ; Hands
		Armor hands = PlayerRef.GetEquippedArmorInSlot(33)
		SearchAndSet(true, hands, "Hands", Textures[1])
	Else
		; Player is wearing nothing on their hands.
		PartCheck(true, BodyParts[2], "Hands", Textures[1])
	EndIf
	

	If(PlayerRef.GetEquippedArmorInSlot(37) != None) ; Feet
		Armor feet = PlayerRef.GetEquippedArmorInSlot(37)
		SearchAndSet(true, feet, "Feet", Textures[0])
	Else
		; The player has (literal) cold feet because they're wearing nothing there.
		PartCheck(true, BodyParts[3], "Feet", Textures[0])
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
        AddOverrideTextureSet(PlayerRef, true, MateraBody, BodyParts[0], "TailM", 6, -1, Textures[4], false)
		
	ElseIf(TailType == 1)
		AddOverrideTextureSet(PlayerRef, true, MateraBody, BodyParts[0], "Albino", 6, -1, Textures[4], false)
	EndIf
EndFunction


;---------------------------------------------------------------------------------------------------------------------
; "Utility" Functions.


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



; This checks the body part for a node. I mentioned in an earlier comment that if it's the only node, it won't find it. 
; However, there are mods that add nodes to the hands and/or feet in the shape of nails or claws. This handles that scenario.
Function PartCheck(Bool female, ArmorAddon bodypart, String node, TextureSet tex)
	If(HasArmorAddonNode(PlayerRef, false, MateraBody, bodypart, node, true))
		AddOverrideTextureSet(PlayerRef, female, MateraBody, bodypart, node, 6, -1, tex, true)
	Else
		AddOverrideTextureSet(PlayerRef, female, MateraBody, bodypart, "" , 6, -1, tex, true)
	EndIf
EndFunction

;---------------------------------------------------------------------------------------------------------------------
; Debugging and log functions. 


; This outputs to the Papyrus log file the passed in string with a "pre-pend" I think it's called.
Function Log(String s) Global
	Debug.Trace("(Matera Reborn) |  " + s)
EndFunction

; If I ever end up figuring out how to check the texture path on a nif model, and use that to find the right node so I can set the texture, there should be a variable
; that is checked. This is because someone may have custom texture paths for their body mesh that aren't where the default textures are. Doing it this way has built in handling for when I implement that.




;---------------------------------------------------------------------------------------------------------------------
; Getters and Setters. Currently, they are unused, which is why they are commented out. However, I would love to be able to figure out how to get the two scripts to talk to each other.\
; If someone is reading this and knows how to do it, do it. Most, if not all the code exists in both scripts to do it.  



bool Function GetIsMale() ; If it's true, they're male, if not, female. Pretty simple. 
	return IsMale
EndFunction

int Function GetTailType()
	return TailType
EndFunction

string Function GetFemaleBodyNode()
	return FemaleBodyNode
EndFunction

Actor Function GetPlayerRef()
	return PlayerRef
EndFunction

TextureSet Function GetFemaleBodyTex() Global
	return Textures[0]
EndFunction 

TextureSet Function GetMaleBodyTex() Global
	return Textures[2]
EndFunction

TextureSet Function GetFemaleHandsTex() Global
	return Textures[1]
EndFunction

TextureSet Function GetMaleHandsTex() Global
	return Textures[3]
EndFunction

TextureSet Function GetTailTex() Global
	return Textures[4]
EndFunction

Armor Function GetMateraBody()
	return MateraBody
EndFunction

ArmorAddon Function GetMateraTorso()
	return MateraTorso
EndFunction

ArmorAddon Function GetMateraHands()
	return MateraHands
EndFunction

ArmorAddon Function GetTail()
	return BodyParts[0]
EndFunction 

ArmorAddon Function GetMateraFeet()
	return MateraFeet
EndFunction
