# Kotlin Android template

A starting point for Kotlin Android projects that you develop **with Docker only**. You don't install Java, Android Studio or the Android SDK on your computer. It's for local development.

It includes:
- a small sample app (Jetpack Compose, one screen, one unit test) to replace with your own code;
- a build container with Java 17 and the Android SDK;
- an Android emulator container that opens as a window on your desktop.

## Requirements

- Linux with a desktop session (X11 or Wayland with XWayland)
- Docker
- KVM hardware virtualization (`/dev/kvm` must exist)

## Development loop

1. **Start the emulator** (leave it running):
   ```bash
   ./scripts/emulator.sh
   ```
   The first run builds the images and boots a fresh device, which takes several minutes. **Ctrl+C** stops the emulator and saves its state, so later starts take only seconds.

2. **Run your app** in another terminal, every time you change the code:
   ```bash
   ./scripts/preview.sh
   ```
   This builds the app, installs it on the emulator and opens it.

3. **Run the tests:**
   ```bash
   bin/android-env ./gradlew test
   ```

## Useful commands

`bin/android-env` runs any command inside the build container, in the current folder:

```bash
bin/android-env ./gradlew assembleDebug   # build the APK (app/build/outputs/apk/debug/)
bin/android-env ./gradlew test            # run unit tests
bin/android-env ./gradlew lint            # check for common Android mistakes (report in app/build/reports/)
bin/android-env ./gradlew tasks           # list everything Gradle can do
bin/android-env bash                      # open a shell inside the container
bin/android-env --rebuild                 # rebuild the image after editing docker/android-sdk/Dockerfile
./scripts/emulator.sh --rebuild           # rebuild the emulator image after editing docker/emulator/
```

## Start a new project from this template

1. Copy the folder (without `.git`, `build/` and `.gradle/`) and run `git init`.
2. Choose your app ID, e.g. `com.yourname.myapp`, and set it in:
   - `app/build.gradle.kts`: `namespace` and `applicationId`;
   - `scripts/preview.sh`: `APP_ID`.
3. Move the code from `app/src/*/java/com/example/hellokotlin/` to the folder that matches your package, and update the `package` lines.
4. Set `rootProject.name` in `settings.gradle.kts` and `app_name` in `app/src/main/res/values/strings.xml`.

**Another Android API level:** set the version in `app/build.gradle.kts` (`compileSdk`, `targetSdk`, `buildToolsVersion`), then rebuild both images:
```bash
ANDROID_PLATFORM=36 BUILD_TOOLS=36.0.0 bin/android-env --rebuild
ANDROID_PLATFORM=36 ./scripts/emulator.sh --rebuild
docker volume rm android-emulator-avd
```

## Files

| File | What it is |
|---|---|
| `app/src/main/java/.../MainActivity.kt` | The screen, written with **Jetpack Compose**. |
| `app/src/main/java/.../Greeting.kt` | Plain Kotlin logic, kept apart from the UI so it can be tested. |
| `app/src/main/java/.../ui/theme/Theme.kt` | Colors. Follows the device's dark mode. |
| `app/src/test/.../GreetingTest.kt` | Unit tests. They run in the build container, no emulator needed. |
| `app/src/main/AndroidManifest.xml` | The app's name, icon and the screen that opens first. |
| `app/src/main/res/` | Resources: texts (`values/strings.xml`) and the icon. |
| `app/build.gradle.kts` | App build settings: app ID, Android versions, dependencies. |
| `gradle/libs.versions.toml` | **Version catalog**: every library and plugin version in one place. |
| `settings.gradle.kts`, `build.gradle.kts` | Project-wide build setup and the list of modules. |
| `gradlew`, `gradle/wrapper/` | **Gradle wrapper**: downloads the exact Gradle version the project needs. |
| `docker/android-sdk/Dockerfile` | Build container: Java 17 + Android SDK. |
| `docker/emulator/` | Emulator container, built on top of the build container. |
| `bin/android-env` | Runs a command inside the build container. |
| `scripts/` | `emulator.sh`, `preview.sh`, and `build.sh` (builds the APK). |

## Docker volumes

| Volume | Contents |
|---|---|
| `android-env-gradle` | Gradle download cache. Safe to delete; it's downloaded again. |
| `android-env-android` | Debug signing key. If it's deleted, uninstall the app from the emulator before installing again. |
| `android-emulator-avd` | The emulator device and its saved state. Delete it to start with a fresh device. |

## Troubleshooting

- **`/dev/kvm` not found:** enable virtualization (VT-x / AMD-V) in your BIOS.
- **`DISPLAY is not set`:** run `./scripts/emulator.sh` from a terminal in your desktop session, not over SSH.
- **Emulator behaves strangely or won't boot:** stop it, run `docker volume rm android-emulator-avd`, then start it again.
- **`INSTALL_FAILED_UPDATE_INCOMPATIBLE`:** the signing key changed. Uninstall the app in the emulator, or reset the emulator as described above.
