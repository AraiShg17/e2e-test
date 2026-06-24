# e2e-test

**Next.js (App Router) + Playwright** の E2E テストと、**テスト失敗時に Claude が自動でアプリを修正して PR を更新する** CI のサンプルです。

「ボタンを押すとモーダルが開く」という単純なアプリを題材に、次の一連を実演します：

```
壊れた PR を出す → CI で E2E 失敗 → Claude が自動修正 → PR が緑に戻る
```

## 技術スタック

- **Next.js 15 (App Router) + React 19 + TypeScript**
- **CSS Modules**（Tailwind は使わない / `@layer` + デザイントークン + `light-dark()`）
- **Playwright**（Chromium）で E2E
- CI は **GitHub Actions + `anthropics/claude-code-action@v1`**

## ディレクトリ構成

`app/` は URL 境界に徹し、画面実装は `features/` に置く方針（`.claude/skills/frontend-directory` 準拠）。

| パス | 役割 |
| --- | --- |
| `app/layout.tsx` / `app/page.tsx` | ルート・メタデータ。`page.tsx` は feature を呼ぶだけ（Server Component） |
| `features/modal-demo/ModalDemo.tsx` | ボタン → `<dialog>` をモーダル表示（`'use client'` は末端のみ） |
| `features/modal-demo/ModalDemo.module.css` | CSS Modules + BEM のスタイル |
| `styles/globals.css` | `@layer` とデザイントークン |
| `tests/modal.spec.ts` | クリック→モーダル表示を検証する E2E |
| `.github/workflows/e2e.yml` | PR で E2E 実行 → **失敗したら Claude が自動修正** |
| `.claude/skills/` | フロントエンド実装規約（Claude が参照） |

## ローカルで動かす

```bash
npm install
npx playwright install chromium

# テスト実行（Playwright が next dev を自動起動）
npm run test:e2e

# UI モード（タイムラインを見ながら）
npm run test:e2e:ui

# 実際にブラウザを表示して目視
npm run test:e2e -- --headed

# アプリを目視確認
npm run dev   # → http://localhost:3000
```

### 失敗の「証拠」を見る

Playwright は実際の Chromium を起動して操作・検証しています。失敗時には以下が `test-results/` と HTML レポートに残ります（`playwright.config.ts` で設定）。

| 証拠 | 設定 | 中身 |
| --- | --- | --- |
| スクリーンショット | `screenshot: only-on-failure` | 失敗の瞬間の PNG |
| 録画 | `video: retain-on-failure` | 操作の様子の webm |
| トレース | `trace: retain-on-failure` | 操作ごとのDOM・スクショ・ネットワーク・コンソールを時系列再生 |

```bash
# HTML レポート（合否＋各証拠へのリンク）を開く
npx playwright show-report

# トレースを再生（巻き戻して各操作の見た目を確認できる）
npx playwright show-trace test-results/**/trace.zip
```

CI ではこれらを `playwright-report` artifact にまとめて保存し、結果サマリを PR にコメントします。
さらに**失敗時の録画は GIF に変換して PR コメントに直接埋め込む**ので、ダウンロードせずにコメント上でそのまま再生して確認できます（GIF は `e2e-evidence` ブランチにホスト。GitHub はコメント内の `<video>` を許可しないため GIF を使用）。

## CI（PR 時に自動実行）

`.github/workflows/e2e.yml` は PR の作成・更新時に動きます。

1. **`e2e` ジョブ**: `npm ci` → Playwright で E2E 実行。**失敗時はスクリーンショット・録画(webm)・トレースを証拠として保存**し、結果サマリを PR にコメントします。
2. **`auto-fix` ジョブ**: `e2e` が **失敗したときだけ** 起動。
   `anthropics/claude-code-action@v1` が PR の head ブランチ上で
   - `npm run test:e2e` を実行して失敗原因を特定
   - `features/` のアプリコードを修正（テストは編集しない）
   - 全テストが緑になるまで繰り返し、修正コミットを PR に push

   Claude はアクション内でテストを実行して**自分で緑を確認してから**コミットします。

### セットアップ（自動修正を有効にする）

`auto-fix` ジョブには Anthropic API キーが必要です。リポジトリの Secret に登録してください：

```bash
gh secret set ANTHROPIC_API_KEY
# プロンプトに API キーを貼り付け
```

> Secret 未設定の間は `auto-fix` ジョブのみ失敗します（`e2e` ジョブは問題なく動きます）。

### 補足: CI の自動再実行について

`auto-fix` が push する際の `GITHUB_TOKEN` では、GitHub の仕様上 **新しいコミットで CI が再トリガーされません**（無限ループ防止）。
そのため Claude はアクション内でテストを実行して修正を自己検証しています。
push 後に E2E を自動で再実行して緑を可視化したい場合は、`GITHUB_TOKEN` の代わりに PAT（Personal Access Token）を使って checkout / push してください。

## 自動修正デモ（`demo/break-modal`）

`demo/break-modal` ブランチには **わざとモーダルが開かない壊れた状態** が入っています。
このブランチで PR を作ると、上記の auto-fix ループがそのまま再現できます。

```bash
git fetch origin
git switch demo/break-modal
gh pr create --base main --head demo/break-modal \
  --title "demo: モーダルが開かないバグ（自動修正のデモ）" \
  --body "E2E が失敗し、Claude が自動修正することを確認するための PR"
```

PR の Actions タブで `e2e` が失敗 →（Secret 設定済みなら）`auto-fix` が走り、修正コミットが PR に追加されます。
