{ config
, stable
, ...
}:
{
  environment.systemPackages = with stable; [
    # lm_sensors
    lenovo-legion
  ];
}
