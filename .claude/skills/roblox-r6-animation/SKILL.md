---
name: roblox-r6-animation
description: Faire jouer, synchroniser ou déboguer une animation R6 dans RSBattleground (moteur Anim, clips à clés et clips bakés).
---

# Animations R6 côté Roblox

## Moteur
- `src/shared/Anim/init.luau` écrit `Motor6D.Transform` à chaque `Stepped`, côté client, pour tous les persos visibles.
- `Clips.luau` : clips à clés écrits à la main. `Baked.luau` : clips échantillonnés depuis Blender (prioritaires à nom égal).
- Joints : Torso (RootJoint), Head (Neck), RA, LA, RL, LL, Weapon (Motor6D `Grip` du bras droit).
- Aucun asset d'animation publié : rien à uploader, tout est dans le repo.

## Règles
- Le serveur déclenche avec `Combat.playAnim(character, nom, sauf)` ; le client acteur joue en prédiction puis les autres reçoivent l'event.
- `Anim.freeze` sert au hitstop. `Hold = true` garde la dernière pose jusqu'à `Anim.stop`.
- Une hitbox se cale sur le temps du clip, jamais l'inverse sans retoucher le clip.

## Validation
1. Compiler (`luau-compile`), build Rojo.
2. Play dans Studio, capture d'écran ou vidéo par le MCP à la frame d'impact.
3. Vérifier qu'un mannequin sans Animator revient bien au repos.

## Limites
- `Transform` n'est pas répliqué : un client qui n'a pas reçu l'event ne voit pas l'anim.
- Pour passer à de vrais assets Animation, il faut publier sur le compte du créateur (accord explicite requis).
