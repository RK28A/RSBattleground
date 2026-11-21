---
name: roblox-optimization
description: Garder RSBattleground fluide (effets, destruction, réseau).
---

# Optimisation

- Destruction : budget `Config.Destruction.MaxPieces` par explosion, débris en groupe de collision `Debris`, durée de vie courte.
- Réseau : un event par action, jamais par frame. Les projectiles sont simulés serveur et rejoués visuellement client.
- Client : une seule boucle `Stepped` pour toutes les anims, pas de connexion par effet sans déconnexion.
- Mesurer avant d'optimiser : `Stats`, microprofiler, nombre d'instances dans `workspace.Fx`.
