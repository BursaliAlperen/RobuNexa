# RobuNexa — Pluginsiz Tek Tık GitHub Kurulum

## 1. Studio'da HTTP'yi aç

**File → Experience Settings → Security → Allow HTTP Requests**

Roblox'un resmi dokümanında HttpService ile HTTP isteklerinin bu ayardan etkinleştirildiği belirtiliyor.

## 2. Command Bar'ı aç

**View/Script → Command Bar**

Windows'ta güncel Studio'da Command Bar için `Ctrl+9` kullanılabilir.

## 3. Tek installer script

GitHub'daki şu dosyanın tamamını kopyala:

https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/rbxm-moveset-system/Roblox/Studio/ONE_CLICK_INSTALL.lua

Command Bar'a yapıştır ve **Run**.

Installer:

- GitHub tree'yi okur.
- `Roblox/` altındaki runtime `.lua` dosyalarını bulur.
- `.server.lua` → Script
- `.client.lua` → LocalScript
- Modules/MiniGames/ServerModules → ModuleScript
- Klasörleri otomatik oluşturur.
- Script Source'larını doğrudan Studio'ya yazar.
- Kurulum sırasında runtime Script'leri kapalı tutar.
- Bütün dosyalar bittikten sonra managed Script'leri açar.
- Kurulum sonucunu Output'a raporlar.

## 4. Test

Kurulumdan sonra Explorer'da en az şunları görmelisin:

- ReplicatedStorage/Modules
- ReplicatedStorage/MiniGames
- ReplicatedStorage/Remotes
- ServerScriptService/ServerModules
- ServerScriptService/GameServer.server.lua
- StarterPlayer/StarterPlayerScripts/MainClient.client.lua
- StarterPlayer/StarterPlayerScripts/ScoreHUD.client.lua

10 mini oyun:

1. Dodge Run
2. Target Rush
3. Stack Tower
4. Coin Rush
5. Jump Challenge
6. Reaction Test
7. Color Rush
8. Memory Match
9. Falling Platforms
10. Floor Is Lava

## 5. Yayın

Önce **Play** ile test et.

Sonra:

**File → Publish to Roblox**

### Önemli

Bu sistem `loadstring` kullanmaz. GitHub'dan indirilen kaynak, Studio Command Bar'ın yetkisiyle gerçek Script/LocalScript/ModuleScript nesnelerine yazılır.

RBXM binary assetleri bu installer'ın dışında tutulur; Roblox'un normal Lua çalışma ortamında rastgele `.rbxm` byte'larını Instance'a dönüştürmeye çalışmıyoruz.

Branch şu an:

`rbxm-moveset-system`

PR/main'e merge ettikten sonra installer içindeki BRANCH değerini `main` yapabilirsin.
