{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.gimp3
  ]
  ++ (with pkgs.gimp3Plugins; [
    # G'MIC 图像处理框架插件（提供数百种滤镜和效果，非常强大）
    gmic

    # 批量图像处理插件（批量修改尺寸、颜色、格式等）
    bimp

    # 傅里叶变换插件（用于频域图像分析，可去除图像周期性纹理）
    fourier

    # 支持 Farbfeld 图像格式的插件
    # farbfeld

    # 纹理生成插件（从小图块自动生成无缝纹理，适合贴图和游戏开发）
    texturize

    # 内容感知缩放插件（智能缩放图像，保持主体结构，类似 Photoshop）
    lqrPlugin

    # 闪电特效插件（为图像添加真实闪电效果）
    lightning

    # 镜头畸变校正插件（修复桶形、枕形等摄影镜头畸变）
    gimplensfun

    # 内容识别填充插件（可智能填充缺失区域，非常实用）
    resynthesizer

    # 曝光融合插件（合成多张不同曝光的图像，适合 HDR 效果）
    exposureBlend

    # 小波锐化插件（通过小波变换锐化图像，增强细节而不产生噪点）
    waveletSharpen
  ]);
}
