# LEMA

A new Flutter project.

## Generating Android Debug Key
> keytool -genkey -v -keystore debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000

## Show SHA1 and SHA256
> keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

<img src="https://raw.githubusercontent.com/gerardosocias29/leap/main/assets/Screenshot%20from%202022-11-20%2022-25-32.png">
