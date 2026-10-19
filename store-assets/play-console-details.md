# Study Cafe: Google Play Console details

Everything decided for the store listing and the Play Console forms (as of 2026-10-19). Keep this file private (it contains reviewer credentials).

## App identity
| Field | Value |
|---|---|
| App name (en-US) | Study Cafe: Pomodoro Timer |
| App name (tr-TR) | Study Cafe: Pomodoro Sayacı |
| Package name | com.cynora.studycafe.pomodoro |
| Default language | English (en-US) |
| Added language | Turkish (tr-TR) |
| App or game | App |
| Free or paid | Free |
| Category | Productivity (Verimlilik) |
| Tags (max 5) | Clock, alarm and timer (Saat, alarm ve zamanlayıcı) / Productivity (Verimlilik) / Study guide (Çalışma kılavuzu) / Personal development (Kişisel gelişim). The Calendar (Takvim) tag was removed because the app has no calendar. |
| Contact email | eren.gp54@gmail.com |
| Developer website | https://cynorra.github.io (must be the root; app-ads.txt is served from it) |
| Privacy policy (EN) | https://cynorra.github.io/studycafe/privacy.html |
| Privacy policy (TR) | https://cynorra.github.io/studycafe/privacy-tr.html |
| Account deletion URL (EN) | https://cynorra.github.io/studycafe/delete-account.html |
| Account deletion URL (TR) | https://cynorra.github.io/studycafe/delete-account-tr.html |
| Terms of service | https://cynorra.github.io/studycafe/terms.html / terms-tr.html |
| AdMob publisher | pub-4674211063760769 |
| app-ads.txt | https://cynorra.github.io/app-ads.txt |

## Store listing texts
Full texts: `listing-en-US.txt`, `listing-tr-TR.txt`, `play-listing.csv` (same folder).
- en-US short (78): Pomodoro focus timer & study timer. Earn points, keep streaks, grow your cafe.
- tr-TR short (78): Pomodoro odaklanma ve ders çalışma sayacı. Puan kazan, seri yap, kafeni büyüt.

## Graphics
- App icon 512x512: `icon-512.png`
- Feature graphic 1024x500: `feature-graphic-en.png`, `feature-graphic-tr.png`
- Phone screenshots (2-8): to be produced with `gemini-screenshot-prompts.md`

## Release notes (first release)
```
<en-US>
First release of Study Cafe: a cozy pomodoro timer with points, daily streaks, achievements and a virtual cafe you decorate. Available in English and Turkish.
</en-US>
<tr-TR>
Study Cafe'nin ilk sürümü: puan, günlük seri, başarım ve süsleyebileceğin sanal bir kafe içeren rahat bir pomodoro zamanlayıcı. Türkçe ve İngilizce dilleriyle.
</tr-TR>
```

## App content forms
| Form | Answer |
|---|---|
| App access | Restricted (leaderboard needs an account). Provide the reviewer account below. |
| Ads | Yes, contains ads (Google AdMob: banner, interstitial, native, rewarded) |
| Content rating category | All other app types (not game, not social/communication) |
| Content rating answers | Violence, sexual content, drugs, gambling, profanity: No. User-generated content (display names on the leaderboard): Yes, with report/hide tools. User-to-user messaging: No. Location sharing: No. In-app purchases: No. Web browser or search engine: No. News or education product: No. |
| Target audience | 13-15, 16-17, 18+ (nothing under 13; do not select "appeals to children") |
| Government app / health / financial | No |
| Data deletion | Yes. In app: Profile > Delete Account. Web: the deletion URL above. |

### Reviewer account (App access)
- Username: `play-reviewer@studycafe.test`
- Password: `StudyCafe123`
- Instructions (max 500 characters):
```
Most features work without an account (tap "Continue as guest" on the login screen). Only the Leaderboard needs an account: open Profile or Leaderboard and sign in with the demo email and password entered above. No 2-step verification, QR codes, biometrics or location access are used. All content is free, nothing needs payment.
```
The account lives in the production Firebase project (pomodoro-app-d3068). Keep it until the review passes.

## Data safety form (suggested answers, verify against the final build)
Data is encrypted in transit (HTTPS). Users can request deletion (URL above). Account data is optional.

| Data type | Collected | Shared | Purpose |
|---|---|---|---|
| Email address | Yes (only if the user creates an account) | No (Firebase acts as service provider) | Account management, app functionality |
| Name (display name; Google account name when using Google sign-in) | Yes (optional) | Shown to other users on the leaderboard | Account management, app functionality |
| User IDs (Firebase uid) | Yes (account) | No | Account management, app functionality |
| App interactions (points, sessions, streaks; analytics events) | Yes | No | App functionality, analytics |
| Crash logs and diagnostics | Yes | No | Analytics (Firebase Crashlytics) |
| Device or other IDs (advertising ID) | Yes | Yes, with Google (AdMob) | Advertising |
| Approximate location (derived from IP by the ads SDK) | Declare as Google's AdMob disclosure guide advises | Yes, with Google (AdMob) | Advertising |

Not collected: precise location, contacts, photos, files, audio, financial info, health info, messages.

## Consent and ads (AdMob console)
- Create the GDPR consent message (EEA/UK) in AdMob > Privacy & messaging, and a US states message if wanted. Without it the consent form never appears.
- After the app is live, link it to the Play listing in AdMob (App settings > App store details) and wait for app-ads.txt verification (up to a day or more).

## Google sign-in checklist
1. Add the upload key SHA-1 (`keytool -list -v -keystore D:\android-projeler\keystores\cynora-upload.jks -alias cynora-upload`) and the Play app signing SHA-1 (Play Console > Test and release > App integrity > App signing) to Firebase > Project settings > Android app `com.cynora.studycafe.pomodoro`.
2. Download the new `google-services.json` into `android/app/` (it must contain a non-empty `oauth_client`).
3. Tag a new release so CI builds it.

## Open items
- Phone and tablet screenshots (Gemini prompts file).
- Coffee shop and lo-fi sounds: add licensed `coffee_shop.mp3` / `lofi_beats.mp3` to `assets/sounds/` to show them in the sound picker (they are hidden until the files exist).
