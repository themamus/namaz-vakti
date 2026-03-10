# 🕌 Namaz Vakti

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-3.1+-0175C2?logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Android-5.0+-3DDC84?logo=android&logoColor=white" />
  <img src="https://img.shields.io/badge/iOS-13.0+-000000?logo=apple&logoColor=white" />
  <img src="https://img.shields.io/badge/API-Aladhan-green" />
  <img src="https://img.shields.io/badge/License-MIT-yellow" />
</p>

<p align="center">
GPS konumunuza göre günlük namaz vakitlerini gösteren, kıble yönünü hesaplayan ve ezan bildirimleri gönderen production-ready Flutter uygulaması.
</p>

---

## ✨ Özellikler

| Özellik | Detay |
|---------|-------|
| 📍 Konum | GPS otomatik tespit + manuel şehir arama |
| 🕐 6 Vakit | İmsak, Güneş, Öğle, İkindi, Akşam, Yatsı |
| ⏱ Geri Sayım | Sıradaki vakite canlı geri sayım |
| 🔔 Bildirim | Vakit başına ayrı bildirim + titreşim kontrolü |
| 🧭 Kıble | Manyetik pusula ile Mekke yönü ve mesafesi |
| 📅 Hicri Takvim | Hicri/Miladi tarih, önemli İslami günler |
| 🌙 Ramazan Modu | İmsak & İftar saatleri özel banner |
| 🌗 Dark Mode | Tam Material 3 karanlık tema |
| 🌍 Çoklu Dil | Türkçe · İngilizce · Arapça |
| 📶 Offline | 24 saatlik önbellek, internetsiz çalışır |

---

## 🏗 Mimari

Clean Architecture — 3 katmanlı yapı:

```
lib/
├── core/
│   ├── constants/app_constants.dart
│   ├── errors/failures.dart
│   ├── theme/app_theme.dart
│   └── utils/
│       ├── location_service.dart
│       ├── notification_service.dart
│       └── qibla_service.dart
├── data/
│   ├── datasources/
│   │   ├── remote/prayer_times_remote_datasource.dart
│   │   └── local/prayer_times_local_datasource.dart
│   ├── models/prayer_times_model.dart
│   └── repositories/prayer_times_repository_impl.dart
├── domain/
│   └── entities/prayer_times_entity.dart
└── presentation/
    ├── providers/
    ├── screens/
    └── widgets/
```

---

## 🚀 Kurulum

### 1. Repoyu Klonla

```bash
git clone https://github.com/KULLANICI_ADIN/namaz_vakti.git
cd namaz_vakti
```

### 2. Bağımlılıkları Yükle

```bash
flutter pub get
```

### 3. Ezan Seslerini Ekle

`assets/sounds/` klasörüne ekleyin (detay: `assets/sounds/README.md`):

```
azan_default.mp3 · azan_mecca.mp3 · azan_medina.mp3 · azan_turkey.mp3
```

### 4. iOS (sadece macOS)

```bash
cd ios && pod install && cd ..
```

### 5. Çalıştır

```bash
flutter run                          # Debug
flutter build apk --release          # Android APK
flutter build appbundle --release    # Play Store
flutter build ios --release          # iOS
```

---

## ⚙️ Varsayılan Ayarlar

`lib/core/constants/app_constants.dart`:

```dart
static const int defaultCalculationMethod = 13; // Diyanet İşleri Başkanlığı
```

| ID | Kurum |
|----|-------|
| **13** | Diyanet İşleri Başkanlığı ⭐ |
| 1 | Muslim World League |
| 4 | Umm Al-Qura, Makkah |
| 2 | ISNA North America |

---

## 📦 Temel Paketler

`provider` · `http` · `geolocator` · `geocoding` · `flutter_local_notifications` · `flutter_compass` · `shared_preferences` · `connectivity_plus` · `just_audio` · `hijri` · `google_fonts`

---

## 🌐 API

[Aladhan API](https://aladhan.com/prayer-times-api) — Ücretsiz, anahtarsız.

---

## 🔒 Gizlilik

Kullanıcı verisi toplanmaz. Konum yalnızca API parametresi olarak kullanılır.

---

## 📄 Lisans

MIT — Detaylar için [LICENSE](LICENSE) dosyasına bakın.

---

<p align="center"><b>🕌 Allah kabul etsin 🤲</b></p>
