# RSBattleground

Battlegrounds Roblox en R6.

## Lancer

1. Installer Rojo 7.4.4 (plugin Studio + CLI, même version).
2. `rojo serve` à la racine du repo.
3. Dans Studio : plugin Rojo > Connect, puis Play.
4. Game Settings > Avatar > Avatar Type : R6.

## Touches

| Touche | Action |
|---|---|
| Clic gauche | M1 (maintenir pour enchaîner) |
| Espace + 4e M1 | Uppercut |
| 4e M1 en chute | Downslam |
| F | Block |
| Q (+ W/A/S/D) | Dash |
| 1 2 3 4 | Skills |
| G | Ult |
| M | Sélection du perso |

## Structure

- `src/shared` : config, persos, remotes, moteur d'anims par keyframes
- `src/server` : avatar R6, états, combat, hitbox, ragdoll, destruction, skills
- `src/client` : inputs, VFX, HUD

Toute Part ancrée avec le tag `Destructible` est cassable par `Destruction.blast`.
