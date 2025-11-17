# Руководство по Сборке APK - ShopMobile App

## 📋 Требования

### 1. Flutter SDK
- **Версия:** 3.9.0 или выше
- **Канал:** stable

### 2. Java Development Kit (JDK)
- **Версия:** 17 (уже установлен: `C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot`)
- **Переменная окружения:** `JAVA_HOME` должна указывать на JDK

### 3. Android SDK
- **Устанавливается:** через Android Studio или Flutter
- **Минимальная версия:** Android 5.0 (API level 21)

---

## 🚀 Установка Flutter (если не установлен)

### Вариант 1: Скачать Flutter SDK

1. **Скачать Flutter:**
   ```
   https://docs.flutter.dev/get-started/install/windows
   ```

2. **Распаковать в:**
   ```
   C:\src\flutter
   ```

3. **Добавить в PATH:**
   ```
   C:\src\flutter\bin
   ```

4. **Проверить установку:**
   ```bash
   flutter doctor
   ```

### Вариант 2: Использовать Chocolatey

```bash
choco install flutter
```

### Вариант 3: Использовать Scoop

```bash
scoop bucket add extras
scoop install flutter
```

---

## 🔧 Настройка Проекта

### 1. Установить зависимости

```bash
cd c:\Users\JusanUser\PycharmProjects\pythonProject2\shopmobile-master\shopmobile-master

# Получить зависимости
flutter pub get

# Сгенерировать код (если нужно)
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Проверить конфигурацию

```bash
# Проверить наличие устройств и SDK
flutter doctor -v

# Проверить проект
flutter analyze
```

---

## 📦 Сборка APK

### Вариант 1: Release APK (рекомендуется)

```bash
# Собрать release APK (оптимизированный)
flutter build apk --release

# Расположение готового APK:
# build/app/outputs/flutter-apk/app-release.apk
```

### Вариант 2: Debug APK (для тестирования)

```bash
# Собрать debug APK (с отладочной информацией)
flutter build apk --debug

# Расположение:
# build/app/outputs/flutter-apk/app-debug.apk
```

### Вариант 3: Split APKs (по архитектурам)

```bash
# Собрать отдельные APK для каждой архитектуры
flutter build apk --split-per-abi

# Расположение:
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
# build/app/outputs/flutter-apk/app-x86_64-release.apk
```

### Вариант 4: Bundle (для Google Play)

```bash
# Собрать Android App Bundle (для публикации в Google Play)
flutter build appbundle --release

# Расположение:
# build/app/outputs/bundle/release/app-release.aab
```

---

## 🎯 Быстрая Сборка (Один Скрипт)

### Создан скрипт: `build_apk.bat`

Используйте готовый скрипт:

```bash
# Запустить сборку
build_apk.bat
```

Скрипт автоматически:
1. Проверит наличие Flutter
2. Установит зависимости
3. Соберет release APK
4. Покажет размер файла
5. Скопирует APK в удобное место

---

## 📱 Установка APK на Устройство

### На физическом устройстве:

1. **Включить режим разработчика:**
   - Настройки → О телефоне → 7 раз нажать на "Номер сборки"

2. **Включить установку из неизвестных источников:**
   - Настройки → Безопасность → Неизвестные источники

3. **Установить через ADB:**
   ```bash
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

4. **Или скопировать APK на устройство** и установить вручную

### На эмуляторе Android:

```bash
# Запустить эмулятор
flutter emulators --launch <emulator_id>

# Установить APK
flutter install
```

---

## 🔍 Проверка Сборки

### Проверить размер APK:

```bash
# Показать размер APK
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

### Проанализировать содержимое APK:

```bash
# Показать содержимое APK
flutter build apk --analyze-size
```

### Запустить на устройстве:

```bash
# Запустить приложение
flutter run --release
```

---

## 🐛 Решение Проблем

### Ошибка: "Flutter not found"

**Решение:**
1. Установить Flutter SDK (см. раздел "Установка Flutter")
2. Добавить `flutter\bin` в PATH
3. Перезапустить терминал

### Ошибка: "Android SDK not found"

**Решение:**
```bash
flutter doctor --android-licenses
```

### Ошибка: "Gradle build failed"

**Решение:**
1. Проверить `JAVA_HOME`:
   ```bash
   echo %JAVA_HOME%
   # Должно быть: C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot
   ```

2. Очистить кэш:
   ```bash
   flutter clean
   flutter pub get
   ```

3. Пересобрать:
   ```bash
   flutter build apk --release
   ```

### Ошибка: "Out of memory"

**Решение:**
Увеличить память для Gradle в `android/gradle.properties`:
```properties
org.gradle.jvmargs=-Xmx4096m
```

---

## 🎨 Настройка APK

### Изменить название приложения:

Файл: `android/app/src/main/AndroidManifest.xml`
```xml
<application android:label="Shop Mobile">
```

### Изменить иконку:

1. Поместить иконку в: `android/app/src/main/res/mipmap-*/ic_launcher.png`
2. Или использовать: `flutter_launcher_icons` package

### Изменить версию:

Файл: `pubspec.yaml`
```yaml
version: 1.0.0+1
# Формат: version_name+build_number
```

---

## 📊 CI/CD Сборка (GitHub Actions)

APK автоматически собирается при push в `main` ветку:

1. **Перейти на GitHub:**
   ```
   https://github.com/Batyr3107/meiram-/actions
   ```

2. **Найти последний workflow:**
   - Название: "Flutter CI/CD"

3. **Скачать артефакт:**
   - Artifacts → `release-apk`

**Преимущества CI/CD:**
- ✅ Автоматическая сборка
- ✅ Тестирование перед сборкой
- ✅ Анализ кода
- ✅ Доступность APK без локальной сборки

---

## 📝 Команды для Быстрого Старта

```bash
# 1. Установить зависимости
flutter pub get

# 2. Проверить проект
flutter analyze

# 3. Собрать release APK
flutter build apk --release

# 4. Найти готовый APK
echo build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔗 Полезные Ссылки

- [Flutter Documentation](https://docs.flutter.dev/)
- [Android Developers](https://developer.android.com/)
- [Flutter Build Modes](https://docs.flutter.dev/testing/build-modes)
- [Publishing APK](https://docs.flutter.dev/deployment/android)

---

## ✅ Финальная Проверка

После успешной сборки вы получите:

```
✓ Flutter SDK установлен
✓ Зависимости получены
✓ APK успешно собран
✓ Файл: build/app/outputs/flutter-apk/app-release.apk
✓ Размер: ~15-25 MB
```

**APK готов к установке и тестированию!** 🎉
