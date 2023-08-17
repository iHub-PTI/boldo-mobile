enum Flavors {
  dev(
    environment: "dev",
    envFile: ".env-dev",
    appConfigFile: ".env_app_config-dev",
    iceServerConfigFile: ".env_ice_server_config-dev",
    appName: "Boldo-dev",
  ),
  qa(
    environment: "qa",
    envFile: ".env-qa",
    appConfigFile: ".env_app_config-qa",
    iceServerConfigFile: ".env_ice_server_config-qa",
    appName: "Boldo-test",
  ),
  prod(
  environment: "prod",
  envFile: ".env-prod",
    appConfigFile: ".env_app_config-prod",
    iceServerConfigFile: ".env_ice_server_config-prod",
  appName: "Boldo-prod",
  );

  const Flavors({
    required this.environment,
    required this.envFile,
    required this.appConfigFile,
    required this.iceServerConfigFile,
    required this.appName,
  });
  final String environment;
  final String envFile;
  final String appConfigFile;
  final String iceServerConfigFile;
  final String appName;
}