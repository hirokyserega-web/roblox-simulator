# 🌙 Roblox Ghost Simulator — Mobile UI Specification

This document provides a highly detailed specification of the toy-like, vibrant, and fun mobile game user interface (UI) designed for the **Roblox Ghost Simulator**. It is tailored to replicate the layout, sharp text, and playful cartoonish style of the game, optimized for mobile screens.

---

## 🎨 Art Style & Aesthetic Guidelines

* **Theme:** "Toy-Like / Candy 3D" meets "Spooky Low-Poly". A delightful contrast of bright, glossy, neon elements overlaid on a dark, mysterious night cemetery.
* **Palette:**
  * **Cemetery Environment:** Deep navy blues, dark purples, forest greens, and bright lunar white/cream.
  * **UI Containers:** Chunky slate-gray/dark obsidian backgrounds with thick, high-contrast glossy borders.
  * **Buttons & Indicators:** Highly saturated neon colors—vibrant lime green (`#39FF14`), electric purple (`#BF00FF`), golden yellow (`#FFD700`), bright orange (`#FF6700`), and crimson red (`#FF007F`).
* **Styling:**
  * **Glossy Finishes:** Semi-transparent inner white highlights to simulate a 3D glass or plastic finish.
  * **Rounded Corners:** Extreme rounding (`UICorner` with radius of `12` to `24` pixels) to give a friendly, non-aggressive feel.
  * **Thick Outlines:** All UI elements have thick, dark-colored strokes (`UIStroke` of `3` to `5` pixels) to stand out from the 3D background.
  * **Drop Shadows:** Heavy black or dark purple offset drop shadows on buttons to give a physical "pressable" appearance.

---

## 📐 Layout & Component Breakdown

### 1. 🌌 Low-Poly Stylized Background
* **Visuals:** A charming, low-poly stylized night cemetery at midnight.
* **Details:**
  * Silhouette of stylized, slightly twisted pine trees and bare oak trees.
  * Handful of tilted, cartoonish grey headstones.
  * A gigantic, bright glowing **Full Moon** filling the upper sky, casting a soft white-blue directional light and ambient mist.
  * Subtle particles (fireflies or green glowing mist) drifting gently in the background.

---

### 2. 🧭 Upper-Left HUD: Currency & Rebirth
* **Currency Bar:**
  * **Design:** An elongated capsule container with a glossy dark-blue background and a thick white/light-blue border.
  * **Left Side:** A shiny green 3D dollar coin icon.
  * **Text:** **`$ 100,000`** in a bold, comic font (such as *Fredoka One* or *Luckiest Guy*), rendered in crisp white with a heavy black outline.
  * **Bonus Label:** A smaller neon-green label on the right side reading **`+500`**, indicating active passive income or recent earnings.
* **⚡ Rebirth Button:**
  * **Placement:** Positioned immediately adjacent to the Currency Bar.
  * **Design:** Compact, purple neon-glowing pill button with an electric-purple outline.
  * **Icon:** A vibrant yellow/orange 3D lightning bolt.
  * **Text:** **`REBIRTH`** in bold italicized uppercase white font.
* **📡 SIGNAL Panel:**
  * **Placement:** Directly below the Currency Bar.
  * **Design:** A glowing horizontal panel with a neon-green pulse indicator.
  * **Text:** **`SIGNAL: STRONG`** in bright green neon text, warning the player that ghosts are nearby.

---

### 3. ⚙️ Upper-Right HUD: Settings
* **Settings Button:**
  * **Design:** A circular, gold-colored gear button with glossy highlights and a thick chocolate-brown border.
  * **Action:** Opens the game's configurations (sound, codes, graphics, quality).

---

### 4. 🛍️ Central Window: "UPGRADE SHOP"
* **Main Container:**
  * A massive, centered modal panel with a thick, glossy golden border.
  * The top tab reads **`UPGRADE SHOP`** in large, bright-yellow cartoon letters with an orange drop-shadow.
  * A subtle grid pattern covers the dark backing of the window to keep listings organized.
* **Shop Items (Detailed List):**
  1. **🔋 GHOST VACUUM Lvl 3**
     * **Description:** Details the level 3 vacuum cleaner.
     * **Action Button:** A vibrant green **`$1,000 BUY`** button. The button has a bright lime-green face, a dark-green under-shadow, and a thick outline.
  2. **🔍 DETECTOR Lvl MAX**
     * **Description:** Represents the fully upgraded ghost detector.
     * **Action Button:** A premium, sparkling gold button displaying **`MAX`** in bold white text, indicating no further upgrades are available.
  3. **🎒 BACKPACK Lvl 2**
     * **Description:** Details the level 2 container.
     * **Action Button:** A crimson-red **`$750 BUY`** button, with smaller bold text below reading **`NOT ENOUGH`**, styled in a dark-red disabled visual tone to indicate insufficient funds.

---

### 5. 🎒 Right Side: Inventory Panels
* **👻 Spook (x3) Panel:**
  * A vertical widget listing captured spirits. Displays tiny, cute cartoon ghost icons in individual slots, labelled **`Spook (x3)`** with a rarity color-coded outline (e.g., green for Common, blue for Rare).
* **📦 Backpack Capacity Panel:**
  * **Design:** A tall vertical container showing current backpack capacity.
  * **Visual State:** Features a gauge or text reading **`7/10`** fullness.
  * **Alert Text:** A pulsing red **`FULL! SELL`** banner indicating that the player needs to visit the sell zone immediately.
* **🔔 Ghost Notifications:**
  * Small sliding popups on the right edge stating **`Captured Green Spook!`** with tiny floating ghost emojis.

---

### 6. 🎛️ Lower-Left HUD: Large Toy Buttons
Four oversized, glossy, square buttons with highly rounded corners, thick dark borders, and a distinct 3D plastic bubble-like reflection:
1. **🛒 Orange Cart Button:** For opening the game pass/currency store.
2. **🏆 Yellow Trophy Button:** For opening the global and local leaderboards.
3. **👾 Purple Monster Button:** For opening the pet/egg-opening inventory.
4. **🎁 Green Gift Button:** For daily rewards, featuring a pulsing **red notification dot** in the upper-right corner.

---

### 7. 🌀 Central-Bottom HUD: Capture Progress
* **Capture Bar:**
  * **Design:** A long, horizontal bright-blue neon progress bar.
  * **Left Side:** A cute, cartoonish circular icon containing a shivering ghost.
  * **Text:** **`CAPTURING...`** overlaying the progress fill (e.g., *75%*) in sharp, white, readable comic typography.

---

This UI successfully combines high-end cartoon visual feedback, clear informational states, and a playful spooky theme, making the gameplay loop incredibly satisfying for mobile gamers!
