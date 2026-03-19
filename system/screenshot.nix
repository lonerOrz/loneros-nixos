{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    # grimblast # grim + slurp
    grim # 截图
    slurp # 选择
    swappy # 截图注释
    satty # Screenshot Annotation
    tesseract # OCR engine
  ];
}
