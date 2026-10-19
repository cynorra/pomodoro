# Study Cafe: Gemini screenshot prompts

Format for every image: **vertical 9:16, 1080x1920, PNG**. Google Play accepts 2-8 phone screenshots (each side 320-3840 px). The first 3 matter most.

**Rules before uploading**
- Compare every generated image with the real app (internal-test build): colours, tabs, labels and features must match. Play rejects misleading screenshots. Drop any image that shows a button or feature the app does not have.
- No "free", "best", "#1", prices, ratings, awards, store badges or competitor logos in the images.
- Turkish set: generate separately and check the Turkish characters (ı ş ğ İ ö ü ç).
- Real in-app facts used below: dark theme, gold (#D4AF37), purple accent (#9D76C1), surface #1E1E1E; bottom tabs Focus / Stats / Cafe / Profile; focus 25 min, short break 5 min, long break 15 min every 4 sessions; ambient sounds shipped: Rain, Brown Noise, Fireplace.

## Master style prompt (paste at the start of every request)

```
Create a vertical 9:16 (1080x1920) Google Play Store screenshot for a mobile app called "Study Cafe", a Pomodoro focus timer. Style: modern 2026 app-store marketing frame. Background: deep near-black (#0A0A0A) with a soft warm gold glow (#D4AF37) and a subtle purple accent (#9D76C1). The top 22% holds a large, bold, high-contrast headline (white, max 5 words, sans-serif, centered, generous margins). Below it, a frameless full-width phone UI shown flat and perfectly crisp, rounded corners, soft drop shadow, no device bezel. App UI language: dark surface cards (#1E1E1E), gold (#D4AF37) accents, rounded 16px cards, bottom navigation bar with 4 tabs: Focus, Stats, Cafe, Profile. Keep all text inside the 90% safe area, no tiny unreadable text. Do NOT include: store badges, star ratings, "#1", "best", "free", price, awards, competitor logos, real people, watermarks, or any app feature not described below.
```

## Screen prompts (append after the master prompt)

### 1. Focus timer (hero)
```
Screen: the Focus tab. A large circular countdown ring with a gold progress arc, big time "25:00" in the centre, the label "Deep Focus" under it, below it a gold "Start" button and a smaller "Reset" button. Top row: a small chip "🔥 3-day streak" and a points total.
Headline EN: "Focus 25. Rest 5."
Headline TR: "25 dk odaklan, 5 dk dinlen"
```

### 2. Points and virtual cafe
```
Screen: Virtual Cafe tab. Title "Virtual Cafe", a 2-column grid of rounded item cards (coffee cup, plant, lamp, bookshelf style cafe decor items), each with a small gold point cost, a speaker icon in the top-right, and a gold button "Watch Ad +50 Points".
Headline EN: "Earn points. Grow your cafe."
Headline TR: "Puan kazan, kafeni büyüt"
```

### 3. Streaks and achievements
```
Screen: Achievements. A grid of round badge cards ("3-Day Streak", "First 100 Points", "Focus Master", "Point Hunter"), some unlocked in gold, some locked in grey with a progress bar.
Headline EN: "Build daily streaks"
Headline TR: "Günlük seri yap"
```

### 4. Statistics
```
Screen: Statistics. Three filter chips "Week / Month / All time" with Week selected, three summary cards (Hours, Points, Sessions), and a weekly bar chart for Monday to Sunday in gold bars.
Headline EN: "See your study time"
Headline TR: "Çalışma süreni gör"
```

### 5. Ambient sounds
```
Screen: Virtual Cafe tab with a bottom sheet titled "Select Ambient Sound" listing exactly three options with an emoji each: 🌧️ Rain, 🎧 Brown Noise, 🔥 Fireplace, plus a "Close" text button.
Headline EN: "Calming study sounds"
Headline TR: "Sakinleştiren çalışma sesleri"
(TR UI labels: Yağmur, Kahverengi Gürültü, Şömine, Kapat)
```

### 6. Leaderboard
```
Screen: Global Leaderboard. A podium with three avatars 🥇🥈🥉 and fictional display names (invented usernames only), below it a list of rank tiles with rank number, name, "🔥 12-day streak" and gold point totals.
Headline EN: "Compare with other students"
Headline TR: "Diğer öğrencilerle karşılaştır"
```

### 7. Share progress
```
Screen: a share card preview: a rounded gold-and-dark card showing a points total and a streak count with the text "Study Cafe", displayed inside a system share sheet.
Headline EN: "Share your progress"
Headline TR: "İlerlemeni paylaş"
```

## Tablet versions (7" and 10")
Repeat the same seven prompts but replace the format line with: "Create a 16:10 landscape (1920x1200) screenshot" (or 10:16 portrait), and widen the layout (two-column cards). Play favours apps that ship tablet screenshots.

## Suggested upload order
1 Focus timer, 2 Cafe, 5 Ambient sounds, 3 Achievements, 4 Statistics, 6 Leaderboard, 7 Share.

---

# App icon prompt (Gemini)

Goal: one 1024x1024 PNG, full-bleed square (no rounded corners, no border, no transparency). It is used as the Play Store icon (512x512) and, after processing, as the Android launcher icon (adaptive, round and square masks). Hand me the PNG and I convert it into all Android sizes.

**Hard rules for the result**
- Square 1:1, 1024x1024, the background fills every pixel to the edges (Android crops it with a circle/squircle mask).
- The whole subject (cup + ring + steam) must sit inside the central 60% of the image; nothing important within 20% of any edge.
- One clear focal object, readable as a 48x48 thumbnail. No text, letters, numbers, watermark, border, or UI.
- Brand palette: deep espresso black (#14100D to #0A0705) background, rich gold (#D4AF37, highlights #FFF1BC, shadows #9C6F14), optional tiny purple (#9D76C1) rim light.

**Main prompt**
```
Design a premium mobile app icon, 1024x1024, 1:1, full-bleed square with no rounded corners and no border. Concept: a cozy study cafe focus timer. Centered subject: a elegant gold coffee cup on a saucer with two soft curls of steam, enclosed by a thin glowing circular timer ring that is about 80% complete (a gap at the upper left, rounded ends). Style: modern 2026 premium app icon, soft 3D glass-and-metal feel with a polished gold gradient (highlights #FFF1BC, mid #D4AF37, shadows #9C6F14), gentle inner glow and a warm golden bloom behind the cup, subtle specular highlights, very clean edges. Background: smooth deep espresso-black radial gradient (#2A1D10 centre to #0A0705 edges) with a faint diagonal sheen, no patterns, no objects. Composition: the whole subject sits in the central 60% of the canvas with generous empty space around it, symmetric and balanced, strong silhouette that stays readable at 48x48 pixels. High contrast, sharp, no noise. Do NOT include any text, letters, numbers, logo, watermark, border, rounded-corner frame, drop shadow outside the subject, people, extra objects, or a phone mockup.
```

**Variant B (softer, "clay 3D")**
```
Same concept and layout as above but rendered as a friendly soft 3D clay/ceramic style: a chunky rounded gold-glazed coffee cup with a small saucer and two steam wisps inside a thick glowing gold timer ring, soft studio lighting, smooth rounded forms, warm golden rim light on a deep espresso-black gradient background. Keep the subject inside the central 60%, no text, no border, full-bleed square 1024x1024.
```

**Variant C (minimal flat, best for tiny sizes)**
```
Minimal flat app icon, 1024x1024 full-bleed square. A single bold gold (#D4AF37) coffee cup silhouette with two steam curls, enclosed in a thick gold circular timer ring with a small gap, on a solid deep espresso (#14100D) background with a very soft warm glow behind the cup. Flat vector look, thick shapes, huge contrast, readable at 48x48. Subject inside the central 60%. No text, no border, no gradients except the soft glow.
```

**Check before sending it to me**
1. Looks good as a tiny thumbnail (zoom out to about 48 px): the cup and ring must still read.
2. Nothing important near the edges (a circular crop must not cut anything).
3. No letters or garbled pseudo-text anywhere.
4. Same style family as the feature graphic (use the same image as a reference when you generate it).
