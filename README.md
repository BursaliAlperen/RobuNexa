# RobuNexa — NAM Reanimate (R6)

RobuNexa, NAM Reanimate altyapısının bu depoda barındırılan bir uyarlamasıdır. Eski içerik/modül bağlantıları RobuNexa'ya taşındı, uzaktan gelen Pusher mesajlarını Lua kodu olarak çalıştıran bölüm kaldırıldı ve **15 özgün R6 anime-esintili animasyon** Dances listesine eklendi.

> **Durum:** Bu bir geçiş/test derlemesidir; canlı executor içinde çalıştırılarak doğrulanmadı. Önce kendi özel test ortamında dene. Her Roblox deneyiminde veya her executor'da çalışacağı garanti edilmez.

## Dosya yapısı

- `Reanim.txt` — NAM Reanimate ana betiği.
- `LoadRobuNexa.lua` — sabit bir commit'e işaret eden GitHub başlatıcısı.
- `content/` — NAM'ın yerleşik moveset, dance, limb-map ve hat-map modülleri.
- `Animations/R6/` — 15 özgün anime-esintili animasyon verisi ve Studio KeyframeSequence oluşturucusu.
- `assets/anime/Hakari.anim` — upstream depodan aynen alınan gerçek ikili Hakari dans dosyası.
- `Modules/RobuNexaConfig.lua` — pasif URL/yol yapılandırması örneği.
- `NAM-ROBUNEXA-MIGRATION.md` — geçiş ve güvenlik notları.
- `store/list.txt` — bu sürümde bilerek boş bırakılmış topluluk mağazası manifesti.

## Hızlı başlatma (executor)

Yalnızca güvendiğin bir executor ortamında ve test etme iznin olan yerlerde kullan. Bu betik standart Roblox Studio LocalScript'i değildir; executor'a özgü dosya ve HTTP fonksiyonları gerektirir.

Executor'a şu satırı yapıştır:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/1b9267f0f788fdfea3bfb1a5e2197b359676537f/Reanim.txt"))()
```

Alternatif olarak `LoadRobuNexa.lua` dosyasının içeriğini çalıştırabilirsin. Ana betik URL'si değiştirilemez bir Git commit'ine sabitlenmiştir; yerleşik modüller de sabitlenmiş bir depo anlık görüntüsünden alınır. Bu, sürümü tekrarlanabilir yapar ama kodu çalıştırmadan önce inceleme gereğini ortadan kaldırmaz.

## İlk çalıştırma

1. Klasik **R6** avatar ile başla. Eklenen animasyonlar R15 için tasarlanmamıştır.
2. Başlatıcıyı çalıştır ve betiğin `NAMReanim/` klasörlerini oluşturmasını bekle.
3. NAM arayüzünde yerleşik modüllerin yüklenmesini bekle.
4. **Dances** listesini açıp `RN ...` ile başlayan animasyonlardan birini seç.
5. Bir modül yüklenmezse **Init Logs** bölümünü açıp ilk HTTP/compile hatasını incele. 404 veya derleme hatası sürüyorsa tekrar tekrar çalıştırma.
6. Eski yerel önbellek sorun çıkarırsa önce `NAMReanim/BuiltinModules/` veya `NAMReanim/Content/Anims/` klasörlerini yedekle; ardından ilgili dosyaları temizle. Ayarları sıfırlamak istemiyorsan `NAMReanim/tree.ehehetilde` dosyasını silme.

## Eklenen 15 animasyon

| Dances listesindeki ad | Tür |
|---|---|
| RN Anime Idle | Döngülü bekleme pozu |
| RN Anime Walk | Döngülü yürüme |
| RN Anime Run | Döngülü koşma |
| RN Wave | Selamlama/el sallama |
| RN Anime Guard | Döngülü savunma pozu |
| RN Anime Dash | Öne eğilme pozu; karakteri ileri itmez |
| RN Victory Pose | Zafer pozu |
| RN Anime Punch | Yalnızca görsel yumruk animasyonu |
| RN Spin Kick | Yalnızca görsel tekme pozu |
| RN Salute | Selam verme |
| RN Bow | Eğilerek selamlama |
| RN Power Charge | Döngülü güç toplama pozu |
| RN Sword Slash | Yalnızca görsel kılıç savurma pozu |
| RN Jump Land | Zıplama/iniş pozu; kök parçayı hareket ettirmez |
| RN Point | İşaret etme |
| Hakari's Dance | Kaynak depodan alınmış, döngülü Hakari dansı (native .anim) |

RN ile başlayan 15 hareket bu depo için oluşturulmuş özgün anime-esintili pozlardır; belirli bir anime sahnesinden kopyalanmamıştır. Hakari's Dance ayrı bir gerçek native .anim dosyasıdır ve kaynak/atıf bilgisi assets/anime/README.md içinde verilir. Yumruk, tekme ve kılıç savurma animasyonları **hasar, hitbox, silah veya sunucu taraflı hareket eklemez**.

## .anim dosyaları nasıl yükleniyor?

NAM'ın `AnimLib.Track.fromfile` fonksiyonu JSON değil, little-endian STEVE KeyframeSequence ikili biçimini bekler. RobuNexa'ya özel 15 hareket Animations/R6/*.anim altında Base64 metin sarmalayıcısıdır; yükleyici bunları çözüp NAMReanim/Content/Anims/ altına native dosya olarak yazar. Buna karşılık assets/anime/Hakari.anim gerçek binary .anim dosyasıdır ve aynen indirilip kullanılır. Dosyaların türü assets/anime/README.md içinde açıklanır.

## Güvenlik

- Eski Pusher WebSocket dinleyicisi kaldırıldı. Önceki kod, uzaktan gelen `jumpscare` mesajının içeriğini `loadstring` ile derleyip çalıştırabiliyordu.
- Yerleşik Lua modülleri ve animasyon dosyaları sabitlenmiş commit'lerden yüklenir.
- Animasyon içeriği veri olarak çözülür; Lua kodu olarak çalıştırılmaz.
- Topluluk mağazası bu sürümde bilerek boştur.
- NAM hâlâ executor API'leri ve yerleşik Lua modüllerini yüklemek için `loadstring` kullanır. `NAMReanim/Modules/` altındaki her dosya çalıştırılabilir kullanıcı kodudur; yalnızca yazdığın veya dikkatlice incelediğin modülleri bırak.
- Bilinmeyen loadstring kodlarını çalıştırma, hesap çerezlerini/oturum token'larını paylaşma ve güvenmediğin bir betik için güvenlik korumalarını kapatma.

## Bulunan hazır anime emote bağlantıları

Bunlar Roblox Creator Store'da yayımlanmış emote kayıtlarına ait keşif bağlantılarıdır; indirilebilir .anim kaynak dosyası değildirler ve bu depoya kopyalanmamıştır. Bazıları ücretli olabilir ve kullanım koşulları yayımlayan içerik sahibine bağlıdır:

- [Gojo Emote (Rolimon's kaydı)](https://www.rolimons.com/item/74198526108091) — yayımlanmış emote kaydı.
- [Sukuna Domain Expansion](https://www.rolimons.com/item/101430160520995) ve [Sukuna Aura Idle](https://www.rolimons.com/item/89424059240713) — yayımlanmış emote kayıtları.
- [Kira Laugh — Death Note](https://www.rolimons.com/item/119613379552783) — yayımlanmış emote kaydı.

Bu item ID'leri NAM'ın native .anim parser'ına doğrudan verilemez. Bunların ham animasyon verisini izinsiz çıkarmak yerine dosyanın sahibi/üreticisi tarafından sağlanan .anim veya .rbxm dışa aktarımını kullan.

## Bilinen sınırlamalar

- Bu değişiklik sırasında canlı executor testi yapılmadı; açılış ve animasyon oynatma elle test edilmelidir.
- Eski arayüzün bazı ses/görsel ikili dosyaları taşınmadı; bu yüzden isteğe bağlı UI medyası eksik olabilir.
- Topluluk mağazası boş. Sonradan modül eklenecekse kaynak, lisans ve bağlantılar incelemelidir.
- Roblox Studio oluşturucusu düzenlenebilir KeyframeSequence nesneleri oluşturur; otomatik olarak yayınlanmış animasyon ID'si üretmez.
- Limb/hat reanimation uyumluluğu deneyime ve executor'a göre değişebilir.

## Roblox'un resmî belgeleri

- [Animation Editor](https://create.roblox.com/docs/animation/editor)
- [KeyframeSequence API](https://create.roblox.com/docs/reference/engine/classes/KeyframeSequence)
- [Studio'da animasyon dışa/içe aktarma](https://create.roblox.com/docs/education/build-it-play-it-island-of-move/sharing-animations)

## Lisans ve atıf

Taşınan eski yerleşik modüller upstream MIT lisansı altındadır; `content/LICENSE-Uhhhhhh.txt` dosyasına bak. RobuNexa animasyon hareketleri bu depo için özgün olarak oluşturulmuştur. Roblox kurallarına, deneyim sahibinin kurallarına ve üçüncü taraf varlık lisanslarına uy.
