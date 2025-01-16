{
  username,
  ...
}:
{
  services.ollama = {
    enable = true;
    #user = "${username}";
    host = "127.0.0.1";
    port = 11434;
    #home = "/home/${username}/ollama"; # default /var/lib/ollama
    #models = "/home/${username}/ollama/modules"; # default ${home}/models
    acceleration = "cuda"; # or "rocm"
  };
}
