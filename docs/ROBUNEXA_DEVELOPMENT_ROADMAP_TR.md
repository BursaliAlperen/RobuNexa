# RobuNexa — Teknik Denetim ve Gelişim Yol Haritası

Bu belge, mevcut depo yapısına göre hazırlanmış bir mühendislik denetimi ve aşamalı geliştirme planıdır. Amaç mevcut NAM/reanimation davranışını koruyarak sistemi daha güvenilir, bakımı kolay, performanslı ve test edilebilir hale getirmektir.

## 1. Mevcut durum

Depoda görülen ana bileşenler:

- `source/reanim.lua`: reanimation çekirdeği için eski/deneysel bir uygulama.
- `source/reanimation/engine.lua`: alternatif harici reanimation motoru seçicisi.
- `content/movesets/Gojo/module.lua`: Gojo moveset'i.
- `content/movesets/Sukuna/v_sukuna.lua`: Sukuna moveset'i.
- `content/animations/` ve `content/sounds/`: yerel animasyon ve ses varlıkları.
- `uiassets/`: arayüz kaynakları.

**Önemli mimari kural:** NAM moveset giriş noktası ile harici engine seçicisi aynı oturumda birlikte çalıştırılmamalıdır. İkisi de karakter rig'i ve animasyon yaşam döngüsünü yönetebilir.

## 2. Öncelikli teknik riskler

### P0 — Çekirdek dosyanın güvenli hale getirilmesi

`source/reanim.lua` ilk incelemede aşağıdaki somut sorunları içeriyor:

- Illusion parçacık boyutu ifadesinde geçersiz Lua sözdizimi bulunuyor.
- Skill cooldown kontrolünde tanımsız `hfill` kullanılıyor.
- `IsSkillOnCooldown` içindeki tablo erişimi/parantez ifadesi bozuk.
- Fling temizliğinde `Debris:AddItem(self.RootPart, duration)` karakterin root parçasını yok edebilir; temizlenmesi gereken geçici kuvvet nesneleridir.
- `bodyAngularVelocity` değişkeni koşul bloğu dışında kullanılıyor; yerel kapsamı doğru yönetilmeli.
- HingeConstraint nesneleri için Attachment0/Attachment1 bağlantıları oluşturulmuyor.
- Karakter klonlama ve PrimaryPart ataması gerçek karakterin parçalarına referans verebilir; klon izolasyonu doğrulanmalı.
- Animator oluşturma yaklaşımı her BasePart'a Animator ekliyor; Roblox animasyon mimarisiyle uyumlu rig/Animator yönetimi kullanılmalı.

Bu dosya, mevcut ana loader ile ilişkisi ve aktif kullanım durumu doğrulanmadan topluca değiştirilmemelidir. Önce derlenebilirlik ve çağrı sözleşmeleri doğrulanmalıdır.

### P1 — Yaşam döngüsü ve kaynak temizliği

- Her moveset için tek bir cleanup/dispose yolu tanımla.
- CharacterRemoving, respawn, moveset değişimi ve UI kapatılmasında bağlantıları kes.
- Geçici Instance, Sound, ParticleEmitter, BodyMover ve kamera değişikliklerini kaydet ve geri yükle.
- Her ability için iptal edilebilir token/generation kullan; eski async görevlerin yeni karaktere etki etmesini önle.
- Tüm dış API ve executor bağımlılıklarını tek bir adapter katmanında topla.

### P1 — Ability altyapısı

Bütün moveset'lerde ortak bir ability sözleşmesi kullan:

- `Name`, `Description`, `Cooldown`, `Duration`, `Input`
- `CanActivate(context)`
- `Activate(context)`
- `Cancel(context)`
- `Cleanup(context)`

Cooldown'lar bitiş zamanı üzerinden yönetilmeli; UI sadece bu durumun görünümünü sunmalı. Aynı yeteneğin eşzamanlı tetiklenmesi engellenmeli. Hedef, karakter ve root part her aktivasyonda yeniden doğrulanmalı.

### P2 — UI/UX

- Ölçeklenebilir ve mobil uyumlu HUD.
- Ability ikonları, kısa açıklamalar ve kalan cooldown süresi.
- Hazır / beklemede / kullanımda / devre dışı durumları.
- Klavye, gamepad ve dokunmatik input eşlemesi.
- UI yeniden oluşturulurken yinelenen bağlantıları önleme.
- Erişilebilir kontrast, okunabilir metin ve kapatılabilir efektler.

### P2 — Asset yönetimi

- Tek bir asset manifest dosyası kullan.
- Her dosyanın yolu, türü, karakteri ve opsiyonel olup olmadığı kaydedilsin.
- İndirme başarısızlıkları için sınırlı retry ve anlaşılır hata bildirimi ekle.
- Dosya varlığı ve AnimLib parse doğrulaması yap.
- Kullanılmayan, yinelenen veya referansı kırık asset'leri raporla.
- Üçüncü taraf medya lisans/provenance bilgilerini ayrı kaydet.

### P2 — Performans

- RenderStepped üzerinde gereksiz tam model taramalarını kaldır.
- Efekt ve seslerde yaşam süresi sınırları koy.
- Sık kullanılan efektler için kontrollü pooling değerlendir.
- Her frame yerine gerektiğinde veya düşük frekansta güncellenebilecek işleri ayır.
- Parçacık sayısı, ses ve post-processing için kalite profilleri sun.
- Her moveset için aç/kapatılabilir debug ölçümleri ekle.

## 3. Önerilen hedef klasör yapısı

```text
source/
  core/
    lifecycle.lua
    character_context.lua
    cooldowns.lua
    asset_manager.lua
    input_manager.lua
    diagnostics.lua
  adapters/
    nam.lua
    executor.lua
  ui/
    hud.lua
    ability_button.lua
  movesets/
    gojo/
    sukuna/
content/
  manifests/
  animations/
  sounds/
tests/
  static/
  fixtures/
docs/
  architecture/
  development/
```

Bu yapı tek seferde taşınmamalı; mevcut loader sözleşmesi korunarak küçük adımlarla uygulanmalıdır.

## 4. Test ve kalite kapıları

Her PR şu kontrollerden geçmelidir:

1. Lua sözdizimi kontrolü.
2. Modül yükleme ve bağımlılık kontrolü.
3. Asset manifestindeki dosyaların varlık kontrolü.
4. Cooldown sınır durumları (0, negatif, tekrar tetikleme).
5. Respawn ve moveset değişiminde cleanup.
6. Eksik Humanoid/root/Animator durumları.
7. İndirme ve ses oynatma başarısızlığı.
8. Uzun süreli kullanımda bağlantı ve Instance sızıntısı.

Roblox executor ortamlarının tamamı otomatik test edilemeyeceği için gerçek oyun içi doğrulama ayrıca yapılmalıdır. Başarılı statik test, oyunda çalıştığının kanıtı değildir.

## 5. Uygulama sırası

### Faz 1 — Stabilizasyon
- Ana giriş noktalarını ve loader sözleşmesini doğrula.
- P0 sözdizimi ve veri kaybı risklerini düzelt.
- Character lifecycle ve cleanup testlerini ekle.

### Faz 2 — Ortak altyapı
- Cooldown ve ability API'sini ortaklaştır.
- Asset manifest ve indirme adapter'ı oluştur.
- Input ve UI durumlarını birbirinden ayır.

### Faz 3 — Moveset iyileştirmeleri
- Gojo ve Sukuna yeteneklerini ortak API'ye geçir.
- Animasyon geçişleri ve iptal davranışını standartlaştır.
- Her yeteneğin hedef, mesafe, durum ve cooldown doğrulamasını ekle.

### Faz 4 — Deneyim ve performans
- Mobil HUD ve input desteği.
- Efekt kalite profilleri.
- Tanılama paneli ve performans ölçümleri.
- Yeni moveset'ler için örnek modül şablonu.

## 6. Kabul kriterleri

- Respawn veya moveset değişimi sonrasında eski bağlantı/efekt kalmamalı.
- Aynı ability cooldown sırasında ikinci kez çalışmamalı.
- Eksik asset tüm moveset'i çökertmemeli.
- UI durumu gerçek ability durumuyla eşleşmeli.
- Bir moveset'in cleanup işlemi diğer moveset'i etkilememeli.
- Ana NAM ve harici engine giriş noktaları birbirinden bağımsız kalmalı.
- Her değişiklik küçük, incelenebilir commit ve PR'larla sunulmalı.

## 7. Geliştirme ilkeleri

- Var olan çalışan davranışı koru; varsayımla API değiştirme.
- Başarılı test edilmemiş özelliği tamamlandı olarak işaretleme.
- Üçüncü taraf kod ve medya lisanslarını koru.
- Kullanıcıya ait oyun oturumlarını veya başka oyuncuları etkileyen yetkisiz davranışlar ekleme.
- Önce güvenilir çekirdek, sonra görsel zenginlik ve yeni yetenekler.
