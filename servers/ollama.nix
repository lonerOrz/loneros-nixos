{
  pkgs,
  username,
  ...
}:
let
  host = "0.0.0.0";
  port = 11434;
in
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    host = host;
    port = port;
    # environmentVariables = {
    #   OLLAMA_NUM_PARALLEL = 2;
    # };
    loadModels = [ "qwen2.5-coder:7b" ];
    syncModels = true;
    models = "/var/lib/ollama/models";
  };

  environment.variables.OLLAMA_HOST = "${host}:${toString port}";
}
