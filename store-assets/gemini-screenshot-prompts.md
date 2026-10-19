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
