{
  lib,
  pkgs,
  config,
  ...
}:

let
  # ============================================================
  # 基础参数
  # ============================================================

  proxy-port = 7890;
  ui-port = 9090;

  # ============================================================
  # MRS helpers
  # ============================================================

  mrsDomain = name: url: {
    type = "http";
    behavior = "domain";
    format = "mrs";
    path = "./ruleset/${name}.mrs";
    interval = 86400;
    inherit url;
  };

  mrsIP = name: url: {
    type = "http";
    behavior = "ipcidr";
    format = "mrs";
    path = "./ruleset/${name}.mrs";
    interval = 86400;
    inherit url;
  };

  # ============================================================
  # 直连规则
  # ============================================================

  directRules = [
    # LAN
    "DOMAIN-SUFFIX,local,DIRECT"
    "DOMAIN-SUFFIX,localhost,DIRECT"
    "DOMAIN-SUFFIX,lan,DIRECT"
    "DOMAIN-SUFFIX,home.arpa,DIRECT"

    "IP-CIDR,127.0.0.0/8,DIRECT,no-resolve"
    "IP-CIDR,10.0.0.0/8,DIRECT,no-resolve"
    "IP-CIDR,172.16.0.0/12,DIRECT,no-resolve"
    "IP-CIDR,192.168.0.0/16,DIRECT,no-resolve"
    "IP-CIDR,100.64.0.0/10,DIRECT,no-resolve"
    "IP-CIDR,169.254.0.0/16,DIRECT,no-resolve"

    "IP-CIDR6,::1/128,DIRECT,no-resolve"
    "IP-CIDR6,fe80::/10,DIRECT,no-resolve"

    # Proxy
    "PROCESS-NAME,clash,DIRECT"
    "PROCESS-NAME,mihomo,DIRECT"
    "PROCESS-NAME,v2ray,DIRECT"
    "PROCESS-NAME,xray,DIRECT"
    "PROCESS-NAME,naive,DIRECT"
    "PROCESS-NAME,trojan,DIRECT"
    "PROCESS-NAME,trojan-go,DIRECT"
    "PROCESS-NAME,ss-local,DIRECT"
    "PROCESS-NAME,privoxy,DIRECT"
    "PROCESS-NAME,leaf,DIRECT"

    # Download
    "PROCESS-NAME,aria2c,DIRECT"
    "PROCESS-NAME,Transmission,DIRECT"
    "PROCESS-NAME,uTorrent,DIRECT"
    "PROCESS-NAME,qbittorrent,DIRECT"
    "PROCESS-NAME,fdm,DIRECT"
    "PROCESS-NAME,Folx,DIRECT"
    "PROCESS-NAME,NetTransport,DIRECT"
    "PROCESS-NAME,WebTorrent,DIRECT"
    "PROCESS-NAME,motrix,DIRECT"
    "PROCESS-NAME,Thunder,DIRECT"
    "PROCESS-NAME,DownloadService,DIRECT"
    "PROCESS-NAME,clash-verge,DIRECT"
    "PROCESS-NAME-REGEX,.*qbittorrent.*,DIRECT"

    # Tracker
    "DOMAIN-SUFFIX,bz.tc,DIRECT"
    "DOMAIN-SUFFIX,nyaa.si,DIRECT"
  ];

  # ============================================================
  # 强制代理
  # ============================================================

  proxyRules = [
    # "DOMAIN-SUFFIX,example.com,节点选择"
  ];

  # ============================================================
  # AI 补充规则
  # ============================================================

  aiExtra = {
    type = "inline";
    behavior = "classical";
    format = "yaml";

    payload = [
      "DOMAIN-SUFFIX,claude.ai"
      "DOMAIN-SUFFIX,anthropic.com"

      "DOMAIN-SUFFIX,gemini.google.com"
      "DOMAIN-SUFFIX,aistudio.google.com"
      "DOMAIN-SUFFIX,ai.google.dev"
      "DOMAIN-SUFFIX,generativelanguage.googleapis.com"

      "DOMAIN-SUFFIX,copilot.microsoft.com"
      "DOMAIN-SUFFIX,copilot.cloud.microsoft"

      "DOMAIN-SUFFIX,perplexity.ai"

      "DOMAIN-SUFFIX,grok.com"
      "DOMAIN-SUFFIX,x.ai"

      "DOMAIN-SUFFIX,huggingface.co"
      "DOMAIN-SUFFIX,character.ai"

      "DOMAIN-SUFFIX,mistral.ai"
      "DOMAIN-SUFFIX,cohere.com"

      "DOMAIN-SUFFIX,meta.ai"
    ];
  };

in
{
  # ============================================================
  # Packages
  # ============================================================

  environment.systemPackages = with pkgs; [
    sparkle-wrapper
  ];

  # ============================================================
  # sparkle
  # ============================================================

  security.wrappers.sparkle = {
    owner = "root";
    group = "root";

    capabilities = "cap_net_bind_service,cap_net_raw,cap_net_admin=+ep";

    source = "${lib.getExe pkgs.sparkle}";
  };

  # ============================================================
  # Mihomo
  # ============================================================

  services.mihomo = {
    enable = true;
    package = pkgs.mihomo;

    configFile = config.sops.templates."mihomo.yaml".path;

    webui = pkgs.metacubexd;

    tunMode = true;

    extraOpts = "-m";
  };

  # 非 TUN 模式使用
  networking.proxy.default = lib.mkIf (
    config.services.mihomo.enable && !config.services.mihomo.tunMode
  ) "http://127.0.0.1:${toString proxy-port}";

  # ============================================================
  # Mihomo config
  # ============================================================

  sops.templates."mihomo.yaml" = {
    owner = "root";
    mode = "0600";

    content = builtins.readFile (
      (pkgs.formats.yaml { }).generate "mihomo-raw.yaml" {

        # ======================================================
        # Basic
        # ======================================================

        "mixed-port" = proxy-port;

        mode = "rule";
        "log-level" = "info";

        ipv6 = true;

        "allow-lan" = true;
        "bind-address" = "*";

        "find-process-mode" = "strict";

        "tcp-concurrent" = true;
        "unified-delay" = true;

        "keep-alive-interval" = 15;

        "inbound-tfo" = true;
        "outbound-tfo" = true;

        "connection-pool-size" = 256;
        "idle-timeout" = 60;

        "tcp-concurrent-users" = 64;

        # ======================================================
        # Profile
        # ======================================================

        profile = {
          "store-selected" = true;
          "store-fake-ip" = true;
        };

        # ======================================================
        # GeoData
        # ======================================================

        "geodata-mode" = true;
        "geo-auto-update" = true;
        "geo-update-interval" = 24;

        "geox-url" = {
          geosite = "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geosite.dat";

          geoip = "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geoip.dat";

          mmdb = "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/country.mmdb";

          asn = "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/GeoLite2-ASN.mmdb";
        };

        # ======================================================
        # Controller
        # ======================================================

        "external-controller" = "0.0.0.0:${toString ui-port}";

        secret = config.sops.placeholder."mihomo/secret";

        # ======================================================
        # Sniffer
        # ======================================================

        sniffer = {
          enable = true;

          "force-dns-mapping" = true;
          "parse-pure-ip" = true;
          "override-destination" = true;

          sniff = {
            HTTP = {
              ports = [
                80
                "8080-8880"
              ];

              "override-destination" = true;
            };

            TLS = {
              ports = [
                443
                8443
              ];
            };

            QUIC = {
              ports = [
                443
                8443
              ];
            };
          };

          "skip-domain" = [
            "Mijia Cloud"
            "+.push.apple.com"
          ];
        };

        # ======================================================
        # TUN
        # ======================================================

        tun = {
          enable = true;

          stack = "system";

          "auto-route" = true;
          "auto-detect-interface" = true;

          "dns-hijack" = [
            "any:53"
            "tcp://any:53"
          ];

          "strict-route" = false;
        };

        # ======================================================
        # DNS
        # ======================================================

        dns = {
          enable = true;

          "prefer-h3" = false;

          ipv6 = false;

          listen = "127.0.0.1:1053";

          "enhanced-mode" = "fake-ip";

          "fake-ip-range" = "198.18.0.1/16";

          "fake-ip-filter-mode" = "blacklist";

          "use-hosts" = true;
          "use-system-hosts" = true;

          "respect-rules" = true;

          "skip-intruder" = true;

          # 节点域名解析
          "proxy-server-nameserver" = [
            "223.5.5.5"
            "119.29.29.29"
          ];

          "default-nameserver" = [
            "223.5.5.5"
            "119.29.29.29"
          ];

          # DNS policy
          "nameserver-policy" = {
            "rule-set:cn_domain" = [
              "https://dns.alidns.com/dns-query"
              "https://doh.pub/dns-query"
            ];

            "rule-set:google_domain" = [
              "https://dns.google/dns-query"
            ];

            "rule-set:github_domain" = [
              "https://dns.google/dns-query"
            ];

            "rule-set:telegram_domain" = [
              "https://cloudflare-dns.com/dns-query"
            ];

            "rule-set:twitter_domain" = [
              "https://cloudflare-dns.com/dns-query"
            ];

            "rule-set:netflix_domain" = [
              "https://cloudflare-dns.com/dns-query"
            ];

            "rule-set:youtube_domain" = [
              "https://dns.google/dns-query"
            ];
          };

          # Fake-IP
          "fake-ip-filter" = [
            "*.lan"

            "+.local"
            "+.internal"
            "+.localdomain"
            "+.home.arpa"

            "+.m2m"
            "+.bogon"

            "localhost.ptlogin2.qq.com"

            "injections.adguard.org"
            "local.adguard.org"

            "127.0.0.1.sslip.io"
            "127.atlas.skk.moe"

            "dns.msftncsi.com"

            "*.srv.nintendo.net"
            "*.stun.playstation.net"

            "xbox.*.microsoft.com"
            "*.xboxlive.com"

            "*.turn.twilio.com"
            "*.stun.twilio.com"

            "stun.syncthing.net"
            "stun.*"

            "*.sslip.io"
            "*.nip.io"

            "imap.gmail.com"
            "smtp.gmail.com"
            "pop.gmail.com"
            "mail.google.com"

            "accounts.google.com"
            "oauth2.googleapis.com"
            "www.googleapis.com"

            "*.torrent"
            "*.announce"
            "*.tracker"
          ];

          nameserver = [
            "223.5.5.5"
            "119.29.29.29"

            "https://doh.pub/dns-query"
            "https://dns.alidns.com/dns-query"

            "8.8.8.8"
            "1.1.1.1"

            "https://dns.google/dns-query"
            "https://cloudflare-dns.com/dns-query"

            "quic://dns.adguard.com:784"
          ];

          fallback = [
            "8.8.8.8"
            "1.1.1.1"

            "https://dns.google/dns-query"
            "https://1.1.1.1/dns-query"

            "tls://8.8.8.8:853"
          ];

          "fallback-filter" = {
            geoip = true;

            "geoip-code" = "CN";

            ipcidr = [
              "240.0.0.0/4"
              "0.0.0.0/32"
              "127.0.0.1/32"
              "100.64.0.0/10"
            ];
          };
        };

        # ======================================================
        # Proxy Providers
        # ======================================================

        "proxy-providers" = {

          "订阅1" = {
            type = "http";

            url = config.sops.placeholder."mihomo/subscription1";

            interval = 21600;

            path = "./proxy_providers/sub1.yaml";

            "health-check" = {
              enable = true;

              url = "https://cp.cloudflare.com/generate_204";

              interval = 1800;
            };

            override = {
              udp = true;

              "additional-prefix" = "「订阅1」";
            };
          };

          "订阅2" = {
            type = "http";

            url = config.sops.placeholder."mihomo/subscription2";

            interval = 21600;

            path = "./proxy_providers/sub2.yaml";

            "health-check" = {
              enable = true;

              url = "https://cp.cloudflare.com/generate_204";

              interval = 1800;
            };

            override = {
              udp = true;

              "additional-prefix" = "「订阅2」";
            };
          };
        };

        # ======================================================
        # Proxy Groups
        # ======================================================

        "proxy-groups" = [

          # --------------------------------------------------
          # Main
          # --------------------------------------------------

          {
            name = "PROXY";
            type = "select";

            proxies = [
              "节点选择"
            ];
          }

          {
            name = "节点选择";
            type = "select";

            proxies = [
              "自动选择"
              "故障转移"
              "负载均衡"

              "香港"
              "台湾"
              "日本"
              "韩国"
              "美国"
              "新加坡"

              "DIRECT"
            ];
          }

          # --------------------------------------------------
          # Auto
          # --------------------------------------------------

          {
            name = "自动选择";
            type = "url-test";

            include-all = true;
            "exclude-type" = "direct";

            url = "http://www.gstatic.com/generate_204";

            interval = 300;
            tolerance = 100;
          }

          {
            name = "故障转移";
            type = "fallback";

            include-all = true;
            "exclude-type" = "direct";

            url = "http://www.gstatic.com/generate_204";

            interval = 300;
          }

          {
            name = "负载均衡";
            type = "load-balance";

            strategy = "consistent-hashing";

            include-all = true;
            "exclude-type" = "direct";

            url = "http://www.gstatic.com/generate_204";

            interval = 300;
          }

          # --------------------------------------------------
          # Region
          # --------------------------------------------------

          {
            name = "香港";
            type = "url-test";

            include-all = true;
            "exclude-type" = "direct";

            filter = "(?i)(香港|港|hk|hong.?kong)";

            url = "http://www.gstatic.com/generate_204";

            interval = 300;
            tolerance = 100;
          }

          {
            name = "台湾";
            type = "url-test";

            include-all = true;
            "exclude-type" = "direct";

            filter = "(?i)(台湾|台|tw|taiwan|taipei)";

            url = "http://www.gstatic.com/generate_204";

            interval = 300;
            tolerance = 100;
          }

          {
            name = "日本";
            type = "url-test";

            include-all = true;
            "exclude-type" = "direct";

            filter = "(?i)(日本|日|jp|japan|tokyo|osaka)";

            url = "http://www.gstatic.com/generate_204";

            interval = 300;
            tolerance = 100;
          }

          {
            name = "韩国";
            type = "url-test";

            include-all = true;
            "exclude-type" = "direct";

            filter = "(?i)(韩国|韩|kr|korea|seoul)";

            url = "http://www.gstatic.com/generate_204";

            interval = 300;
            tolerance = 100;
          }

          {
            name = "美国";
            type = "url-test";

            include-all = true;
            "exclude-type" = "direct";

            filter = "(?i)(美国|美|us|usa|united.?states|america|los.?angeles|san.?jose)";

            url = "http://www.gstatic.com/generate_204";

            interval = 300;
            tolerance = 100;
          }

          {
            name = "新加坡";
            type = "url-test";

            include-all = true;
            "exclude-type" = "direct";

            filter = "(?i)(新加坡|新|sg|singapore)";

            url = "http://www.gstatic.com/generate_204";

            interval = 300;
            tolerance = 100;
          }

          # --------------------------------------------------
          # Services
          # --------------------------------------------------

          {
            name = "AI";
            type = "select";

            proxies = [
              "美国"
              "日本"
              "新加坡"
              "韩国"
              "节点选择"
              "故障转移"
            ];
          }

          {
            name = "媒体";
            type = "select";

            proxies = [
              "节点选择"
              "香港"
              "台湾"
              "日本"
              "美国"
              "新加坡"
            ];
          }

          {
            name = "通讯";
            type = "select";

            proxies = [
              "节点选择"
              "故障转移"
              "香港"
              "日本"
              "美国"
              "新加坡"
            ];
          }

          {
            name = "游戏";
            type = "select";

            proxies = [
              "节点选择"
              "故障转移"
              "香港"
              "台湾"
              "日本"
              "美国"
              "新加坡"
              "DIRECT"
            ];
          }

          {
            name = "GitHub";
            type = "select";

            proxies = [
              "节点选择"
              "故障转移"
              "香港"
              "台湾"
              "日本"
              "美国"
              "新加坡"
              "DIRECT"
            ];
          }

          {
            name = "Microsoft";
            type = "select";

            proxies = [
              "节点选择"
              "香港"
              "台湾"
              "日本"
              "美国"
              "新加坡"
              "DIRECT"
            ];
          }

          {
            name = "Apple";
            type = "select";

            proxies = [
              "节点选择"
              "香港"
              "台湾"
              "日本"
              "美国"
              "新加坡"
              "DIRECT"
            ];
          }

          # --------------------------------------------------
          # Special
          # --------------------------------------------------

          {
            name = "广告";
            type = "select";

            proxies = [
              "REJECT"
              "DIRECT"
            ];
          }

          {
            name = "隐私";
            type = "select";

            proxies = [
              "REJECT"
              "DIRECT"
            ];
          }

          {
            name = "AdBlock";
            type = "select";

            proxies = [
              "REJECT"
              "DIRECT"
            ];
          }

          {
            name = "直连";
            type = "select";

            proxies = [
              "DIRECT"
              "节点选择"
            ];
          }

          {
            name = "漏网";
            type = "select";

            proxies = [
              "节点选择"
              "直连"
              "自动选择"
              "故障转移"
            ];
          }
        ];

        # ======================================================
        # Rule Providers
        # ======================================================

        "rule-providers" = {

          # Private
          private_domain = mrsDomain "private_domain" "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/private.mrs";

          private_ip = mrsIP "private_ip" "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/private.mrs";

          # CN
          cn_domain = mrsDomain "cn_domain" "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/cn.mrs";

          cn_ip = mrsIP "cn_ip" "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geoip/cn.mrs";

          # Tracker
          tracker = mrsDomain "tracker" "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/tracker.mrs";

          # Ads
          reject = mrsDomain "reject" "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/category-ads-all.mrs";

          privacy = mrsDomain "privacy" "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/privacy.mrs";

          reject-extra = {
            type = "http";
            behavior = "domain";
            format = "mrs";
            path = "./ruleset/reject-extra.mrs";
            interval = 86400;

            url = "https://github.com/MiHomoer/MiHomo-Hagezi/raw/release/HageziUltimate.mrs";
          };

          # AI
          ai = mrsDomain "ai" "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/category-ai-!cn.mrs";

          ai-extra = aiExtra;

          # Media
          streaming = mrsDomain "streaming" "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/gflow.mrs";

          netflix_domain = mrsDomain "netflix_domain" "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/netflix.mrs";

          youtube_domain = mrsDomain "youtube_domain" "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/youtube.mrs";

          # Communication
          telegram_domain = mrsDomain "telegram_domain" "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/telegram.mrs";

          twitter_domain = mrsDomain "twitter_domain" "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/twitter.mrs";

          # Google
          google_domain = mrsDomain "google_domain" "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/google.mrs";

          # GitHub
          github_domain = mrsDomain "github_domain" "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/github.mrs";

          # Microsoft
          microsoft_domain = mrsDomain "microsoft_domain" "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/microsoft.mrs";

          # Apple
          apple_domain = mrsDomain "apple_domain" "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/apple.mrs";

          # Games
          games_domain = mrsDomain "games_domain" "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/category-games.mrs";
        };

        # ======================================================
        # Rules
        # ======================================================

        rules =
          directRules
          ++ proxyRules
          ++ [

            # Tracker
            "RULE-SET,tracker,DIRECT,no-resolve"

            # Ads
            "RULE-SET,reject,广告,no-resolve"
            "RULE-SET,privacy,隐私,no-resolve"
            "RULE-SET,reject-extra,AdBlock,no-resolve"

            # AI
            "RULE-SET,ai,AI,no-resolve"
            "RULE-SET,ai-extra,AI,no-resolve"

            # Media
            "RULE-SET,streaming,媒体,no-resolve"
            "RULE-SET,netflix_domain,媒体,no-resolve"
            "RULE-SET,youtube_domain,媒体,no-resolve"

            # Communication
            "RULE-SET,telegram_domain,通讯,no-resolve"
            "RULE-SET,twitter_domain,通讯,no-resolve"

            # Google
            "RULE-SET,google_domain,节点选择,no-resolve"

            # Microsoft
            "RULE-SET,microsoft_domain,Microsoft,no-resolve"

            # Apple
            "RULE-SET,apple_domain,Apple,no-resolve"

            # GitHub
            "RULE-SET,github_domain,GitHub,no-resolve"

            # Games
            "RULE-SET,games_domain,游戏,no-resolve"

            # Private
            "RULE-SET,private_domain,DIRECT,no-resolve"
            "RULE-SET,private_ip,DIRECT,no-resolve"

            # CN
            "RULE-SET,cn_domain,DIRECT,no-resolve"
            "RULE-SET,cn_ip,DIRECT,no-resolve"

            # Telegram IP
            "GEOIP,telegram,通讯,no-resolve"

            # Japan IP
            "GEOIP,JP,PROXY,no-resolve"

            # Final
            "MATCH,漏网"
          ];
      }
    );
  };
}
