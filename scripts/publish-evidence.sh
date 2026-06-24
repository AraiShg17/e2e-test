#!/usr/bin/env bash
# 失敗テストの録画(video.webm)を GIF に変換し、専用ブランチ e2e-evidence に
# push して raw URL を得る。PR コメント用の Markdown を evidence-gifs.md に書き出す。
# GitHub のコメントは <video> を許可しないが、GIF は画像として埋め込め、その場で再生される。
set -euo pipefail

: "${GITHUB_TOKEN:?}" "${GITHUB_REPOSITORY:?}" "${GITHUB_RUN_ID:?}" "${PR_NUMBER:?}"
EVID_BRANCH="e2e-evidence"
OUT_MD="evidence-gifs.md"
rm -f "$OUT_MD"

shopt -s nullglob

# 失敗テストの録画を収集（-retryN ディレクトリは重複なので除外し、テストごとに1本）
videos=()
for d in test-results/*/; do
  base="$(basename "$d")"
  case "$base" in *-retry*) continue ;; esac
  [ -f "${d}video.webm" ] && videos+=("${d}video.webm")
done

if [ "${#videos[@]}" -eq 0 ]; then
  echo "No failure videos found; nothing to publish."
  exit 0
fi

command -v ffmpeg >/dev/null 2>&1 || { sudo apt-get update -y && sudo apt-get install -y ffmpeg; }

WORK="$(mktemp -d)"
gifnames=()
labels=()
i=0
for v in "${videos[@]}"; do
  i=$((i + 1))
  base="$(basename "$(dirname "$v")")"
  label="${base#modal-}"
  label="${label%-chromium}"
  gif="evidence-${i}.gif"
  # palettegen/paletteuse で見やすい GIF に。長すぎる録画は先頭8秒に制限。
  ffmpeg -y -t 8 -i "$v" \
    -vf "fps=10,scale=640:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
    "${WORK}/${gif}" </dev/null
  gifnames+=("$gif")
  labels+=("$label")
done

# e2e-evidence ブランチへ push（無ければ orphan で新規作成）
EVID_DIR="$(mktemp -d)"
REPO_URL="https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
if ! git clone --depth 1 --branch "$EVID_BRANCH" "$REPO_URL" "$EVID_DIR" 2>/dev/null; then
  git clone --depth 1 "$REPO_URL" "$EVID_DIR"
  git -C "$EVID_DIR" checkout --orphan "$EVID_BRANCH"
  git -C "$EVID_DIR" rm -rf . >/dev/null 2>&1 || true
fi

DEST="${EVID_DIR}/pr-${PR_NUMBER}/run-${GITHUB_RUN_ID}"
mkdir -p "$DEST"
cp "${WORK}"/*.gif "$DEST"/

git -C "$EVID_DIR" config user.name "github-actions[bot]"
git -C "$EVID_DIR" config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git -C "$EVID_DIR" add -A
git -C "$EVID_DIR" commit -m "evidence: PR #${PR_NUMBER} run ${GITHUB_RUN_ID}" >/dev/null
git -C "$EVID_DIR" push origin "$EVID_BRANCH"

# PR コメント用 Markdown を生成
{
  echo "**失敗時の録画 (GIF・クリック不要で再生)**"
  echo
  for idx in "${!gifnames[@]}"; do
    url="https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/${EVID_BRANCH}/pr-${PR_NUMBER}/run-${GITHUB_RUN_ID}/${gifnames[$idx]}"
    echo "![${labels[$idx]}](${url})"
    echo
  done
} >"$OUT_MD"

echo "Wrote ${OUT_MD} with ${#gifnames[@]} GIF(s)."
