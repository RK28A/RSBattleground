# RSBattleground

Battlegrounds Roblox en R6. Rojo, Luau, Blender pour l'art.

## Règles
- Commits au nom de RK28A uniquement, sans mention d'outil. Pas de push direct sur `main` pour le travail artistique : branche dédiée.
- Code sans commentaires. Valeurs de gameplay dans `src/shared/Config.luau` et `src/shared/Characters/*`.
- Tout ce qui change le combat est validé serveur (`server/Combat.luau`).
- Ne rien publier sur le compte Roblox (assets, place) sans demande explicite.
- Ne pas toucher à la map de la place ouverte sans demande.
- Dire ce qui a été testé en jeu, mesuré, ou seulement compilé.

## Vérifier
- `luau-compile --null` sur chaque fichier, `rojo build`, `luau tests/almighty.spec.luau`.
- Test en jeu par le MCP Studio : voir `.claude/skills/roblox-playtesting`.

## Skills
`.claude/skills/` : blender-animation, blender-modeling, roblox-r6-animation, roblox-vfx, roblox-cinematics, roblox-asset-import, roblox-playtesting, roblox-optimization.
