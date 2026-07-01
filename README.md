# 點餐助手

給店內員工使用的 Android 點餐與待出餐記錄工具，可離線使用。

## 下載

前往 [GitHub Releases](https://github.com/hPPPf7/staff-order-app/releases/latest) 下載
`staff-order-app.apk`。

Android 安裝時需要允許瀏覽器安裝未知來源應用程式。

## 更新

App 啟動及回到前景時會自動檢查 GitHub Releases。發現新版後會顯示下載更新通知，
使用者下載 APK 後依照 Android 畫面確認安裝。

推送 `v1.0.1` 格式的 Git 標籤後，GitHub Actions 會自動建置固定簽章的 APK 並建立
GitHub Release。

## 本機建置

```powershell
npm install
npm run android:apk
```

本機正式建置需要 `.tools/signing/release.jks` 與
`.tools/signing/password.txt`。
