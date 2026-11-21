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
| 1 2 3 4 | Skills (maintenir 1 et 4 pour charger, viser à la souris) |
| G | Ult |

## Tests

`luau tests/almighty.spec.luau` : machine à états de The Almighty, probabilités d'esquive et de contre, résurrection.

## Options de test (`src/shared/Config.luau`)

- `TestArena`, `TestDummies` : zone de test et mannequins
- `TestDummyAttack` : les mannequins frappent quand on est à portée
- `TestUltFull` : ult pleine à chaque spawn

## Structure

- `src/shared` : config, persos, remotes, moteur d'anims par keyframes
- `src/server` : avatar R6, états, combat, hitbox, ragdoll, destruction, skills
- `src/client` : inputs, VFX, HUD

Toute Part ancrée avec le tag `Destructible` est cassable par `Destruction.blast`.
