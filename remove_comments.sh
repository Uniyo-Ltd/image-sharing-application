#!/bin/bash
find . -name "*.dart" | grep -v "\.g\.dart$" | while read file; do echo "Processing $file"; tmp_file=$(mktemp); perl -0777 -pe "s|/\*.*?\*/||gs" "$file" > "$tmp_file"; perl -pe "s|//.*$||g" "$tmp_file" > "$file"; rm "$tmp_file"; done; echo "Comment removal complete"
