# 學校電腦同步設定

這份文件是在學校另一台已安裝 Codex 的電腦上使用。

## 1. 安裝 Git

如果還沒有 Git，先安裝：

https://git-scm.com/download/win

安裝完成後開 PowerShell，確認：

```powershell
git --version
```

## 2. 登入 GitHub

最簡單的方式是用瀏覽器先登入 GitHub，clone 或 push 時依照 Git 的提示登入。

如果學校電腦有安裝 GitHub CLI，也可以：

```powershell
gh auth login
```

## 3. 下載同步資料夾

把 `YOUR_NAME/YOUR_REPO` 換成你的 GitHub private repo：

```powershell
cd "$env:USERPROFILE\Documents"
git clone https://github.com/YOUR_NAME/YOUR_REPO.git 同步計畫
cd .\同步計畫
```

## 4. 同步 Codex 聊天紀錄

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\sync-codex-sessions.ps1
```

這個指令會做四件事：

1. 先從 GitHub 拉下最新內容。
2. 從學校電腦的 `~\.codex\sessions` 匯出聊天紀錄。
3. 有變更就自動 commit。
4. 推回 GitHub。

## 5. 平常使用習慣

在家裡電腦和學校電腦，每次開始或結束 Codex 工作時跑一次：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\sync-codex-sessions.ps1
```

如果兩台電腦同時修改同一份匯出檔，Git 可能會要求處理衝突。通常只要先在其中一台跑同步，再到另一台跑同步，就能避免。
