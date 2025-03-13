#!/usr/bin/env bash

# 检查是否传入了 URL 参数
if [ $# -eq 0 ]; then
  echo "Error: Please provide a YouTube URL."
  exit 1
fi

# 获取第一个参数作为视频 URL
url="$1"

# 获取视频标题
video_title=$(yt-dlp --get-title "$url")

# 设置保存路径
save_dir="$HOME/Videos/yt-dlp/$video_title"

# 创建保存目录
mkdir -p "$save_dir"

# 使用 yt-dlp 下载视频，并附加字幕
yt-dlp --write-auto-subs --sub-langs zh-Hans --convert-subs srt --output "$save_dir/%(title)s [%(id)s].%(ext)s" "$url"

# 检查下载是否成功
if [ $? -eq 0 ]; then
  echo "Download completed successfully!"
else
  echo "Error: Download failed."
fi
