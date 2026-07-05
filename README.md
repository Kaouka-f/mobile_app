# Kaouka

Application mobile Flutter — réseau social géolocalisé. Les utilisateurs publient des **requêtes** (posts texte + média), découvrent les personnes **autour d'eux**, échangent des **messages** et gèrent leur **profil**.

---

## Prérequis

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.0 (`sdk: '>=3.0.3 <4.0.0'`)
- Xcode (iOS) et/ou Android Studio (Android)
- Compte Firebase configuré (`google-services.json` / `GoogleService-Info.plist` déjà présents)
- Fichier `.env` à la racine (référencé dans `pubspec.yaml` — ne pas le committer s'il contient des secrets)

---

## Installation

```bash
# Cloner le repo, puis :
cd mobile_app
flutter pub get

# iOS uniquement
cd ios && pod install && cd ..
```

---

## Lancement

L'app se configure via des **dart-defines** (voir `.vscode/launch.json`) :

| Configuration | Commande équivalente | Description |
|---|---|---|
| **prod** | `flutter run` | Serveur de production (`elaborium.site`) |
| **test** | `flutter run --dart-define=MODE=TEST` | Serveur local (`192.168.1.100`) |
| **prod selector** | `flutter run --dart-define=SELECTOR=true` | Mode bot / sélecteur de comptes |
| **test selector** | `flutter run --dart-define=MODE=TEST --dart-define=SELECTOR=true` | Test + sélecteur |

```bash
# Exemples
flutter run --dart-define=MODE=TEST
flutter run --dart-define=SELECTOR=true
```

---

## Architecture du projet

```
lib/
├── main.dart              # Point d'entrée, Firebase, Provider, BackgroundFetch
├── http_manager.dart      # Toutes les requêtes HTTP vers le backend
├── shared_data.dart       # État utilisateur persistant (SharedPreferences)
├── database.dart          # SQLite locale (messages, contacts, bots)
├── request.dart           # Modèle Request (post / commentaire)
├── person.dart            # Modèles Person et ReqPerson
├── message.dart           # Modèle de message chat
├── contact.dart           # Modèle de contact
├── utils.dart             # Helpers (géoloc, encodage ID, popups…)
├── theme.dart             # Thèmes clair / sombre
├── logging.dart           # Journalisation
├── notifications.dart     # Notifications locales
├── firebase_messaging.dart
├── file_downloader.dart
├── bot.dart               # Gestion des bots (mode SELECTOR)
│
├── pages/                 # Écrans de l'application
├── components/            # Widgets réutilisables
└── notifiers/             # ChangeNotifier (Provider)
```

### Flux principal

```
main.dart
  └── HomePage (navigation par onglets)
        ├── ArroundPage      → personnes à proximité
        ├── ExtraPage        → feed médias
        ├── ContactPage      → liste des contacts / chat
        └── ProfilePage      → profil, posts, paramètres
```

Au démarrage, `main.dart` :
1. Initialise Firebase et `SharedData`
2. Récupère ou crée l'identifiant utilisateur via `retrieveId()` → `getId`
3. Enregistre le token FCM (`postNotifToken`)
4. Monte l'app avec `MultiProvider`

---

## Couche HTTP — `http_manager.dart`

Toutes les communications passent par un **proxy** backend :

```
https://{host}:{port}/proxy/{endpoint}
```

- **Production** : `elaborium.site:443` (HTTPS)
- **Test** (`MODE=TEST`) : `192.168.1.100:443`
- Pour du dev local non sécurisé, décommenter les lignes `host` / `port` / `secure` en tête de fichier

### Fonctions de base

| Fonction | Rôle |
|---|---|
| `get(queryParams, path)` | GET JSON → `Map` |
| `post(data, path)` | POST JSON → `dynamic` |
| `sendFile(data, file, path)` | POST multipart (upload fichier) |
| `sendFiles(data, files, path)` | POST multipart (plusieurs fichiers) |

Les requêtes HTTPS utilisent un `SecurityContext` personnalisé (certificat `assets/csr.pem`).

### Endpoints GET

| Endpoint | Paramètres | Description |
|---|---|---|
| `getId` | — | Obtient un nouvel ID utilisateur |
| `getArrounds` | `id`, `long`, `lat` | Personnes + requêtes à proximité |
| `getInfos` | `personid` | Infos d'un utilisateur |
| `getAllReqs` | `id`, `lastReqId` | Tous les posts d'un utilisateur (pagination) |
| `getOwnReqs` | `id`, `lastReqId` | Mes propres posts |
| `getInterressed` | `id`, `lastReqId` | Posts auxquels je suis intéressé |
| `getComments` | `id`, `lastReqId` | Commentaires d'un post |
| `getRequest` | `reqId` | Détail d'une requête (deep link) |
| `getFeed` | `id` | Feed de médias |
| `getMsgs` | `id`, `thold` | Messages reçus (polling) |
| `getLikes` | `reqId` | Liste des likes |
| `isPayed` | `id` | Statut de paiement |
| `isBlocked` | `id`, `userId` | Vérifier si un user est bloqué |
| `signUp` | `id`, `password`, `email` | Inscription |
| `getBots` | `password` | Liste des bots (dev) |

### Endpoints POST

| Endpoint | Paramètres | Description |
|---|---|---|
| `postReq` | `id`, `request` + fichier | Publier une requête |
| `postComments` | `id`, `postId`, `comment` + fichier | Commenter |
| `postPP` | `id` + fichier | Photo de profil |
| `postPPSetting` | `id`, `scale`, `offsetX`, `offsetY` | Recadrage photo profil |
| `postName` | `id`, `name` | Changer le pseudonyme |
| `postNotifToken` | `id`, `notifToken` | Token push Firebase |
| `postLocation` | `id`, `long`, `lat` | Mettre à jour la position |
| `sendMsg` | `personId`, `targetPersonId`, `message` | Envoyer un message |
| `likeReq` | `id`, `reqId` | Liker un post |
| `updateReq` | `id`, `reqId`, `newReq` | Modifier un post |
| `deleteReq` | `id`, `reqId` | Supprimer un post |
| `deleteInterressed` | `id`, `reqId` | Retirer un intérêt |
| `deleteMsgs` | `id` | Supprimer tous les messages |
| `deleteMsg` | `id`, `media` | Supprimer un message |
| `deleteAccount` | `id` | Supprimer le compte |
| `signal_request` | `id`, `reqId` | Signaler un post |
| `blockUser` | `id`, `userId` | Bloquer un utilisateur |
| `visible` | `id`, `value` | Visibilité du profil |
| `connect` | `id` | Connexion (auth) |
| `onConnection` / `onDisconnection` | `id` | Événements connexion socket |
| `paying` | `id`, `payId` | Paiement |
| `createBot` | `id`, `privateId`, `name`, … | Créer un bot (dev) |

### Exemple d'appel

```dart


// Récupérer les personnes autour de moi
final people = await getArrounds(userId, longitude, latitude);

// Publier une requête avec un média
await postRequest(userId, "Mon message", File('/chemin/photo.jpg'));

// Envoyer un message
await sendMsg(myId, targetId, "Salut !", File(''));
```

---

## Modèles de données

### `Person`
Représente un utilisateur : `id`, `name`, `img`, `scale`, `offsetX/Y`, `connected`.

### `Request`
Un post ou commentaire : `reqId`, `request` (texte), `media`, `reqTime`, `likeNb`, `commentNb`, `likes`.

### `ReqPerson`
Couple `{ person, request, dist }` — utilisé partout pour afficher un post avec son auteur et la distance.

### `SharedData` (singleton)
État global de l'utilisateur courant, persisté via `SharedPreferences` :
- Identité : `id`, `name`, `imageUrl`, `imageScale`, `imageOffset`
- Préférences : `visible`, `payed`, `mode` (thème), tokens notif
- Les setters déclenchent automatiquement les appels HTTP associés (`postName`, `postPP`, `visible`, etc.)

---

## State management (Provider)

| Notifier | Fichier | Rôle |
|---|---|---|
| `PersistentVisibleProvider` | `visible_notifier.dart` | Visibilité du profil |
| `PersistentModeProvider` | `mode_notifier.dart` | Thème clair / sombre |
| `PeopleNotifier` | `person_notifier.dart` | Liste des personnes autour |
| `MessageNotifier` | `message_notifier.dart` | Nouveaux messages (singleton) |
| `PersistentImageProvider` | `image_notifier.dart` | Photo de profil |

Utilisation typique :

```dart
// Lire
final mode = Provider.of<PersistentModeProvider>(context);

// Écouter les changements
Consumer<MessageNotifier>(
  builder: (context, notifier, _) => Text('${notifier.messagenb}'),
)
```

---

## Pages

| Page | Fichier | Description |
|---|---|---|
| `HomePage` | `home_page.dart` | Shell principal : bottom nav, deep links, connectivité, CGU |
| `ArroundPage` | `arround_page.dart` | Carte des personnes à proximité (géoloc) |
| `ExtraPage` | `extra_page.dart` | Feed de médias (`getFeed`) |
| `ContactPage` | `contact_page.dart` | Liste des contacts, accès au chat |
| `ChatPage` | `chat_page.dart` | Conversation 1-to-1 |
| `ProfilePage` | `profile_page.dart` | Profil, mes posts, posts intéressés |
| `SettingPage` | `setting_page.dart` | Paramètres utilisateur |
| `AccountPage` | `account_page.dart` | Gestion du compte |
| `LoginPage` / `SignupPage` | `login_page.dart`, `signup_page.dart` | Authentification |
| `PaymentPage` | `payment_page.dart` | Paiement |
| `RequestInfoPage` | `request_info_page.dart` | Détail d'une requête |
| `DeepLinkRequestPage` | `deep_link_request_page.dart` | Ouverture via lien profond |
| `LostConnectionPage` | `lost_connection_page.dart` | Écran hors-ligne |
| `MaintenancePage` | `maintenance_page.dart` | Mode maintenance |
| `PolitiquePage` | `politique_page.dart` | Politique de confidentialité |
| `UserMenu` | `user_menu.dart` | Menu latéral / actions rapides |

---

## Composants réutilisables

| Composant | Fichier | Rôle |
|---|---|---|
| `ReqPersonList` | `req_person_list.dart` | Liste de posts avec avatar et actions |
| `RequestCard` | `request_card.dart` | Carte d'un post individuel |
| `ReqList` | `req_list.dart` | Liste simplifiée de requêtes |
| `KAvatar` | `kavatar.dart` | Avatar utilisateur (photo + recadrage) |
| `PostViewer` | `post_viwewer.dart` | Affichage d'un post (texte + média) |
| `PostBottomBar` | `post_bottom_bar.dart` | Barre d'actions sous un post (like, comment…) |
| `TileBottomBar` | `tile_bottom_bar.dart` | Barre d'actions compacte |
| `InputBar` | `input_bar.dart` | Barre de saisie (home) |
| `ChatBubble` | `chat_bubble.dart` | Bulle de message |
| `PhotoViewer` | `photo_viewer.dart` | Visualiseur d'image plein écran |
| `VideoPlayer` | `video_player.dart` | Lecteur vidéo |
| `AudioPlayer` | `audio_player.dart` | Lecteur audio |
| `Camera` | `camera.dart` | Prise de photo / vidéo |
| `CustomTextField` | `custom_text_field.dart` | Champ de texte stylisé |
| `CustomElevatedButton` | `custom_elevated_button.dart` | Bouton principal |
| `CustomToggleButton` | `custom_toggle_button.dart` | Toggle stylisé |
| `PermissionToggleButton` | `permission_toggle_button.dart` | Toggle de permission |
| `VisibleIndicator` | `visible_indicator.dart` | Indicateur visibilité profil |
| `BadgeIcon` | `badge_icon.dart` | Icône avec badge (notifications) |
| `SelectorButton` | `selector_button.dart` | Sélecteur de bot (mode SELECTOR) |
| `CGU` | `cgu_.dart` | Acceptation des conditions générales |

---

## Base de données locale (SQLite)

`DatabaseHelper` (`database.dart`) gère deux bases :

| Base | Fichier | Tables principales |
|---|---|---|
| Par utilisateur | `{id}_ctj.db` | `messages`, `contacts`, `db_id` |
| Commune | `common_ctj.db` | `bots` (mode SELECTOR) |

Les messages sont stockés localement et synchronisés via `getMsgs` (polling HTTP). Les contacts sont enrichis avec `getInfos` au chargement.

---

## Services externes

| Service | Package | Usage |
|---|---|---|
| Firebase Core / Messaging | `firebase_core`, `firebase_messaging` | Push notifications |
| Géolocalisation | `geolocator` | Position pour `getArrounds` / `postLocation` |
| Background Fetch | `background_fetch` | Tâches en arrière-plan |
| Connectivité | `connectivity_plus` | Détection perte de réseau |
| Deep links | `app_links` | Ouverture de posts via URL |
| Notifications locales | `flutter_local_notifications` | Alertes in-app |
| Cache médias | `flutter_cache_manager` | Cache images / fichiers |

---

## Conventions utiles

- **IDs encodés** : les IDs utilisateur sont encodés/décodés via `encodeId` / `decodeId1` dans `utils.dart` (format `{id1}_{id2}`).
- **Logs** : `LoggerManager` dans `logging.dart` — actif dès le démarrage.
- **Orientation** : portrait uniquement (forcé dans `MyApp`).
- **Locale** : formatage des dates en français (`initializeDateFormatting('fr')`).

---

## Build release

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

Pour Android, la configuration de signature se trouve dans `android/app/build.gradle.kts` (keystore dans `android/app/keystore/` — **ne pas committer les clés**).

---

## Fichiers à ne pas committer

- `.env`
- `android/app/keystore/` (clés de signature)
- `assets/private_key.pem`
- Fichiers générés : `build/`, `.dart_tool/`

---

## Pour aller plus loin

- `TODO.md` — autorisations iOS/Android à vérifier
- `design_idea.txt` — notes de design
- `.vscode/launch.json` — configurations de debug prêtes à l'emploi
