{
  config,
  lib,
  pkgs,
  defaultUser,
  service,
  ...
}:
with lib;
with config; {
  config.services.icecream.daemon.enable = true;
  config.services.icecream.scheduler.enable = true;
}
