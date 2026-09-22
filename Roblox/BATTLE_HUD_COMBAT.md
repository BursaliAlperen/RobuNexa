# Battle HUD / Combat Layer

Screenshot-inspired battleground layer for RobuNexa.

Placement:
- ReplicatedStorage/Modules: BattleConfig, BattleUI, ShiftLock
- ServerScriptService/ServerModules: KillService, Targeting
- ServerScriptService: BattleServer
- StarterPlayer/StarterPlayerScripts: BattleClient

Included:
- Left Komut Dosyaları / Koleksiyon / Mağaza buttons.
- Purple Rastgele seçici button.
- Blood Moon / 2x event banner and center feed.
- Kills + Cash bottom-left.
- Chest timer + lock control bottom-right.
- Target name + health bars.
- Z/X/C/V mobile skill buttons.
- Desktop M1 and Z/X/C/V bindings.
- Custom ShiftLock toggle; LeftShift also works on desktop.
- Server-authoritative target, range, cooldown, damage and kill validation.

The code uses local ModuleScripts with require(). It does not download or execute arbitrary remote Lua.
