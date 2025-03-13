#!/usr/bin/env bash

# 检查是否提供了输入视频路径
if [ $# -ne 1 ]; then
  echo "Usage: v2g <video_path>"
  exit 1
fi

# 获取输入的视频路径
video_path="$1"

# 获取视频的信息
video_info=$(ffmpeg -i "$video_path" 2>&1)

# 提取帧率 (fps) 和分辨率 (resolution)
fps=$(echo "$video_info" | grep -oP "(\d+(\.\d+)?) fps" | head -n 1 | awk '{print $1}')
resolution=$(echo "$video_info" | grep -oP "\d{2,4}x\d{2,4}" | head -n 1)

# 检查是否成功获取到 fps 和 resolution
if [ -z "$fps" ] || [ -z "$resolution" ]; then
  echo "Error: Could not extract frame rate or resolution from the video."
  exit 1
fi

# 输出日志
echo "Video info:"
echo "  FPS: $fps"
echo "  Resolution: $resolution"

# 获取文件名并去除扩展名
base_name=$(basename "$video_path" .mp4)
output_gif="$base_name.gif"

# 检查输出文件是否已经存在，避免覆盖
counter=1
while [ -f "$output_gif" ]; do
  output_gif="${base_name}($counter).gif"
  counter=$((counter + 1))
done

# 使用 ffmpeg 转换视频为 GIF
ffmpeg -hwaccel cuda -i "$video_path" -vf "fps=$fps,scale=$resolution:flags=lanczos" -c:v gif "$output_gif"
if [ $? -ne 0 ]; then
  echo "Error: Failed to convert video to GIF."
  exit 1
fi

# 输出转换结果
echo "GIF saved to $output_gif"
