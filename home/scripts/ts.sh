#!/usr/bin/env bash

# 输入文本
text="$*"

# 如果没有提供文本，提示用户
if [ -z "$text" ]; then
  echo "请输入要翻译的文本。"
  exit 1
fi

# 提取目标语言（如果有的话）
target_lang=""
if [[ "$text" =~ -t\ ([a-zA-Z\-]+) ]]; then
  target_lang="${BASH_REMATCH[1]}"
  text="${text//-t $target_lang/}" # 从文本中移除目标语言参数
fi

# 使用trans工具检测语言
detected_lang=$(echo "$text" | trans -b -identify | tr -d '\n')

# 检查是否成功检测到语言
if [ -z "$detected_lang" ]; then
  echo "无法检测到语言，检查文本内容是否有效。"
  exit 1
fi

# 输出检测到的语言
# echo "检测到语言: $detected_lang"

# 如果没有指定目标语言，默认为中文
if [ -z "$target_lang" ]; then
  target_lang="zh"
fi

# 根据检测到的语言进行翻译
case "$detected_lang" in
en)
  echo "$text" | trans -b ":$target_lang"
  ;;
zh-CN)
  echo "$text" | trans -b ":en"
  ;;
ja)
  echo "$text" | trans -b ":$target_lang"
  ;;
fr)
  echo "$text" | trans -b ":$target_lang"
  ;;
ko)
  echo "$text" | trans -b ":$target_lang"
  ;;
*)
  echo "检测到的语言 ($detected_lang) 未特别处理，默认翻译成英文："
  echo "$text" | trans -b ":en"
  ;;
esac
