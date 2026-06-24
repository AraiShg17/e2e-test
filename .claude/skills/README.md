# Claude Code / Cursor Agent Skills

各サブフォルダをスキルとしてコピーします。

```bash
# Claude Code: 個人（推奨）
mkdir -p ~/.claude/skills
cp -R frontend-directory ~/.claude/skills/
cp -R frontend-html-css ~/.claude/skills/
cp -R frontend-native-ui ~/.claude/skills/
cp -R frontend-scroll-css ~/.claude/skills/
cp -R frontend-a11y-security ~/.claude/skills/
cp -R frontend-forms ~/.claude/skills/
cp -R frontend-interactions ~/.claude/skills/
cp -R frontend-next-data ~/.claude/skills/
cp -R frontend-performance ~/.claude/skills/
cp -R frontend-testing ~/.claude/skills/

# Claude Code: プロジェクト共有
mkdir -p /path/to/project/.claude/skills
cp -R frontend-* /path/to/project/.claude/skills/

# Cursor: プロジェクト共有
mkdir -p /path/to/project/.cursor/skills
cp -R frontend-* /path/to/project/.cursor/skills/
```

## スキル一覧

| フォルダ | いつ使うか |
|----------|------------|
| `frontend-directory` | 新規コンポーネント・フォルダ構成・Hooks/API の配置 |
| `frontend-html-css` | HTML マークアップ、CSS Modules、デザイントークン |
| `frontend-native-ui` | Dialog、Popover、View Transitions、Anchor |
| `frontend-scroll-css` | Scroll-driven animations、scroll-state、CSS-only carousel、reading-flow |
| `frontend-a11y-security` | a11y 監査、環境変数、DOM セキュリティ |
| `frontend-forms` | Chrome 先行フォーム、autofill、`:user-valid`、`field-sizing` |
| `frontend-interactions` | 楽観的 UI、debounce/throttle、rollback、二重送信防止 |
| `frontend-next-data` | Next.js fetch cache、Server Actions、revalidation |
| `frontend-performance` | INP、Long Tasks、`scheduler.postTask()`、`content-visibility`、`next/image` |
| `frontend-testing` | Vitest + Testing Library、getByRole、userEvent、fetch mock |

各スキルは `disable-model-invocation: true` です。使うときはエージェントへ明示的に指示してください。

エージェントへの指示例: 「`frontend-native-ui` スキルに従ってメニューを実装して」
