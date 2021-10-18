Scriptname MateraOptions extends RaceMenuBase



Event OnBodyPaintRequest()
	MakeBodyColour("Albino Matera", "Actors\\Character\\Overlays\\Matera\\Albino\\femalebody.dds")
EndEvent

Event OnHandPaintRequest()
	MakeHandColour("Albino Matera", "Actors\\Character\\Overlays\\Matera\\Albino\\femalehands.dds")
EndEvent


Function  MakeBodyColour(String name, String diffuse)
	AddBodyPaint(name, diffuse)
	AddBodyPaint(name, "Actors\\Character\\Overlays\\Matera\\_Shared\\femalebody_msn.dds")
	AddBodyPaint(name, "Actors\\Character\\Overlays\\Matera\\_Shared\\femalebody_s.dds")
EndFunction


Function MakeHandColour(String name, String diffuse)
	AddHandPaint(name, diffuse)
	AddHandPaint(name, "Actors\\Character\\Overlays\\Matera\\_Shared\\femalehands_msn.dds")
	AddHandPaint(name, "Actors\\Character\\Overlays\\Matera\\_Shared\\femalehands_s.dds")
EndFunction
