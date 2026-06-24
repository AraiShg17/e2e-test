#!/usr/bin/env bash
# 代表テスト「ボタンを押すとモーダルが開く」の録画(video.webm)を GIF 1本に変換し、
# 専用ブランチ e2e-evidence に push して raw URL を出力する。
# GitHub のコメントは <video> を許可しないが、GIF は画像として埋め込め、その場で再生される。
#
# 環境変数:
#   GIF_NAME  出力ファイル名（例: failure.gif / success.gif）。既定 evidence.gif
#   URL_OUT   生成した GIF の raw URL を書き出すファイル。既定 evidence-gif-url.txt
set -euo pipefail

: "${GITHUB_TOKEN:?}" "${GITHUB_REPOSITORY:?}" "${GITHUB_RUN_ID:?}" "${PR_NUMBER:?}"
GIF_NAME="${GIF_NAME:-evidence.gif}"
URL_OUT="${URL_OUT:-evidence-gif-url.txt}"
EVID_BRANCH="e2e-evidence"
rm -f "$URL_OUT"

shopt -s nullglob

# 代表テストの録画を1本だけ選ぶ（-retryN は除外）。見つからなければ最初の動画。
pick=""
for d in test-results/*/; do
  base="$(basename "$d")"
  case "$base" in *-retry*) continue ;; esac
  [ -f "${d}video.webm" ] || continue
  if [[ "$base" == *"ボタンを押すとモーダルが開く"* ]]; then
    pick="${d}video.webm"
    break
  fi
  [ -z "$pick" ] && pick="${d}video.webm"
done

if [ -z "$pick" ]; then
  echo "No video found; skipping evidence publish."
  exit 0
fi
echo "Selected video: $pick"

command -v ffmpeg >/dev/null 2>&1 || { sudo apt-get update -y && sudo apt-get install -y ffmpeg; }

WORK="$(mktemp -d)"
ffmpeg -y -t 8 -i "$pick" \
  -vf "fps=10,scale=640:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
  "${WORK}/${GIF_NAME}" </dev/null

# e2e-evidence ブランチへ push（無ければ orphan で新規作成）。並行 push に備えリトライ。
EVID_DIR="$(mktemp -d)"
REPO_URL="https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
publish() {
  rm -rf "$EVID_DIR" && mkdir -p "$EVID_DIR"
  if ! git clone --depth 1 --branch "$EVID_BRANCH" "$REPO_URL" "$EVID_DIR" 2>/dev/null; then
    git clone --depth 1 "$REPO_URL" "$EVID_DIR"
    git -C "$EVID_DIR" checkout --orphan "$EVID_BRANCH"
    git -C "$EVID_DIR" rm -rf . >/dev/null 2>&1 || true
  fi
  local dest="${EVID_DIR}/pr-${PR_NUMBER}/run-${GITHUB_RUN_ID}"
  mkdir -p "$dest"
  cp "${WORK}/${GIF_NAME}" "$dest/"
  git -C "$EVID_DIR" config user.name "github-actions[bot]"
  git -C "$EVID_DIR" config user.email "41898282+github-actions[bot]@users.noreply.github.com"
  git -C "$EVID_DIR" add -A
  git -C "$EVID_DIR" commit -m "evidence: PR #${PR_NUMBER} run ${GITHUB_RUN_ID} ${GIF_NAME}" >/dev/null
  git -C "$EVID_DIR" push origin "$EVID_BRANCH"
}
for attempt in 1 2 3; do
  if publish; then break; fi
  echo "push retry ${attempt}..."
  sleep 3
done

URL="https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/${EVID_BRANCH}/pr-${PR_NUMBER}/run-${GITHUB_RUN_ID}/${GIF_NAME}"
echo "$URL" | tee "$URL_OUT"
