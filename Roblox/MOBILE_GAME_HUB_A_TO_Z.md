# RobuNexa A→Z Mobile Game Hub — Final Build Plan

## Hedef

Roblox Studio'da yayınlanabilir, mobile-first, 16:9 responsive, 10 mini oyunlu, ücretsiz ve server-authoritative bir hub.

Bu proje runtime'da GitHub'dan Lua indirip `loadstring` ile çalıştırmaz. GitHub kaynak kontrolüdür; yayınlanacak deneyimde kod Studio'nun gerçek Script/LocalScript/ModuleScript nesnelerinde bulunur.

## Katmanlar

### Client

`StarterPlayerScripts/MainClient.client.lua`

Tek merkezli UI:
- Boot
- Home
- Game Select
- Leaderboard
- Stats
- Settings
- Game HUD
- Countdown
- Game Over

Responsive:
- landscape 16:9 composition
- portrait/mobile fallback
- safe-area aware
- touch/mouse `Activated`
- minimum büyük dokunma hedefleri
- `UIAspectRatioConstraint`, `UIScale`, `UISizeConstraint`
- scrolling game list

Visual language:
- koyu arka plan
- krem primary surface
- turuncu accent
- düşük kontrast border
- küçük corner stud detayları
- hafif scale/punch/popup feedback
- kısa ve net oyun metinleri

### Server

`ServerScriptService/GameServer.server.lua`
`ServerModules/GameService.lua`

Sorumluluk:
- game session lock
- game start/finish
- world lifecycle
- action throttling
- payload validation
- score clamp
- DataStore save
- OrderedDataStore leaderboard
- module error isolation

### World

`ServerModules/WorldBuilder.lua`

Her game:
- base
- walls
- platform/decor
- game-specific layout module
- düşük part bütçesi

Hub:
- 10 portal
- ProximityPrompt
- GameId attribute

### Lighting

`ServerModules/LightingService.lua`

Her oyunun kendi theme key'i:
- Ambient
- OutdoorAmbient
- Fog
- Atmosphere
- ColorCorrection

## 10 oyun

1. Dodge Run — 5 lane reflex
2. Target Rush — target hit
3. Stack Tower — placement timing
4. Coin Rush — pickup timing
5. Jump Challenge — jump sequence
6. Reaction Test — delayed green signal
7. Color Rush — color matching
8. Memory Match — card pairs
9. Falling Platforms — timed platform collapse
10. Floor Is Lava — safe platform survival

Her ModuleScript `start(ctx)` ve `cleanup()` sağlar; action mantığı `ctx.onAction` ile server'da çalışır.

## Skor güvenliği

Client yalnızca intent gönderir:

`{Action = "...", Value = ...}`

Server:
1. aktif session var mı?
2. player başka oyunda mı?
3. payload table mı?
4. Action string uzunluğu güvenli mi?
5. Value primitive mi?
6. 30ms action throttle geçildi mi?
7. mini-game kendi kuralına uyuyor mu?
8. score `math.clamp(0, MaxScore)`

Client'a gelen score UI için gösterimdir; kayıt server tarafından yapılır.

## Data

DataStore:
`MobileGameHub_v1`

Oyuncu:
- Games[GameId] best score
- BestScore

OrderedDataStore:
- oyun başına global ranking
- retry/backoff
- rank lookup

## Error policy

Build/start/action sırasında hata:
- `pcall`
- warn
- session unlock
- world cleanup
- gerekiyorsa score 0 ile Finish
- client GameOver/Hub state

Oyuncu server hatası nedeniyle boş world'de bırakılmaz.

## Performans bütçesi

Hedef:
- mini-game world < 250 BasePart
- procedural dekor küçük tutulur
- particle burst kısa ömürlü
- tek burst <= 12 particle emission
- gereksiz Heartbeat bağlantısı yok
- UI listesi ScrollingFrame
- efektler event-driven

Creator Store kullanılırsa:
- yalnızca lisansı uygun, script içermeyen, düşük-poly asset
- texture hedefi <= 1024
- imported asset içindeki Script/LocalScript/ModuleScript runtime'a alınmadan önce incelenir

## Yayın checklist

1. HTTP Requests yalnızca geliştirme/installer iş akışı gerekiyorsa aç.
2. Studio Play Solo.
3. Start/finish/game switching test.
4. 10 oyunun tamamını test.
5. mobile touch test.
6. 16:9 desktop test.
7. DataStore için published experience test.
8. server/client error Output kontrolü.
9. memory/part/particle bütçesi kontrolü.
10. Publish to Roblox.

## GitHub workflow

Kod değişiklikleri GitHub branch'inde tutulur. Studio'ya canlı oyunun içinde keyfi source indirme yerine:
- GitHub source
- Studio sync/import
- Play test
- Publish

kullanılır.

## Mevcut önemli dosyalar

- `Roblox/StarterPlayerScripts/MainClient.client.lua`
- `Roblox/StarterPlayerScripts/ScoreHUD.client.lua`
- `Roblox/ReplicatedStorage/Modules/GameConfig.lua`
- `Roblox/ReplicatedStorage/Modules/Remotes.lua`
- `Roblox/ReplicatedStorage/Modules/UITheme.lua`
- `Roblox/ReplicatedStorage/Modules/Anim.lua`
- `Roblox/ReplicatedStorage/Modules/FxKit.lua`
- `Roblox/ReplicatedStorage/Modules/AudioKit.lua`
- `Roblox/ServerScriptService/GameServer.server.lua`
- `Roblox/ServerScriptService/ServerModules/GameService.lua`
- `Roblox/ServerScriptService/ServerModules/WorldBuilder.lua`
- `Roblox/ServerScriptService/ServerModules/LightingService.lua`
- `Roblox/ServerScriptService/ServerModules/DataService.lua`
- `Roblox/ServerScriptService/ServerModules/LeaderboardService.lua`
- `Roblox/ReplicatedStorage/MiniGames/*.lua`

## Tasarım prensibi

GUI "çok parlak casino" gibi değil; oyun hissini destekleyen:
- yüksek okunabilirlik
- büyük touch targets
- kısa round
- net score feedback
- ölçülü motion
- tutarlı spacing
- stud-inspired Roblox detayları

üzerine kurulur.

Monetization yok:
- Robux shop yok
- paid boost yok
- reklam yok
- pay-to-win yok
