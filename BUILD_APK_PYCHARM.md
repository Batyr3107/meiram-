# Сборка APK через PyCharm - Пошаговая Инструкция

## 🎯 Быстрый Старт

Ваш Flutter SDK найден:
```
C:\Users\JusanUser\Downloads\flutter_windows_3.32.5-stable\flutter
```

---

## 📱 Способ 1: Через PyCharm (Рекомендуется)

### Шаг 1: Открыть Терминал в PyCharm

1. Откройте проект в PyCharm
2. Внизу нажмите на вкладку **"Terminal"** или нажмите `Alt+F12`
3. Убедитесь что терминал открыт в директории проекта:
   ```
   c:\Users\JusanUser\PycharmProjects\pythonProject2\shopmobile-master\shopmobile-master
   ```

### Шаг 2: Установить Flutter Path (Если не настроен)

В терминале PyCharm выполните:

```powershell
# Временно добавить Flutter в PATH для текущей сессии
$env:PATH = "C:\Users\JusanUser\Downloads\flutter_windows_3.32.5-stable\flutter\bin;$env:PATH"

# Проверить Flutter
flutter --version
```

**Ожидаемый результат:**
```
Flutter 3.32.5 • channel stable
Dart 3.8.1
```

### Шаг 3: Получить Зависимости

```powershell
flutter pub get
```

**Ожидаемый результат:**
```
Running "flutter pub get" in shop_app...
Got dependencies!
```

### Шаг 4: Собрать APK

```powershell
flutter build apk --release
```

**Процесс займёт ~3-5 минут:**
```
Building with sound null safety
Running Gradle task 'assembleRelease'...
✓ Built build\app\outputs\flutter-apk\app-release.apk (15.2MB)
```

### Шаг 5: Найти APK

APK будет здесь:
```
c:\Users\JusanUser\PycharmProjects\pythonProject2\shopmobile-master\shopmobile-master\build\app\outputs\flutter-apk\app-release.apk
```

---

## 📱 Способ 2: Через PowerShell (Альтернатива)

### Шаг 1: Открыть PowerShell

1. Нажмите `Win + X`
2. Выберите **"Windows PowerShell"** или **"Terminal"**

### Шаг 2: Перейти в Проект

```powershell
cd c:\Users\JusanUser\PycharmProjects\pythonProject2\shopmobile-master\shopmobile-master
```

### Шаг 3: Установить Flutter Path

```powershell
$env:PATH = "C:\Users\JusanUser\Downloads\flutter_windows_3.32.5-stable\flutter\bin;$env:PATH"
```

### Шаг 4: Собрать APK

```powershell
flutter pub get
flutter build apk --release
```

---

## 📱 Способ 3: Через CMD

### Открыть CMD и выполнить:

```cmd
cd c:\Users\JusanUser\PycharmProjects\pythonProject2\shopmobile-master\shopmobile-master

set PATH=C:\Users\JusanUser\Downloads\flutter_windows_3.32.5-stable\flutter\bin;%PATH%

flutter pub get
flutter build apk --release
```

---

## 🔧 Настройка Flutter в PyCharm (Один раз)

### Для постоянной настройки Flutter в PyCharm:

1. **Откройте Settings:**
   - `File` → `Settings` (или `Ctrl+Alt+S`)

2. **Найдите Flutter:**
   - `Languages & Frameworks` → `Flutter`

3. **Укажите Flutter SDK Path:**
   ```
   C:\Users\JusanUser\Downloads\flutter_windows_3.32.5-stable\flutter
   ```

4. **Нажмите Apply → OK**

5. **Перезапустите PyCharm**

После этого вы сможете:
- Видеть Flutter проекты
- Использовать Flutter команды напрямую
- Запускать на эмуляторах через PyCharm

---

## 🎨 Настройка APK

### Изменить Название Приложения

Файл: `android/app/src/main/AndroidManifest.xml`
```xml
<application
    android:label="Shop Mobile"
    ...>
```

### Изменить Версию

Файл: `pubspec.yaml`
```yaml
version: 1.0.1+2  # version_name+build_number
```

### Изменить Иконку

Поместите иконку в:
```
android/app/src/main/res/mipmap-hdpi/ic_launcher.png
android/app/src/main/res/mipmap-mdpi/ic_launcher.png
android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
```

---

## 🐛 Решение Проблем

### Ошибка: "Flutter SDK not found"

**Решение:**
Убедитесь что путь правильный:
```powershell
Test-Path "C:\Users\JusanUser\Downloads\flutter_windows_3.32.5-stable\flutter\bin\flutter.bat"
# Должно вернуть: True
```

### Ошибка: "Gradle build failed"

**Решение:**
```powershell
# Очистить предыдущие сборки
flutter clean

# Получить зависимости заново
flutter pub get

# Собрать снова
flutter build apk --release
```

### Ошибка: "Android SDK not found"

**Решение:**
```powershell
# Запустить Flutter doctor
flutter doctor

# Принять Android лицензии
flutter doctor --android-licenses
```

### Ошибка: "Dart SDK version conflict"

**Решение:**
Уже исправлено! В `pubspec.yaml` теперь:
```yaml
environment:
  sdk: '>=3.8.0 <4.0.0'  # ✅ Совместимо с вашим Flutter
```

---

## 📊 Варианты Сборки

### 1. Release APK (Рекомендуется для установки)
```powershell
flutter build apk --release
```
- Оптимизированный
- Размер: ~15-25 MB
- Быстрый
- Для установки на устройства

### 2. Debug APK (Для разработки)
```powershell
flutter build apk --debug
```
- С отладочной информацией
- Размер: ~30-40 MB
- Для тестирования

### 3. Split APK (Отдельно для каждой архитектуры)
```powershell
flutter build apk --split-per-abi
```
Создаёт отдельные APK:
- `app-armeabi-v7a-release.apk` (для старых телефонов)
- `app-arm64-v8a-release.apk` (для современных телефонов)
- `app-x86_64-release.apk` (для эмуляторов)

### 4. Android App Bundle (Для Google Play)
```powershell
flutter build appbundle --release
```
- Формат: `.aab`
- Для публикации в Google Play Store

---

## 📱 Установка APK на Устройство

### Вариант 1: Через ADB

```powershell
# Включить USB Debugging на телефоне
# Подключить телефон к компьютеру

# Установить APK
adb install build\app\outputs\flutter-apk\app-release.apk
```

### Вариант 2: Вручную

1. Скопируйте APK на телефон
2. Откройте файл на телефоне
3. Разрешите установку из неизвестных источников
4. Нажмите "Установить"

---

## ✅ Финальная Проверка

После успешной сборки:

```
✓ Flutter SDK: C:\Users\JusanUser\Downloads\flutter_windows_3.32.5-stable\flutter
✓ Dart SDK: 3.8.1
✓ Проект: shop_app
✓ APK: build\app\outputs\flutter-apk\app-release.apk
✓ Размер: ~15-25 MB
```

---

## 🚀 Быстрая Команда (Всё в Одном)

Скопируйте и вставьте в PowerShell терминал PyCharm:

```powershell
# Установить путь к Flutter
$env:PATH = "C:\Users\JusanUser\Downloads\flutter_windows_3.32.5-stable\flutter\bin;$env:PATH"

# Очистить предыдущие сборки
flutter clean

# Получить зависимости
flutter pub get

# Собрать release APK
flutter build apk --release

# Показать размер APK
Get-Item build\app\outputs\flutter-apk\app-release.apk | Select-Object Name, @{Name="Size (MB)"; Expression={[math]::Round($_.Length / 1MB, 2)}}

# Открыть папку с APK
explorer build\app\outputs\flutter-apk
```

**Готово!** APK собран и готов к установке! 🎉

---

## 📚 Дополнительная Информация

- **Flutter Documentation:** https://docs.flutter.dev/
- **PyCharm Flutter Plugin:** https://plugins.jetbrains.com/plugin/9212-flutter
- **Android Developers:** https://developer.android.com/

---

**Примечание:** Если возникнут проблемы, обратитесь к [BUILD_APK_GUIDE.md](BUILD_APK_GUIDE.md) для детальных инструкций.
