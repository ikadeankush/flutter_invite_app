# Invite Sender — Flutter scaffold

Personalizes any invitation card with each guest's name and sends it from the
**host's own WhatsApp account** — no business API, no shared number, one tap
per guest.

## What's in this scaffold

```
lib/
  main.dart                        # wires the 3-screen flow together
  models/
    guest.dart                     # name + phone
    name_slot.dart                 # where/how the name is drawn; CardTemplate for multi-template support
  services/
    excel_service.dart             # parses the guest list .xlsx
    card_generator_service.dart    # renders name onto the card as a PNG
    whatsapp_service.dart          # Android native send / iOS fallback
  screens/
    template_designer_screen.dart  # upload card, tap to place name, tune style
    guest_list_screen.dart         # upload Excel or paste guests
    send_screen.dart               # one-tap-per-guest send loop

android/app/src/main/kotlin/.../MainActivity.kt   # the WhatsApp share-intent
android/app/src/main/res/xml/file_paths.xml       # required for sharing the file
android/app/src/main/AndroidManifest_ADDITIONS.xml  # merge into your real manifest
```

## How the send actually works

1. Host designs the template once (tap where the name goes, pick font/size/color).
2. Host uploads or pastes the guest list.
3. For each guest, the app renders the personalized card, then hands it to
   WhatsApp via Android's share-intent with that guest's chat pre-opened,
   image attached, and message pre-filled.
4. Host taps **Send** inside WhatsApp — from their own number. That one tap
   is an Android/WhatsApp security requirement and is not something any app
   should try to bypass; trying to would mean automating WhatsApp itself,
   which breaks its terms of service.

On iOS, Apple doesn't allow pre-selecting a WhatsApp contact this way, so the
fallback there pre-fills the message and opens the share sheet for the host
to attach the image manually — a platform limit, not a bug.

## To actually build and run this

This scaffold was written outside a Flutter environment, so it hasn't been
compiled. To get it running:

```bash
flutter create --project-name invite_sender --org com.example .
# then copy these lib/, pubspec.yaml, and android/ files into the generated project,
# merging AndroidManifest_ADDITIONS.xml into the generated AndroidManifest.xml
flutter pub get
flutter run
```

## Known gaps to finish before shipping

- **Color picker** in `template_designer_screen.dart` is a 5-swatch stub —
  swap in `flutter_colorpicker` for a full picker.
- **Multi-template library** (wedding/birthday/etc.): the `CardTemplate`
  model in `name_slot.dart` already supports this — add a screen that lists
  saved templates by category and lets the host pick one instead of always
  designing from scratch.
- **Persisting templates/guests** between app launches: everything here is
  in-memory for the session. Add `shared_preferences` or `sqflite` to save
  templates and guest lists.
- **Android permissions**: reading the guest's Excel file and writing temp
  card images may need runtime storage permission handling via
  `permission_handler`, depending on target Android SDK version.
- **Play Store policy check**: apps that interact with WhatsApp via share
  intents are common and generally fine, but review Google Play's current
  policies on messaging automation before publishing, since policies do
  change.
