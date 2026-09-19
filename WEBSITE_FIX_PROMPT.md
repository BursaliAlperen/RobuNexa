# Prompt: hatchable.site Ã¶n yÃ¼zÃ¼ndeki "Untrusted renderer" hatasÄ±nÄ± dÃ¼zelt

AÅŸaÄŸÄ±daki metni, web sitesinin (https://roblox-forge-ai.hatchable.site) Ã¶n yÃ¼z
kaynak kodunun bulunduÄŸu proje/repoyu bir AI asistanÄ±na (veya geliÅŸtiriciye)
verirken kopyala-yapÄ±ÅŸtÄ±r olarak kullan. Bu, masaÃ¼stÃ¼ EXE tarafÄ±nda (bu zip)
bulunan gÃ¼venlik davranÄ±ÅŸÄ±nÄ± web sitesi tarafÄ±nda dÃ¼zgÃ¼n ÅŸekilde
yansÄ±tmak iÃ§in yazÄ±lmÄ±ÅŸtÄ±r â€” EXE kodunda hiÃ§bir deÄŸiÅŸiklik gerekmiyor.

---

## BaÄŸlam

Roblox Forge AI adlÄ± Ã¼rÃ¼nÃ¼n iki ayrÄ± yÃ¼zÃ¼ var:

1. **MasaÃ¼stÃ¼ EXE (Electron):** `desktop.html` + `desktop.js`, yalnÄ±zca
   `file://.../desktop.html` Ã¼zerinden yÃ¼klendiÄŸinde Ã§alÄ±ÅŸÄ±r. Ana sÃ¼reÃ§te
   (`desktop-main.cjs`) her IPC Ã§aÄŸrÄ±sÄ± `senderFrame.url === APP_URL`
   kontrolÃ¼nden geÃ§er; eÅŸleÅŸmezse bilerek `Error: Untrusted renderer.`
   fÄ±rlatÄ±lÄ±r. Bu **kasÄ±tlÄ± bir gÃ¼venlik Ã¶nleki** ve test paketiyle
   (`tests/main.test.cjs`) doÄŸrulanmÄ±ÅŸ durumda â€” burada dq!Zqgİ\š[Y^YXÙZË‚Œ‹ˆ
Š•ÙXˆÚ]\ÚH
HÙ[š[ˆ0ï™[XÙq'Ú[ˆ\˜YŠNŠŠˆ^[±,H\˜^pï°ïˆš\ˆÛÜX\ñ,[±,Bˆ™^XH™[™\š[šH\˜^q,Xñ,YHğíœİ\š^[Ü‹ˆ\˜^q,Xñ,YH[Xİ›Ûˆ™[ØYØ\ÓXZ[˜ˆÛXY1,q'ñ,HpéÚ[ˆ•ÙXœÚ]H[HÚ\šqgÈX\‹–Y[šH›Ü™ÙHTHÙ^HÛqgİ\ˆˆÚXšBˆ]Û›\ˆ1,ZÛ[™1,q'ñ,[™Hİ[[±,Xñ,^XH[KİZÛšZÈš\ˆ]Hñ,^±,^[Ü‚ˆ\œ›Üˆ[›ÚÚ[™È™[[İHY]Ù	Ø]]\İ\	Îˆ\œ›Üˆ[\İY™[™\™\‹˜ˆKØY˜HØ\±,qgİ1,\±,Xñ,H™H›Ù™\Ş[Û™[ğíœ°ï›Y^Y[ˆš\ˆİ[[±,Xñ,H[™^Z[ZK‚‚ˆÈÈX\1,[XÚØ[\‚‚ŒKˆ
Š“X\Øpïİ0ï™H0í™[^[[\šH\Ü]]ŠŠˆÙXˆÚ]\ÚHÛÙ[™H1gİH^[[[\šBˆ]ZÛ^Y[ˆ]Û›\±,H[ˆÚ\šqgËÛÙÚ[ˆ
]šXÙKX]]˜qgÛ]XJK›Ü™ÙHTBˆÙ^HÛqgİ\›XK’Ø^Y]	ˆ˜q'Û[ˆˆ
œšYÙHİ\
KİY[ÈœšYÙBˆ˜qgÛ]XKÙ\™\›XKXİ]š]KÛÙÈ0éÙZÛYKˆ[›\±,[ˆ\ÚHX[±,^˜ØHVBˆpéÚ[™H[›[[1,NÈ\˜^q,Xñ,YHÙ\°éÙZÈš\ˆ˜XÚÙ[™˜q'Û[1,\ñ,H[ÚË‚‚Œ‹ˆ
ŠH]Û›\±,HÙXˆÚ]\Ú[™H˜\œØ^KØ[ˆÛ\˜ZÈ]œ™H0ì\š^KÙÜšH
\ØX›Y
Bˆ™[™\ˆ]ŠŠˆ0ïÛ[˜Xš[\ˆ[XHq/]œÚ^ˆš\˜ZÛXNÈ\ØX›Y0í›š][q'ÚBˆ™^XHqgÙq'Ù\š^[HğíœœÙ[Û\˜ZÈH\ÚYˆÛq'İ[HÙ[H]‚