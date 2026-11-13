# Study Cafe: Kişisel Veri İşleme Envanteri ve SDK Listesi

Son güncelleme: 2026-11-13 (uygulama sürümü 1.0.10). Her yeni SDK, veri alanı veya amaç eklenmeden önce güncellenir.

Veri sorumlusu: Cynorra (bireysel geliştirici), eren.gp54@gmail.com. Veri işleyenler: Google (Firebase, AdMob).

## Veri envanteri

| Veri | Amaç | Hukuki sebep (KVKK m.5) | Kaynak | Saklandığı yer | Süre | Alıcı / ülke |
|---|---|---|---|---|---|---|
| E-posta, şifre (Firebase tarafından), hesap kimliği | Hesap, oturum | m.5/2-c sözleşme | Kullanıcı | Firebase Authentication | Hesap ömrü | Google, ABD/AB |
| Görünen ad | Hesap, liderlik tablosu | m.5/2-c | Kullanıcı / Google girişi | Firestore `leaderboard`, Auth profili | Hesap ömrü | Google; diğer kullanıcılara görünür |
| Puan, çalışma dakikası, seri | Uygulama işlevi, liderlik | m.5/2-c | Uygulama | Cihaz (Isar); hesap varsa Firestore `leaderboard`, `users` | Hesap ömrü / kaldırana kadar | Google |
| Seans geçmişi, başarımlar, kafe öğeleri | Uygulama işlevi | m.5/2-c | Uygulama | Yalnızca cihaz (Isar) | Silinene / kaldırılana kadar | Yok |
| Davet kodu, davet kaydı (hesap kimlikleri, kod, zaman) | Davet bonusu | m.5/2-c | Uygulama | Firestore `invite_codes`, `referrals` | Hesap silinene kadar | Google |
| Odak durumu (ad, bitiş zamanı) | Arkadaşlara görünürlük (isteğe bağlı, varsayılan kapalı) | m.5/1 açık rıza (ayarı açma) | Kullanıcı | Firestore `presence` | Seans bitene / en çok 3 saat | Google; diğer kullanıcılara görünür |
| İkramlar (gönderen/alıcı kimliği, ad, ikram, zaman) | Sosyal özellik | m.5/2-c | Uygulama | Firestore `gifts` | Alıcı silene / hesap silinene kadar | Google |
| Oyuncu bildirimleri (bildiren/bildirilen kimliği, neden, zaman) | Kötüye kullanım önleme | m.5/2-f meşru menfaat | Kullanıcı | Firestore `reports` (uygulamadan okunamaz) | Kalıcı (moderasyon kaydı) | Google |
| Gizlenen oyuncular, odak durumu seçimi, günlük bonus zamanı | Uygulama ayarı | m.5/2-c | Uygulama | Cihaz (Keystore destekli güvenli depolama) | Hesap silinene kadar | Yok |
| Analiz ve çökme verileri (anonim olaylar, uygulama örnek kimliği, cihaz modeli, OS sürümü) | Hata giderme, geliştirme | m.5/1 açık rıza (ilk açılış ekranı) | Otomatik | Firebase Analytics / Crashlytics | Firebase varsayılan süreleri | Google, ABD/AB |
| Rıza kaydı (seçim, zaman, metin sürümü) | İspat | m.5/2-ç / f | Uygulama | Cihaz (güvenli depolama) | Hesap silinene / kaldırılana kadar | Yok |
| Reklam kimliği, IP, temel cihaz bilgisi | Reklam gösterimi | m.5/2-f; AB/BK'de açık rıza (UMP) | Otomatik | Google AdMob | Google politikası | Google, ABD/AB |

Özel nitelikli veri toplanmaz (sağlık, din, biyometrik, konum vb. yoktur). Mikrofon, kamera, rehber, konum, depolama izni istenmez.

## SDK ve üçüncü taraf listesi

| SDK | Ne toplar | Kapatılabilir mi | Rıza öncesi çalışır mı |
|---|---|---|---|
| firebase_auth | E-posta, kimlik | Hesap açılmazsa kullanılmaz | Hayır (yalnızca giriş yapılırsa) |
| cloud_firestore | Yukarıdaki bulut verileri | Hesap açılmazsa kullanılmaz | Hayır |
| firebase_analytics | Anonim olaylar | Evet (ayar + ilk ekran) | **Hayır** (manifestte kapalı) |
| firebase_crashlytics | Çökme raporu | Evet (aynı anahtar) | **Hayır** (manifestte kapalı) |
| firebase_remote_config | Ayar getirir; Firebase Installations kimliği | Hayır | Evet (zamanlayıcı/ödül ayarları için; kişisel veri göndermez) |
| google_mobile_ads (AdMob) | Reklam kimliği, IP | AB/BK'de UMP formu; başka yerde Android reklam kimliği ayarı | Evet (ücretsiz uygulamanın geliri; Aydınlatma Metni'nde belirtilmiştir) |
| google_sign_in | Ad, e-posta | Kullanıcı seçerse | Hayır |
| flutter_local_notifications | Hiçbiri (yerel) | İzin verilmezse kapalı | Yerel |

## Yurt dışı aktarım (KVKK m.9) ve veri işleyen ilişkisi (m.12)

- Firebase ve AdMob verileri Türkiye dışında işler. **Açık madde:** Google'ın sunduğu standart sözleşme/ek hükümlerin Kurul'a bildirimi (imzadan itibaren 5 iş günü) gerekip gerekmediği bir avukatla netleştirilmelidir; bu repo bu bildirimi yapmaz.
- Google Cloud/Firebase Veri İşleme ve Güvenlik Şartları kabul edilmiştir (Firebase konsolunda varsayılan). Kayıt: konsol > Proje ayarları.
- Firestore bölgesini kontrol edin ve buraya yazın: `____` (yazılmadı; konsoldan okunmalı).

## Teknik ve idari önlemler (özet)

- Aktarımda TLS (Firebase SDK). Firestore kuralları varsayılan kapalı; kullanıcı yalnızca kendi verisine erişir (`firestore.rules`, 38 kural testi).
- Hassas yerel veri Android Keystore destekli `flutter_secure_storage`'da; `allowBackup=false`.
- Hata günlüklerine kullanıcı kimliği/e-posta yazılmaz.
- Üretim Firebase projesine erişim: yalnızca geliştirici hesabı. Ekip yok.
