# Codex 網頁版連 GitHub 設定

這份文件用來排查「網頁版 Codex / ChatGPT 一直連不上 GitHub repository」。

## 先完成本機 repo push

先讓這個同步專案推到 GitHub private repo：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\setup-github-repo.ps1
```

如果已經登入 GitHub CLI，這會自動建立 `codex-chat-sync` private repo，設定 remote，並 push。

## 在 ChatGPT / Codex 網頁版連 GitHub

1. 打開 ChatGPT。
2. 進入 Settings。
3. 找到 Connectors 或 Connected apps。
4. 選 GitHub。
5. 安裝並授權 ChatGPT GitHub connector。
6. 在 GitHub 的 repository access 頁面選取 `codex-chat-sync`。
7. 回到 Codex 網頁版，等待約 5 到 10 分鐘再重新整理。

## 如果 repo 還是找不到

GitHub 對新建立或 private repository 可能需要時間建立搜尋索引。到 GitHub 搜尋列輸入：

```text
repo:YOUR_NAME/codex-chat-sync import
```

把 `YOUR_NAME` 換成你的 GitHub 帳號。搜尋後等 5 到 10 分鐘，再回 Codex 網頁版重試。

## 常見原因

- GitHub connector 尚未授權 private repo。
- repo 是剛建立的，GitHub 搜尋索引還沒完成。
- 學校或組織 GitHub 管理員限制 OAuth app。
- ChatGPT 的 GitHub connector 只能讀 repo；要讓 Codex 產生、修改、push code，需要用 Codex 產品本身的 GitHub 連線。

參考：

- OpenAI Help Center: https://help.openai.com/en/articles/11145903
- OpenAI Help Center Codex setup: https://help.openai.com/en/articles/11390924-placeholder
