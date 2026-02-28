#!/bin/bash
# post-ai-news.sh — fetch AI news and push a new Jekyll post
# Runs daily at 2 AM via OpenClaw cron

set -e

REPO_DIR="/home/openclaw/.openclaw/workspace/ai-news-blog"
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

cd "$REPO_DIR"

# Pull latest changes
git pull --rebase origin main 2>&1 || true

# Fetch top AI stories from HN (filter AI-related)
echo "Fetching HN stories..."
HN_RAW=$(curl -s "https://hacker-news.firebaseio.com/v0/topstories.json" | tr ',' '\n' | head -50)

AI_STORIES=""
COUNT=0

for ID in $HN_RAW; do
  [ "$COUNT" -ge 5 ] && break
  ID=$(echo "$ID" | tr -d '[]" ')
  [ -z "$ID" ] && continue

  STORY=$(curl -s "https://hacker-news.firebaseio.com/v0/item/$ID.json")
  TITLE=$(echo "$STORY" | grep -o '"title":"[^"]*"' | head -1 | sed 's/"title":"//;s/"//')
  URL=$(echo "$STORY" | grep -o '"url":"[^"]*"' | head -1 | sed 's/"url":"//;s/"//')
  SCORE=$(echo "$STORY" | grep -o '"score":[0-9]*' | head -1 | sed 's/"score"://')

  # Filter for AI-relevant keywords
  if echo "$TITLE" | grep -qi -E "AI|LLM|GPT|Claude|Gemini|model|neural|machine.learning|deep.learning|OpenAI|Anthropic|agent|inference|benchmark|quantiz"; then
    AI_STORIES="$AI_STORIES\n- **[$TITLE]($URL)** (score: $SCORE)"
    COUNT=$((COUNT + 1))
  fi
done

# Fallback: grab recent AI news from lobste.rs
if [ "$COUNT" -lt 2 ]; then
  echo "Supplementing with lobste.rs..."
  LOBSTERS=$(curl -s "https://lobste.rs/t/ai.json" 2>/dev/null | grep -o '"title":"[^"]*"\|"url":"[^"]*"' | paste - - | head -5)
  while IFS= read -r LINE; do
    TITLE=$(echo "$LINE" | grep -o '"title":"[^"]*"' | sed 's/"title":"//;s/"//')
    URL=$(echo "$LINE" | grep -o '"url":"[^"]*"' | sed 's/"url":"//;s/"//')
    [ -n "$TITLE" ] && AI_STORIES="$AI_STORIES\n- **[$TITLE]($URL)**"
  done <<< "$LOBSTERS"
fi

# Generate the post file
POST_FILE="$REPO_DIR/_posts/${DATE}-ai-news-digest.md"

cat > "$POST_FILE" << MDEOF
---
layout: post
title: "AI News Digest — ${DATE}"
date: ${DATE}
categories: [daily-digest]
tags: [ai, news, digest]
excerpt: "Today's top AI stories from across the web."
---

*Auto-generated daily digest — ${TIMESTAMP} UTC*

## Top AI Stories Today

$(echo -e "$AI_STORIES")

---

*Sources: Hacker News, Lobste.rs. Posts are auto-curated based on relevance to AI/ML.*
MDEOF

echo "Post written: $POST_FILE"

# Commit and push
git add "_posts/${DATE}-ai-news-digest.md"
git commit -m "Daily AI news digest: ${DATE}" 2>&1
git push origin main 2>&1

echo "Done. Post pushed for ${DATE}."
