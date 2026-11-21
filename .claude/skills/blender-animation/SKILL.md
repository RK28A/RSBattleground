---
name: blender-animation
description: Créer ou retoucher une animation R6 de RSBattleground dans Blender (bpy), la prévisualiser en rendu et la baker en clip Luau.
---

# Animation R6 dans Blender

## Outils
- `tools/blender/r6.py` : rig R6 (Torso, Head, RA, LA, RL, LL, Weapon), conversion d'axes Roblox/Blender, bake, rendu de planche.
- `tools/blender/sovereign_m1.py` : exemple complet (Blade1).
- Blender headless : `pip install bpy`, puis `python3 tools/blender/<script>.py --render`.

## Conventions
- Angles donnés en repère local Roblox du perso : X+ lève le membre vers l'avant, Y+ tourne à gauche, Z+ écarte le bras droit (Z- pour le gauche). Même ordre que `CFrame.Angles(x, y, z)`.
- Pivots R6 exacts (épaules en (±1, 0.5, 0), hanches en (±1, -1, 0), cou en (0, 1, 0)). `Weapon` est la poignée dans la main droite.
- 60 fps, quaternions, poignées Bézier auto-clampées. Appeler `fix_quaternion_flips` avant le bake.

## Méthode
1. Poser les clés par joint avec `r6.key`. Ne jamais donner les mêmes temps à tous les joints.
2. Ordre d'une attaque : anticipation (hanches et torse d'abord), frappe courte, dépassement, retour. Le bras suit le torse de 1 à 3 frames, l'arme suit le bras, la tête compense, le bras libre contrebalance.
3. Le coup doit croiser l'avant du perso à l'instant de la hitbox (`Config.M1.Windup` pour les M1).
4. `--render` produit `art/preview/<nom>_sheet.png`. La lire et corriger avant de baker pour de bon.
5. Le bake écrit `src/shared/Anim/Baked.luau`. Un clip baké remplace le clip à clés du même nom.

## Critères
- Silhouette lisible à la frame d'impact, arc de lame continu.
- Aucun membre immobile pendant que le torse tourne.
- Retour au repos sans à-coup sur la dernière clé (pose identique à la première).

## Limites
- Pas de coudes ni de genoux en R6 : le poids passe par le torse, les hanches et le décalage temporel.
- Le rendu de contrôle est en blocs, sans vêtements ni VFX.
