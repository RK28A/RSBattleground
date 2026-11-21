---
name: blender-modeling
description: Modéliser une arme ou un mesh de VFX pour RSBattleground dans Blender et l'exporter pour Roblox.
---

# Modélisation

## Règles
- 1 unité Blender = 1 stud. Le perso regarde +Y dans Blender, Z vers le haut.
- Pivot de l'arme à la poignée, lame vers l'avant de la main (axe -Z Roblox du bras).
- Budget : arme < 2 000 triangles, mesh de VFX < 300. Pas de modificateurs non appliqués à l'export.
- Matériaux simples : couleur, rugosité, émission. Les shaders Blender complexes ne passent pas dans Roblox.
- UV dépliées seulement si une texture est prévue.

## Étapes
1. Construire en Python (bpy), rendre une vue 3/4 et une vue de profil, corriger la silhouette.
2. Exporter en FBX dans `art/export/`.
3. Import Roblox : voir le skill `roblox-asset-import`.

## Commencer petit
Un prototype complet (Blender, export, affichage dans Studio) avant de faire les trois armes.
