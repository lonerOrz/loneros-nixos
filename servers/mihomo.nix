{
  lib,
  pkgs,
  config,
  username,
  ...
}:
let
  proxy-port = "7890";
  ui-port = "9090";
in
{
  environment.systemPackages = with pkgs; [
    sparkle-wrapper
  ];

  security.wrappers.sparkle = {
    owner = "root";
    group = "root";
    capabilities = "cap_net_bind_service,cap_net_raw,cap_net_admin=+ep";
    source = "${lib.getExe pkgs.sparkle}";
  };

  services.mihomo = {
    enable = true;
    package = pkgs.mihomo;
    configFile = config.sops.templates."mihomo.yaml".path;
    webui = pkgs.metacubexd; # clash-dashboard yacd metacubexd
    tunMode = true;
    extraOpts = "-m";
  };

  networking.proxy.default = lib.mkIf (
    config.services.mihomo.enable && !config.services.mihomo.tunMode
  ) "http://127.0.0.1:${proxy-port}";

  sops.templates."mihomo.yaml" = {
    owner = "root";
    mode = "0600";
    content = builtins.readFile (
      (pkgs.formats.yaml { }).generate "mihomo-raw.yaml" {
        #------------------------基础配置------------------------#
        "mixed-port" = lib.toInt proxy-port; # 端口
        "geodata-mode" = true;
        "geo-auto-update" = true;
        "geo-update-interval" = 24;
        "geox-url" = {
          geosite = "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geosite.dat";
          geoip = "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geoip.dat";
          mmdb = "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/country.mmdb";
          asn = "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/GeoLite2-ASN.mmdb";
        };
        "tcp-concurrent" = true;
        "unified-delay" = true;
        "allow-lan" = true;
        "bind-address" = "*";
        "find-process-mode" = "strict";
        ipv6 = true;
        mode = "rule";
        "log-level" = "info";

        # 外部控制设置
        "external-controller" = "0.0.0.0:${ui-port}";
        secret = config.sops.placeholder."mihomo/secret";

        #------------------------性能调优------------------------#
        "tcp-concurrent-users" = 64;
        "keep-alive-interval" = 15;
        "inbound-tfo" = true;
        "outbound-tfo" = true;
        "connection-pool-size" = 256;
        "idle-timeout" = 60;

        #------------------------TUN 配置------------------------#
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

        #------------------------DNS 配置------------------------#
        dns = {
          enable = true;
          "prefer-h3" = true;
          ipv6 = false;
          listen = "127.0.0.1:1053";
          "enhanced-mode" = "fake-ip";
          "use-hosts" = true;

          "default-nameserver" = [
            "223.5.5.5"
            "119.29.29.29"
          ];

          "nameserver-policy" = {
            "geosite:cn" = "https://dns.alidns.com/dns-query";
            "geosite:google" = "https://dns.google/dns-query";
            "geosite:github" = "https://dns.google/dns-query";
            "geosite:telegram" = "https://cloudflare-dns.com/dns-query";
            "geosite:twitter" = "https://cloudflare-dns.com/dns-query";
            "geosite:netflix" = "https://cloudflare-dns.com/dns-query";
            "geosite:youtube" = "https://dns.google/dns-query";
          };

          "fake-ip-range" = "198.18.0.1/16";
          "fake-ip-filter" = [
            "*.lan"
            "localhost.ptlogin2.qq.com"
            "+.m2m"
            "injections.adguard.org"
            "local.adguard.org"
            "+.bogon"
            "+.local"
            "+.internal"
            "+.localdomain"
            "home.arpa"
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
            "https://doh.pub/dns-query#h3=true"
            "https://dns.alidns.com/dns-query#h3=true"
            "tls://223.5.5.5:853"
            "8.8.8.8"
            "1.1.1.1"
            "https://dns.google/dns-query#h3=true"
            "https://cloudflare-dns.com/dns-query#h3=true"
            "quic://dns.adguard.com:784"
          ];

          fallback = [
            "8.8.8.8"
            "1.1.1.1"
            "https://dns.google/dns-query#h3=true"
            "https://1.1.1.1/dns-query#h3=true"
            "tls://8.8.8.8:853"
          ];

          "fallback-filter" = {
            geoip = true;
            "geoip-code" = "CN";
            ipcidr = [ "240.0.0.0/4" ];
          };
        };

        # 代理提供商配置
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
          };
        };

        # 代理分组
        "proxy-groups" = [
          #------------------------基础分组------------------------#
          {
            name = "PROXY";
            type = "select";
            proxies = [ "🚀 节点选择" ];
          }
          {
            name = "🚀 节点选择";
            type = "select";
            proxies = [
              "♻️ 自动选择"
              "🔯 故障转移"
              "🔮 负载均衡"
              "🇭🇰 香港节点"
              "🇲🇴 澳门节点"
              "🇨🇳 台湾节点"
              "🇯🇵 日本节点"
              "🇰🇷 韩国节点"
              "🇺🇲 美国节点"
              "🇬🇧 英国节点"
              "🇩🇪 德国节点"
              "🇫🇷 法国节点"
              "🇮🇳 印度节点"
              "🇸🇬 狮城节点"
              "🇮🇩 印尼节点"
              "🇻🇳 越南节点"
              "🇹🇭 泰国节点"
              "🇦🇺 澳洲节点"
              "🇧🇷 巴西节点"
              "🌍 其他节点"
              "DIRECT"
            ];
          }
          {
            name = "♻️ 自动选择";
            type = "url-test";
            "include-all-providers" = true;
            url = "http://www.gstatic.com/generate_204";
            interval = 300;
            tolerance = 100;
          }
          {
            name = "🔯 故障转移";
            type = "fallback";
            "include-all-providers" = true;
            url = "http://www.gstatic.com/generate_204";
            interval = 300;
          }
          {
            name = "🔮 负载均衡";
            type = "load-balance";
            strategy = "consistent-hashing";
            "include-all-providers" = true;
            url = "http://www.gstatic.com/generate_204";
            interval = 300;
          }
          #------------------------地区分组------------------------#
          {
            name = "🇭🇰 香港节点";
            type = "url-test";
            "include-all-providers" = true;
            filter = "(?i)港|hk|hongkong|hong kong";
            url = "http://www.gstatic.com/generate_204";
            interval = 300;
            tolerance = 100;
          }
          {
            name = "🇲🇴 澳门节点";
            type = "url-test";
            "include-all-providers" = true;
            filter = "(?i)澳门|门|mo|macao";
            url = "http://www.gstatic.com/generate_204";
            interval = 300;
            tolerance = 100;
          }
          {
            name = "🇨🇳 台湾节点";
            type = "url-test";
            "include-all-providers" = true;
            filter = "(?i)台|tw|taiwan|taipei";
            url = "http://www.gstatic.com/generate_204";
            interval = 300;
            tolerance = 100;
          }
          {
            name = "🇯🇵 日本节点";
            type = "url-test";
            "include-all-providers" = true;
            filter = "(?i)日本|jp|japan|tokyo|osaka";
            url = "http://www.gstatic.com/generate_204";
            interval = 300;
            tolerance = 100;
          }
          {
            name = "🇰🇷 韩国节点";
            type = "url-test";
            "include-all-providers" = true;
            filter = "(?i)韩|kr|korea|seoul";
            url = "http://www.gstatic.com/generate_204";
            interval = 300;
            tolerance = 100;
          }
          {
            name = "🇺🇲 美国节点";
            type = "url-test";
            "include-all-providers" = true;
            filter = "(?i)美|us|united states|america|los angeles|san jose|silicon valley";
            url = "http://www.gstatic.com/generate_204";
            interval = 300;
            tolerance = 100;
          }
          {
            name = "🇬🇧 英国节点";
            type = "url-test";
            "include-all-providers" = true;
            filter = "(?i)英|uk|united kingdom|london";
            url = "http://www.gstatic.com/generate_204";
            interval = 300;
            tolerance = 100;
          }
          {
            name = "🇩🇪 德国节点";
            type = "url-test";
            "include-all-providers" = true;
            filter = "(?i)德|de|germany|frankfurt";
            url = "http://www.gstatic.com/generate_204";
            interval = 300;
            tolerance = 100;
          }
          {
            name = "🇫🇷 法国节点";
            type = "url-test";
            "include-all-providers" = true;
            filter = "(?i)法|fr|france|paris";
            url = "http://www.gstatic.com/generate_204";
            interval = 300;
            tolerance = 100;
          }
          {
            name = "🇮🇳 印度节点";
            type = "url-test";
            "include-all-providers" = true;
            filter = "(?i)印度|in|india|mumbai";
            url = "http://www.gstatic.com/generate_204";
            interval = 300;
            tolerance = 100;
          }
          {
            name = "🇸🇬 狮城节点";
            type = "url-test";
            "include-all-providers" = true;
            filter = "(?i)新|sg|singapore";
            url = "http://www.gstatic.com/generate_204";
            interval = 300;
            tolerance = 100;
          }
          {
            name = "🇮🇩 印尼节点";
            type = "url-test";
            "include-all-providers" = true;
            filter = "(?i)印尼|印度尼西亚|id|indonesia|jakarta";
            url = "http://www.gstatic.com/generate_204";
            interval = 300;
            tolerance = 100;
          }
          {
            name = "🇻🇳 越南节点";
            type = "url-test";
            "include-all-providers" = true;
            filter = "(?i)越南|vn|vietnam";
            url = "http://www.gstatic.com/generate_204";
            interval = 300;
            tolerance = 100;
          }
          {
            name = "🇹🇭 泰国节点";
            type = "url-test";
            "include-all-providers" = true;
            filter = "(?i)泰国|th|thailand|bangkok";
            url = "http://www.gstatic.com/generate_204";
            interval = 300;
            tolerance = 100;
          }
          {
            name = "🇦🇺 澳洲节点";
            type = "url-test";
            "include-all-providers" = true;
            filter = "(?i)澳大利亚|au|australia|sydney";
            url = "http://www.gstatic.com/generate_204";
            interval = 300;
            tolerance = 100;
          }
          {
            name = "🇧🇷 巴西节点";
            type = "url-test";
            "include-all-providers" = true;
            filter = "(?i)巴西|br|brazil";
            url = "http://www.gstatic.com/generate_204";
            interval = 300;
            tolerance = 100;
          }
          {
            name = "🌍 其他节点";
            type = "url-test";
            "include-all-providers" = true;
            filter = "(?i)^(?!.*(香港|台湾|日本|韩国|新加坡|美国|英国|德国|法国|印度|泰国|越南|印尼|澳大利亚|巴西|港|台|日|韩|新|美|英|德|法|印|泰|越|尼|澳|巴|hk|tw|jp|kr|sg|us|uk|de|fr|in|th|vn|id|au|br)).*";
            url = "http://www.gstatic.com/generate_204";
            interval = 300;
            tolerance = 100;
          }
          #------------------------场景分组------------------------#
          {
            name = "🎬 国外媒体";
            type = "select";
            proxies = [
              "🚀 节点选择"
              "🇭🇰 香港节点"
              "🇨🇳 台湾节点"
              "🇯🇵 日本节点"
              "🇺🇲 美国节点"
              "🇸🇬 狮城节点"
            ];
          }
          {
            name = "🎮 游戏平台";
            type = "select";
            proxies = [
              "🚀 节点选择"
              "🔯 故障转移"
              "🇭🇰 香港节点"
              "🇯🇵 日本节点"
              "🇺🇲 美国节点"
              "🇸🇬 狮城节点"
              "DIRECT"
            ];
          }
          {
            name = "📱 即时通讯";
            type = "select";
            proxies = [
              "🚀 节点选择"
              "🔯 故障转移"
              "🇭🇰 香港节点"
              "🇯🇵 日本节点"
              "🇺🇲 美国节点"
              "🇸🇬 狮城节点"
            ];
          }
          {
            name = "🤖 AI平台";
            type = "select";
            proxies = [
              "🇯🇵 日本节点"
              "🇺🇲 美国节点"
              "🇸🇬 狮城节点"
              "🇰🇷 韩国节点"
              "🚀 节点选择"
              "🔯 故障转移"
            ];
          }
          {
            name = "🔧 GitHub";
            type = "select";
            proxies = [
              "🚀 节点选择"
              "🔯 故障转移"
              "🇭🇰 香港节点"
              "🇨🇳 台湾节点"
              "🇯🇵 日本节点"
              "🇺🇲 美国节点"
              "🇸🇬 狮城节点"
              "DIRECT"
            ];
          }
          {
            name = "Ⓜ️ 微软服务";
            type = "select";
            proxies = [
              "🚀 节点选择"
              "🇭🇰 香港节点"
              "🇨🇳 台湾节点"
              "🇯🇵 日本节点"
              "🇺🇲 美国节点"
              "🇸🇬 狮城节点"
              "DIRECT"
            ];
          }
          {
            name = "🍎 苹果服务";
            type = "select";
            proxies = [
              "🚀 节点选择"
              "🇭🇰 香港节点"
              "🇨🇳 台湾节点"
              "🇯🇵 日本节点"
              "🇺🇲 美国节点"
              "🇸🇬 狮城节点"
              "DIRECT"
            ];
          }
          #------------------------特殊分组------------------------#
          {
            name = "🎯 全球直连";
            type = "select";
            proxies = [
              "DIRECT"
              "🚀 节点选择"
            ];
          }
          {
            name = "🛑 广告拦截";
            type = "select";
            proxies = [
              "REJECT"
              "DIRECT"
            ];
          }
          {
            name = "🍃 应用净化";
            type = "select";
            proxies = [
              "REJECT"
              "DIRECT"
            ];
          }
          {
            name = "🆎 AdBlock";
            type = "select";
            proxies = [
              "REJECT"
              "DIRECT"
            ];
          }
          {
            name = "🛡️ 隐私防护";
            type = "select";
            proxies = [
              "REJECT"
              "DIRECT"
            ];
          }
          {
            name = "🐟 漏网之鱼";
            type = "select";
            proxies = [
              "🚀 节点选择"
              "🎯 全球直连"
              "♻️ 自动选择"
              "🔯 故障转移"
            ];
          }
        ];

        # 规则提供商配置
        "rule-providers" = {
          reject = {
            type = "http";
            behavior = "domain";
            url = "https://testingcf.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/reject.txt";
            path = "./ruleset/reject.yaml";
            interval = 86400;
          };
          privacy = {
            type = "http";
            behavior = "domain";
            url = "https://testingcf.jsdelivr.net/gh/blackmatrix7/ios_rule_script/rule/Clash/Privacy/Privacy.yaml";
            path = "./ruleset/privacy.yaml";
            interval = 86400;
          };
          "reject-extra" = {
            type = "http";
            behavior = "domain";
            url = "https://testingcf.jsdelivr.net/gh/blackmatrix7/ios_rule_script/rule/Clash/AdvertisingLite/AdvertisingLite.yaml";
            path = "./ruleset/reject-extra.yaml";
            interval = 86400;
          };
          "ai-platforms" = {
            type = "http";
            behavior = "classical";
            url = "https://testingcf.jsdelivr.net/gh/blackmatrix7/ios_rule_script/rule/Clash/OpenAI/OpenAI.yaml";
            path = "./ruleset/ai-platforms.yaml";
            interval = 86400;
          };
          streaming = {
            type = "http";
            behavior = "classical";
            url = "https://testingcf.jsdelivr.net/gh/blackmatrix7/ios_rule_script/rule/Clash/GlobalMedia/GlobalMedia.yaml";
            path = "./ruleset/streaming.yaml";
            interval = 86400;
          };
          social = {
            type = "http";
            behavior = "classical";
            url = "https://testingcf.jsdelivr.net/gh/blackmatrix7/ios_rule_script/rule/Clash/Telegram/Telegram.yaml";
            path = "./ruleset/social.yaml";
            interval = 86400;
          };
          microsoft = {
            type = "http";
            behavior = "classical";
            url = "https://testingcf.jsdelivr.net/gh/blackmatrix7/ios_rule_script/rule/Clash/Microsoft/Microsoft.yaml";
            path = "./ruleset/microsoft.yaml";
            interval = 86400;
          };
          apple = {
            type = "http";
            behavior = "classical";
            url = "https://testingcf.jsdelivr.net/gh/blackmatrix7/ios_rule_script/rule/Clash/Apple/Apple.yaml";
            path = "./ruleset/apple.yaml";
            interval = 86400;
          };
          games = {
            type = "http";
            behavior = "classical";
            url = "https://testingcf.jsdelivr.net/gh/blackmatrix7/ios_rule_script/rule/Clash/Game/Game.yaml";
            path = "./ruleset/games.yaml";
            interval = 86400;
          };
          "dev-platforms" = {
            type = "http";
            behavior = "classical";
            url = "https://testingcf.jsdelivr.net/gh/blackmatrix7/ios_rule_script/rule/Clash/GitHub/GitHub.yaml";
            path = "./ruleset/dev-platforms.yaml";
            interval = 86400;
          };
        };

        # 规则配置
        rules = [
          "RULE-SET,reject,🛑 广告拦截,no-resolve"
          "RULE-SET,privacy,🛡️ 隐私防护,no-resolve"
          "RULE-SET,reject-extra,🆎 AdBlock,no-resolve"

          "DOMAIN-SUFFIX,local,DIRECT"
          "DOMAIN-SUFFIX,localhost,DIRECT"
          "IP-CIDR,127.0.0.0/8,DIRECT"
          "IP-CIDR,172.16.0.0/12,DIRECT"
          "IP-CIDR,192.168.0.0/16,DIRECT"
          "IP-CIDR,10.0.0.0/8,DIRECT"
          "IP-CIDR,17.0.0.0/8,DIRECT"
          "IP-CIDR,100.64.0.0/10,DIRECT"
          "IP-CIDR,224.0.0.0/4,DIRECT"
          "IP-CIDR6,fe80::/10,DIRECT"

          "RULE-SET,ai-platforms,🤖 AI平台,no-resolve"
          "RULE-SET,streaming,🎬 国外媒体,no-resolve"
          "RULE-SET,social,📱 即时通讯,no-resolve"
          "RULE-SET,microsoft,Ⓜ️ 微软服务,no-resolve"
          "RULE-SET,apple,🍎 苹果服务,no-resolve"
          "RULE-SET,games,🎮 游戏平台,no-resolve"
          "RULE-SET,dev-platforms,🔧 GitHub,no-resolve"

          "PROCESS-NAME,clash,DIRECT"
          "PROCESS-NAME,v2ray,DIRECT"
          "PROCESS-NAME,xray,DIRECT"
          "PROCESS-NAME,naive,DIRECT"
          "PROCESS-NAME,trojan,DIRECT"
          "PROCESS-NAME,trojan-go,DIRECT"
          "PROCESS-NAME,ss-local,DIRECT"
          "PROCESS-NAME,privoxy,DIRECT"
          "PROCESS-NAME,leaf,DIRECT"
          "PROCESS-NAME,Thunder,DIRECT"
          "PROCESS-NAME,DownloadService,DIRECT"
          "PROCESS-NAME-REGEX,.*qbittorrent.*,DIRECT"
          "PROCESS-NAME,.qbittorrent-wr,DIRECT"
          "PROCESS-NAME,Transmission,DIRECT"
          "PROCESS-NAME,fdm,DIRECT"
          "PROCESS-NAME,aria2c,DIRECT"
          "PROCESS-NAME,Folx,DIRECT"
          "PROCESS-NAME,NetTransport,DIRECT"
          "PROCESS-NAME,uTorrent,DIRECT"
          "PROCESS-NAME,WebTorrent,DIRECT"
          "PROCESS-NAME,motrix,DIRECT"
          "PROCESS-NAME,clash-verge,DIRECT"

          "GEOIP,LAN,DIRECT,no-resolve"
          "GEOIP,CN,DIRECT,no-resolve"

          "GEOIP,private,DIRECT,no-resolve"
          "GEOIP,telegram,PROXY"
          "GEOIP,JP,PROXY"
          "GEOIP,CN,DIRECT"
          "DST-PORT,80/8080/443/8443,PROXY"

          "DOMAIN-SUFFIX,bz.tc,DIRECT"
          "DOMAIN-SUFFIX,tracker.opentrackr.org,DIRECT"
          "DOMAIN-SUFFIX,nyaa.si,DIRECT"
          "DOMAIN-SUFFIX,tracker.torrent.to,DIRECT"

          "MATCH,🚀 节点选择"
        ];
      }
    );
  };
}
