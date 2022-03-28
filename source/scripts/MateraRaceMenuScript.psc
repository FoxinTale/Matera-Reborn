Scriptname MateraRaceMenuScript extends RaceMenuBase

; Check out this fellow's site if you wish to use NiOverride. You'll thank me later.
; https://geek-of-all-trades.neocities.org/programming/skyrim/nioverride-textures-01-beginners.html

; NiOverride has very little documentation as to how to use it. This is why I have such heavily commented scripts here.
; The only documentation I found is in the comments in NiOverride's script itself. 
; Did I need to document all this as well as I did? No. But I did. Hopefully it helps any poor sods going through the code in the future.

import NiOverride ; From RaceMenu. Without that, this would not be easy...if possible at all. 

; New things to add/ or to change:
;	- UNP body support once CBBE is complete. That's not going to be fun. (for the naked body parts, this is functional, but for armoured, it is not)
;	- Male body support. This will be even worse. 
;	- Maybe remove HDT-ness from the tails as an option. Why one would not want swooshy tails, who knows. But it should be an option.
;	- A spell of some kind that does not require the character creation menu to be opened. Or MCM. I dunno. RaceMenu will still be needed for NiOverride.

; Known issues: 
;	- Vampire doesn't quite work yet. I need to see if there is a script event for when the transformation happens. 
;	- I've discovered that sometimes the equipped ears and tails can bug out. Maybe create a spell (alteration, or race power) that exists just to unequip and re-equip them.


; Tail types: Beta Matera (Non HDT & HDT), Inari HDT (If a retexture is possible), Original Matera (Non HDT & HDT), Fox Tail (Non HDT & HDT)
; NiOverride's Skin functions do not work like I thought they did. 


Int Property RM_MATERA_VERSION = 1 AutoReadOnly
Int Property Version = 0 Auto
String Property CATEGORY_KEY = "racemenu_matera" AutoReadOnly

Actor Property PlayerRef Auto
ActorBase PB ; PlayerBase, but since it's "defined elsewhere", I have to abbreviate it.
Armor Property MateraBody Auto

Race Property MateraRace Auto
Race Property MateraVampireRace Auto

; Looking at the ears, I think the armour was a bad idea We're gonna have to go back to headparts. 
; This can probably start with blank ears
;------------
FormList Property MateraTailList Auto ; The list of tails. 
;	0 = Original, 1= Beta, 2 = Fluff, 3 = Nine Tail, 4 = Nine Tail Fan, 5 = Silky, 6 = Six Tail, 7 = Small, 8 = Three Tail, 9 = Rogue Tail, 10 = Fox, 11 = Fox Five

FormList Property MateraEarsList Auto ; The list of ears. 
;	0 = Original Matera, 1 = Elin, 2 = Elven, 3 = Lopsided, 4 = Rogue, 5 = Sideways, 6 = Small, 7 = Small Tufts, 8 = Spiky, 9 = Fox 

;/
The texture formlists.  I like it this way because I can add and remove things at will if needed.
This is how I manage this instead of swapping so damn many parts out, I just swap the texture sets instead.
Formlists are essentially prefilled arrays where (generally, but not always) the datatype is known already. 
They're filled from within the creation kit / editor itself, though they can be filled and emptied within a script, it would be a royal pain to fill all these lists.

This is how I am using the colour formlists, with each number equaling to the colour it should be. This is why I do not want to add new colours. 30 should be enough anyways.:

	0 = Albino, 1 = Black, 2 = Black Tip, 3 = Concept, 4 = Cotton Candy, 5 = Cotton Candy Black, 6 = Cotton Candy Blue, 7 = Cotton Candy White,
	8 = Dark Brown, 9 = Default, 10 = Default Tip, 11 = Everlast Evil, 12 = Fennec, 13 = Georgian Black, 14 = Georgian White, 15 = Green Tip, 16 = Holo 
	17 = Ice, 18 = Krystal, 19 = Krystal Tip, 20 = Light Brown, 21 = Maned Wolf Mystic, 22 = Mixed, 23 = Pink Tip, 24 = Pumpkin, 25 = Silver 
	26 = Silver Light, 27 = Slushie, 28 = White, 29 = White Tip.
/;

; Body and hand colours. Feet textures are part of the body texture.
FormList Property FemaleBodyColour_List Auto
FormList Property FemaleHandsColour_List Auto
FormList Property MaleBodyColourList Auto
FormList Property MaleHandsColourList Auto

; Tail texture lists
FormList Property BetaTailColourList Auto
FormList Property OriginalTailColourList Auto
FormList Property FoxTailColourList Auto

; Ear Texture lists
FormList Property BetaEarColourList Auto
FormList Property MateraEarsColourList Auto
FormList Property FoxEarsColourList Auto

; I decided to make these arrays. While it does hurt code readability, in theory, arrays are a singluar contiguous block of memory or (presumably) save space storage.
; This would (also theoretically) enable slightly faster access times due to it being a single continuous block and not being separate, scattered variables.
; Looking at the save file with something like Resaver, we can see that arrays actually have their own section, and are indeed stored as a continuous block.
; Good job Bethesda, you did something right!
TextureSet[] MateraTextures ; Which aspect is which is defined later on in here.
ArmorAddon[] MateraParts ; Read the above comment. 
Bool[] Bodies ; Let the bodies hit the floor. (Body types storage. I couldn't resist a reference). This may be removed in the future.
Bool[] Booleans ; IsMale, IsMatera, FirstRun, processing, HasHDT

Bool HasHDT = false

; Considering turning these into arrays as well.
Float MateraColour = 10.0
Float MateraTailType = 0.0
Float MateraEarType = 0.0

Float MateraEarCount = 8.0 ; This will change if HDT tails is installed. From 9 to 11.
Float MateraTailCount = 9.0 ; This only increases by 1 if HDT is installed.

; This as well. 
Int DefaultColour = 10
Int CurrentColour = 10
Int TailType = 1 ; Default 1
Int BodyType = 0 ; Default 0
Int EarType = 0 ; Default 0

; Keywords applied to the objects so that if, somehow something overrides them, and is *not* from this mod, the keyword is checked for, and if not found, the item is ignored.
; Otherwise, this could lead to hilariously broken textures set swapping.
Keyword Property MateraEarsKeyword Auto
Keyword Property MateraTailKeyword Auto

; This is set via a light plugin. As, currently I do not have permissions to directly use the HDT tail meshes and bundle them with the mod, I will need to change the
; model paths of the tails that do have existing HDT models to the ones from Equippable HDT Tails for SE. This value will by default be 0, and that plugin will change it to a 1.
; This is because the HDT tails have additional (invisible in game) model nodes to make the collision physics work. We need to be able to ignore these nodes or know they exist so
; the texture changing bit doesn't put the texture on the wrong node. Whenever I do get permissions, I still might do it this way.
GlobalVariable Property MateraHasHDTGlobal Auto

;---------------------------------------------------------------------------------------------------------------------
; Events.


String BodyString = ""

; Runs when the script initialises for the very first time.
Event OnInit()
	Parent.OnInit()
	Version = RM_MATERA_VERSION
	InitialiseValues()
	PluginCheck()
	RegisterForMenu("RaceSex Menu") ; RaceMenu, or the character creation menu name. 
	CheckHDT()
EndEvent


; When RaceMenu is loaded and the category is requested, create the new "Matera" category.
Event OnCategoryRequest()
	AddCategory(CATEGORY_KEY, "MATERA", -750)
EndEvent


Event OnMenuOpen(String MenuName)
	If(!Booleans[2])
		Booleans[2] = true
	EndIf
	If(MenuName == "RaceSex Menu")
		CheckSex()
		RaceCheck()
		PluginCheck()
	EndIf
EndEvent

; When a UI menu is closed.
Event OnMenuClose(String MenuName)
	If(MenuName == "RaceSex Menu")
;		If(Booleans[2]) ; Setting first run to false if it is not.
;			Booleans[2] = false
;		EndIf
		RaceCheck()
		CheckSex()
	EndIf
EndEvent


; When it is time for slider creations, create them and set their appropriate values.
Event OnSliderRequest(Actor player, ActorBase playerBase, Race actorRace, bool isFemale)
	AddSliderEx("Fur Colour", CATEGORY_KEY, "matera_colour", 0.0, 29.0, 1.0, MateraColour)
	AddSliderEx("Ear Style", CATEGORY_KEY, "matera_ear_style", 0.0, MateraEarCount, 1.0, MateraEarType)
	AddSliderEx("Tail Type", CATEGORY_KEY, "matera_tail_type", 0.0, MateraTailCount, 1.0, MateraTailType) 
EndEvent


; when the RaceMenu slider is changed...
Event OnSliderChanged(string callback, float value)
	If(callback == "matera_colour")
		If(value <= 29.0)
			MateraColour = value
			FindColour(value)
		EndIf

	ElseIf(callback == "matera_ear_style")
		If(value <= MateraEarCount)
			MateraEarType = value
			EarType = value as Int
			SetEarType()
		EndIf

	ElseIf(callback == "matera_tail_type")
		If(value <= MateraTailCount)
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
	MateraParts = new ArmorAddon[5] ; 0 = Feet, 1 = Torso, 2 = Hands. Others are currently unused, but are left so they may be used in the future.
	Bodies = new Bool[4] ; CBBE, 3BBB, UNP, UUNP
	Booleans = new Bool[5] 

	If(!PlayerRef) ; Null check. It can happen sometimes when Papyrus loses its goddamn mind.
		PlayerRef = Game.GetPlayer()
	EndIf

	PB = PlayerRef.GetActorBase()

	FillArrays()
	InitialiseBodyParts()
EndFunction


; Because arrays can't be declared and filled in the same line like most other sane languages. Bloody Papyrus. Not the boi, the skelly is a bean. This language... It is horrible sometimes.
Function FillArrays()
	MateraTextures[0] = FemaleBodyColour_List.GetAt(DefaultColour) as TextureSet ; Female body texture
	MateraTextures[1] = FemaleHandsColour_List.GetAt(DefaultColour) as TextureSet ; Female hands texture
	MateraTextures[2] = MaleBodyColourList.GetAt(DefaultColour) as TextureSet ; Male body texture
	MateraTextures[3] = MaleHandscolourList.GetAt(DefaultColour) as TextureSet ; Male hands texture
	MateraTextures[4] = BetaTailColourList.GetAt(DefaultColour) as TextureSet ; Tail texture
	MateraTextures[5] = BetaEarColourList.GetAt(DefaultColour) as TextureSet ; Ears texture

	Booleans[0] = true ; IsMale, Because the player character is usually male by default, unless they have Skyrim Unbound's "Female by Default" installed, or some other mod that changes this.
	Booleans[1] = false ; IsMatera, pretty simple to figure that one out. 
	Booleans[2] = true ; FirstRun
	Booleans[3] = false ; Processing
	Booleans[4] = false ; HDT, whether or not HDT physics based tails are installed. 

	Bodies[0] = false ; CBBE
	Bodies[1] = false ; 3BBB
	Bodies[2] = false ; UNP
	Bodies[3] = false ; UUNP
EndFunction


; One of the more unusual functions I've named, but it does exactly what it says. 
Function InitialiseBodyParts() 
	MateraParts[0] = MateraBody.GetNthArmorAddon(0) ; Feet
	MateraParts[1] = MateraBody.GetNthArmorAddon(1) ; Torso
	MateraParts[2] = MateraBody.GetNthArmorAddon(2) ; Hands

	MateraParts[0].RegisterForNiNodeUpdate()
	MateraParts[1].RegisterForNiNodeUpdate()
	MateraParts[2].RegisterForNiNodeUpdate()
	Log("Initialisation complete", 0)
EndFunction


; This is here to keep me from repeating these four lines at least four times. 
Function SetBodyArray(Bool CBBE, Bool ThreeBBB, Bool UNP, Bool UUNP)
	Bodies[0] = CBBE
	Bodies[1] = ThreeBBB
	Bodies[2] = UNP
	Bodies[3] = UUNP
EndFunction

;---------------------------------------------------------------------------------------------------------------------
; Checking functions. 

Function RaceCheck()
	If(Game.GetPlayer().GetRace() == MateraRace || Game.GetPlayer().GetRace() == MateraVampireRace) ; Done this way because for whatever reason using PlayerRef won't work.
		Booleans[1] = true ; If player is now a Matera, set this to true.
	Else
		Booleans[1] = false ; Otherwise, it's false.
	EndIf
EndFunction


; Pretty self-explanatory.
Function CheckSex()
	If(PB.GetSex() == 0)
		Booleans[0] = true
	Else
		Booleans[0] = false
	EndIf
EndFunction


; If 3BBB or UUNP is detected, it overrides the base CBBE or UNP, as the nodes have different names.
; I do it this way, instead of using something like plugin load order checking, this is dynamic. It no longer relies on having a plugin installed. Yay.
Function PluginCheck()
	Log("Any errors in your debug log from this part are harmless. This just means you do not have the body type mod installed.", 0)
	Form CBBE = Game.GetFormFromFile(0x800, "CBBE.esp")
	Form ThreeBBB = Game.GetFormFromFile(0x800, "3BBB.esp") ; It didn't like calling it 3BBB, so ThreeBBB it is.
	; Apparently UNP does not have a plugin. I could have sworn it did.
	Form UUNP = Game.GetFormFromFile(0x800, "BHUNP3BBB.esp")

	If(CBBE)
		Log("CBBE installed", 0)
		SetBodyArray(true, false, false, false)
	EndIf

	If(ThreeBBB)
		Log("3BBB Installed", 0)
		SetBodyArray(true, true, false, false)
	EndIf

	If(UUNP)
		SetBodyArray(false, false, true, true)
		Log("UUNP installed", 0)
	EndIf

	If(!Bodies[0] && !Bodies[1]) ; CBBE not found, so it must be UNP...Right? I honestly have no idea what other body replacers there are out there.
		SetBodyArray(false, false, true, false)
	EndIf

	Log("End section of harmless errors from Matera plugin checking.", 0)
EndFunction


Function CheckHDT()
	Int HDTInt = MateraHasHDTGlobal.GetValueInt()

	If(HDTInt == 0)
		HasHDT = false
		MateraTailCount = 9.0 ; Reset to default values, just to play it safe. I have zero confidence in Papyrus not to start drooling on itself. 
		MateraEarCount = 8.0
		Log("HDT not found", 1)
	Else
		HasHDT = true
		MateraTailCount = 11.0
		MateraEarCount = 9.0
		Log("HDT found.", 1)	
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
		SetEarTexture(ColourChoice)
	EndIf

	If(Booleans[0])
		SetMaleBodyColour()
	Else
		SetFemaleBodyColour()	
	EndIf

	While(Booleans[3]) ; Processing...It's thinking, give it some time.
		Utility.Wait(0.1)
	EndWhile

	SetEarColour()
	SetTailColour()

	;Utility.Wait(0.1)
	PlayerRef.QueueNiNodeUpdate()
EndFunction


;---------------------------------------------------------------------------------------------------------------------
; Body colour changing 

; 0 = Female Body, 1 = Female Hands, 2 = Male Body, 3 = Male Hands, 4 = Tail, 5 = Ears
; 0 = Feet, 1 = Torso, 2 = Hands
Function SetFemaleBodyColour()
	Booleans[3] = true ; "Hold on, I need time to think and look through my nodes."
	
	If(PlayerRef.GetEquippedArmorInSlot(32) != None)
		Armor body = PlayerRef.GetEquippedArmorInSlot(32)		
		SearchAndSet(!Booleans[0], body, "CBBE", 0)
		SearchAndSet(!Booleans[0], body, "3BBB", 0)
	Else
		; I discovered via netimmerse debug logs that if the part passed in is just a body part, then the root node is what it is looking for.
		; If the node I pass in is the *only* node there, it fails to find it. However, if a blank string is passed in, it has no issues finding it.
		; This issue took a solid week of head scratching and frustration for me to figure out. 
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
	;PlayerRef.QueueNiNodeUpdate()
	Booleans[3] = false ; "Okay, I'm done thinking. I found my nodes and did the things I needed to."
EndFunction
	
	
Function SetMaleBodyColour()
	; Not implemented yet. Awating to make female body work first. CBBE mainly works, UNP is totally untested.
	; And hell, if I can get skin functions working I may be able to remove even more code. Which is good. Less crap to go wrong.
	; Heavily considering HIMBO being a requirement.
EndFunction
	

;---------------------------------------------------------------------------------------------------------------------
; Tail colour operations.


;Handles setting the tail texture depending on the currently selected tail type.
Function SetTailTexture(Int ColourChoice)
	If(TailType == 0)
		MateraTextures[4] = OriginalTailColourList.GetAt(ColourChoice) as TextureSet

	ElseIf(TailType >= 1 && TailType <= 8); Greater than or equal to one and less than or equal to 8
		MateraTextures[4] = BetaTailColourList.GetAt(ColourChoice) as TextureSet

	ElseIf(TailType == 9 || TailType == 10)
		MateraTextures[4] = FoxTailColourList.GetAt(ColourChoice) as TextureSet

	Else
		Log("Tail type invalid", 1)
	EndIf
EndFunction


Function SetTailColour()
	; Textures array index 4 is the tail texture.
	Armor Tail = PlayerRef.GetEquippedArmorInSlot(40)

	If(Tail) ; Basically, a null check to see if there was any tail equipped.
		If(Tail.HasKeyword(MateraTailKeyword))
;			If(HasHDT) ; HDT tails have multiple nodes to make the physics work in the form of virtual body parts that are invisible in game, but exist in the model.
 				;Also, switch statements don't exist in papyrus. So I have to do if/elseif/else messes like this. 
				Debug.Trace("Tail Type: " + TailType)
				If(TailType == 0)
					AddOverrideTextureSet(PlayerRef, !Booleans[0], Tail, Tail.GetNthArmorAddon(0), "", 6, -1, MateraTextures[4], false) 

				ElseIf(TailType == 1)
					AddOverrideTextureSet(PlayerRef, !Booleans[0], Tail, Tail.GetNthArmorAddon(0), "TailM", 6, -1, MateraTextures[4], false)
				
				ElseIf(TailType > 1 && TailType <= 8)
					AddOverrideTextureSet(PlayerRef, !Booleans[0], Tail, Tail.GetNthArmorAddon(0), "", 6, -1, MateraTextures[4], false) ; Non HDT tails only have one node. 

				ElseIf(TailType == 9)
					AddOverrideTextureSet(PlayerRef, !Booleans[0], Tail, Tail.GetNthArmorAddon(0), "fox_tail_0", 6, -1, MateraTextures[4], false)

				ElseIf(TailType == 10)
					AddOverrideTextureSet(PlayerRef, !Booleans[0], Tail, Tail.GetNthArmorAddon(0), "fox_tail_0", 6, -1, MateraTextures[4], false)
					AddOverrideTextureSet(PlayerRef, !Booleans[0], Tail, Tail.GetNthArmorAddon(0), "fox_tail_001", 6, -1, MateraTextures[4], false)
					AddOverrideTextureSet(PlayerRef, !Booleans[0], Tail, Tail.GetNthArmorAddon(0), "fox_tail_002", 6, -1, MateraTextures[4], false)
					AddOverrideTextureSet(PlayerRef, !Booleans[0], Tail, Tail.GetNthArmorAddon(0), "fox_tail_003", 6, -1, MateraTextures[4], false)
					AddOverrideTextureSet(PlayerRef, !Booleans[0], Tail, Tail.GetNthArmorAddon(0), "fox_tail_004", 6, -1, MateraTextures[4], false)
				
				Else
					; Also should not happen once all tail types are implemented.
				EndIf
;			Else
;				AddOverrideTextureSet(PlayerRef, !Booleans[0], Tail, Tail.GetNthArmorAddon(0), "", 6, -1, MateraTextures[4], false) ; Non HDT tails only have one node. 
;			EndIf
			
		;	PlayerRef.QueueNiNodeUpdate()
		Else
			Log("Equipped item in the tail slot is not a Materan tail!", 1)
		EndIf
	Else
		Log("No tail found.", 1)
	EndIf
EndFunction



;---------------------------------------------------------------------------------------------------------------------
; Ear colour changing function

Function SetEarTexture(Int ColourChoice)
	Armor Ears = PlayerRef.GetEquippedArmorInSlot(43)

	If(Ears)
		If(EarType == 0)
			MateraTextures[5] = MateraEarsColourList.GetAt(ColourChoice) as TextureSet

		ElseIf(EarType > 0 && EarType <= 8) ; All the beta ears share the same textures, so....
			MateraTextures[5] = BetaEarColourList.GetAt(ColourChoice) as TextureSet
			
		ElseIf(EarType == 9)
			MateraTextures[5] = FoxEarsColourList.GetAt(ColourChoice) as TextureSet

		Else
			; Shouldn't really happen.
		EndIf
	Else
		Log("No ears were found.", 2)
	EndIf
EndFunction


Function SetEarColour()
	Armor Ears = PlayerRef.GetEquippedArmorInSlot(43)

	If(Ears)
		If(Ears.HasKeyword(MateraEarsKeyword))
				AddOverrideTextureSet(PlayerRef, !Booleans[0], Ears, Ears.GetNthArmorAddon(0), "", 6, -1, MateraTextures[5], false) ; All ears, even the HDT ones have a single node, apparently.
				PlayerRef.QueueNiNodeUpdate()
		Else
			Log("Equipped item in ears slot is not Materan ears!", 1)
		EndIf
	Else
		Log("Nothing found in the ears slot!", 2)
	EndIf
EndFunction

;---------------------------------------------------------------------------------------------------------------------
; Tail and ear changing functions. I had tried using an armor addon and just swapping the model path. I would do this by having a formlist  of the tails (like I do) 
; and get the model path of the chosen tail, and set the tail "addon"' model path to the new tail, then queue a ninode update. This...failed. Otherwise I would be using that instead.
; This same process would have been done for the ears too. I had them as headparts and swapped those out, but that got real messy and sometimes failed. It worked, sure. But was a huge mess.
; You can see it in the other branches (and commit history) of this mod. I hated it, and hated implementing it. 

Function SetTailType()
	Armor CurrentTail = PlayerRef.GetEquippedArmorInSlot(40) ; Tail will always be slot 40. This is safe to use.
	Armor NewTail = MateraTailList.GetAt(TailType) as Armor
	PlayerRef.RemoveItem(CurrentTail, 1, true, None)

	PlayerRef.AddItem(NewTail, 1, true)
	PlayerRef.EquipItem(NewTail, true, true)
	SetTailColour()
	PlayerRef.QueueNiNodeUpdate()
EndFunction

                                                                                                                           
Function SetEarType()
	Armor CurrentEars = PlayerRef.GetEquippedArmorInSlot(43) ; Ear slot should always be free.
	Armor NewEars = MateraEarsList.GetAt(EarType) as Armor

	PlayerRef.RemoveItem(CurrentEars, 1, true, None)
	PlayerRef.AddItem(NewEars, 1, true)
	PlayerRef.EquipItem(NewEars, true, true)
	SetEarColour()
;	Utility.Wait(0.1)
	PlayerRef.QueueNiNodeUpdate()
Endfunction


;---------------------------------------------------------------------------------------------------------------------
; "Utility" Functions.


; Searches an armor piece for the passed in node.
Function SearchAndSet(bool isFemale, Armor arm, String node, int TexOption) ; Full name would be SearchForNodeAndSetColourIfNodeExists, but that's too damn long to type out every time.
	int i = 0 ; Good ol' "i"!
	int addoncount = arm.GetNumArmorAddons()
	TextureSet tex = MateraTextures[TexOption]

	; For loops don't exist either. So I have to use controlled while loops, and set the counter when I need to break out of the loop. 
	While(i < addoncount)
		If(HasArmorAddonNode(PlayerRef, false, arm, arm.GetNthArmorAddon(i), node, true))
			AddOverrideTextureSet(PlayerRef, isFemale, arm, arm.GetNthArmorAddon(i), node, 6, -1, tex, true)
			i = addoncount ; Break out of the loop once the node has been found.
		Else
			Log("Node " + node + " not found on armor piece " + arm.GetName() + ".", 1)
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
; Debugging and logging. 

; This outputs to the Papyrus log file the passed in string with a "pre-pend" I think it's called.
Function Log(String s, Int severity)
	Debug.Trace("(Matera Reborn) |  " + s, severity)
EndFunction


; If I ever end up figuring out how to check the texture path on a nif model, and use that to find the right node so I can set the texture, there should be a variable
; that is checked. This is because someone may have custom texture paths for their body mesh that aren't where the default textures are. 
; Doing it this way has built in handling for when I implement that.

;---------------------------------------------------------------------------------------------------------------------
; Getters. The names explain what they return or get.

String Function GetBodyString()
	If(Bodies[0] && !Bodies[1])
		BodyString = "CBBE"

	ElseIf(Bodies[0] && Bodies[1])
		BodyString = "3BBB"
	
	ElseIf(!Bodies[0] && !Bodies[1] && Bodies[3])
		BodyString = "BaseShape"
		
	Else
		BodyString = ""
	EndIf

	return BodyString
EndFunction

Bool Function GetIsMale()
	return Booleans[0]  
EndFunction

Bool Function GetIsMatera()
	return Booleans[1]
EndFunction

Bool Function GetIsFirstRun()
	return Booleans[2]
EndFunction

Bool Function GetIsProcessing()
	return Booleans[3]
EndFunction

Bool Function GetHasHDT()
	return Booleans[4]
EndFunction

Int Function GetTailType()
	return TailType
EndFunction

Int function GetEarsType()
	return EarType
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

TextureSet Function GetEarsTex()
	return MateraTextures[5]
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

