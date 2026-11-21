# Pipeline artistique

## Audit (21/11/2026)
| Outil | État |
|---|---|
| Roblox Studio | installé, ouvert |
| MCP Roblox Studio | connecté à Claude, testé (exécution Luau, Play, entrées, captures) |
| Blender sur le PC | absent |
| Blender côté Claude | bpy 5.3 headless, fonctionnel (rig, clés, rendu Cycles, export) |
| Blender MCP | non installé (demande Blender sur le PC) |
| Python sur le PC | 3.12 et 3.14 |
| Git sur le PC | installé |
| Node.js, VS Code | installés |
| After Effects, Premiere, OBS, Shotcut | installés |
| Rojo, StyLua, Selene, luau-lsp, FFmpeg sur le PC | non vérifiables : le shell local de l'app Claude ne démarre pas tant que le disque C n'a pas 17 Go libres |
| Plugins Studio | ZonitoVisuals et MA2Theme vus dans la sortie |

## Chaîne animation
Blender (clés, courbes) → rendu de contrôle → bake 60 fps → `src/shared/Anim/Baked.luau` → moteur `Anim` → Studio.
Aucun asset publié n'est nécessaire.

## Chaîne modèle
Blender → FBX → upload Open Cloud par le MCP → `insert_asset`. L'upload publie sur le compte Roblox : accord requis à chaque fois.

## Limites
- Le MCP Studio ne lit pas les fichiers locaux et ne joint pas GitHub.
- Les rendus de contrôle sont en blocs.
