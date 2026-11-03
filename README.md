# Hello Kotlin: your first Android app

A small Android app written in Kotlin. It shows a greeting, a box where you type your name, and a button that counts your taps. You build it with **Docker only**. You don't install Java, Android Studio or the Android SDK on your computer.

The Docker environment (`docker/` + `bin/android-env`) doesn't depend on this app, so you can reuse it for bigger projects later (see [Reusing the environment](#reusing-the-environment-for-your-next-project)).

---

## 1. Build the app

```bash
./scripts/build.sh
```

The first run takes about 5–10 minutes. It builds the Docker image (Java + Android SDK), then Gradle downloads its own dependencies. Later builds take seconds because everything is cached in Docker volumes.

The result is `app/build/outputs/apk/debug/app-debug.apk`. An **APK** is the file Android installs apps from.

## 2. Send it to your phone over Wi-Fi

```bash
./scripts/serve.sh
```

The script prints a URL like `http://192.168.1.20:8000/` and a QR code. Leave it running.

## 3. Install it on the phone

1. Connect the phone to the **same Wi-Fi network** as your computer.
2. Scan the QR code with the camera, or type the URL into Chrome.
3. Tap **Download & install**, then open the downloaded file.
4. Android warns you about installing from an unknown source. Tap **Settings** and turn on **Allow from this source** for your browser, then go back and tap **Install**. You only need to do this once.
5. Google Play Protect may say it doesn't recognize the app. Tap **More details → Install anyway**. This is normal for an app you built yourself.
6. Open **Hello Kotlin** from your app drawer. 🎉

Stop the server with `Ctrl+C` when you're done.

## 4. Make a change

1. Open `app/src/main/java/com/example/hellokotlin/Greeting.kt` and change `"Hello, $who!"` to something else, e.g. `"Hi there, $who 👋"`.
2. Run `./scripts/build.sh` again. If it fails, it's probably the unit test: update `GreetingTest.kt` to match your new text. That's the tests doing their job.
3. Run `./scripts/serve.sh` and install again from the phone. It installs as an update over the old version.

---

## What each file does

| File | What it is |
|---|---|
| `app/src/main/java/.../MainActivity.kt` | The screen. Written with **Jetpack Compose**: the UI is made of Kotlin functions marked `@Composable`. |
| `app/src/main/java/.../Greeting.kt` | Plain Kotlin logic (text messages), kept apart from the UI so it can be tested. |
| `app/src/main/java/.../ui/theme/Theme.kt` | Colors. Follows the phone's dark mode and wallpaper colors. |
| `app/src/test/.../GreetingTest.kt` | Unit tests. They run on your computer, no phone needed. |
| `app/src/main/AndroidManifest.xml` | Tells Android the app's name, icon and which screen opens first. |
| `app/src/main/res/` | Resources: app name (`values/strings.xml`), icon (`drawable/`, `mipmap*/`). |
| `app/build.gradle.kts` | Build settings for the app: app ID, supported Android versions, dependencies. |
| `gradle/libs.versions.toml` | **Version catalog**: every library and plugin version in one place. |
| `settings.gradle.kts`, `build.gradle.kts` | Project-wide build setup. Lists the modules (just `:app` for now). |
| `gradlew`, `gradle/wrapper/` | **Gradle wrapper**: downloads the exact Gradle version this project needs. |
| `docker/android-sdk/Dockerfile` | The build environment: Java 17 + Android SDK. |
| `bin/android-env` | Runs any command inside that environment, in the current folder. |
| `scripts/build.sh`, `scripts/serve.sh` | Shortcuts for the steps above. |

## Useful commands

Run any Gradle task through `bin/android-env`:

```bash
bin/android-env ./gradlew assembleDebug   # build the APK
bin/android-env ./gradlew test            # run unit tests
bin/android-env ./gradlew lint            # check for common Android mistakes (report in app/build/reports/)
bin/android-env ./gradlew tasks           # list everything Gradle can do
bin/android-env bash                      # open a shell inside the environment
```

---

## Reusing the environment for your next project

The image has nothing specific to this app in it. It contains Java 17, the Android SDK and `adb`. Each project brings its own Gradle version through its wrapper.

- **Use it anywhere:** `ln -s "$PWD/bin/android-env" ~/.local/bin/android-env`, then run `android-env ./gradlew assembleDebug` in any Android project folder. That includes projects created by Android Studio or copied from tutorials.
- **Other Android API levels:** `ANDROID_PLATFORM=36 BUILD_TOOLS=36.0.0 android-env --rebuild`. If a project asks for SDK packages that aren't installed, the Android Gradle Plugin downloads them during the build.
- **Rebuild the image** after editing the Dockerfile: `android-env --rebuild`.
- **Caches:** Gradle downloads are stored in the `android-env-gradle` Docker volume. The debug signing key is in `android-env-android`. Keep that volume: if the key changes, the phone refuses to install the new build as an update.

### Next step: install straight from the computer with adb

Once you're comfortable, you can skip the download step and let `adb` (included in the image) install and launch the app directly:

1. On the phone: **Settings → About phone → tap "Build number" 7 times** to enable Developer options.
2. **Wireless (Android 11+):** in Developer options turn on **Wireless debugging**, tap **Pair device with pairing code**, then:
   ```bash
   bin/android-env adb pair <ip>:<pairing-port>     # enter the code shown on the phone
   bin/android-env adb connect <ip>:<port>
   ```
   **USB:** turn on **USB debugging**, plug the phone in, and add `--usb`: `bin/android-env --usb adb devices`.
3. Build and install in one step: `bin/android-env ./gradlew installDebug`.

The adb server stops with each container. For a session where you connect once and run several commands, use `bin/android-env bash` and run everything inside that shell.

---

## Troubleshooting

- **Phone can't open the URL:** check that both devices are on the same Wi-Fi network. Guest networks often block devices from reaching each other. Your firewall may also be blocking port 8000: `sudo ufw allow 8000/tcp`. You can use a different port with `PORT=8080 ./scripts/serve.sh`.
- **"App not installed" when updating:** the signing key changed, probably because the `android-env-android` volume was deleted. Uninstall the old app from the phone and install again.
- **Build is slow the first time:** that's expected while dependencies download. Later builds use the cache.
- **Lint warnings about newer versions:** these are only suggestions. To upgrade, change the version numbers in `gradle/libs.versions.toml`.
