# Saklama/İmha Politikası, Veri İhlali Müdahale Planı ve Başvuru Prosedürü

Son güncelleme: 2026-11-13.

## 1. Saklama ve imha

| Veri | Süre | İmha |
|---|---|---|
| Hesap, profil, liderlik, davet, ikram, odak durumu | Hesap ömrü | Uygulamada "Hesabı Sil" (otomatik, anında); web/e-posta talebi 30 gün içinde elle |
| Cihaz verisi (seans, başarım, kafe, ayarlar) | Kullanıcı silene / uygulama kaldırılana kadar | Hesap silmede otomatik temizlenir (`LocalDataService.wipe`) |
| Oyuncu bildirimleri | Kalıcı (moderasyon) | İstemciden silinemez; yalnızca yönetici silebilir |
| Analiz / çökme | Firebase'in varsayılan saklama süresi | Rıza geri çekilince toplama durur; konsoldan silinebilir |
| Rıza kaydı | Hesap silinene / kaldırılana kadar | Hesap silmede temizlenir |

- Pasif hesap: şu an otomatik silme yok. **Açık madde:** kullanılmayan hesaplar için (ör. 24 ay) bildirimli silme kuralı karar verilmeli; Cloud Function/zamanlanmış iş gerektirir.
- İmha kayıtları: hesap silme talepleri (e-posta ile gelenler) tarih ve sonuçla bu klasörde `imha-kayitlari.md` dosyasında tutulur, en az 3 yıl saklanır (henüz kayıt yok).
- Yedekler: uygulama yedeği yok (`allowBackup=false`). Firestore yedeği/PITR açıksa silinen veri o sürede yedekte kalabilir; konsolda kontrol edilmelidir.

## 2. İlgili kişi başvuru prosedürü (KVKK m.11, 30 gün)

1. Başvuru e-postası `eren.gp54@gmail.com` adresine gelir (konu: "KVKK başvurusu").
2. Aynı gün kayıt açılır: tarih, ad/e-posta, talep, numara (`basvuru-kayitlari.md`).
3. Kimlik doğrulama: başvuru, hesabın kayıtlı e-postasından gelmelidir; gelmiyorsa hesapla eşleşen bilgi istenir.
4. Talep tipine göre:
   - Bilgi/kopya: uygulamadaki "Verilerimi dışa aktar" JSON'u veya Firestore'dan elle dışa aktarım.
   - Silme: Firebase Auth kullanıcısı + `users`, `leaderboard`, `presence`, `gifts` (to/from), `invite_codes`, `referrals` kayıtları silinir; `reports` hariç tutulur ve nedeni yanıtta yazılır.
   - Düzeltme: görünen ad hesap üzerinden değiştirilir.
5. En geç 30 gün içinde ücretsiz, yazılı (e-posta) yanıt verilir. Red durumunda gerekçe ve Kurul'a şikâyet yolu yazılır.
6. Şablon yanıtlar: bilgi talebi, düzeltme, silme, itiraz, aktarım bilgisi (gerekince bu klasöre eklenir).

## 3. Veri ihlali müdahale planı (72 saat)

Karar verici ve teknik sorumlu: geliştirici (tek kişi). Yedek kişi: **belirlenmedi (açık madde)**.

**İhlal örnekleri:** Firestore kurallarının yanlışlıkla açılması, anahtar/keystore sızıntısı, Firebase hesabının ele geçirilmesi, yanlış alıcıya gönderim, Google tarafı ihlal bildirimi (bir başkasının sana bildirmesi de "öğrenme" anıdır).

**İhlal anında**
1. Öğrenme zamanını kaydet (72 saatlik süre başlar).
2. Durdur: Firestore kurallarını kapat (`firebase deploy --only firestore:rules` ile kısıtlı kurallar), Firebase/Google hesap şifrelerini ve oturumlarını sıfırla, sızan anahtarları döndür (Firebase Console > Proje ayarları, Play yükleme anahtarı için Play Console).
3. Kanıt: konsol günlüklerinin ve etkilenen belgelerin kopyasını al, silme.
4. Etkiyi ölç: hangi koleksiyon, kaç kullanıcı, hangi veri (bu uygulamada özel nitelikli veri yok; e-posta, görünen ad, kimlik, puan).
5. 72 saat içinde Kurul'a bildir: KVKK "Kişisel Veri İhlal Bildirim Formu" (kvkk.gov.tr). Bilgi eksikse eldekiyle bildir, sonra tamamla; gecikirse nedenini yaz.
6. Etkilenen kullanıcılara en kısa sürede bildir: e-posta (Firebase Auth e-postaları) ve gerekirse web sitesinde duyuru. İçerik: ne oldu, hangi veri, olası sonuç, alınan önlem, iletişim.
7. Google tarafı kaynaklıysa Google'ın bildirimini saklayıp aynı süreci işlet.

**Sonrasında:** ihlal kaydı (`ihlal-kayitlari.md`: tarih, neden, etki, önlem, bildirimler), kök neden analizi, kurallar/test güncellemesi, yılda bir tatbikat (ör. "keystore sızdı" senaryosu).

## 4. VERBİS değerlendirmesi

Yıllık çalışan sayısı 50'nin altında ve yıllık mali bilanço eşiğin altında bir bireysel geliştirici için genel kural muafiyettir; ana faaliyet konusu özel nitelikli veri işlemek de değildir. **Bu değerlendirme geliştiricinin kendi rakamlarıyla her yıl yenilenmeli ve yazılı kaydedilmelidir:** karar: `____` (tarih: `____`). Hukuki görüş değildir; Kurul'un güncel eşikleri için kvkk.gov.tr kontrol edilmelidir.
