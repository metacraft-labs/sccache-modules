{pkgs, ...}: {
  environment.systemPackages = [pkgs.icemon];
  services.icecream.daemon.enable = true;
  services.icecream.daemon.openFirewall = true;
  services.icecream.daemon.openBroadcast = true;
  # services.icecream.scheduler.enable = true;
  services.icecream.scheduler.openFirewall = true;
  # services.icecream.scheduler.openBroadcast = true;
}
