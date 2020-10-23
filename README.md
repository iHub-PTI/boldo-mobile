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
   # ####################### Online #######################
    SOCKETS_ADDRESS = https://sockets.boldo.penguin.software
    SERVER_ADDRESS = https://api.boldo.penguin.software
    KEYCLOAK_REALM_ADDRESS = https://sso-test.pti.org.py/auth/realms/iHub

   # ###################### Android ######################
   # SOCKETS_ADDRESS = http://10.0.2.2:8000
   # SERVER_ADDRESS = http://10.0.2.2:8008
   # KEYCLOAK_REALM_ADDRESS = http://10.0.2.2:8080/auth/realms/iHub

   # ######################## iOs ########################
   # SOCKETS_ADDRESS = http://localhost:8000
   # SERVER_ADDRESS = http://localhost:8008
   # KEYCLOAK_REALM_ADDRESS = http://localhost:8080/auth/realms/iHub
   ```

   Note: Uncomment the Android secion in case you want to run it on an Android.

4. `flutter run` - to start the app on an available device

Note: You can check the availability of connected devices by running `flutter doctor`.

## Building the app

```
 flutter build apk --split-per-abi \
 --dart-define=SOCKETS_ADDRESS=https://sockets.boldo.penguin.software \
 --dart-define=SERVER_ADDRESS=https://api.boldo.penguin.software \
 --dart-define=KEYCLOAK_REALM_ADDRESS=https://sso-test.pti.org.py/auth/realms/iHub
```

## Supported Platforms

To allow as many people as possible access to health services, this applications aims to run also on old devices. Currently we support the following minmal platform versions:

- iOS: 10
- Android: 4.4 (KitKat)

## Contributing

The project is currently under heavy development but contributors are welcome. For bugs or feature requests or eventual contributions, just open an issue. Contribution guidelines will be available shortly.

## Authors and License

This project was created as part of the iHub COVID-19 project in collaboration between [Penguin Academy](https://penguin.academy) and [PTI (Parque Tecnológico Itaipu Paraguay)](http://pti.org.py).

This project is licensed under
[GPL v3](LICENSE)
