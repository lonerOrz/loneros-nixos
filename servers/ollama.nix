{
  pkgs,
  ...
}:
let
  host = "0.0.0.0";
  port = 11434;
in
{
  services.ollama = {
    inherit host port;
    enable = true;
    package = pkgs.ollama-cuda;
    loadModels = [ "qwen3:8b-q4_K_M" ];
    syncModels = true;
    models = "/var/lib/ollama/models";
    environmentVariables = {
      OLLAMA_NUM_PARALLEL = "1";
      OLLAMA_MAX_LOADED_MODELS = "1";
      OLLAMA_CONTEXT_LENGTH = "8192";
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_KV_CACHE_TYPE = "q8_0"; # KV缓存
      OLLAMA_GPU_OVERHEAD = "1073741824"; # 预留1GB防OOM
    };
  };

  environment.variables.OLLAMA_HOST = "${host}:${toString port}";
}
