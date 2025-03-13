#!/usr/bin/env bash

# 默认输出格式为 png
output_format="png"
resize=""

# 解析参数，支持 -f 选项指定格式，-s 选项指定尺寸
while [[ $# -gt 0 ]]; do
  case "$1" in
  -f)
    output_format="$2"
    shift 2
    ;;
  -s)
    resize="$2"
    shift 2
    ;;
  *)
    input_image="$1"
    shift
    ;;
  esac
done

# 检查是否传入了图片路径
if [ -z "$input_image" ]; then
  echo "Usage: mkimage <image_path> [-f format] [-s widthxheight]"
  exit 1
fi

# 检查文件是否是有效的图片
if ! file --mime-type "$input_image" | grep -q image/; then
  echo "$input_image is not a valid image file."
  exit 1
fi

# 提取文件名并替换扩展名
filename=$(basename "$input_image")
extension="${filename##*.}"
output_filename="${filename%.*}.$output_format"

# 如果有指定尺寸，使用 -resize 参数进行缩放
if [ -n "$resize" ]; then
  magick "$input_image" -resize "$resize"\! "$output_filename"
else
  magick "$input_image" "$output_filename"
fi

echo "Converted $input_image to $output_filename"
