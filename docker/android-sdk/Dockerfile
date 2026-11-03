# Reusable Android build environment: JDK + Android SDK, no project-specific bits.
# Every project brings its own Gradle version via its Gradle wrapper (./gradlew).
FROM eclipse-temurin:17-jdk

# Change these (e.g. --build-arg ANDROID_PLATFORM=36) when a project needs another API level.
# Missing SDK packages are also auto-downloaded by the Android Gradle Plugin at build time.
ARG ANDROID_PLATFORM=35
ARG BUILD_TOOLS=35.0.0
ARG CMDLINE_TOOLS_VERSION=11076708
# Match the host user so files written into the mounted project are not owned by root.
ARG USER_UID=1000
ARG USER_GID=1000

ENV ANDROID_HOME=/opt/android-sdk \
    ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/build-tools/${BUILD_TOOLS}

RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && curl -fsSL -o /tmp/cmdline-tools.zip \
       https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS_VERSION}_latest.zip \
    && unzip -q /tmp/cmdline-tools.zip -d ${ANDROID_HOME}/cmdline-tools \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && rm /tmp/cmdline-tools.zip

RUN yes | sdkmanager --licenses > /dev/null \
    && sdkmanager --install \
       "platform-tools" \
       "platforms;android-${ANDROID_PLATFORM}" \
       "build-tools;${BUILD_TOOLS}" > /dev/null

# The base image ships an "ubuntu" user with UID 1000; reuse/replace it with "dev".
RUN (userdel -r ubuntu 2>/dev/null || true) \
    && groupadd -o -g ${USER_GID} dev \
    && useradd -o -m -u ${USER_UID} -g ${USER_GID} -s /bin/bash dev \
    && chown -R dev:dev ${ANDROID_HOME} \
    && mkdir -p /home/dev/.gradle /home/dev/.android \
    && chown -R dev:dev /home/dev

USER dev
WORKDIR /workspace
CMD ["bash"]
