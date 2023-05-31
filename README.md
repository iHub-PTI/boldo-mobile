# Boldo - Mobile

Boldo can be found in any Paraguayan household. It is a magic team that can calm all kind of stomache ache.

This is the flutter based native application (iOs and Android) for Boldo - a telemedicine solution for doctors and patients.
The mobile app is specifically for patients.

## Getting Started

1. This project has the following dependencies:

   - flutter (latest version)

2. Install dependencies: `flutter pub get` (normally happens automatically)

3. Create a `.env` file in the project's root folder and add these contents:

   ```
   # ###################### locale enviroments ######################
   SOCKETS_ADDRESS = http://localhost:8000 
   SERVER_ADDRESS = http://localhost:8008
   KEYCLOAK_REALM_ADDRESS = http://localhost:8080/realms/iHub
   

   # ###################### SENTRY credentials to listen erros on release mode ##########
   # SENTRY_DSN=CREATE A PROJECT IN SENTRY FOR FLUTTER 
   # SENTRY_ENV=ASK DEVELOPERS FOR KEY

   ```
   
   Notes:
   - [Sentry flutter documentation](https://docs.sentry.io/platforms/flutter/)
   - For the SOCKETS_ADDRESS build the project [boldo-socket](https://github.com/iHub-PTI/boldo-sockets)
   - For the SERVER_ADDRESS build the project [boldo-server](https://github.com/iHub-PTI/boldo-server)
   - For the KEYCLOAK_REALM_ADDRESS build the project [ihub-keycloak](https://github.com/iHub-PTI/ihub-keycloak)
   
   
4. Create a `.env_ice_server_config` file in the project's root folder and add these contents:
   
   ```
   
   ICE_SERVER_TURN_URL = "turn:<your.turn.uri>:<UDP-PORT>"
   ICE_SERVER_TURN_USERNAME = <guest>
   ICE_SERVER_TURN_CREDENTIAL = <credential>
   
   ICE_SERVER_STUN_URL = stun:<your.stun.uri>:<UDP-PORT>
   ICE_SERVER_STUN_USERNAME = <guest>
   ICE_SERVER_STUN_CREDENTIAL = <credential>
   
   ```

5. `flutter run` - to start the app on an available device

Note: You can check the availability of connected devices by running `flutter doctor`.

## Building the app

```
 flutter build apk --split-per-abi \
 --dart-define=SOCKETS_ADDRESS=https://sockets.boldo.penguin.software \
 --dart-define=SERVER_ADDRESS=https://api.boldo.penguin.software \
 --dart-define=KEYCLOAK_REALM_ADDRESS=https://sso-test.pti.org.py/auth/realms/iHub \
 --dart-define=SENTRY_DSN=ASK DEVELOPERS FOR KEY
```

## Known issues

The webRTC and chatty libraries causes a lot of unnecessary comments. To disable them you can add `!org.webrtc,!I/chatty` as a filter in your VSCode debug console. To ignore even more, add those as well `!E/CameraCaptureSession,!EGL_emulation,!FlutterWebRTCPlugin,!HostConnection`.

## Supported Platforms

To allow as many people as possible access to health services, this applications aims to run also on old devices. Currently we support the following minmal platform versions:

- iOS: 11
- Android: 5.0 (Lollipop)

## Contributing

The project is currently under heavy development but contributors are welcome. For bugs or feature requests or eventual contributions, just open an issue. Contribution guidelines will be available shortly.

## Authors and License

This project was created as part of the iHub COVID-19 project in collaboration between [Penguin Academy](https://penguin.academy) and [PTI (Parque Tecnológico Itaipu Paraguay)](http://pti.org.py).

This project is licensed under
[GPL v3](LICENSE)
