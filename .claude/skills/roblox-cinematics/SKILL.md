---
name: roblox-cinematics
description: Monter une séquence synchronisée entre plusieurs persos (finisher, contre, résurrection) dans RSBattleground.
---

# Cinématiques

## Briques
- Verrous temporels serveur : `State.lock`, `State.cinematic` (invulnérable), `State.busy`. Tous expirent seuls, personne ne reste bloqué.
- Placement : `Combat.safeSpot`, `Combat.around`, `Combat.face`.
- Anims : un clip par perso, lancés au même instant serveur.
- Caméra et écran : côté client, uniquement pour les joueurs impliqués, avec retour garanti par `task.delay`.

## Méthode
1. Écrire la chronologie (temps, acteur, action) avant le code.
2. Authoring des clips des deux persos dans la même scène Blender pour caler les contacts.
3. Le serveur déroule la chronologie et valide à chaque étape que les deux persos existent encore.
4. Prévoir la sortie : mort, départ ou téléportation d'un acteur.

## Référence
`server/Skills/Sovereign/Almighty.luau`, fonction `resurrect`.
