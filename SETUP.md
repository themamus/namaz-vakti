# 🛠 Kurulum Rehberi — Namaz Vakti

Bu dosya, uygulamayı sıfırdan çalışır hale getirmek için gereken tüm adımları içerir.

---

## 1. Flutter Kurulumu (yoksa)

```bash
# macOS / Linux
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Kurulumu doğrula
flutter doctor
```

> Windows için: https://flutter.dev/docs/get-started/install/windows

---

## 2. Projeyi İndir

```bash
git clone https://github.com/KULLANICI_ADIN/namaz_vakti.git
cd namaz_vakti
```

---

## 3. Bağımlılıkları Yükle

```bash
flutter pub get
```

---

## 4. Ezan Seslerini Ekle

`assets/sounds/` klasörüne şu 4 MP3 dosyasını ekleyin:

```
azan_default.mp3
azan_mecca.mp3
azan_medina.mp3
azan_turkey.mp3
```

Ücretsiz kaynak için `assets/sounds/README.md` dosyasına bakın.

---

## 5. Android Kurulumu

### android/local.properties dosyası oluştur:

```
sdk.dir=/Users/KULLANICI/Library/Android/sdk
flutter.sdk=/Users/KULLANICI/flutter
flutter.buildMode=debug
flutter.versionName=1.0.0
flutter.versionCode=1
```

> `sdk.dir` yolunu kendi sisteminize göre değiştirin.

### Paket adını değiştir (isteğe bağlı):

`android/app/build.gradle` dosyasında:
```gradle
applicationId "com.SIRKETINIZ.namazvakti"
```

---

## 6. iOS Kurulumu (sadece macOS)

```bash
cd ios
pod install
cd ..
```

`ios/Runner/Info.plist` dosyasında Bundle ID'yi güncelleyin.

---

## 7. Çalıştır

```bash
# Bağlı cihazları listele
flutter devices

# Belirli cihazda çalıştır
flutter run -d <device_id>

# Tüm platformlarda
flutter run
```

---

## 8. Release Build

### Android APK:
```bash
flutter build apk --release
# Çıktı: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (Play Store):
```bash
flutter build appbundle --release
# Çıktı: build/app/outputs/bundle/release/app-release.aab
```

### iOS (Xcode gerekli):
```bash
flutter build ios --release
# Sonra Xcode'dan Archive → Distribute App
```

---

## 9. İmzalama (Release için zorunlu)

### Android — keystore oluştur:
```bash
keytool -genkey -v -keystore namaz_vakti.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias namaz_vakti
```

`android/key.properties` oluştur:
```
storePassword=SIFRENIZ
keyPassword=SIFRENIZ
keyAlias=namaz_vakti
storeFile=../namaz_vakti.jks
```

`android/app/build.gradle` içine ekle:
```gradle
def keyProperties = new Properties()
def keyPropertiesFile = rootProject.file('key.properties')
if (keyPropertiesFile.exists()) {
    keyPropertiesFile.withReader('UTF-8') { reader ->
        keyProperties.load(reader)
    }
}

android {
    signingConfigs {
        release {
            keyAlias keyProperties['keyAlias']
            keyPassword keyProperties['keyPassword']
            storeFile keyProperties['storeFile'] ? file(keyProperties['storeFile']) : null
            storePassword keyProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

---

## 10. Sorun Giderme

| Sorun | Çözüm |
|-------|-------|
| `flutter doctor` hata | Eksik araçları `flutter doctor --android-licenses` ile kabul et |
| `pod install` başarısız | `sudo gem install cocoapods && pod repo update` |
| Build hatası | `flutter clean && flutter pub get` |
| Konum çalışmıyor | Emülatörde: Extended Controls > Location |
| API yanıt vermiyor | VPN kapalı mı? `api.aladhan.com` erişilebilir mi? |
| Bildirim gelmiyor | Cihaz Ayarları > Uygulamalar > Namaz Vakti > Bildirimler |

---

## 11. Klasör Yapısı Özeti

```
namaz_vakti/
├── lib/                    ← Tüm Dart kodu
├── android/                ← Android native dosyaları
├── ios/                    ← iOS native dosyaları
├── assets/
│   ├── sounds/             ← MP3 ezan sesleri (manuel ekle)
│   ├── translations/       ← TR/EN/AR dil dosyaları
│   └── fonts/              ← Özel fontlar
├── test/                   ← Unit testler
├── pubspec.yaml            ← Proje bağımlılıkları
├── .gitignore
├── README.md
├── LICENSE
└── SETUP.md                ← Bu dosya
```
