# Android emulator: the build image (docker/android-sdk) plus the emulator and a system image.
FROM android-env:latest

ARG ANDROID_PLATFORM=35

ENV ANDROID_PLATFORM=${ANDROID_PLATFORM} \
    ANDROID_AVD_HOME=/opt/avd \
    QT_QPA_PLATFORM=xcb
ENV PATH=${PATH}:${ANDROID_HOME}/emulator

USER root

# Libraries the emulator needs to open a window on the host display and use the GPU
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       libasound2t64 libpulse0 libnss3 libnspr4 \
       libgl1 libegl1 libglx-mesa0 libgl1-mesa-dri libdrm2 \
       libx11-xcb1 libxkbcommon-x11-0 libxcb-cursor0 libxcursor1 \
       libxdamage1 libxcomposite1 libxi6 libxtst6 libxrandr2 libxkbfile1 libice6 libsm6 \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p ${ANDROID_AVD_HOME} && chown dev:dev ${ANDROID_AVD_HOME}

USER dev

RUN sdkmanager --install \
       "emulator" \
       "system-images;android-${ANDROID_PLATFORM};default;x86_64" > /dev/null

COPY --chown=dev:dev entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
