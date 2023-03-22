{ config, pkgs, ... }:
{
        nixpkgs.config.allowUnfree = true;

        environment.systemPackages = with pkgs; [ killall ];

        networking.firewall.enable = false;

        home-manager.users.root.home.stateVersion = "22.11";
        system.stateVersion = "22.11";

        _module.args.user = "root";

        imports = [
                <home-manager/nixos>
                #./ide.nix
                ./sccache.nix
        ];        

	service.sccache.enable = true;
        service.sccache.scheduler = false;
        service.sccache.client = true;
        service.sccache.server = true;

        #service.sccache.server_key = "KD7cQ4LZBMkWonq0TocqFzU_QnTxRdza_mkVnMtLztY";
        #service.sccache.server_token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjAsInNlcnZlcl9pZCI6IjE5Mi4xNjguMS4xOjEwNTAxIn0.9JmalliC4eDIK1bP6hh_Y4-k5IPgwSdutSkqXh9Mg2k";
        #service.sccache.server_token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjAsInNlcnZlcl9pZCI6IjEwLjEyMS4zNy45ODoxMDUwMSJ9.SgZHSa98bj-xdWXxdlJPoaFxFVh_eFBVS1YWe2zVry0";
        #service.sccache.server_token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjAsInNlcnZlcl9pZCI6IjEyNy4wLjAuMToxMDUwMSJ9.98NoYYpzTp-lqP8ipNvo4LdGEMRV9IdeGk6roSDRxZM";

        service.sccache.token = "TOKEN";
        service.sccache.sched_url = "http://192.168.1.121:10600";
        service.sccache.sched_addr = "192.168.1.121:10600";
        #service.sccache.server_addr = "127.0.0.1:10501";
        service.sccache.server_addr = "192.168.1.107:10501";

	networking.firewall.allowedTCPPorts = [ 10600 10501 ];
	networking.firewall.allowedUDPPorts = [ 10600 10501 ];

}
