# TankHealth



This addon is an ElvUI plugin which adds the potential amount of healing a tank can do onto their healthbar.

![alt text](https://imgur.com/Q4xQXeE.png "TankHealth illustrative image")

The heal spell that is used depends on the class:

- DH: [Soul Cleave](http://www.wowhead.com/spell=203798/soul-cleave)
- DK: [Death Strike](http://www.wowhead.com/spell=49998/death-strike)
- Druid: [Frenzied Regeneration](http://www.wowhead.com/spell=22842/frenzied-regeneration)
- Monk: [Expel Harm](http://www.wowhead.com/spell=115072/expel-harm)
- Paladin: [Light of the Protector](http://www.wowhead.com/spell=184092/light-of-the-protector)
- Warrior: [Ignore Pain](http://www.wowhead.com/spell=190456/ignore-pain) (shows the potential absorb)

### Help

If something is broken, please [open an issue on the issue tracker](https://github.com/sunaurus/ElvUI_TankHealth/issues/new).

### Contributing

All pull requests are appreciated, but please let me know before you start work so that I know not to work on
the same thing. If there are any issues on the issue tracker or something on the to do list (below), feel free to
work on them. New features will also be considered.


### To do

- Cache relevant talents on PLAYER_TALENT_UPDATE events (instead of checking every time we calculate potential heals)
- Change bar color based on heal power? (for example, red if heal is near theoretical minimum, green if heal is near theoretical maximum)