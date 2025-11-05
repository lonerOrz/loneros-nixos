{
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
    host = host;
    port = port;
    acceleration = "cuda"; # or "rocm"
    environmentVariables = {
      OLLAMA_LLM_LIBRARY = "gpu";
    };
    # loadModels = [ "llama3" ]; # cli pull
  };

  environment.variables.OLLAMA_HOST = "${host}:${toString port}";
}
