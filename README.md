# TankHealth

This addon is an ElvUI plugin which adds the potential amount of healing a tank can do onto their healthbar.
The heal spell that is used depends on the class:

- DH: Soul Cleave http://www.wowhead.com/spell=203798/soul-cleave
- Druid: Frenzied Regeneration http://www.wowhead.com/spell=22842/frenzied-regeneration
- DK: Death Strike http://www.wowhead.com/spell=49998/death-strike
- Paladin: Light of the Protector Light of the protector http://www.wowhead.com/spell=184092/light-of-the-protector
- Warrior: Impending Victory http://www.wowhead.com/spell=202168/impending-victory
- Monk: Expel Harm http://www.wowhead.com/spell=115072/expel-harm

### To do

- Implement healing calculations for all classes
- Fix artifact traits in DH healing calculation
- Add a screenshot of the addon to the readme
- Be more DRY in main.lua (could probably remove Override and just do all logic in PostUpdate?)