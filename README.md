# Codex Chat Sync

這個資料夾用來把本機 Codex 聊天紀錄匯出成 Markdown，並用 GitHub private repository 在多台電腦之間同步。

建議 GitHub repository 一定要設為 private，因為聊天紀錄可能包含本機路徑、專案內容、指令輸出或個人資料。

## 目前這台電腦

第一次連到 GitHub：

```powershell
git remote add origin https://github.com/YOUR_NAME/YOUR_REPO.git
git branch -M main
git push -u origin main
```

日後同步：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\sync-codex-sessions.ps1
```

## 學校另一台電腦

在學校電腦上安裝 Git，登入 GitHub，然後 clone 同一個 private repo：

```powershell
cd "$env:USERPROFILE\Documents"
git clone https://github.com/YOUR_NAME/YOUR_REPO.git 同步計畫
cd .\同步計畫
powershell -ExecutionPolicy Bypass -File .\scripts\sync-codex-sessions.ps1
```

之後兩台電腦都用同一個指令同步：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\sync-codex-sessions.ps1
```

## 檔案說明

- `conversations/`：匯出的 Codex session Markdown
- `conversations/index.md`：所有 session 的索引
- `scripts/export-codex-sessions.ps1`：只匯出，不提交
- `scripts/sync-codex-sessions.ps1`：先 pull，再匯出、commit、push

預設只匯出 user / assistant 對話。若你真的想把工具呼叫與底層事件也輸出：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\export-codex-sessions.ps1 -IncludeTools
```
