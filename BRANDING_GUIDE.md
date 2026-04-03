# Burn Rate - Brand Guidelines

This document outlines the core visual identity for the **Burn Rate** application. By adhering to these guidelines, we ensure consistency across iOS, Android, Web, and any future promotional materials.

![Burn Rate App Icon](/Users/ryanrichmond/.gemini/antigravity/brain/135243da-fb4d-4a52-b028-51c656efd2e5/burn_rate_icon_1775187271027.png)

## 1. Brand Philosophy
Burn Rate aims to feel **premium, urgent, and precise**. It combines the sleekness of modern fintech tools with the intensity of a live "meter running". The visual language relies heavily on pure dark backgrounds to make the gold and orange "burn" components pop vibrantly.

## 2. Color Palette

The color scheme harmonizes the deep navy of the app logo with the luxurious, warm golds of the application's interface. 

### Core Backgrounds (The "Deep Void")
The application avoids pure black (`#000000`), instead utilizing a rich, extremely dark navy to provide depth and reduce eye strain, while still creating high contrast for the golden accents.
* **Base Background:** `#06090E` (Used for full-screen scaffold)
* **Surface Background 1:** `#090F16` (Used in gradient tops)
* **Surface Background 2:** `#11151D` (Used in gradient middles)
* **Card Surface:** `#0B121A` (Used for secondary info cards)
* **Button Surface:** `#161F2B` (Used for action buttons)

### Primary Accents (The "Burn")
The golds and oranges represent time, money, and the "burn rate" itself. They are used for active elements, running timers, and critical numbers. 
* **Vibrant Gold:** `#FFC566` (Primary accent color, used for icons and critical labels)
* **Warm Orange/Gold:** `#FFB648` (Used for secondary highlights)
* **Soft Gold:** `#FFD995` (Used for active text states)
* **Pale Gold Tint:** `#FFD8A1` (Combined with 14% opacity for active chips)

### Gradients
Gradients are essential to Burn Rate's premium feel.
* **App Background:** Linear Gradient from Top Left (`#090F16`) to Bottom Right (`#06090E`), passing through `#11151D`.
* **Live Status Display:** A striking gradient to highlight the real-time cost, going from Dark Amber (`#35210C`) to Rich Brown/Orange (`#7C4A0E`) into Navy (`#191E2A`).

## 3. Typography

The application uses clean, modern sans-serif fonts to communicate numbers elegantly and clearly. (Currently utilizing native system fonts `San Francisco` on iOS / `Roboto` on Android).

* **Display/Big Numbers (The Cost):** 
  * Font Weight: `Extra Bold` (800)
  * Tracking/Letter Spacing: Tightly condensed (`-3` or `-6` depending on size) to make large numbers feel monolithic and cohesive.
  * Color: Pure White (`#FFFFFF`).
* **Headers & Titles:**
  * Font Weight: `Bold` (700) or `Medium` (500)
  * Color: White or White with 84% opacity.
* **Eyebrow Labels:**
  * Style: `UPPERCASE`
  * Letter Spacing: Wide (`1.1`)
  * Color: Vibrant Gold (`#FFC566`)
* **Body Text & Hints:**
  * Color: White with varying opacities (`62%`, `70%`, `76%`) to establish a clear visual hierarchy without introducing gray colors.

## 4. UI Elements & Motifs

* **Shape & Geometry:** The application relies heavily on rounded corners to feel approachable. Cards use a `34px` or `24px` border radius, while smaller chips use `18px` or `16px`.
* **Borders:** Subtle, 8% opacity white borders (`Colors.white.withAlpha(0.08)`) are used to separate dark elements on dark backgrounds, creating a faux-glassmorphism effect without heavy blurring.
* **Feedback States:** Inactive states are subtly styled (e.g., `8%` white opacity backgrounds), while active states gain a glowing warm tint (e.g., `14%` pale gold opacity backgrounds with gold borders).
* **Drop Shadows:** Shadows are used sparingly but deliberately, such as the `Color(0x55240F00)` shadow under the main Live Status Display, anchoring the floating golden elements to the dark background.
