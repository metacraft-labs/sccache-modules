{pkgs, ...}: {
  environment.systemPackages = [pkgs.distcc];
  services.distccd.enable = true;
  services.distccd.zeroconf = true;
  services.distccd.openFirewall = true;
  services.distccd.stats.enable = true;
  services.distccd.allowedClients = ["127.0.0.1" "192.168.1.0"];
  environment.sessionVariables.DISTCC_HOSTS = "raych virtual acer-vx15-nixos mcl-nixos-desktop01  mcl-nixos-desktop05 zlx-flow-x13 zlx-nixos-desktop zlx-nixos-desktop2";
}
