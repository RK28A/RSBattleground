---
name: roblox-playtesting
description: Tester RSBattleground dans Studio par le MCP (lancer, simuler des entrées, mesurer, capturer).
---

# Tests en jeu

## Outils MCP
`start_stop_play`, `user_keyboard_input`, `user_mouse_input`, `execute_luau` (Server ou Client), `get_console_output`, `screen_capture`, `video_capture`.

## Pièges connus
- `execute_luau` a son propre cache de `require` : un module requis depuis là n'est PAS celui du jeu. Pour agir sur l'état réel, passer par la BindableFunction `ServerScriptService.Server.RSBDebug` (active si `Config.Debug`) : `hook:Invoke({ Damage = 5 })` fait frapper le mannequin.
- Les entrées simulées sont asynchrones : enregistrer l'état dans une boucle serveur plutôt que lire juste après l'envoi.
- Le créateur peut jouer en même temps : vérifier la position et les cooldowns avant d'interpréter un résultat.
- Journaliser peu : une ligne par changement d'état utile, pas une ligne par frame.

## Protocole
1. Arrêter le Play, appliquer les sources, relancer.
2. Lire la console : aucune erreur venant de `Server`, `Shared` ou `Client`.
3. Mesurer côté serveur (HP, attributs `Ult*`, `CD*`, positions).
4. Capturer une image à l'instant clé, la regarder, corriger.
5. Dire ce qui a été mesuré, vu, ou seulement compilé.
