# Codex Chat Sync

這個資料夾用來把本機 Codex 聊天紀錄匯出成 Markdown，並用 Git 同步到 GitHub。

## 使用方式

匯出目前本機所有 Codex 對話：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\export-codex-sessions.ps1
```

匯出後會產生：

- `conversations/`：每個 Codex session 的 Markdown 檔
- `conversations/index.md`：所有 session 的索引

提交到 Git：

```powershell
git add .
git commit -m "Sync Codex conversations"
```

第一次推到 GitHub 時，先在 GitHub 建一個 private repository，然後把 remote 加進來：

```powershell
git remote add origin https://github.com/YOUR_NAME/YOUR_REPO.git
git branch -M main
git push -u origin main
```

之後同步只要：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\sync-codex-sessions.ps1
```

## 隱私提醒

建議 GitHub repository 設成 private。Codex 對話可能包含本機路徑、專案內容、指令輸出、API 設定片段或個人資料。

預設匯出只包含 user / assistant 對話。若你真的想把工具呼叫與底層事件也輸出，可以加上：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\export-codex-sessions.ps1 -IncludeTools
```
