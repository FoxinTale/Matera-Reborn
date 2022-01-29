Scriptname MateraSwitching extends ActiveMagicEffect

Actor Property PlayerRef Auto
Race Property MateraRace Auto
Formlist Property Skins Auto
Message Property SkinSelect Auto


Event OnEffectStart(Actor akTarget, Actor akCaster)
    If(akCaster == Game.GetPlayer())

        int SkinOption = SkinSelect.show()
        Armor NewSkin = Skins.GetAt(SkinOption) as Armor

        MateraRace.SetSkin(NewSkin)

        PlayerRef.QueueNiNodeUpdate()
    EndIf
EndEvent