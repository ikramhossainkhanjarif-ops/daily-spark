# Daily Spark

A "Soft & Cute" public motivational alarm clock, built on the same
Clean Architecture + native Kotlin exact-alarm backend as your
previous alarm apps.

## Layout

```
lib/
  domain/          Pure Dart: entities, repository interfaces, use cases
  data/            SharedPreferences + MethodChannel implementations,
                    200 built-in messages, 5-sound catalog
  presentation/    BLoC (alarm list), Material 3 UI, ringing page

android/app/src/main/kotlin/com/dailyspark/app/
  AlarmSchedulerPlugin.kt   MethodChannel bridge (channel:
                            com.dailyspark.app/alarm_scheduler)
  AlarmScheduler.kt         AlarmManager exact-alarm scheduling/re-arming
  AlarmReceiver.kt          Fires on alarm trigger, starts the service
  AlarmRingingService.kt    Foreground service: audio, vibration, launches UI
  NativeAlarmStore.kt       Native SharedPreferences mirror (own prefs file)
  BootReceiver.kt           Re-arms all alarms after ACTION_BOOT_COMPLETED
  MainActivity.kt           Lock-screen show/turn-on flags
```

## Before building

1. Drop 5 alarm tone files into `android/app/src/main/res/raw/` named
   to match the `soundId`s in `built_in_sounds.dart`
   (`morning_chimes.mp3`, `gentle_bells.mp3`, `cheerful_pop.mp3`,
   `soft_marimba.mp3`, `sunrise_birds.mp3`) — this is what
   `AlarmRingingService.kt` plays via `MediaPlayer`. Also copy the
   same files into `assets/sounds/` so the in-app sound-picker preview
   (which plays through Flutter's `audioplayers`) works too.
2. Add the four Poppins font weights under `assets/fonts/` (or swap
   the `fonts:` block in `pubspec.yaml` for whatever typeface you
   prefer — Material 3's default works fine if you'd rather skip
   bundling a font).
3. Add a launcher icon at `android/app/src/main/res/mipmap-*/ic_launcher.png`.

## Known gotchas (carried over from Love Alarms / WeTogether / Us)

- **Don't commit `gradlew` / `gradlew.bat`** — let Codemagic/CI
  regenerate them, this avoided a class of AGP/Gradle mismatch
  failures on past builds.
- **Build APKs, not AABs**, if you're installing directly on your own
  device rather than publishing to Play — much faster loop for
  from-phone testing.
- **`codemagic.yaml` must sit at the true repo root**, not inside
  `android/` or a nested folder, or Codemagic won't discover it.
- If `flutter build apk` complains about `const` expressions in the
  theme or gradient lists, double check nothing non-const (like a
  `Color` computed at runtime) snuck into a `const` list — this bit
  the earlier two apps a few times.
- SCHEDULE_EXACT_ALARM on Android 12+ (S) requires the user to grant
  the "Alarms & reminders" special permission; `AlarmScheduler.kt`
  falls back to an inexact `setAndAllowWhileIdle` if
  `canScheduleExactAlarms()` is false, but you'll want an in-app
  prompt (e.g. `Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM`) to ask
  for it properly — that's not wired up yet in this scaffold.

## What's deliberately left as a follow-up

- Wiring the "Alarms & reminders" permission-request flow mentioned
  above.
- Persisting the `MainActivity` cold-start path so a killed app that's
  launched by a firing alarm intent (rather than a running engine)
  reads the `com.dailyspark.app.ACTION_ALARM_FIRE` intent extras in
  `main.dart`/`MainActivity` and opens `RingingPage` directly. Right
  now the Dart-side navigation is wired for the "engine already
  running" case via `onAlarmFiring`; the cold-start intent path needs
  a small `getInitialRoute`-style check added once you're ready to
  test full app-kill behavior on a device.
