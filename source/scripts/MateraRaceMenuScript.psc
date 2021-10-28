Scriptname MateraRaceMenuScript extends RaceMenuBase

; Check out this fellow's site if you wish to use NiOverride. You'll thank me later.
; https://geek-of-all-trades.neocities.org/programming/skyrim/nioverride-textures-01-beginners.html
; NiOverride has very little documentation as to how to use it. This is why I have such heavily commented scripts here.
; That, and to help both others wondering how I pulled this off, and my future self looking back at this.
import NiOverride

; New things to add/ or to change:
;	- Multiple tail types*.
;	- UNP body support once CBBE is complete. That's not going to be fun. (for the naked body parts, this is functional, but for armoured, it is not)
;	- Male body support. This will be even worse. 

; Tail types: Beta Matera (Non HDT & HDT), Inari HDT (If a retexture is possible), Original Matera (Non HDT & HDT), Fox Tail (Non HDT & HDT)

;/

What I want to do is replace the headparts with an armor addon, and just swap that model path and textureset. 
The hard part is finding the right biped slot for these ears.
I would love to do away with all this head part nonsense. 

Though, I've tried just about every biped slot I can think of for the base ears. Nothing. I think they will have to be forced to have one. Somehow.
I have no idea if it is possible, and if it is I have no idea how to do so. This part isn't a comment, it's a cry for help.
I *really* hated the head part nonsense and want to get rid of it, but can't.

I also wish to investigate the usage of NiOverride's "Skin" functions. 
/;
Int Property RM_MATERA_VERSION = 1 AutoReadOnly
Int Property Version = 0 Auto
String Property CATEGORY_KEY = "racemenu_matera" AutoReadOnly

Actor Property PlayerRef Auto
ActorBase PB ; PlayerBase, but since it's "defined elsewhere", I have to abbreviate it.
Armor Property MateraBody Auto

Race Property MateraRace Auto
Race Property MateraVampireRace Auto

; I had to make a lot of HeadParts (Thank you SSE Edit scripts for saving me about 3 hours) and put them into FormLists, as they're head parts. Not armors or armor addons, and therefore I was unable to easily
; change textures on them. That, and at the time I did it this way, I had already spent a solid 5 days on trying to swap the ears out and changing their texturesets alone...This way works reliably. 
; doing away with the headparts means I can get rid of these lists. And the 30 headparts contained within each list.
FormList Property ElinEarsList Auto
FormList Property ElvenEarsList Auto
FormList Property FoxEarsList Auto
FormList Property LopsidedEarsList Auto
FormList Property MateraEarsList Auto
FormList Property RogueEarsList Auto
FormList Property SidewaysEarsList Auto
FormList Property SmallEarsList Auto
FormList Property SmallTuftsEarsList Auto
FormList Property SpikyEarsList Auto
FormList Property MiscMateraHeadPartsList Auto
;------------
FormList Property MateraTailList Auto ; The list of tails. 0 = Beta, 1 = Original, 2 = Fox, 3 = Fox Five Tail

;/
The texture formlists. I'm basically treating the formlists as arrays. I like it this way because I can add and remove things at will.
Here's how I'm using the formlists. The number is the position  in the lists. This applies to all of them:

	0 = Albino, 1 = Black, 2 = Black Tip, 3 = Concept, 4 = Cotton Candy, 5 = Cotton Candy Black, 6 = Cotton Candy Blue, 7 = Cotton Candy White,
	8 = Dark Brown, 9 = Default, 10 = Default Tip, 11 = Everlast Evil, 12 = Fennec, 13 = Georgian Black, 14 = Georgian White, 15 = Green Tip, 16 = Holo 
	17 = Ice, 18 = Krystal, 19 = Krystal Tip, 20 = Light Brown, 21 = Maned Wolf Mystic, 22 = Mixed, 23 = Pink Tip, 24 = Pumpkin, 25 = Silver 
	26 = Silver Light, 27 = Slushie, 28 = White, 29 = White Tip.
/;
FormList Property FemaleBodyColour_List Auto
FormList Property FemaleHandsColour_List Auto
FormList Property MaleBodyColourList Auto
FormList Property MaleHandsColourList Auto
FormList Property BetaTailColourList Auto
FormList Property OriginalTailColourList Auto

; I decided to make these arrays. While it does hurt code readability, in theory, arrays are a singluar contiguous block of memory or (presumably) save space.
; This would (also theoretically) enable slightly faster access times due to it being a single continuous block and not being separate, scattered variables.
; This is, of course assuming Papyrus and Skyrim's internal code behaves like a sensible, competent little thing.  
TextureSet[] MateraTextures
ArmorAddon[] MateraParts

; Begone.
HeadPart DefaultEars
HeadPart CurrentEars
HeadPart NewEars
HeadPart BlankEars
HeadPart PrevEars
HeadPart MateraFemaleHead
HeadPart MateraMaleHead

; Considering turning these into arrays as well.
Float MateraEar = 0.0
Float MateraColour = 10.0
Float MateraBodyColour = 10.0
Float MateraEarsColour = 10.0
Float MateraTailColour = 10.0
Float MateraTailType = 0.0

Int CurrentEar = 0
Int DefaultColour = 10
Int CurrentColour = 10
Int OldTailType = 0
Int TailType = 0
Int EarsPosition = 1 ; Default.
Int DefaultPos = 1 ; Default
Int BodyType = 0 ; Default

; There will be a light plugin that sets this value, and the user is asked during installation. 0 = Base game, 1 = CBBE, 2 = 3BBB, 3 = UNP, 4 = UUNP.
; I cannot use plugin index checking, as while at least CBBE and 3BBB have plugins, they're both light plugins, and I haven't figured out how to check for those, if it's even possible.
; I think I can only use light plugin checking in the FOMOD mod installer.
GlobalVariable Property BodyTypeGlobal Auto

Bool IsMale = true ; Because the player character is usually male by default, unless they have Skyrim Unbound's "Female by Default" installed, or some other mod that changes this.
Bool IsMatera = false
Bool FirstRun = true
Bool processing = false

String FemaleBodyNode ; This is what the BodyType global variable determines.


; Tail Formlist: 0 = Beta, 1 = Original, 2 = Fox, 3 = Fox Five
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
		RaceCheck()
		Utility.Wait(0.1)

		If(IsMatera)
			PrevEars = CurrentEars
			Utility.Wait(5.0) ; Literally wait for the menus to load and do their things.
			FixEars()
		EndIf
	EndIf
EndEvent


Event OnMenuClose(String MenuName)
	If(MenuName == "RaceSex Menu")
		If(FirstRun)
			FirstRun = false
		EndIf
		RaceCheck()
		CheckSex()
		Utility.Wait(10.0)
	
		If(PB != None) ; Sanity check.
			HeadPartDebug(PB)
		Else
			Actorbase PlayerBase = PlayerRef.GetActorBase()
			HeadPartDebug(PlayerBase)
		EndIf
	EndIf
EndEvent


; When it is time for slider creations, create them and set their appropriate values.
Event OnSliderRequest(Actor player, ActorBase playerBase, Race actorRace, bool isFemale)
	AddSliderEx("Fur Colour", CATEGORY_KEY, "matera_body_colour", 0.0, 29.0, 1.0, MateraBodyColour)
	AddSliderEx("Ear Style", CATEGORY_KEY, "matera_ear_style", 0.0, 7.0, 1.0, MateraEar)
	AddSliderEx("Tail Type", CATEGORY_KEY, "matera_tail_type", 0.0, 3.0, 1.0, MateraTailType) 
EndEvent


; when the RaceMenu slider is changed...
Event OnSliderChanged(string callback, float value)
	If(callback == "matera_ear_style")
		If(value <= 9.0)
			MateraEar = value
			SetEarType(value)
		EndIf

	ElseIf(callback == "matera_body_colour")
		If(value <= 29.0)
			MateraBodyColour = value
			FindColour(value)
		EndIf

	ElseIf(callback == "matera_tail_type")
		If(value <= 3.0)
			MateraTailType = value
			TailType = value as Int
			SetTailType()
		Endif
	EndIf
EndEvent


;---------------------------------------------------------------------------------------------------------------------
; Variable and property initialisation functions. They pretty much do what they say.

Function InitialiseValues()

	MateraTextures = New TextureSet[6] ; 0 = Female Body, 1 = Female Hands, 2 = Male Body, 3 = Male Hands, 4 = Tail, 5 = Ears
	MateraParts = new ArmorAddon[5] ; 0 = Tail, 1 = Torso, 2 = Hands, 3 = Feet, 4 = Ears. I'm unsure if the last one will be used, but I'm putting it there in case I do figure it out.

	MateraTextures[0] = FemaleBodyColour_List.GetAt(DefaultColour) as TextureSet
	MateraTextures[1] = FemaleHandsColour_List.GetAt(DefaultColour) as TextureSet
	MateraTextures[2] = MaleBodyColourList.GetAt(DefaultColour) as TextureSet
	MateraTextures[3] = MaleHandscolourList.GetAt(DefaultColour) as TextureSet
	MateraTextures[4] = BetaTailColourList.GetAt(DefaultColour) as TextureSet
	
	; Be gone.
	BlankEars = MiscMateraHeadPartsList.GetAt(0) as HeadPart
	DefaultEars = MiscMateraHeadPartsList.GetAt(1) as HeadPart
	MateraFemaleHead = MiscMateraHeadPartsList.GetAt(2) as HeadPart
	MateraMaleHead = MiscMateraHeadPartsList.GetAt(3) as HeadPart
	
	If(PlayerRef == None) ; Null check. It can happen sometimes when Papyrus loses its mind.
		PlayerRef = Game.GetPlayer()
	EndIf

	CurrentEars = DefaultEars
	PB = PlayerRef.GetActorBase()

	InitialiseBodyParts()
EndFunction


; One of the more unusual functions I've named, but it does exactly what it says. 
Function InitialiseBodyParts() 
	MateraParts[0] = MateraBody.GetNthArmorAddon(0) ; Feet
	MateraParts[1] = MateraBody.GetNthArmorAddon(1) ; Torso
	MateraParts[2] = MateraBody.GetNthArmorAddon(2) ; Hands

	MateraParts[0].RegisterForNiNodeUpdate()
	MateraParts[1].RegisterForNiNodeUpdate()
	MateraParts[2].RegisterForNiNodeUpdate()
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

	If(BodyType == 0) ; Default value. Could have been either the base game (ew) or what I'm using it as. No option was selected.
		Debug.MessageBox("No body type was selected during installation. Please reinstall Matera Reborn, otherwise this will not work.")

	ElseIf(BodyType == 1) ; These names kind of explain themselves.
		 FemaleBodyNode = "CBBE"

	ElseIf(BodyType == 2) 
		 FemaleBodyNode = "3BBB"

	ElseIf(BodyType == 3) 
		 FemaleBodyNode = "UNP"

	ElseIf(BodyType == 4) ; Except for this one. This is BHUNP / UUNP Next Generation.
		 FemaleBodyNode = "BaseShape" ; What is this name even?
	Else
		Log("Somehow, the body type is not valid.")
	EndIf
EndFunction


Function CheckSex()
	If(PB.GetSex() == 0)
		IsMale = true
	Else
		IsMale = false
	EndIf
EndFunction


;---------------------------------------------------------------------------------------------------------------------
; The formlist handling

; 0 = Female Body, 1 = Female Hands, 2 = Male Body, 3 = Male Hands, 4 = Tail, 5 = Ears


; This searches the colour formlists for their appropriate colour, then sets the textures to what it finds. 
Function FindColour(Float ColourOption) 
	Int ColourChoice = ColourOption as int
	CurrentColour = ColourChoice

	 If(ColourChoice <= 29 ) ; Sanity check, should never exceed 29 but you never know.
		MateraTextures[0] = FemaleBodyColour_List.GetAt(ColourChoice) as TextureSet
		MateraTextures[1] = FemaleHandsColour_List.GetAt(ColourChoice) as TextureSet
		MateraTextures[2] = MaleBodyColourList.GetAt(ColourChoice) as TextureSet
		MateraTextures[3] = MaleHandscolourList.GetAt(ColourChoice) as TextureSet
		SetTailTexture(ColourChoice)
	EndIf

	If(IsMale)
		SetMaleBodyColour()
	Else
		SetFemaleBodyColour()	
	EndIf

	While(processing)
		Utility.Wait(0.1)
	EndWhile

	SetEarColour()
	SetTailColour()

	Utility.Wait(0.1)
	PlayerRef.QueueNiNodeUpdate()
EndFunction


;---------------------------------------------------------------------------------------------------------------------
; Ear section. This section handles anything relating with the ears.
; *screaming that slowly devolves into cries*

; I wish switch statements existed in Papyrus. That would make thise cleaner.
Function SetEarColour()
	HeadPart NewEarColour

	If(CurrentEar == 0)
		NewEarColour = ElinEarsList.GetAt(CurrentColour) as HeadPart

	ElseIf(CurrentEar == 1)
		NewEarColour = ElvenEarsList.GetAt(CurrentColour) as HeadPart

	ElseIf(CurrentEar == 2)
		NewEarColour = LopsidedEarsList.GetAt(CurrentColour) as HeadPart

	ElseIf(CurrentEar == 3)
		NewEarColour = RogueEarsList.GetAt(CurrentColour) as HeadPart

	ElseIf(CurrentEar == 4)
		NewEarColour = SidewaysEarsList.GetAt(CurrentColour) as HeadPart

	ElseIf(CurrentEar == 5)
		NewEarColour = SmallEarsList.GetAt(CurrentColour) as HeadPart

	ElseIf(CurrentEar == 6)
		NewEarColour = SmallTuftsEarsList.GetAt(CurrentColour) as HeadPart

	ElseIf(CurrentEar == 7)
		NewEarColour = SpikyEarsList.GetAt(CurrentColour) as HeadPart
	EndIf

	PrevEars = NewEarColour 
	CurrentEars = NewEarColour
	SetEar(NewEarColour, EarsPosition) ; Previously 1
EndFunction


Function SetEar(HeadPart ear, int slot)
	If(ear != None) ; Basically a null check.
		ActorBase PlayerBase = PlayerRef.GetActorBase()
		HeadPartDebug(PlayerBase)

		If(PlayerBase.GetNthHeadPart(slot) == MateraMaleHead || PlayerBase.GetNthHeadPart(slot) == MateraFemaleHead)
				Debug.Trace("Why is the head being replaced?")
				WTFWhyIsThisHappening(PlayerBase, ear)
		Else
			PlayerBase.SetNthHeadPart(ear, slot)
			PlayerRef.QueueNiNodeUpdate()
		EndIf
	Else
		Log("The headpart is nothing.")
	EndIf
EndFunction


Function SetEarType(Float EarOption)
	int EarChoice = EarOption as int
	CurrentEar = EarChoice
	FormList EarsList

	If(EarChoice == 0)
		EarsList = ElinEarsList

	ElseIf(EarChoice == 1)
		EarsList = ElvenEarsList

	ElseIf(EarChoice == 2)
		EarsList = LopsidedEarsList

	ElseIf(EarChoice == 3)
		EarsList = RogueEarsList

	ElseIf(EarChoice == 4)
		EarsList = SidewaysEarsList

	ElseIf(EarChoice == 5)
		EarsList = SmallEarsList

	ElseIf(EarChoice == 6)
		EarsList = SmallTuftsEarsList

	ElseIf(EarChoice == 7)
		EarsList = SpikyEarsList

	ElseIf(EarChoice == 8)
		EarsList = FoxEarsList

	ElseIf(EarChoice == 9)
		EarsList = MateraEarsList
		
	EndIf
	PrevEars = CurrentEars

	HeadPartCheck()

	NewEars = EarsList.GetAt(CurrentColour) as HeadPart
	SetEar(NewEars, EarsPosition) ; Previously 1
EndFunction


Function FixEars()
	HeadPartCheck()
	Utility.Wait(0.25) ; Wait for the headpart to be found, then set it.
	SetEar(CurrentEars, EarsPosition)
EndFunction


; I don't have a better name for this. This is called when, for whatever reason, the current slot that the ears would go into is occupied the head.
; If not handled, this causes the head to literally be overwritten, leaving a floating pair of eyes with hair. Not even the mouth is there.
Function WTFWhyIsThisHappening(ActorBase AB, HeadPart ear) 
	int i = 0
	int headparts = AB.GetNumHeadParts()

	; We do not want to break out of this loop, for sanity's sake. And if any other issues arise in the future, I can deal with them here. 
	While(i < headparts)
		If(AB.GetNthHeadPart(i) == DefaultEars)
			DefaultPos = i
			EarsPosition = i
		endIf
		i += 1
	EndWhile

	AB.SetNthHeadPart(ear, DefaultPos)
	PlayerRef.QueueNiNodeUpdate()
EndFunction


;---------------------------------------------------------------------------------------------------------------------
; Body colour changing 

; 0 = Female Body, 1 = Female Hands, 2 = Male Body, 3 = Male Hands, 4 = Tail, 5 = Ears
; 0 = Feet, 1 = Torso, 2 = Hands
Function SetFemaleBodyColour()
	processing = true
	
	If(PlayerRef.GetEquippedArmorInSlot(32) != None)
		Armor body = PlayerRef.GetEquippedArmorInSlot(32)
		SearchAndSet(!IsMale, body, "CBBE", 0)
		SearchAndSet(!IsMale, body, "3BBB", 0)
	Else
		; I discovered via netimmerse debug logs that if the part passed in is just a body part, then the root node is what it is looking for.
		; If the node I pass in is the *only* node there, it fails to find it. However, if a blank string is passed in, it has no issues finding it.
		; This also means that the player's body is naked.
		AddOverrideTextureSet(PlayerRef, true, MateraBody, MateraParts[1], "", 6, -1, MateraTextures[0], true) ; Nodes are the same name on CBBE, CBBE 3BBB, UNP, and BHUNP!
	EndIf
	

	If(PlayerRef.GetEquippedArmorInSlot(33) != None) ; Hands
		Armor hands = PlayerRef.GetEquippedArmorInSlot(33)
		SearchAndSet(true, hands, "Hands", 1)
	Else
		; Player is wearing nothing on their hands.
		PartCheck(true, MateraParts[2], "Hands", MateraTextures[1])
	EndIf
	

	If(PlayerRef.GetEquippedArmorInSlot(37) != None) ; Feet
		Armor feet = PlayerRef.GetEquippedArmorInSlot(37)
		SearchAndSet(true, feet, "Feet", 0)
	Else
		; The player has (literal) cold feet because they're wearing nothing there.
		PartCheck(true, MateraParts[0], "Feet", MateraTextures[0])
	EndIf

	processing = false
EndFunction
	
	
Function SetMaleBodyColour()
	; Not implemented yet. Awating to make female body work first. CBBE mainly works, UNP is totally untested.
EndFunction
	

;---------------------------------------------------------------------------------------------------------------------
; Tail operations.

;Handles setting the tail texture depending on the currently selected tail type.
Function SetTailTexture(Int ColourChoice)
	If(TailType == 0)
		MateraTextures[4] = BetaTailColourList.GetAt(ColourChoice) as TextureSet

	ElseIf(TailType == 1)
		MateraTextures[4] = OriginalTailColourList.GetAt(ColourChoice) as TextureSet

	; I have to make the textures for these first.
	;Else If(TailType == 2 || TailType == 3)
		;MateraTextures[4] = FoxTailColourList.GetAt(ColourChoice) as TextureSet
	Else
		; I dunno. this shouldn't happen once all tail types are implemented.
	EndIf
EndFunction


Function SetTailColour()
	; Textures array index 4 is the tail texture.
	Armor Tail = PlayerRef.GetEquippedArmorInSlot(40)

	If(Tail)
		If(TailType == 0)
			AddOverrideTextureSet(PlayerRef, !IsMale, Tail, Tail.GetNthArmorAddon(0), "TailM", 6, -1, MateraTextures[4], false)

		ElseIf(TailType == 1)
			AddOverrideTextureSet(PlayerRef, !IsMale, Tail, Tail.GetNthArmorAddon(0), "Albino", 6, -1, MateraTextures[4], false)
		
		;ElseIf(TailType == 2)
			;AddOverrideTextureSet(PlayerRef, !IsMale, Tail, Tail.GetNthArmorAddon(0), "fox_tail_0", 6, -1, MateraTextures[4], false)

		;ElseIf(TailType == 3)
			;AddOverrideTextureSet(PlayerRef, !IsMale, Tail, Tail.GetNthArmorAddon(0), "fox_tail_0", 6, -1, MateraTextures[4], false)
			;AddOverrideTextureSet(PlayerRef, !IsMale, Tail, Tail.GetNthArmorAddon(0), "fox_tail_001", 6, -1, MateraTextures[4], false)
			;AddOverrideTextureSet(PlayerRef, !IsMale, Tail, Tail.GetNthArmorAddon(0), "fox_tail_002", 6, -1, MateraTextures[4], false)
			;AddOverrideTextureSet(PlayerRef, !IsMale, Tail, Tail.GetNthArmorAddon(0), "fox_tail_003", 6, -1, MateraTextures[4], false)
			;AddOverrideTextureSet(PlayerRef, !IsMale, Tail, Tail.GetNthArmorAddon(0), "fox_tail_004", 6, -1, MateraTextures[4], false)
		
		Else
			; Also should not happen once all tail types are implemented.
		EndIf
	Else
		Log("No tail found.")
	EndIf
EndFunction


Function SetTailType()
	Armor CurrentTail = PlayerRef.GetEquippedArmorInSlot(40)
	Armor NewTail = MateraTailList.GetAt(TailType) as Armor
	PlayerRef.RemoveItem(CurrentTail, 1, true, None)

	PlayerRef.AddItem(NewTail, 1, true)
	PlayerRef.EquipItem(NewTail, true, true)

	PlayerRef.QueueNiNodeUpdate()
EndFunction


;---------------------------------------------------------------------------------------------------------------------
; "Utility" Functions.


; Searches an armor piece for the passed in node.
Function SearchAndSet(bool isFemale, Armor arm, String node, int TexOption) ; Full name would be SearchForNodeAndSetColourIfNodeExists, but that's too damn long.
	int i = 0 
	int addoncount = arm.GetNumArmorAddons()
	TextureSet tex = MateraTextures[TexOption]

	While(i < addoncount)
		If(HasArmorAddonNode(PlayerRef, false, arm, arm.GetNthArmorAddon(i), node, true))
			AddOverrideTextureSet(PlayerRef, isFemale, arm, arm.GetNthArmorAddon(i), node, 6, -1, tex, true)
			i = addoncount ; Break out of the loop once the node has been found.
		Else
			Log("Node " + node + " not found on armor piece " + arm.GetName() + ".")
		EndIf
		i += 1
	EndWhile
EndFunction


; Sanity checking the headparts. I don't remember why I implemented this, but I remember it was due to some wonkiness in a script.
Function HeadPartCheck()
	ActorBase PlayerBase = PlayerRef.GetActorBase()

	int i = 0
	int headparts = PlayerBase.GetNumHeadParts()
	HeadPart hp

	HeadPartDebug(PlayerBase)

	While(i < headparts)
		hp = PlayerBase.GetNthHeadPart(i)

		If(hp.GetName() == DefaultEars.GetName())
			SetEar(CurrentEars, i)
			EarsPosition = i
;			i = headparts ; Break out of the loop.
		EndIf

		If(PrevEars)
			If(hp.GetName() == PrevEars.GetName())
				SetEar(BlankEars, i)
			EndIf
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


; This pretty much just lists the headparts of the passed in actor base, (Player Base anywhere in this script).
Function HeadPartDebug(ActorBase AB)
	int i = 0
	int headparts = AB.GetNumHeadParts()
	HeadPart hp

	While(i < headparts)
		hp = AB.GetNthHeadPart(i)
		Debug.Trace("Headpart #" + i + " : " + hp.GetName())

		i += 1
	EndWhile
	Debug.Trace("          ")
EndFunction


; This outputs to the Papyrus log file the passed in string with a "pre-pend" I think it's called.
Function Log(String s)
	Debug.Trace("(Matera Reborn) |  " + s)
EndFunction

; If I ever end up figuring out how to check the texture path on a nif model, and use that to find the right node so I can set the texture, there should be a variable
; that is checked. This is because someone may have custom texture paths for their body mesh that aren't where the default textures are. Doing it this way has built in handling for when I implement that.

;---------------------------------------------------------------------------------------------------------------------
; Getters.

bool Function GetIsMale(); If it's true, they're male, if not, female. Pretty simple. 
	return IsMale
EndFunction

bool Function GetIsFirstRun()
	return FirstRun
EndFunction

bool Function GetIsProcessing()
	return processing
EndFunction

int Function GetTailType()
	return TailType
EndFunction

; TextureSet Getters
TextureSet Function GetFemaleBodyTex()
	return MateraTextures[0]
EndFunction 

TextureSet Function GetFemaleHandsTex()
	return MateraTextures[1]
EndFunction

TextureSet Function GetMaleBodyTex()
	return MateraTextures[2]
EndFunction

TextureSet Function GetMaleHandsTex()
	return MateraTextures[3]
EndFunction

TextureSet Function GetTailTex()
	return MateraTextures[4]
EndFunction

;Armor Addon Getters
ArmorAddon Function GetMateraFeet()
	return MateraParts[0]
EndFunction

ArmorAddon Function GetMateraTorso()
	return MateraParts[1]
EndFunction

ArmorAddon Function GetMateraHands()
	return MateraParts[2]
EndFunction

