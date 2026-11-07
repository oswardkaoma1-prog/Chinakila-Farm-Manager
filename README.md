# Chinakila Farm Manager — starter project

This is the first source-code scaffold for the free-build Chinakila architecture.

## Components
- `officer_app/`: Flutter Android app scaffold with a local SQLite offline queue.
- `management_dashboard/`: separate responsive management dashboard prototype.
- `integration_server/`: small Node.js API proxy. Kobo API token stays on the server.

## Important status
This is a starter scaffold, not a finished APK or deployed service. It has not yet been built or tested on your Windows computer. The actual Kobo project UID and deployed form structure are still required before live synchronisation can be configured.

## Architecture
Officer phone -> local SQLite queue -> secure integration server -> KoboToolbox
Management dashboard -> secure integration server -> KoboToolbox API v2

## Windows setup
1. Install Flutter SDK and Android Studio.
2. Open a terminal in `officer_app`.
3. Run `flutter create .` to generate the Android platform folders.
4. Run `flutter pub get`.
5. Run `flutter run` with an Android phone connected or emulator running.

For the integration server:
1. Install Node.js LTS.
2. Open a terminal in `integration_server`.
3. Run `npm install`.
4. Copy `.env.example` to `.env` and fill in your Kobo project asset UID and API token.
5. Run `npm start`.

Never send your Kobo API token in chat or put it in the Android app. Store it only in the server environment.

## Next required information
- Confirm the Kobo project is deployed.
- Copy the project asset UID from its Kobo project URL (do not share the API token).
- Confirm the exact form field names after final XLSForm validation.
