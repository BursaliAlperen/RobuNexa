# NAM

**NAM**; animasyonlar, sesler ve reanimasyon arayüzünü içeren projedir. NAM markası ve bu depodaki güncel düzenlemeler **mamalalanam** tarafından sürdürülür.

## Loadstring

Uyumlu Roblox istemci ortamında çalıştırılacak komut:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/v1.0.10/source/reanim.lua"))()
```

> Script, dosya sistemi ve ağ erişimi sağlayan uyumlu bir istemci ortamı gerektirir. Yalnızca güvendiğiniz kodları çalıştırın.

## Depo yapısı

- `source/reanim.lua` — NAM arayüzü ve reanimasyon istemcisi
- `content/` — `.anim` animasyonları, ses dosyaları ve moveset’ler
- `uiassets/` — arayüz sesleri ve görseller

İçerik yükleyicileri bu depodaki `main` branch’inden veri alır. Eski sürümün kullanıcı ayarları ve yerel modülleri ilk çalıştırmada yeni `NAMReanim` klasörüne aktarılır.

## Kaynak ve lisans notu

NAM markası ve **mamalalanam** tarafından yapılan değişiklikler, özgün kaynak kodu için geçerli olan lisans bildirimini değiştirmez. Kaynak kodun bir bölümü MIT lisanslı upstream materyale dayanır. Ayrı bir lisans dosyası kullanılmadığından gerekli bildirim bu README’de tutulur:

> Copyright (c) 2025 STEVETHEREALONE

MIT License şartları: yazılımın veya önemli bir kısmının tüm kopyalarında yukarıdaki telif bildirimi ve aşağıdaki izin bildirimi bulunmalıdır. Yazılım, açık veya zımni hiçbir garanti olmaksızın “olduğu gibi” sunulur; yazarlar, kullanımdan doğan talepler veya zararlardan sorumlu tutulamaz.

> Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Üçüncü taraf medya

Bazı arayüz müzikleri Dubmood’a ait olabilir; önceki kaynak notlarında kullanım koşullarının kesin biçimde doğrulanmadığı belirtilmiştir. Bazı animasyonların kaynak/provenans bilgisi de eksiktir. Bu nedenle `.mp3` ve diğer medya dosyalarının tümü için MIT lisansı veya ticari kullanım izni olduğu varsayılmamalıdır; ilgili hak sahiplerinin koşullarını gözetin.
