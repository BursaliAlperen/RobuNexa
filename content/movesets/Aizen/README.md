# Aizen Moveset — RobuNexa / NAM

## Genel Bakış
**Sōsuke Aizen** odaklı, AAA kalitede moveset. Ana odak: **Kyoka Suigetsu (Mutlaka Illüzyon)** sistemi.

## Yetenekler

| Yetenek | Açıklama | CD | Hasar |
|---------|----------|-----|-------|
| **Aizen Cero** | Yeşil enerji topu, düz çizgide fırlatır | 1.0sn | 75 |
| **Aizen Cero Oscuro** | Koyu mor, daha büyük ve güçlü Cero | 15.0sn | 120 |
| **Aizen Hierro** | 10.0sn koruyucu kalkan, dokunma ile zayıflar | 10.0sn | — |
| **Aizen Shunpo** | Işık hızında teleport, en yakın düşmana veya ileriye | 2.0sn | — |
| **Aizen Kyoka Suigetsu** | Tüm düşmanlara illüzyon klonu bombardımanı | 30.0sn | — |
| **Aizen Ultimate** | 50 yarıçap tam illüzyon alanı, 10 klon, screen shake | 60.0sn | — |

## Illüzyon Sistemi Detayları

### Kyoka Suigetsu (Temel)
- Her oyuncunun karakterinin **yarı saydam klonunu** oluşturur
- Klonlar mor/altın neon materyal ile ayırt edilir
- Her klonun etrafında **parlayan halka efekti**
- Rastgele gecikme ile sırayla görünür (0-0.5sn arası)
- 12sn sonra fade-out ile kaybolur

### Kyoka Suigetsu Ultimate
- **10 illüzyon klonu** — 20 birim yarıçapta daire şeklinde
- **100 birim çap** illüzyon aura (yarı saydam mor küre)
- **Screen shake** efekti (2sn)
- Altın renkli klonlar
- 8sn sürer

## R6 Desteği
- `isR6Rig()` fonksiyonu karakterin R6/R15 olduğunu otomatik algılar
- `applyR6Pose()` R15 Motor6D formatını R6 joint map'ine dönüştürür
- R6 joint mapping: RootJoint → HumanoidRootPart, LeftHip → Left Leg vb.

## Fling Sistemi
- `flingTarget(model, power)` — Hedefi fırlatır + döndürür
- `BodyVelocity` ile doğrusal güç
- `BodyAngularVelocity` ile açısal dönüş (rastgele eksen)
- 0.4sn sonra otomatik temizlenir

## Ses Dosyaları (Eklenecek)
```
content/sounds/aizen-cero.mp3
content/sounds/aizen-shunpo.mp3
content/sounds/aizen-illusion.mp3
content/sounds/aizen-hierro.mp3
```

## Animasyon Dosyaları (Eklenecek)
```
content/animations/Aizen/AizenIdle.anim
content/animations/Aizen/AizenWalk.anim
content/animations/Aizen/AizenJump.anim
content/animations/Aizen/AizenFall.anim
content/animations/Aizen/Cero.anim
content/animations/Aizen/CeroOscuro.anim
content/animations/Aizen/Hierro.anim
content/animations/Aizen/Shunpo.anim
content/animations/Aizen/KyokaSuigetsu.anim
content/animations/Aizen/KyokaSuigetsuUltimate.anim
```

## Entegrasyon
NAM loader'a dahil etmek için `source/reanim.lua` içindeki moveset kayıt bölümüne:
```lua
"Aizen/v_aizen.lua@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/movesets/Aizen/v_aizen.lua",
```
satırını ekleyin.