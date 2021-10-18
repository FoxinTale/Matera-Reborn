Scriptname MateraRaceMenuScript extends RaceMenuBase

import po3_SKSEFunctions



Race Property MateraRace Auto
Actor Property PlayerRef Auto

FormList Property FemaleColoursList Auto
FormList Property MaleColoursList Auto
FormList Property EarsColoursList Auto
FormList Property TailColoursList Auto
FormList Property EarsList Auto

String[] EarStyles
String[] FurColours

Float MateraEar = 5.0
Float MateraColour = 9.0

Int CurrentEar = 0
Int CurrentColour = 0

;--------------------------------------------------------------------------------------------------------------------------------------------------
; DOCUMENTATION
;
; Ideally, I would have used a similar data structure to a hashmap or 2D array, but neither of those two exist in Papyryus so I'm doing it in documentation.
;	This is added both for my own sanity and anyone else going through here. This was a pain in my ass to figure out.
;
; For ear styles: 0 = Elin, 1 = Elven, 2 = Lopsided, 3 = Rogue, 4 = Sideways, 5 = Small, 6 = Small Tufts, 7 = Spiky.
;
; For fur colours: 0 = Albino, 1 = Black, 2 = Black Tip, 3 = Concept, 4 = Cotton Candy, 5 = Cotton Candy Black, 6 = Cotton Candy Blue, 7 = Cotton Candy White,
;		8 = Dark Brown, 9 = Default, 10 = Default Tip, 11 = Everlast Evil, 12 = Fennec, 13 = Georgian Black, 14 = Georgian White, 15 = Green Tip, 16 = Holo
;		17 = Ice, 18 = Krystal, 19 = Krystal Tip, 20 = Light Brown, 21 = Maned Wolf Mystic, 22 = Mixed, 23 = Pink Tip, 24 = Pumpkin, 25 = Silver
;		26 = Silver Light, 27 = slushie, 28 = White, 29 = White Tip 
;--------------------------------------------------------------------------------------------------------------------------------------------------

Event OnInit()
	PopulateArrays()
EndEvent

Event OnPlayerLoadGame()
	ReInit()
EndEvent

;Event OnReloadSettings(Actor player, ActorBase playerBase)
	; Restore and re-apply your values here
	; if they are dynamically added properties
;EndEvent

;Event On3DLoaded(ObjectReference akRef)
;	OnReloadSettings(_playerActor, _playerActorBase)
;EndEvent

;Event OnCellLoaded(ObjectReference akRef)
;
;EndEvent



Event OnCategoryRequest()
	AddCategory("CATEGORY_MATERA", "Matera")
EndEvent



; Use this event to reset your values to defaults as well as Add your sliders
; AddSlider(string name, int section, string callback, float min, float max, float interval, float position)
Event OnSliderRequest(Actor player, ActorBase playerBase, Race actorRace, bool isFemale)
	; --------- Reset stored values here -----
	MateraEar = 5.0
	MateraColour = 9.0

	; --------- Add the sliders --------------
	AddSlider("Ear Style", CATEGORY_MATERA, "matera_ear_style", 0.0, 7.0, 1.0, MateraEar)
	AddSlider("Colour", CATEGORY_MATERA, "matera_colour", 0.0, 29.0, 1.0, MateraColour)
	
EndEvent

Event OnSliderChanged(string callback, float value)
	If(callback == "matera_ear_style")
		If(value <= 7.0)
			EarStyle= value
		EndIf
	ElseIf(callback == "matera_colour")
	
		
		
	Else
		; This shouldn't ever happen.
	EndIf
EndEvent



Function ReInit()


EndFunction


; Papyrus cannot declare arrays cleanly in one line. aaaaaaa.
Function PopulateArrays()
	EarStyles = New String[7]

	
	EarStyles[0] = "elin"
	EarStyles[1] = "elven"
	EarStyles[2] = "lopsided"
	EarStyles[3] = "rogue"
	EarStyles[4] = "sideways"
	EarStyles[5] = "small"
	EarStyles[6] = "smalltufts"
	EarStyles[7] = "spiky"
	
	
	
	
	
EndFunction



Function ChangeEar(Float earoption)
	int EarChoice = EarOption as int
	
	If(EarChoice == 0)
	
	ElseIf(EarChoice == 1)
	
	ElseIf(EarChoice == 2)
	
	ElseIf(EarChoice == 3)


EndFunction


; I'm sorry for the disaster that this function is, but switch statements don't exist in Papyrus. 
Function ChangeColour()

	ReplaceArmorTextureSet(Player, Armor akArmor, TextureSet akSourceTXST, TextureSet akTargetTXST, int aiTextureType = -1) global native


EndFunction


Function MaintainEars()
	;aaaaaa
EndFunction


Function MaintainTail()
	;aaaaaa
EndFunction


Function MaintainColour()
	;aaAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
EndFunction