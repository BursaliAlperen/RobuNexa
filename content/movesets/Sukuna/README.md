# Sukuna Moveset — Cleave Focus

This NAM moveset keeps Cleave as the signature animated slash and includes Dismantle, Combo, Rush, and Laugh. Domain and Fuuga remain disabled. Fling and all knockback/physics-impulse behaviour have been removed.

## Automatic equipped-accessory discovery

- The moveset scans the character's currently equipped accessories during initialization and refreshes the scan while running.
- It first checks the applied avatar description and catalog AssetIds, then checks accessory instances and their names as a fallback.
- The Cleave weapon accessory is matched by its known catalog ID `101090904148116` or a case-insensitive accessory name containing `cleave`.
- The slash-effect accessory is matched separately by its known catalog ID `18908729586`, explicit ID/name metadata, or a name containing `cleave slash` / `slash effect`.
- It uses only accessories already equipped on the character (including the supported reanimated figure lookup). It does not insert, clone, download, or create a replacement accessory.
- If the required accessory is not equipped, the moveset leaves that effect unavailable rather than silently choosing an unrelated hat.

## Animation and effects

- `content/animations/Sukuna/Cleave.anim` — Cleave action animation.
- `content/animations/Sukuna/Dismantle.anim` — Dismantle animation.
- `content/animations/Sukuna/Combo.anim` — Combo animation.
- `content/animations/Sukuna/Rushbeatdown.anim` — Rush animation.
- `content/sounds/sukuna-slash.mp3` — slash sound.
- Cleave drives the existing equipped accessory through timed slash passes. No duplicate animation or accessory assets are created.

## Skills and cooldowns

| Skill | Key | Cooldown |
|---|---|---:|
| Cleave | X | 5 s |
| Dismantle | C | 7 s |
| Combo | Z | 15 s |
| Rush | R | 18 s |
| Laugh | L | 12 s |

Each skill has an independent cooldown. On touch devices, the five available skills appear in the Sukuna ability panel.

## Removed behaviour

- No Fling ability, NPC scan, player targeting, knockback, physics impulse, or angular impulse.
- No automatic target damage or hitbox logic is added by this accessory animation pass.
- Domain and Fuuga remain disabled; their buttons are not shown.
- No chat announcements or finger-pickup mechanic is started.
- The moveset does not delete normal avatar accessories when it is destroyed.
