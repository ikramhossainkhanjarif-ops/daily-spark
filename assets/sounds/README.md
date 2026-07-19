# Sound files go in TWO places (same 5 files, copied to both)

This app uses two different audio engines, each needing its own copy:

## 1. `assets/sounds/` (this folder)
Used by the in-app **sound picker preview** (tapping ▶ next to a
sound in Settings → Wake-up sound), which plays through Flutter's
`audioplayers` package while the app is open.

## 2. `android/app/src/main/res/raw/`
Used by the **native alarm ringing service** (`AlarmRingingService.kt`)
to actually play the alarm sound when it fires — this has to be a
native Android resource because it runs even if Flutter isn't active.

## Required filenames (must match exactly, lowercase, no spaces)
Put the same 5 mp3 files in both folders with these exact names:

- morning_chimes.mp3
- gentle_bells.mp3
- cheerful_pop.mp3
- soft_marimba.mp3
- sunrise_birds.mp3

Android resource names (`res/raw/`) can't contain capital letters,
spaces, or characters other than lowercase letters/numbers/underscore
— hence the naming convention above applies to both folders.

If you want different sounds or more/fewer of them, update
`lib/data/constants/built_in_sounds.dart` to match the ids/filenames
you actually use.
