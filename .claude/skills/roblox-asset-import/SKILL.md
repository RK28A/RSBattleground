---
name: roblox-asset-import
description: Amener dans Roblox Studio un script, un mesh, une texture ou un son produit hors de Studio.
---

# Import d'assets

## Canaux disponibles
| Quoi | Comment | Accord requis |
|---|---|---|
| Scripts | `rojo build` en `.rbxm`, dépôt dans `D:\Code\RSBattleground`, glisser dans Studio, puis rangement par le MCP | non |
| Petits correctifs de script | `execute_luau` en mode Edit (remplacement de texte dans `Source`) | non |
| Mesh, image, son | Upload Open Cloud par le MCP (`open_cloud_invoke`, `/assets/v1/assets`) puis `insert_asset` | oui, à chaque fois : c'est une publication sur le compte Roblox |
| Mesh sans upload | `EditableMesh` construit côté client à partir de données Luau | non |

## Règles
- Ne jamais publier un asset sans que le créateur l'ait demandé explicitement.
- Ne jamais annoncer un asset comme intégré tant que son ID ne s'affiche pas dans Studio.
- Le MCP ne peut pas lire un fichier local ni joindre GitHub : passer par un des canaux ci-dessus.
- Le mode Edit est indisponible pendant un Play : arrêter le test avant de modifier les sources.
