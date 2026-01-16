{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.cluster.k3s;

  clusterConfig = {
    package = pkgs.k3s;

    disable = [
      # 默认使用 k3s 自带组件
    ];

    configPath = "/etc/rancher/k3s/k3s.yaml";
  };
in
{
  options.cluster.k3s = {

    enable = mkEnableOption "Opinionated k3s node";

    role = mkOption {
      type = types.enum [
        "server"
        "agent"
      ];
      description = ''
        Role of this node in the k3s cluster.

        - server: control-plane node (runs API server, scheduler, etc.)
        - agent: worker node (runs workloads only)
      '';
    };

    clusterInit = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether this node initializes the cluster.

        This must be true for exactly one server node
        (the first control-plane node).
      '';
    };

    serverAddr = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Address of the existing k3s server to join.

        Required for all nodes except the initial server
        (clusterInit = true).
        Example: https://master.example.com:6443
      '';
    };

    tokenFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Path to the k3s cluster token.

        Required for agents and non-initial servers.
        Not required when clusterInit = true.
      '';
    };

    node = {
      name = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Kubernetes node name.

          If null, the system hostname will be used.
        '';
      };

      labels = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          Kubernetes node labels.

          Labels are key=value pairs used for scheduling,
          placement, and grouping of workloads.
          Example: [ "role=control-plane" "env=dev" ]
        '';
      };

      taints = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          Kubernetes node taints.

          Taints repel pods unless they explicitly tolerate them.
          Commonly used to protect control-plane nodes from
          running regular workloads.
        '';
      };

      ip = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Node IP address to advertise to the cluster.

          Usually not needed unless the node has multiple
          network interfaces.
        '';
      };
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      kubectl
      k9s
    ];

    services.k3s = {
      enable = true;

      # ---- 集群统一 ----
      inherit (clusterConfig)
        package
        disable
        configPath
        ;

      # ---- 节点差异 ----
      role = cfg.role;
      clusterInit = cfg.clusterInit;
      tokenFile = lib.mkIf (cfg.tokenFile != null) cfg.tokenFile;

      serverAddr = if cfg.clusterInit then "" else cfg.serverAddr;

      nodeName = cfg.node.name;
      nodeLabel = cfg.node.labels;
      nodeTaint = cfg.node.taints;
      nodeIP = cfg.node.ip;
    };

    environment.variables.KUBECONFIG = clusterConfig.configPath;
  };
}
