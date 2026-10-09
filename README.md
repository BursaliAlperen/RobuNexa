# RobuNexa — NAM Reanimate (R6)

RobuNexa, NAM Reanimate altyapısının bu depoda barındırılan bir uyarlamasıdır. Eski içerik/modül bağlantıları RobuNexa'ya taşındı, uzaktan gelen Pusher mesajlarını Lua kodu olarak çalıştıran bölüm kaldırıldı ve **15 özgün R6 anime-esintili animasyon** Dances listesine eklendi.

> **Durum:** Bu bir geçiş/test derlemesidir; canlı executor içinde çalıştırılarak doğrulanmadı. Önce kendi özel test ortamında dene. Her Roblox deneyiminde veya her executor'da çalışacağı garanti edilmez.

## Dosya yapısı

- `Reanim.txt` — NAM Reanimate ana betiği.
- `LoadRobuNexa.lua` — sabit bir commit'e işaret eden GitHub başlatıcısı.
- `content/` — NAM'ın yerleşik moveset, dance, limb-map ve hat-map modülleri.
- `Animations/R6/` — 15 animasyon dosyası ve Roblox Studio KeyframeSequence oluşturucusu.
- `Modules/RobuNexaConfig.lua` — pasif URL/yol yapılandırması örneği.
- `NAM-ROBUNEXA-MIGRATION.md` — geçiş ve güvenlik notları.
- `store/list.txt` — bu sürümde bilerek boş bırakılmış topluluk mağazası manifesti.

## Hızlı başlatma (executor)

Yalnızca güvendiğin bir executor ortamında ve test etme iznin olan yerlerde kullan. Bu betik standart Roblox Studio LocalScript'i değildir; executor'a özgü dosya ve HTTP fonksiyonları gerektirir.

Executor'a şu satırı yapıştır:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/2d1070e80dd105635ded81148a7976cf8314fd1e/Reanim.txt"))()
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

Bunlar bu depo için oluşturulmuş anime-esintili özgün hareketlerdir; belirli bir anime karakterinden veya sahnesinden kopyalanmış dosyalar değildir. Yumruk, tekme ve kılıç savurma animasyonları **hasar, hitbox, silah veya sunucu taraflı hareket eklemez**.

## .anim dosyaları nasıl yükleniyor?

NAM'ın `AnimLib.Track.fromfile` fonksiyonu JSON değil, little-endian STEVE KeyframeSequence ikili biçimini bekler. Bu depodaki `.anim` kaynakları, GitHub dosya düzenleme arayüzü ikili dosya yazamadığı için Base64 metin sarmalayıcısı olarak saklanır. Başlatıcı, sabitlenmiş RobuNexa animasyon bağlantısını algılar, Base64 içeriğini çözer ve gerçek ikili dosyayı `NAMReanim/Content/Anims/` altına yazar; ardından NAM'ın animasyon okuyucusu dosyayı açar.

Bu yüzden tarayıcıdan doğrudan bir raw `.anim` bağlantısı indirirsen hazır ikili dosya değil Base64 metni görürsün. NAM içindeki yükleyiciyi kullan veya dosyayı başka yerde kullanacaksan Base64'ü önce çöz.

## Güvenlik

- Eski Pusher WebSocket dinleyicisi kaldırıldı. Önceki kod, uzaktan gelen `jumpscare` mesajının içeriğini `loadstring` ile derleyip çalıştırabiliyordu.
- Yerleşik Lua modülleri ve animasyon dosyaları sabitlenmiş commit'lerden yüklenir.
- Animasyon içeriği veri olarak çözülür; Lua kodu olarak çalıştırılmaz.
- Topluluk mağazası bu sürümde bilerek boştur.
- NAM hâlâ executor API'leri ve yerleşik Lua modüllerini yüklemek için `loadstring` kullanır. `NAMReanim/Modules/` altındaki her dosya çalıştırılabilir kullanıcı kodudur; yalnızca yazdığın veya dikkatlice incelediğin modülleri bırak.
- Bilinmeyen loadstring kodlarını çalıştırma, hesap çerezlerini/oturum token'larını paylaşma ve güvenmediğin bir betik için güvenlik korumalarını kapatma.

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
