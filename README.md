# Windscribe Record Cleaner

[English](#english) | [فارسی](#فارسی)

---

## English

Removes the local Windscribe account record from the Windows registry, with automatic backup.

### Usage

1. Close Windscribe completely (tray icon, then **Exit**).
2. Run `Windscribe-Record-Cleaner.bat`.
3. Press any key and wait for `Record deleted.`

Keep the `.bat` and `.ps1` files in the same folder.

### Backup

A `.reg` backup is saved to the `backups` folder before deletion. To restore it, double-click the file.

### Options

| Option | Description |
|--------|-------------|
| `-KillClient` | Close Windscribe automatically |
| `-NoBackup` | Skip the backup |
| `-BackupDir <path>` | Custom backup folder |

### Note

This only affects the local record on your computer. It does not change anything on Windscribe's servers.

---

## فارسی

رکورد محلی حساب Windscribe را از رجیستری ویندوز پاک می‌کند، همراه با بکاپ خودکار.

### طرز استفاده

1. برنامه Windscribe را کامل ببندید (آیکون کنار ساعت، سپس **Exit**).
2. فایل `Windscribe-Record-Cleaner.bat` را اجرا کنید.
3. یک کلید بزنید و منتظر پیام `Record deleted.` بمانید.

فایل‌های `.bat` و `.ps1` باید کنار هم در یک پوشه باشند.

### بکاپ

قبل از حذف، بکاپ `.reg` در پوشه `backups` ذخیره می‌شود. برای برگرداندن، فایل را دابل‌کلیک کنید.

### گزینه‌ها

| گزینه | توضیح |
|-------|-------|
| `-KillClient` | بستن خودکار Windscribe |
| `-NoBackup` | بدون بکاپ |
| `-BackupDir <path>` | مسیر دلخواه برای بکاپ |

### نکته

این ابزار فقط رکورد محلی روی کامپیوتر شما را پاک می‌کند و چیزی را روی سرورهای Windscribe تغییر نمی‌دهد.
