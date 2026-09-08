# VNDXS HUB v1.0.0

A Roblox script hub with a signature **Blue & Yellow** theme. Currently supports **DOORS**.

## Quick Start

```lua
https://raw.githubusercontent.com/sd-community1/VNDXS-HUB/refs/heads/main/Loader.luau```

> استبدل `YOUR_USERNAME` باسم حسابك على GitHub

## Theme Colors

| Element    | Color   | Hex       |
|------------|---------|-----------|
| Text       | Yellow  | `#FFD700` |
| Accent     | Blue    | `#1E90FF` |
| Background | Dark    | `#050A1A` |
| Main       | Dark Blue| `#0A0F2E` |
| Outline    | Blue    | `#1E3A8A` |

الثيم **مقفول** — لا يمكن للمستخدم تغييره.

## Project Structure

```
VNDXS-HUB/
├── Loader.luau                  ← Entry point (غيّر YOUR_USERNAME)
├── Components/
│   ├── Environment.luau         ← Executor function testing
│   ├── ESP.luau                 ← ESP library
│   ├── Interface.luau           ← UI loader + forced theme
│   ├── InfoTab.luau             ← Info tab
│   ├── SettingsTab.luau         ← Settings (theme locked)
│   ├── Analytics.luau           ← Opt-in analytics
│   └── AdonisBypass.luau        ← Adonis bypass
├── Games/
│   ├── Doors/
│   │   ├── Loader.luau
│   │   ├── Main.luau            ← Theme applied here
│   │   └── Lobby.luau
│   └── Universal/
└── Scripts/
    └── DeathFarm.luau
```

## Setup on GitHub

1. أنشئ repo جديد باسم `VNDXS-HUB`
2. ارفع جميع الملفات
3. في **Loader.luau** و **Scripts/DeathFarm.luau** — استبدل `YOUR_USERNAME` باسمك
4. تأكد أن الـ repo **Public**
5. استخدم الرابط:
```
https://raw.githubusercontent.com/YOUR_USERNAME/VNDXS-HUB/refs/heads/main/Loader.luau
```

## Credits

Based on Abysall Hub by FireBacon — Modified & rebranded as VNDXS HUB  
License: MIT
