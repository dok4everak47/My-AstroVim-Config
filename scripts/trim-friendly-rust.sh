#!/bin/bash
# 删除 friendly-snippets rust.json 中与自定义 snippets 重复的项
# 用法: Lazy update 还原后跑一次: bash ~/.config/nvim/scripts/trim-friendly-rust.sh
FILE="$HOME/.local/share/nvim/lazy/friendly-snippets/snippets/rust/rust.json"
if [ ! -f "$FILE" ]; then
  echo "找不到 friendly-snippets rust.json: $FILE"
  exit 1
fi
python3 - "$FILE" <<'PY'
import json, sys
p = sys.argv[1]
d = json.load(open(p))
for k in ['if', 'for', 'while', 'match', 'struct', 'enum']:
    if k in d:
        del d[k]
        print('deleted:', k)
json.dump(d, open(p, 'w'), indent=2, ensure_ascii=False)
print('remaining keys:', len(d))
PY
