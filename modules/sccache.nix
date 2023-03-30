{
  config,
  lib,
  pkgs,
  defaultUser,
  ...
}:
with lib; let
  cfg = config.services.sccache;
  user = defaultUser;

  schedulerConf = pkgs.writeTextFile {
    name = "scheduler.conf";
    text = ''
      # The socket address the scheduler will listen on. It's strongly recommended
      # to listen on localhost and put a HTTPS server in front of it.
      public_addr = "${cfg.sched_addr}"

      [client_auth]
      type = "token"
      token = "${cfg.client_token}"

      [server_auth]
      type = "token"
      token = "${cfg.token}"
    '';
  };

  serverConf = pkgs.writeTextFile {
    name = "server.conf";
    text = ''
      # This is where client toolchains will be stored.
      cache_dir = "/tmp/toolchains"
      # The maximum size of the toolchain cache, in bytes.
      # If unspecified the default is 10GB.
      # toolchain_cache_size = 10737418240
      # A public IP address and port that clients will use to connect to this builder.
      public_addr = "${cfg.server_addr}"
      # The URL used to connect to the scheduler (should use https, given an ideal
      # setup of a HTTPS server in front of the scheduler)
      scheduler_url = "${cfg.sched_url}"

      [builder]
      type = "overlay"
      # The directory under which a sandboxed filesystem will be created for builds.
      build_dir = "/tmp/build"
      # The path to the bubblewrap version 0.3.0+ `bwrap` binary.
      bwrap_path = "${pkgs.bubblewrap}/bin/bwrap"

      [scheduler_auth]
      type = "token"
      # This will be generated by the `generate-jwt-hs256-server-token` command or
      # provided by an administrator of the sccache cluster.
      token = "${cfg.token}"
    '';
  };

  clientConf = pkgs.writeTextFile {
    name = "client.conf";
    text = ''
      [dist]
      # The URL used to connect to the scheduler (should use https, given an ideal
      # setup of a HTTPS server in front of the scheduler)
      scheduler_url = "${cfg.sched_url}"
      # Used for mapping local toolchains to remote cross-compile toolchains. Empty in
      # this example where the client and build server are both Linux.
      toolchains = []
      # Size of the local toolchain cache, in bytes (5GB here, 10GB if unspecified).
      toolchain_cache_size = 5368709120

      [dist.auth]
      type = "token"
      # This should match the `client_auth` section of the scheduler config.
      token = "${cfg.client_token}"
    '';
  };
in {
  meta.maintainers = [];

  options = {
    services.sccache = {
      enable = mkEnableOption "sccache";
      scheduler = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      client = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      server = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      client_token = lib.mkOption {
        type = lib.types.str;
        default = "YOUR_TOKEN_HERE";
      };
      #server_key = lib.mkOption {
      #        type = lib.types.str;
      #        default = "YOUR_KEY_HERE";
      #};                #server_token = lib.mkOption {
      #        type = lib.types.str;
      #        default = "YOUR_TOKEN_HERE";
      #};
      token = lib.mkOption {
        type = lib.types.str;
        default = "TOKEN";
      };
      sched_addr = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1:10600";
      };
      sched_url = lib.mkOption {
        type = lib.types.str;
        default = "http://127.0.0.1";
      };
      server_addr = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1:10501";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [sccache bubblewrap icecream];
    networking.firewall.allowedTCPPorts = [10600 10501];
    networking.firewall.allowedUDPPorts = [10600 10501];
    environment.sessionVariables.RUSTC_WRAPPER = "${pkgs.sccache}/bin/sccache";

    systemd.services.sccache_scheduler = mkIf cfg.scheduler {
      description = "sccache-dist scheduler";
      wants = ["network-online.target"];
      after = ["network-online.target"];
      serviceConfig.ExecStart = "${pkgs.sccache}/bin/sccache-dist scheduler --config '${schedulerConf}'";
      serviceConfig.User = "root";
      wantedBy = ["multi-user.target"];
    };

    systemd.services.sccache_server = mkIf cfg.server {
      description = "sccache-dist server";
      wants = ["network-online.target"];
      after = ["network-online.target"];

      serviceConfig.ExecStart = "${pkgs.sccache}/bin/sccache-dist server --config '${serverConf}'";
      serviceConfig.User = "root";

      wantedBy = ["multi-user.target"];
    };
    environment.variables.SCCACHE_CONF = "${clientConf}";
    environment.sessionVariables.SCCACHE_CONF = "${clientConf}";
  };
}
