---
name: roblox-vfx
description: Créer ou améliorer un effet visuel de combat dans RSBattleground.
---

# VFX

## Existant
- `src/client/Fx.luau` : impacts, block, traînée et arc de slash, dash, débris, shake. Helpers exportés dans `Fx.Util`.
- `src/client/FxSovereign.luau` : effets de Blood Sovereign (arc, flèches, aura, yeux, résurrection).
- Le serveur envoie `Net.Fx:FireAllClients(nom, données)` ; tout le rendu est côté client.

## Règles
- Un effet a toujours une durée de vie (`Debris` ou nettoyage suivi par perso).
- Le perso doit rester lisible : pas de flash plein écran de plus de 0,1 s, effets lourds réservés aux coups lourds.
- Particules : rester sous 60 par burst, couper les effets au-delà de 150 studs.
- Préférer Trail, Beam et ParticleEmitter aux Parts ; un mesh dédié pour les ondes de choc et les croissants.

## Ce qui manque encore
- Textures et flipbooks dédiés (aujourd'hui : textures intégrées du moteur).
- Meshes de slash et d'onde de choc (aujourd'hui : segments de Parts).
- Pooling et réglage de qualité.
