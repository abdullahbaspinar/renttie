# Renttie

Renttie, ev sahiplerinin ve mülk yöneticilerinin **mülklerini, kiracılarını ve kira ödemelerini** tek bir yerden takip edebildiği bir Flutter mobil uygulamasıdır. Türkçe arayüze sahiptir; kira dönemlerine göre ödemeleri otomatik oluşturur, kıst (gün bazlı) kira ve peşin/dönem sonu ödeme gibi gerçek hayattaki senaryoları destekler.

---

## İçindekiler

- [Öne Çıkan Özellikler](#öne-çıkan-özellikler)
- [Ekranlar ve Özellik Detayları](#ekranlar-ve-özellik-detayları)
- [Kira ve Ödeme Mantığı](#kira-ve-ödeme-mantığı)
- [Mimari](#mimari)
- [Klasör Yapısı](#klasör-yapısı)
- [Kullanılan Paketler](#kullanılan-paketler)
- [Kurulum](#kurulum)
- [Veri Saklama](#veri-saklama)

---

## Öne Çıkan Özellikler

- **Kimlik doğrulama:** Firebase Authentication ile e-posta/şifre ve Google ile giriş, kayıt olma, şifre sıfırlama.
- **Mülk yönetimi:** Mülk ekleme, düzenleme, silme; tip (daire/ofis/dükkan/diğer), adres ve fotoğraf.
- **Kiracı yönetimi:** Kiracı ekleme, düzenleme, silme; fotoğraf, iletişim bilgileri, depozito, acil durum kişisi.
- **Otomatik ödeme planı:** Kira dönemi (başlangıç–bitiş) ve ödeme gününe göre aylık ödemeler otomatik üretilir.
- **Kıst (gün bazlı) ilk ödeme:** Giriş tarihi ödeme gününden farklıysa ilk ay orantılı hesaplanır.
- **Peşin / Dönem sonu ödeme:** Kiracının kirayı önce mi (peşin) yoksa kaldıktan sonra mı (dönem sonu) ödeyeceği seçilebilir.
- **Finans takibi:** Dönem (geçmiş/bu ay/gelecek) ve durum filtreleri, aya göre gruplama, aylık toplamlar.
- **Ödeme geçmişi ve istatistik:** Zamanında ödeme yüzdesi, ortalama gecikme, ödeme alışkanlığı analizi.
- **İletişim kısayolları:** Kiracıyı ve acil durum kişisini tek dokunuşla arama veya WhatsApp'tan mesaj gönderme.
- **Kira sözleşmesi:** Kiracıya PDF/görsel sözleşme yükleme ve uygulama içinden açma.
- **Aydınlık/Karanlık tema:** Sistem temasına göre otomatik.

---

## Ekranlar ve Özellik Detayları

### Giriş Akışı
- **Splash / Onboarding:** Açılış ekranı ve tanıtım.
- **Auth Choice:** Google ile giriş, e-posta ile giriş ve hesap oluşturma seçenekleri.
- **Giriş / Kayıt / Şifremi Unuttum:** Form doğrulamalı, hata mesajları Türkçeleştirilmiş (`auth_error_messages.dart`).

### Ana Sayfa (Home)
- Bu ayın özeti: beklenen toplam, alınan ve geciken tutarlar (`SummaryCard`).
- **Yaklaşan ödemeler** listesi (önümüzdeki ~60 gün), ilk vadeye göre sıralı.
- Bir ödemeye dokununca **ödeme detay sayfası (bottom sheet)** açılır; buradan ödeme **"Ödendi" / "Ödenmedi"** olarak işaretlenebilir.
- Kıst ödemeler "Kıst" rozetiyle gösterilir.

### Mülklerim (Properties)
- Mülklerin kart listesi (fotoğraf/ikon, tip rozeti, atanmış kiracı ve kira).
- **Mülk detayı:** Fotoğraf, adres, tip, atanan kiracı ve kira; o mülke ait ödeme geçmişi.
- Sağ üstteki kalem ikonuyla **düzenleme**, listede **silme** (bağlı kiracı ve ödemeler de silinir).

### Kiracılar (Tenants)
- Kiracı kart listesi (fotoğraf, mülk, iletişim, ödeme günü).
- **Kiracı detayı:**
  - **Ara** ve **WhatsApp** hızlı iletişim butonları.
  - **Ödeme Geçmişi ve İstatistikler** butonu.
  - Kira bilgileri: aylık kira, ödeme günü, **ödeme şekli (peşin/dönem sonu)**, kira başlangıç/bitiş, depozito.
  - İletişim bilgileri ve **acil durum kişisi** (adı + telefonu, telefondan arama kısayolu).
  - Yüklüyse **kira sözleşmesi** (dokununca açılır).
  - Kalem ikonuyla düzenleme.

### Ödeme Geçmişi ve İstatistik
- **Zamanında ödeme yüzdesi** ve **yapılan ödeme sayısı** kartları.
- **Ödeme alışkanlığı** bandı: "Tam zamanında ödüyor", "Ortalama X gün geç/erken ödüyor".
- Yapılmış tüm ödemelerin listesi; her biri için vade, ödenme tarihi ve gecikme/erken etiketi.

### Finans (Finance)
- Bu ay alınan ve geciken tutar kartları.
- **Dönem filtresi:** Tümü / Geçmiş / Bu Ay / Gelecek.
- **Durum filtresi:** Tümü / Bekliyor / Gecikti / Ödendi.
- Ödemeler **aya göre gruplanır** (ay başlığında o ayın ödenen/toplam tutarı) ve **ilk ödemeden son ödemeye (artan)** sıralanır.
- Ödemeler listeden "Ödendi" olarak işaretlenebilir.

### Profil
- Firebase kullanıcı bilgileri (ad, e-posta, baş harfler).
- Ad güncelleme, bildirimlere erişim, yardım & destek ve çıkış.

### Bildirimler
- Kira hatırlatıcıları / uyarıları için ekran (örnek içerik).

### Hızlı Ekle
- Ana ekrandaki `+` butonuyla açılan alt menüden hızlıca **mülk, kiracı veya ödeme** ekleme.

---

## Kira ve Ödeme Mantığı

Ödemeler, kiracının **kira dönemi (başlangıç–bitiş)**, **ödeme günü**, **aylık kira**, **kıst** ve **ödeme şekli** ayarlarına göre otomatik üretilir (`RentalCubit._generatePaymentsForTenant`).

### Ödeme günü
Her ay kiranın tahsil edileceği gün (1–28 arası). Örn. "her ayın 15'i".

### Kıst (gün bazlı) ilk ödeme
Kiracının **giriş tarihi** ödeme gününden farklı olduğunda ilk ay orantılı hesaplanır.
- Örnek: Kiracı **2 Haziran**'da girdi, ödeme günü **15**, aylık kira 12.000 TL.
- 2–15 Haziran = 13 gün → ilk ödeme `12.000 × 13 / 30 ≈ 5.200 TL`.
- Sonraki aylar tam kira olarak 15'inde devam eder.
- Bu ödemeler arayüzde **"Kıst"** rozetiyle işaretlenir. Özellik kiracı formundan açılıp kapatılabilir; açıkken tutar önizlemesi gösterilir.

### Peşin / Dönem sonu ödeme
Kiracının kirayı ne zaman ödeyeceğini belirler:
- **Peşin (dönem başı):** Önce öder, sonra kalır. Ödeme dönemin başında (ödeme gününde) düşer.
- **Dönem sonu:** Kalır, sonra öder. Ödeme dönemin sonunda (bir sonraki ödeme gününde) düşer.

Bu seçim hem normal aylık ödemelerin hem de kıst ödemenin vade tarihini etkiler.

### Ödeme durumları
- **Bekliyor:** Vadesi gelmemiş.
- **Gecikti:** Vadesi geçmiş ve ödenmemiş (uygulama açılışında otomatik güncellenir).
- **Ödendi:** Ödenmiş; ödenme tarihi kaydedilir ve gecikme/erken istatistiğinde kullanılır.

---

## Mimari

Uygulama **BLoC/Cubit** tabanlı bir durum yönetimi kullanır ve katmanlara ayrılmıştır:

- **Model** (`lib/model`): Saf veri sınıfları (`Property`, `Tenant`, `Payment`, `PaymentStats`, `HomeSummary`) ve JSON serileştirme.
- **Service** (`lib/services`): Dış dünya ile temas eden sınıflar — kimlik doğrulama, yerel veri saklama, dosya/görsel seçme, telefon/WhatsApp.
- **Bloc** (`lib/bloc`): `AuthCubit` (oturum) ve `RentalCubit` (mülk/kiracı/ödeme) iş mantığını yönetir; `Equatable` tabanlı immutable state.
- **View** (`lib/view`): `BlocBuilder`/`BlocListener` ile state'i dinleyen ekranlar ve yeniden kullanılabilir widget'lar.

Veri akışı: **View → Cubit (metot) → Service (kalıcılık) → Cubit (emit state) → View (yeniden çizim)**.

---

## Klasör Yapısı

```
lib/
├── main.dart                      # Uygulama girişi, Firebase init, MultiBlocProvider
├── firebase_options.dart          # Firebase yapılandırması
├── bloc/
│   ├── auth/                       # AuthCubit + AuthState
│   └── rental/                     # RentalCubit + RentalState (mülk/kiracı/ödeme)
├── constants/                      # Renk paleti ve tema
├── model/                          # Property, Tenant, Payment, PaymentStats, HomeSummary
├── services/
│   ├── auth_service.dart           # Firebase Auth + Google Sign-In
│   ├── auth_error_messages.dart    # Hata mesajlarını Türkçeleştirme
│   ├── rental_data_service.dart    # SharedPreferences ile yerel kalıcılık + demo veri
│   ├── image_storage_service.dart  # Galeriden fotoğraf seçip kaydetme
│   ├── file_storage_service.dart   # Sözleşme dosyası seçip kaydetme
│   └── contact_service.dart        # Telefonla arama ve WhatsApp
└── view/
    ├── splash/                     # Splash / Onboarding
    ├── auth/                       # Giriş, kayıt, şifre sıfırlama + widget'lar
    ├── auth_choice/                # Giriş yöntemi seçimi
    └── home/
        ├── main_shell.dart         # Alt navigasyon (Ana Sayfa/Mülkler/Kiracılar/Finans)
        ├── home_tab.dart           # Ana sayfa
        ├── properties_tab.dart     # Mülk listesi
        ├── tenants_tab.dart        # Kiracı listesi
        ├── finance_tab.dart        # Finans (dönem/durum filtreli, aya göre gruplu)
        ├── property_detail_page.dart
        ├── tenant_detail_page.dart
        ├── tenant_payment_history_page.dart  # Ödeme geçmişi + istatistik
        ├── profile_page.dart
        ├── notifications_page.dart
        ├── forms/                  # Mülk/kiracı/ödeme ekleme-düzenleme formları
        └── widgets/                # AppHeader, PaymentCard, PaymentDetailSheet, vb.
```

---

## Kullanılan Paketler

| Paket | Amaç |
|-------|------|
| `flutter_bloc`, `equatable` | Durum yönetimi (Cubit) ve değer eşitliği |
| `firebase_core`, `firebase_auth` | Firebase ve kimlik doğrulama |
| `google_sign_in` | Google ile giriş |
| `shared_preferences` | Yerel veri saklama |
| `image_picker` | Galeriden fotoğraf seçme |
| `file_picker` | Kira sözleşmesi dosyası seçme |
| `open_filex` | Yüklenen sözleşmeyi açma |
| `url_launcher` | Telefonla arama ve WhatsApp |
| `path_provider` | Uygulama dosya dizinine erişim |

---

## Kurulum

### Gereksinimler
- Flutter SDK (Dart `^3.12.2`)
- Firebase projesi (Authentication etkin)

### Adımlar

1. Bağımlılıkları yükleyin:
   ```bash
   flutter pub get
   ```

2. Firebase yapılandırması (FlutterFire CLI ile):
   ```bash
   flutterfire configure
   ```
   Bu adım `lib/firebase_options.dart`, Android için `google-services.json` ve iOS için `GoogleService-Info.plist` dosyalarını oluşturur. Firebase konsolunda **Email/Password** ve **Google** giriş yöntemlerini etkinleştirin.

3. Uygulamayı çalıştırın:
   ```bash
   flutter run
   ```

> Not: Telefonla arama, WhatsApp ve dosya seçme özellikleri için gerekli izinler Android `AndroidManifest.xml` ve iOS `Info.plist` içinde tanımlıdır.

---

## Veri Saklama

Mülk, kiracı ve ödeme verileri şu an **cihaz üzerinde** `shared_preferences` ile JSON olarak saklanır (`rental_data_service.dart`) ve kullanıcı kimliğine (`userId`) göre ayrılır. İlk açılışta örnek (demo) veriler yüklenir. Fotoğraflar ve sözleşme dosyaları uygulamanın belge dizinine kopyalanır ve yolları kayıtlarda tutulur.

> Veriler henüz buluta senkronize edilmez; ileride Firestore gibi bir arka uç eklenerek çoklu cihaz senkronizasyonu sağlanabilir.
