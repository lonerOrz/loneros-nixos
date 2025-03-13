#!/usr/bin/env bash

# 检查是否提供了两个文件路径
if [ $# -lt 2 ]; then
  echo "Usage: vmerge <video_file> <audio_or_video_file> [output_file]"
  exit 1
fi

# 获取输入的两个文件路径
file1="$1"
file2="$2"

# 如果没有指定输出文件名，则使用第一个文件的名称，并加上 "_merged"
output_file="${3:-$(basename "$file1" .mp4)_merged.mp4}"

# 获取第一个文件（假定为视频文件）的时长
duration1=$(ffprobe -i "$file1" -show_entries format=duration -v quiet -of csv="p=0")
# 获取第二个文件的时长
duration2=$(ffprobe -i "$file2" -show_entries format=duration -v quiet -of csv="p=0")

# 设置允许的最大时长差异（单位：秒）
max_diff=1

# 计算时长差异
diff=$(echo "$duration1 - $duration2" | bc)

# 检查时长差异是否在允许范围内
if [ $(echo "$diff <= $max_diff && $diff >= -$max_diff" | bc) -ne 1 ]; then
  echo "Error: The duration difference ($diff seconds) exceeds the allowed range ($max_diff seconds)!"
  exit 1
fi

# 判断第二个文件是视频还是音频
codec_type=$(ffprobe -i "$file2" -show_streams -select_streams a -v quiet -of csv="p=0" -show_entries stream=codec_type)

if [ "$codec_type" == "audio" ]; then
  echo "Detected that the second file is audio, merging video and audio..."
  ffmpeg -i "$file1" -i "$file2" -c:v copy -c:a copy -map 0:v:0 -map 1:a:0 "$output_file"
else
  echo "Detected that the second file is video, merging two videos..."
  ffmpeg -i "$file1" -i "$file2" -filter_complex "[0:v:0][1:v:0]concat=n=2:v=1:a=0[outv]" -map "[outv]" "$output_file"
fi

echo "Merge complete: $output_file"
