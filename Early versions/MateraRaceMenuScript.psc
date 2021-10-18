Scriptname MateraRaceMenuScript extends RaceMenuBase

; Valid Categories
; CATEGORY_BODY = 4
; CATEGORY_HEAD = 8
; CATEGORY_FACE = 16
; CATEGORY_EYES = 32
; CATEGORY_BROW = 64
; CATEGORY_MOUTH = 128
; CATEGORY_HAIR = 256
; CATEGORY_COLOR = 512
; Adding these together will result in your 
; slider appearing in multiple categories
Float EarStyle = 0
Float ColourChoice = 0

FormList Property ElinEarsList Auto
FormList Property ElvenEarsList Auto
FormList Property LopsidedEarsList Auto
FormList Property RogueEarsList Auto
FormList Property SidewaysEarsList Auto
FormList Property SmallEarsList Auto
FormList Property SmallTuftEarsList Auto
FormList Property SpikyEarsList Auto

import po3_SKSEFunctions

String[] EarStyles
String[] FurColours
Race Property MateraRace

;--------------------------------------------------------------------------------------------------------------------------------------------------
; INFORMATION
; Ear Styles: Elin, Elven, Lopsided, Rogue, Sideways, Small, Small Tufts, Spiky.

; Colours: Albino, Black, Black Tip, Concept, Cotton Candy, Cotton Candy Black, Cotton Candy Blue, Cotton Candy White, Dark Brown, Default,
;	Default Tip, Everlast Evil, Fennec, Georgian Black, Georgian White, Green Tip, Holo, Ice, Krystal, Krystal Tip, Light Brown, 
;	Maned Wolf Mystic, Mixed, Pink Tip, Pumpkin, Silver, Silver Light, Slushie, White, White Tip. 

; Body type will be selected in the mod installer (fomod).
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


; AddBodyPaint(string name, string texturePath)
;Event OnBodyPaintRequest()
;	MakeBodyColour("Albino Matera", "Actors\\Character\\Overlays\\Matera\\Albino\\femalebody.dds")
;EndEvent

; AddHandPaint(string name, string texturePath)
;Event OnHandPaintRequest()
	;AddHandPaint("My Handpaint", "Actors\\Character\\Character Assets\\Overlays\\MyWarpaint.dds")
;EndEvent

; AddFeetPaint(string name, string texturePath)
;Event OnFeetPaintRequest()
	;AddFeetPaint("My Feetpaint", "Actors\\Character\\Character Assets\\Overlays\\MyWarpaint.dds")
;EndEvent


;Event OnCategoryRequest()
;	AddCategory("CATEGORY_MATERA", "Matera")
;EndEvent



; Use this event to reset your values to defaults as well as Add your sliders
; AddSlider(string name, int section, string callback, float min, float max, float interval, float position)
Event OnSliderRequest(Actor player, ActorBase playerBase, Race actorRace, bool isFemale)
	; --------- Reset stored values here -----
	EarStyle = 0

	; --------- AddSliders here --------------
	; Give your Slider a very unique callback Name
	; you will use this to determine whether the value 
	; changed, you may also receive other mod callbacks

	AddSlider("Ear Style", CATEGORY_MATERA, "matera_ear_style", 0.0, 8.0, 1.0, EarStyle)
	AddSlider("Colour", CATEGORY_MATERA, "matera_colour", 0.0, 29.0,  10.0, MateraColour)
	
EndEvent

Event OnSliderChanged(string callback, float value)
	If(callback == "matera_ear_style")
		
		
	; if callback == "ChangeMYMODValue"
	; 	_myValue = value
	; endif
EndEvent



Function ReInit()


EndFunction


Function PopulateArrays()
	EarStyles = New String[7] 
	; 0 = Elin, 1 = Elven, 2 = Lopsided, 3 = Rogue, 4 = Sideways, 5 = Small, 6 = Small Tufts, 7 = Spiky.
	
	EarStyles[0] = "elin"
	EarStyles[1] = "elven"
	EarStyles[2] = "lopsided"
	EarStyles[3] = "rogue"
	EarStyles[4] = "sideways"
	EarStyles[5] = "small"
	EarStyles[6] = "smalltufts"
	EarStyles[7] = "spiky"
	
	
EndFunction