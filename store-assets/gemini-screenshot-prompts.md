# Study Cafe: Gemini prompt kit (en-US)

Everything here is written to be pasted straight into Gemini image generation. Work in **one chat** so the set stays visually consistent.

| Asset | Size | Aspect | Count |
|---|---|---|---|
| Phone screenshots | 1080 x 1920 px, PNG | 9:16 portrait | 7 (Play allows 2-8) |
| Tablet screenshots (optional) | 1920 x 1200 px, PNG | 16:10 landscape | 4-7 |
| Feature graphic | 1024 x 500 px, PNG or JPEG, no alpha | about 2:1 | 1 per language |

Reference image to attach in Gemini (keeps the brand identical): `store-assets/icon-512.png`.

---

## 1. Brand sheet (use as-is, do not paraphrase)

```
BRAND: "Study Cafe", a cozy Pomodoro focus timer. Mood: warm, calm, premium, late-night study cafe.
PALETTE: espresso black #0A0A0A / #14100D, rich gold #D4AF37 (highlight #FFF1BC, shadow #9C6F14), warm cream #F2EADC, tomato red #E04A4A (only for the small "tomato" arc), leaf green #4FA855 (tiny accent), soft violet glow #9D76C1 (background light only).
SIGNATURE: a gold timer ring, a coffee cup seen from above with a clock face, and a small green tomato leaf. This mirrors the app icon.
TYPE: bold geometric sans-serif for headlines (Poppins / Sora style), cream or white, tight leading.
```

---

## 2. Master prompt for every screenshot (paste first, then add one screen block)

```
Create a Google Play Store phone screenshot, vertical 9:16, 1080x1920 px, polished 2026 app-store marketing style.

LAYOUT
- Top 20%: a single headline, centered, bold, cream (#F2EADC), maximum 5 words, huge and instantly readable, with at least 8% side margins.
- Below it: the app screen, shown frameless and flat (no phone bezel), full width with 6% side padding, rounded 28px corners, a soft warm-gold drop shadow, perfectly sharp.
- Behind everything: deep espresso-black background (#0A0A0A to #14100D) with a soft warm gold light bloom behind the screen and a faint violet (#9D76C1) rim light in one corner. Add a few tiny floating gold dust particles. Keep it elegant and uncluttered.

APP UI STYLE (must look like a real dark-mode Android app)
- Surface cards #1E1E1E with 16px rounded corners, thin 1px border at 10% white.
- Gold (#D4AF37) accents for buttons, rings and numbers; cream text.
- Bottom navigation bar with exactly 4 tabs: Focus, Stats, Cafe, Profile (clean outline icons, the active tab in gold).
- Real, legible UI text only. No lorem ipsum, no gibberish characters.

QUALITY
- Crisp edges, high contrast, no blur, no noise, no AI artifacts, no warped text.
- Keep every important element inside the central 90% safe area.

NEVER INCLUDE
Store badges, star ratings, "#1", "best", "free", prices, awards, competitor logos or names, real people or photos, watermarks, device frames, hands holding phones, or any feature not described in the screen block.
```

---

## 3. Screen blocks (append ONE after the master prompt)

### Screen 1: Focus timer (hero, upload first)
```
SCREEN: the Focus tab.
Headline: "Focus 25. Rest 5."
UI: a large circular countdown ring with a thick gold progress arc and a faint track, big centered time "25:00" in white, the label "Deep Focus" in gold underneath, then a wide gold "Start" button and a smaller outlined "Reset" button. Top row: a small chip "🔥 3-day streak" on the left and a points total on the right. Subtle cozy-cafe warmth, no extra widgets.
```

### Screen 2: Points and virtual cafe
```
SCREEN: the Cafe tab.
Headline: "Earn points. Grow your cafe."
UI: title "Virtual Cafe" with a small speaker icon at the top right; a gold button "Watch Ad +50 Points" under the title; below it a 2-column grid with EXACTLY three rounded item cards, no others: a large ☕ emoji with "Espresso" and a gold "50 pts" tag, a large 🍵 emoji with "Green Tea" and "30 pts", a large 🍰 emoji with "Cheesecake" and "100 pts". Nothing else in the grid; leave the rest of the screen calm and empty.
```

### Screen 3: Sounds
```
SCREEN: the Cafe tab with a bottom sheet open, dark background dimmed behind it.
Headline: "Calming study sounds"
UI: the sheet is titled "Select Ambient Sound" and lists exactly three rows, each with an emoji and a label: 🌧️ Rain, 🎧 Brown Noise, 🔥 Fireplace. Rain is selected (gold check). Below the rows: a "Turn Off Sound" gold text button and a muted "Close" text button.
```

### Screen 4: Streaks and achievements
```
SCREEN: the Achievements screen.
Headline: "Build daily streaks"
UI: a top card with "🔥 3-day streak" and a progress bar, then a 2-column grid of round badge cards: "3-Day Streak" and "First 100 Points" unlocked in gold with a soft glow; "Focus Master" and "Point Hunter" locked in muted grey with small progress bars.
```

### Screen 5: Statistics
```
SCREEN: the Stats tab.
Headline: "See your study time"
UI: three pill filters "Week / Month / All time" with Week selected in gold; three summary cards in a row labeled "Hours", "Points", "Sessions" with realistic numbers (for example 8.5, 420, 21); below them a weekly bar chart for Monday to Sunday in gold bars with the tallest bar on Thursday.
```

### Screen 6: Leaderboard
```
SCREEN: the Global Leaderboard.
Headline: "Climb the leaderboard"
UI: a top-3 podium with 🥇 🥈 🥉 and invented usernames (for example "mia_codes", "ali.studies", "noah_t"), each with a gold point total; below it a list of rank tiles (4, 5, 6, 7) with rank number, username, "🔥 12-day streak" in muted text and gold points on the right. Use only made-up usernames, no real people.
```

### Screen 7: Share progress
```
SCREEN: a system share sheet opened over the Focus tab.
Headline: "Share your progress"
UI: in the upper area a rounded share card with a gold ring, the text "Study Cafe", a points total "420 pts" and "🔥 3-day streak"; below it a generic share sheet with four generic round app icons (no brand logos).
```

### Suggested upload order
1 Focus timer, 2 Cafe, 3 Sounds, 4 Achievements, 5 Stats, 6 Leaderboard, 7 Share.

---

## 4. Feature graphic prompt (1024 x 500)

Attach `icon-512.png` as the reference image. Generate at the widest landscape ratio Gemini offers, then crop to 1024x500 and keep everything important in the central 80%.

```
Create a premium 2026-style Google Play feature graphic, wide landscape (about 2:1, will be cropped to 1024x500). Use the attached app icon as the exact brand reference: a coffee cup seen from above with a clock face, a gold glowing timer ring, a small tomato-red arc and a tiny green leaf.

SCENE: deep espresso-black background (#14100D) with a soft golden light bloom behind the icon, a faint violet (#9D76C1) rim light, floating gold dust, cinematic depth of field, glassy highlights, ultra-clean premium look.

COMPOSITION
- Left-center: the app icon as a large, softly lit 3D object with gentle shadow.
- Right-center: the name "Study Cafe" in large bold geometric sans-serif, gold (#D4AF37); under it "Pomodoro Timer" in lighter cream; under that a small muted tagline "Focus. Earn points. Build your cafe."
- Everything inside the central 80% of the image, generous empty margins left and right.

NEVER INCLUDE phone screenshots, store badges, star ratings, "free", "best", "#1", prices, awards, people, competitor logos, watermarks, or any extra text.
```

Optional variant with a phone: add at the end, "On the far right add one floating frameless phone showing only a large gold circular countdown ring with 25:00 on a dark screen, nothing else on the screen."

---

## 5. Tablet screenshots (optional)

Play has separate upload slots for **7-inch** and **10-inch** tablets. They are optional, but apps that ship them (4 or more at 1080 px+) are favoured in large-screen recommendations. Min 320 px, max 3840 px per side, PNG or JPEG without alpha.

| Slot | Portrait | Landscape |
|---|---|---|
| 7-inch tablet | 1200 x 1920 | 1920 x 1200 |
| 10-inch tablet | 1600 x 2560 | 2560 x 1600 |

**Important:** on tablets the real app keeps a phone-width column (content is capped at 600 dp and centered). The screenshot must show exactly that. Do NOT invent a two-column or wide tablet layout, Play treats that as misleading.

Use the same master prompt and the same screen blocks, but replace the first line (format) with:

```
Create a Google Play Store tablet screenshot, landscape 16:10, 2560x1600 px, same brand style. Put the headline on the left third, vertically centered, large. On the right two thirds place the same phone-width app screen (about 600 dp wide, exactly as on a phone, frameless, rounded corners, soft gold glow) centered, with calm espresso-black space on both sides. Do not stretch or redesign the UI, do not add extra columns or panels.
```

For the 7-inch slot, resize the same images to 1920x1200. One set of landscape images can be uploaded to both slots.

---

## 6. Quality checklist before uploading

1. Compare each image with the real app (internal-test build): colors, tabs and labels must match. Remove any image that shows a feature the app does not have. Play rejects misleading screenshots.
2. Zoom in on the text: no garbled letters, correct spelling, headlines exactly as written.
3. No "free", "best", "#1", prices, ratings, awards or competitor logos.
4. All seven images share the same background, type and layout grid. If one drifts, regenerate it with: "Match the style, layout grid and typography of the previous images exactly."
5. Export as PNG at 1080x1920 (upscale if Gemini returns smaller), under 8 MB each.

## Review of the first generated set (2026-10-19)

Processed files are in `store-assets/final/` (phones 1080x1920, feature graphic 1024x500). Accuracy check against the real app:

| Image | Verdict | Why |
|---|---|---|
| phone 1 "Your late-night focus cafe" | Do not use | Shows features the app does not have: "Tonight's Order", "Rainy Night Cafe", "Dark Roast Lo-Fi", a Focus Goal bar, a Skip button, "Session 1 of 4". Misleading. |
| phone 2 "Focus 25. Rest 5." | Use | Matches the real timer screen. |
| phone 3 "Earn points. Grow your cafe." | Regenerate | Shows decor items (lamp, fern, bookshelf). The real cafe has exactly three treats: Espresso 50, Green Tea 30, Cheesecake 100. |
| phone 4 "Calming study sounds" | Use | Rain, Brown Noise, Fireplace are the real options. |
| phone 5 "Build daily streaks" | Check | Badge names are real (3 Day Streak, First 100 Points, Focus Master, Point Hunter). Zoom in: "Focus Master" is "Complete 10 sessions" in the app, not hours. |
| phone 6 "See your study time" | Use | Matches the stats screen. |
| phone 7 "Share your progress" | Optional fix | The screen behind the share sheet shows tabs the app does not have. |
| feature graphic | Fix text | "Ambience: Rain & Lo-Fi" is wrong, Lo-Fi is not shipped. Use "Rain & Fireplace". |

### Replacement prompt for phone 3 (paste after the master prompt)
```
SCREEN: the Cafe tab.
Headline: "Earn points. Grow your cafe."
UI: title "Virtual Cafe" with a small speaker icon at the top right; a gold button "Watch Ad +50 Points" under the title; below it a 2-column grid with EXACTLY three rounded item cards, no others: a large ☕ emoji with "Espresso" and a gold "50 pts" tag, a large 🍵 emoji with "Green Tea" and "30 pts", a large 🍰 emoji with "Cheesecake" and "100 pts". Nothing else in the grid; leave the rest of the screen calm and empty.
```

### Replacement for phone 1 (the new hero, use the real timer screen with the streak)
```
SCREEN: the Focus tab.
Headline: "Stay in the flow"
UI: a large circular countdown ring with a thick gold progress arc, big time "18:42" in white, the label "Deep Focus" in gold, a wide gold "Start" button and a smaller outlined "Reset" button. Top row: a "🔥 3-day streak" chip on the left and a points total on the right. No other cards, goals or widgets.
```

### Feature graphic text fix
Edit the existing image with Gemini, or regenerate with the same prompt: "Same image, but change the third card's text to 'Rain & Fireplace' and keep everything else identical."

## Appendix: Turkish headlines (only for a Turkish listing set)

| # | English | Turkish |
|---|---|---|
| 1 | Focus 25. Rest 5. | 25 dk odaklan, 5 dk dinlen |
| 2 | Earn points. Grow your cafe. | Puan kazan, kafeni büyüt |
| 3 | Calming study sounds | Sakinleştiren çalışma sesleri |
| 4 | Build daily streaks | Günlük seri yap |
| 5 | See your study time | Çalışma süreni gör |
| 6 | Climb the leaderboard | Liderlik tablosunda yüksel |
| 7 | Share your progress | İlerlemeni paylaş |

Turkish UI labels for the Cafe sheet: Yağmur, Kahverengi Gürültü, Şömine, Kapat, Sesi Kapat.
