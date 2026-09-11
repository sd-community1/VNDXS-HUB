<div align="center">

<img src="https://i.postimg.cc/bJ1N511k/file-00000000652c82108b4c170e410ab2f2.png" alt="VNDXS HUB" width="680"/>

<br/>

<img src="https://img.shields.io/badge/Version-1.0.0-blueviolet?style=for-the-badge&logo=github&logoColor=white"/>
<img src="https://img.shields.io/badge/Games-3_Supported-9b59b6?style=for-the-badge&logo=roblox&logoColor=white"/>
<img src="https://img.shields.io/badge/License-MIT-blue?style=for-the-badge"/>
<img src="https://img.shields.io/badge/Open_Source-100%25-success?style=for-the-badge&logo=opensourceinitiative&logoColor=white"/>

<br/><br/>

[![Discord](https://img.shields.io/badge/Join_Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://dsc.gg/vndxshub)

<br/>

> **Auto-detects your game. One script. Three worlds.**

</div>

---

## <img src="https://api.iconify.design/lucide:terminal.svg?color=%231E90FF&width=22&height=22" valign="middle"/> Quick Start

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/sd-community1/VNDXS-HUB/refs/heads/main/Loader.luau"))()
```

> Paste in your executor — the hub detects your game and loads the right interface instantly.

---

## <img src="https://api.iconify.design/lucide:scale.svg?color=%231E90FF&width=22&height=22" valign="middle"/> Open Source License

VNDXS HUB is **100% open source** — every line of code is readable, forkable, and available for learning.

**Permitted:**
- Study, learn, and build from this codebase
- Fork and modify for personal or public use
- Redistribute with proper credit

**Required:**
- You **must** credit **VNDXS HUB** and its developer **VNDXS** in any derivative work
- You **must** state clearly that your project was derived from VNDXS HUB — not that you built it independently

> *The correct statement is: "This project was built upon VNDXS HUB by VNDXS."*  
> Claiming sole authorship of a fork is a violation of this license.

---

## <img src="https://api.iconify.design/lucide:gamepad-2.svg?color=%231E90FF&width=22&height=22" valign="middle"/> Supported Games

<br/>

<table>
<tr>

<td align="center" width="33%">
<img src="https://i.postimg.cc/XJPm9PrB/Doors.webp" width="210" style="border-radius:14px"/>
<br/><br/>

**DOORS**

<img src="https://api.iconify.design/lucide:check-circle.svg?color=%2322c55e&width=13"/> Auto Farm
<img src="https://api.iconify.design/lucide:check-circle.svg?color=%2322c55e&width=13"/> Entity ESP<br/>
<img src="https://api.iconify.design/lucide:check-circle.svg?color=%2322c55e&width=13"/> Death Farm
<img src="https://api.iconify.design/lucide:check-circle.svg?color=%2322c55e&width=13"/> Item Notifier<br/>
<img src="https://api.iconify.design/lucide:check-circle.svg?color=%2322c55e&width=13"/> Remove Surge
<img src="https://api.iconify.design/lucide:check-circle.svg?color=%2322c55e&width=13"/> Lobby Support

</td>

<td align="center" width="33%">
<img src="https://i.postimg.cc/xTNYpvYT/Polish-20260910-074803292.jpg" width="210" style="border-radius:14px"/>
<br/><br/>

**ONE SHOT**

<img src="https://api.iconify.design/lucide:check-circle.svg?color=%2322c55e&width=13"/> Aimbot · Silent Aim<br/>
<img src="https://api.iconify.design/lucide:check-circle.svg?color=%2322c55e&width=13"/> Full ESP · Triggerbot<br/>
<img src="https://api.iconify.design/lucide:check-circle.svg?color=%2322c55e&width=13"/> No Recoil · Prediction<br/>
<img src="https://api.iconify.design/lucide:check-circle.svg?color=%2322c55e&width=13"/> Off-Screen Arrows

</td>

<td align="center" width="33%">
<img src="https://i.postimg.cc/zB8HcSpQ/file-00000000fdb48243a9ba8bcbc9798f6f.png" width="210" style="border-radius:14px"/>
<br/><br/>

**BLADE BALL**

<img src="https://api.iconify.design/lucide:check-circle.svg?color=%2322c55e&width=13"/> Auto Parry (Ping-based)<br/>
<img src="https://api.iconify.design/lucide:check-circle.svg?color=%2322c55e&width=13"/> Clash Detection<br/>
<img src="https://api.iconify.design/lucide:check-circle.svg?color=%2322c55e&width=13"/> Emergency Radius<br/>
<img src="https://api.iconify.design/lucide:check-circle.svg?color=%2322c55e&width=13"/> Visual Circle Indicator

</td>

</tr>
</table>

---

## <img src="https://api.iconify.design/lucide:sword.svg?color=%231E90FF&width=22&height=22" valign="middle"/> Blade Ball — Full Feature List

<div align="center">
<img src="https://i.postimg.cc/zB8HcSpQ/file-00000000fdb48243a9ba8bcbc9798f6f.png" width="130" style="border-radius:12px"/>
</div>

<br/>

<details>
<summary><img src="https://api.iconify.design/lucide:shield.svg?color=%231E90FF&width=15"/> &nbsp;<b>Auto Parry System</b></summary>

<br/>

**How it works:**

```
1. Locates the ball in workspace.Balls
2. Checks if you are the current target (via Attribute or Highlight)
3. Calculates direction dot product — ignores balls moving away
4. Computes TimeToHit = Distance / Speed
5. Adds real-time ping compensation (configurable multiplier)
6. Applies 15% boost for hyper-speed balls (>150 studs/s)
7. Fires a virtual mouse click at the perfect frame
8. Switches to ultra-fast Clash mode when ball is within range
```

| Setting | Description |
|---|---|
| <img src="https://api.iconify.design/lucide:toggle-right.svg?color=%231E90FF&width=13"/> **Auto Parry** | Main toggle — also bindable to `L` key |
| <img src="https://api.iconify.design/lucide:wifi.svg?color=%231E90FF&width=13"/> **Ping Compensation** | Adjusts threshold by your real-time ping |
| <img src="https://api.iconify.design/lucide:sliders.svg?color=%231E90FF&width=13"/> **Ping Offset** | Multiplier for how aggressively ping is factored |
| <img src="https://api.iconify.design/lucide:clock.svg?color=%231E90FF&width=13"/> **Parry Threshold** | How early to parry (in milliseconds) |
| <img src="https://api.iconify.design/lucide:zap.svg?color=%23ef4444&width=13"/> **Clash Mode** | Ultra-fast click when ball is critically close |
| <img src="https://api.iconify.design/lucide:alert-circle.svg?color=%23f59e0b&width=13"/> **Emergency Radius** | Force parry regardless of timing if ball is too close |

</details>

<details>
<summary><img src="https://api.iconify.design/lucide:eye.svg?color=%231E90FF&width=15"/> &nbsp;<b>Visuals</b></summary>

<br/>

| State | Color | Meaning |
|---|---|---|
| <img src="https://api.iconify.design/lucide:circle.svg?color=%231E90FF&width=13"/> Neutral | Blue | Ball is nearby but not targeting you |
| <img src="https://api.iconify.design/lucide:circle.svg?color=%2300FFFF&width=13"/> Targeted | Cyan | Ball is heading toward you |
| <img src="https://api.iconify.design/lucide:circle.svg?color=%23FF0000&width=13"/> Clash | Red | Ball is in Clash range — critical |

The circle scales dynamically with ball distance and pulses every other frame for performance.

**Live Stats Panel** updates every second:
- Current ping in ms
- Ball distance in studs
- Whether you are targeted
- Auto Parry on/off status

</details>

---

## <img src="https://api.iconify.design/lucide:crosshair.svg?color=%231E90FF&width=22&height=22" valign="middle"/> One Shot — Full Feature List

<div align="center">
<img src="https://i.postimg.cc/xTNYpvYT/Polish-20260910-074803292.jpg" width="130" style="border-radius:12px"/>
</div>

<br/>

<details>
<summary><img src="https://api.iconify.design/lucide:eye.svg?color=%231E90FF&width=15"/> &nbsp;<b>ESP System</b></summary>

<br/>

| Feature | Description |
|---|---|
| <img src="https://api.iconify.design/lucide:square-dashed.svg?color=%231E90FF&width=13"/> **Boxes** | Corner-style boxes, color-coded by visibility |
| <img src="https://api.iconify.design/lucide:move-diagonal.svg?color=%231E90FF&width=13"/> **Tracers** | Lines from screen bottom to enemy |
| <img src="https://api.iconify.design/lucide:person-standing.svg?color=%231E90FF&width=13"/> **Skeleton** | Full bone structure overlay |
| <img src="https://api.iconify.design/lucide:info.svg?color=%231E90FF&width=13"/> **Info Overlay** | Name · HP Bar · Distance · Weapon |
| <img src="https://api.iconify.design/lucide:alert-triangle.svg?color=%23f59e0b&width=13"/> **Tactical Threat** | Red = High / Orange = Medium / Blue = Normal |
| <img src="https://api.iconify.design/lucide:arrow-right.svg?color=%231E90FF&width=13"/> **Off-Screen Arrows** | Edge indicators, color changes by proximity |
| <img src="https://api.iconify.design/lucide:bomb.svg?color=%23ef4444&width=13"/> **Projectile ESP** | Tracks grenades with danger indicators |

</details>

<details>
<summary><img src="https://api.iconify.design/lucide:crosshair.svg?color=%231E90FF&width=15"/> &nbsp;<b>Aimbot</b></summary>

<br/>

| Feature | Description |
|---|---|
| <img src="https://api.iconify.design/lucide:target.svg?color=%231E90FF&width=13"/> **Aimbot** | Camera locks via `hookmetamethod` — real and functional |
| <img src="https://api.iconify.design/lucide:circle.svg?color=%231E90FF&width=13"/> **FOV Circle** | Visual adjustable field-of-view ring |
| <img src="https://api.iconify.design/lucide:sliders.svg?color=%231E90FF&width=13"/> **Smoothness** | Transition speed control |
| <img src="https://api.iconify.design/lucide:user.svg?color=%231E90FF&width=13"/> **Target Part** | Head / UpperTorso / HumanoidRootPart |
| <img src="https://api.iconify.design/lucide:wall.svg?color=%231E90FF&width=13"/> **Visibility Check** | Ignores wall-blocked targets |
| <img src="https://api.iconify.design/lucide:maximize-2.svg?color=%231E90FF&width=13"/> **Dynamic FOV** | Auto-scales with distance |

</details>

<details>
<summary><img src="https://api.iconify.design/lucide:zap.svg?color=%231E90FF&width=15"/> &nbsp;<b>Silent Aim & Weapons</b></summary>

<br/>

| Feature | Description |
|---|---|
| <img src="https://api.iconify.design/lucide:mouse-pointer-click.svg?color=%231E90FF&width=13"/> **Silent Aim** | Bullet redirect without camera movement |
| <img src="https://api.iconify.design/lucide:activity.svg?color=%231E90FF&width=13"/> **Triggerbot** | Auto-fires on crosshair contact |
| <img src="https://api.iconify.design/lucide:arrow-down.svg?color=%231E90FF&width=13"/> **No Recoil** | Real-time vertical compensation |
| <img src="https://api.iconify.design/lucide:dot.svg?color=%231E90FF&width=13"/> **No Spread** | Eliminates bullet spread |
| <img src="https://api.iconify.design/lucide:git-branch.svg?color=%231E90FF&width=13"/> **Prediction** | Leads moving targets using velocity + bullet speed |

</details>

---

## <img src="https://api.iconify.design/lucide:door-open.svg?color=%231E90FF&width=22&height=22" valign="middle"/> DOORS — Full Feature List

<div align="center">
<img src="https://i.postimg.cc/XJPm9PrB/Doors.webp" width="130" style="border-radius:12px"/>
</div>

<br/>

<details>
<summary><img src="https://api.iconify.design/lucide:list.svg?color=%231E90FF&width=15"/> &nbsp;<b>All Features</b></summary>

<br/>

| Feature | Description |
|---|---|
| <img src="https://api.iconify.design/lucide:bot.svg?color=%231E90FF&width=13"/> **Auto Farm** | Automates full hotel runs end to end |
| <img src="https://api.iconify.design/lucide:scan-eye.svg?color=%231E90FF&width=13"/> **Entity ESP** | Highlights entities through walls |
| <img src="https://api.iconify.design/lucide:package.svg?color=%231E90FF&width=13"/> **Item Notifier** | Alerts on important item spawns |
| <img src="https://api.iconify.design/lucide:skull.svg?color=%231E90FF&width=13"/> **Death Farm** | Automated death loop for XP and Knobs |
| <img src="https://api.iconify.design/lucide:zap-off.svg?color=%231E90FF&width=13"/> **Remove Surge** | Disables surge events entirely |
| <img src="https://api.iconify.design/lucide:door-open.svg?color=%231E90FF&width=13"/> **Lobby Support** | Full functionality in the DOORS lobby |

</details>

---

## <img src="https://api.iconify.design/lucide:palette.svg?color=%231E90FF&width=22&height=22" valign="middle"/> Theme

<div align="center">

| Element | Hex | Preview |
|---|---|---|
| **Text** | `#FFD700` | ![](https://img.shields.io/badge/-%23FFD700-FFD700?style=flat-square) |
| **Accent** | `#1E90FF` | ![](https://img.shields.io/badge/-%231E90FF-1E90FF?style=flat-square) |
| **Background** | `#050A1A` | ![](https://img.shields.io/badge/-%23050A1A-050A1A?style=flat-square) |
| **Main** | `#0A0F2E` | ![](https://img.shields.io/badge/-%230A0F2E-0A0F2E?style=flat-square) |
| **Outline** | `#1E3A8A` | ![](https://img.shields.io/badge/-%231E3A8A-1E3A8A?style=flat-square) |

> Theme is **permanently locked** — the VNDXS identity is preserved across all games and sessions.

</div>

---

## <img src="https://api.iconify.design/lucide:folder-tree.svg?color=%231E90FF&width=22&height=22" valign="middle"/> Project Structure

```
VNDXS-HUB/
│
├── Loader.luau                    ← Entry point — auto-detects game by PlaceId
│
├── Components/
│   ├── Environment.luau           ← Executor capability testing
│   ├── Interface.luau             ← UI library loader + forced theme
│   ├── InfoTab.luau               ← Player info tab
│   ├── SettingsTab.luau           ← Settings + Privacy (analytics opt-in)
│   ├── CreditsTab.luau            ← Credits tab with logo and rating
│   ├── Analytics.luau             ← Opt-in only — no IP, no HWID
│   └── AdonisBypass.luau          ← Adonis admin bypass (on-demand)
│
├── Games/
│   ├── Doors/                     ← DOORS — Hotel + Lobby
│   ├── OneShot/                   ← One Shot — Full combat suite
│   ├── BladeBall/                 ← Blade Ball — Ping-based auto parry
│   └── Universal/                 ← Fallback for unsupported games
│
└── Scripts/
    └── DeathFarm.luau             ← DOORS standalone death farm
```

---

## <img src="https://api.iconify.design/lucide:shield-check.svg?color=%231E90FF&width=22&height=22" valign="middle"/> Privacy & Safety

<img src="https://api.iconify.design/lucide:check.svg?color=%2322c55e&width=14"/> Analytics **disabled by default** — enable from Settings if you wish  
<img src="https://api.iconify.design/lucide:check.svg?color=%2322c55e&width=14"/> **Zero IP collection** — not stored, not sent, ever  
<img src="https://api.iconify.design/lucide:check.svg?color=%2322c55e&width=14"/> **Zero HWID tracking** — ever  
<img src="https://api.iconify.design/lucide:check.svg?color=%2322c55e&width=14"/> When enabled, only sends: username · executor name · game name · execution count  
<img src="https://api.iconify.design/lucide:check.svg?color=%2322c55e&width=14"/> Every line of code is **publicly auditable**  

---

## <img src="https://api.iconify.design/lucide:users.svg?color=%231E90FF&width=22&height=22" valign="middle"/> Credits

<div align="center">

| <img src="https://api.iconify.design/lucide:crown.svg?color=%23FFD700&width=15"/> Role | Name |
|---|---|
| **Developer** | VNDXS |
| **UI Library** | Obsidian — deividcomsono |
| **Base Reference** | Abysall Hub — FireBacon (bocaj111004) |
| **Blade Ball Reference** | Aeloe open-source script |

<br/>

<img src="https://i.postimg.cc/bJ1N511k/file-00000000652c82108b4c170e410ab2f2.png" width="320"/>

<br/><br/>

[![Discord](https://img.shields.io/badge/Join_the_Community-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://dsc.gg/vndxshub)

<br/>

*VNDXS HUB — Built different.*

</div>
