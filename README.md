<div align="center">

<img src="https://i.postimg.cc/bJ1N511k/file-00000000652c82108b4c170e410ab2f2.png" alt="VNDXS HUB" width="600"/>

# VNDXS HUB

**The most powerful open-source Roblox script hub**  
*Built with precision. Designed with identity.*

[![Version](https://img.shields.io/badge/Version-1.0.0-blueviolet?style=for-the-badge&logo=github)](https://github.com/sd-community1/VNDXS-HUB)
[![Games](https://img.shields.io/badge/Games-3_Supported-ff69b4?style=for-the-badge)](https://github.com/sd-community1/VNDXS-HUB)
[![License](https://img.shields.io/badge/License-MIT-9cf?style=for-the-badge)](LICENSE.md)
[![Discord](https://img.shields.io/badge/Discord-Join_Us-5865F2?style=for-the-badge&logo=discord)](https://dsc.gg/vndxshub)

</div>

---

## ⚡ Quick Start

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/sd-community1/VNDXS-HUB/refs/heads/main/Loader.luau"))()
```

> Paste in your executor and run — the hub auto-detects your game.

---

## 🎮 Supported Games

<table>
<tr>
<td align="center" width="33%">

### 🚪 DOORS
Auto Farm · Entity ESP  
Item Notifier · Death Farm  
Remove Surge · Lobby Support

</td>
<td align="center" width="33%">

### 🍈 Blox Fruits
Auto Level (3 Seas)  
Kill Aura · Full ESP  
Teleport · Server Hop  
Auto Raid · Redeem Codes

</td>
<td align="center" width="33%">

### 🎯 One Shot
Aimbot · Silent Aim  
Full ESP · Triggerbot  
No Recoil · Prediction  
Off-Screen Arrows

</td>
</tr>
</table>

---

## 🔫 One Shot — Feature Breakdown

<details>
<summary><b>ESP System</b></summary>

| Feature | Description |
|---|---|
| **Boxes** | Corner-style boxes around players, color-coded by visibility |
| **Tracers** | Lines from screen edge to enemy position |
| **Skeleton** | Full bone structure overlay |
| **Info Overlay** | Name · Health Bar · Distance · Current Weapon |
| **Tactical Threat ESP** | 🔴 High / 🟠 Medium / 🔵 Normal — auto color by danger level |
| **Off-Screen Arrows** | Edge arrows pointing to enemies outside your FOV, color changes by distance |
| **Projectile ESP** | Tracks grenades and throwables with warning indicators |

</details>

<details>
<summary><b>Aimbot</b></summary>

| Feature | Description |
|---|---|
| **Aimbot** | Camera locks to target via `hookmetamethod` — fully functional |
| **FOV Circle** | Adjustable field-of-view circle on screen |
| **Smoothness** | Controls transition speed to avoid sudden snaps |
| **Target Part** | Choose Head / UpperTorso / HumanoidRootPart |
| **Visibility Check** | Only aims at targets not behind walls |
| **Dynamic FOV** | Auto-widens at close range, narrows at long range |

</details>

<details>
<summary><b>Silent Aim & Weapons</b></summary>

| Feature | Description |
|---|---|
| **Silent Aim** | Redirects bullet trajectory to target without moving camera |
| **Triggerbot** | Auto-fires when crosshair overlaps an enemy |
| **No Recoil** | Compensates vertical recoil in real-time |
| **No Spread** | Eliminates bullet spread for pinpoint accuracy |

</details>

<details>
<summary><b>Predictive Aiming</b></summary>

| Feature | Description |
|---|---|
| **Prediction** | Calculates enemy velocity + bullet travel time for lead shots |
| **Bullet Speed** | Adjustable from 50 to 2000 studs/s to match any weapon |

</details>

---

## 🍈 Blox Fruits — Feature Breakdown

<details>
<summary><b>Auto Farm</b></summary>

| Feature | Description |
|---|---|
| **Auto Level** | Automatically farms the right mob for your current level |
| **3 Sea Support** | First Sea · Second Sea · Third Sea — fully mapped |
| **Kill Aura** | Attacks nearby enemies automatically |
| **Auto Quest** | Accepts and completes quests without manual input |
| **Weapon Select** | Choose Melee / Sword / Blox Fruit |
| **Attack Speed** | Normal / Fast / Super Fast |

</details>

<details>
<summary><b>Utility</b></summary>

| Feature | Description |
|---|---|
| **Teleport** | One-click teleport to any island per sea |
| **Server Hop** | Auto-hops to a new server on command or timer |
| **Auto Raid** | Enters and completes raids automatically |
| **Redeem Codes** | Redeems all known active codes instantly |
| **Anti AFK** | Prevents idle kick |
| **Anti Ban** | Removes detection scripts from the game |
| **Max Stats** | Instantly allocates all stat points |

</details>

---

## 🎨 Theme

<div align="center">

| Element | Color | Preview |
|---|---|---|
| **Text** | `#FFD700` | 🟡 Yellow / Gold |
| **Accent** | `#1E90FF` | 🔵 Dodger Blue |
| **Background** | `#050A1A` | ⬛ Deep Dark |
| **Main** | `#0A0F2E` | 🔷 Dark Blue |
| **Outline** | `#1E3A8A` | 🔹 Mid Blue |

> Theme is **locked** — preserving the VNDXS identity across all games.

</div>

---

## 📁 Project Structure

```
VNDXS-HUB/
│
├── Loader.luau                   ← Entry point — auto-detects game
│
├── Components/
│   ├── Environment.luau          ← Executor capability testing
│   ├── Interface.luau            ← UI library loader + forced theme
│   ├── InfoTab.luau              ← Info tab (player info, changelog)
│   ├── SettingsTab.luau          ← Settings (theme locked, privacy)
│   ├── CreditsTab.luau           ← Credits tab with logo + rating
│   ├── Analytics.luau            ← Opt-in only analytics
│   └── AdonisBypass.luau         ← Adonis admin bypass (on-demand)
│
├── Games/
│   ├── Doors/
│   │   ├── Loader.luau
│   │   ├── Main.luau             ← Full DOORS features
│   │   └── Lobby.luau
│   ├── BloxFruits/
│   │   ├── Loader.luau
│   │   └── Main.luau             ← Full BF features (3 seas)
│   ├── OneShot/
│   │   ├── Loader.luau
│   │   └── Main.luau             ← Combat features
│   └── Universal/
│       ├── Loader.luau
│       └── Main.luau             ← General mode for other games
│
└── Scripts/
    └── DeathFarm.luau            ← DOORS death farm standalone
```

---

## 🛡️ Privacy & Safety

- ✅ **Analytics are opt-in** — disabled by default, enable from Settings → Privacy
- ✅ **No IP collection** — only username, executor name, game name, and execution count
- ✅ **No HWID tracking** — ever
- ✅ **Anti Ban** built-in for Blox Fruits
- ✅ **Open source** — every line of code is visible and auditable

---

## 👑 Credits

<div align="center">

| Role | Name |
|---|---|
| **Developer** | VNDXS |
| **UI Library** | Obsidian by deividcomsono |
| **Base Reference** | Abysall Hub by FireBacon (bocaj111004) |
| **BF Reference** | W_Skinny |

<br/>

[![Discord](https://img.shields.io/badge/Join_the_Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://dsc.gg/vndxshub)

*VNDXS HUB — Built different.* 🔵🟡

</div>
