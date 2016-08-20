# TankHealth

This addon is an ElvUI plugin which adds the potential amount of self-healing a tank can do onto their healthbar.

![TankHealth illustrative image](https://imgur.com/Q4xQXeE.png)

The heal spell that is used depends on the class:

- DH: [Soul Cleave](http://www.wowhead.com/spell=203798/soul-cleave)
- DK: [Death Strike](http://www.wowhead.com/spell=49998/death-strike)
- Druid: [Frenzied Regeneration](http://www.wowhead.com/spell=22842/frenzied-regeneration)
- Monk: [Expel Harm](http://www.wowhead.com/spell=115072/expel-harm)
- Paladin: [Light of the Protector](http://www.wowhead.com/spell=184092/light-of-the-protector)
- Warrior: [Ignore Pain](http://www.wowhead.com/spell=190456/ignore-pain) (shows the potential absorb)

The addon takes into account various stats, talents, artifact traits, raid cooldowns and other variables when calculating the potential heal.

### Help

If something is broken, please [open an issue on the issue tracker](https://github.com/sunaurus/ElvUI_TankHealth/issues/new).

### Contributing

All pull requests on [github](https://github.com/sunaurus/ElvUI_TankHealth) are appreciated,
but please let me know before you start work so that I know not to work on the same thing.
Feel free to work on any issues on the issue tracker, something on the to do list (below), or new features.

### To do

- Cache relevant talents on PLAYER_TALENT_UPDATE events (instead of checking every time we calculate potential heals)
- Change bar color based on heal power? (for example, red if heal is near theoretical minimum, green if heal is near theoretical maximum)