# Shop App - Production-Grade Flutter E-Commerce Application

Профессиональное мобильное приложение для электронной коммерции на Flutter с современной архитектурой и лучшими практиками.

## Основные возможности

- Аутентификация пользователей (JWT с refresh tokens)
- Просмотр каталога продавцов и товаров
- Корзина покупок с поддержкой нескольких продавцов
- Управление заказами
- Управление адресами доставки
- Профиль пользователя
- Поиск по продавцам и товарам
- Кэширование данных для оптимальной производительности

## Архитектура

Проект следует принципам **Clean Architecture** с четким разделением ответственности:

```
lib/
├── api/              # API клиенты (DIO)
├── cache/            # Локальное кэширование
├── core/             # Ядро приложения
│   ├── constants/    # Константы приложения
│   ├── error/        # Обработка ошибок
│   ├── logger/       # Логирование
│   └── validators/   # Валидаторы форм
├── dto/              # Data Transfer Objects
├── models/           # Модели данных
├── providers/        # Riverpod state management
├── screens/          # UI экраны
├── services/         # Бизнес-логика
├── utils/            # Утилиты
└── widgets/          # Переиспользуемые виджеты
    ├── animations/   # Анимированные виджеты
    └── common/       # Общие компоненты
```

## Технологический стек

### Core
- **Flutter** - Cross-platform UI framework
- **Dart 3.9+** - Programming language

### State Management
- **flutter_riverpod** - Modern state management
- **riverpod_annotation** - Code generation for providers

### Network & Data
- **dio** - HTTP client
- **shared_preferences** - Key-value storage
- **hive** - NoSQL database
- **cached_network_image** - Image caching

### UI & Animations
- **shimmer** - Loading skeleton
- **flutter_animate** - Animations
- **lottie** - Complex animations
- **flutter_staggered_animations** - List animations

### Forms & Validation
- **flutter_form_builder** - Form building
- **form_builder_validators** - Validation

### Utilities
- **logger** - Advanced logging
- **connectivity_plus** - Network status
- **device_info_plus** - Device information
- **freezed** - Immutable data classes
- **json_serializable** - JSON serialization

### Testing
- **flutter_test** - Widget & unit testing
- **mocktail** - Mocking
- **mockito** - Mocking framework

## Начало работы

### Требования

- Flutter SDK 3.9.0 или выше
- Dart SDK 3.9.0 или выше

### Установка

1. Клонируйте репозиторий:
```bash
git clone <repository-url>
cd shop_app
```

2. Установите зависимости:
```bash
flutter pub get
```

3. Запустите кодогенерацию (если используется):
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Запустите приложение:
```bash
flutter run
```

### Конфигурация

Настройте API base URL через переменную окружения:

```bash
flutter run --dart-define=API_BASE_URL=https://your-api.com
```

## Best Practices

### Код-стайл

Проект следует строгим правилам анализа кода, определенным в `analysis_options.yaml`:

- Обязательные типы возврата
- Предпочтение `const` конструкторов
- Обязательные trailing commas
- Предпочтение относительных импортов
- И более 100 других правил

Проверка кода:
```bash
flutter analyze
```

### Тестирование

Запуск всех тестов:
```bash
flutter test
```

Запуск с покрытием:
```bash
flutter test --coverage
```

### Форматирование

```bash
dart format .
```

## Структура данных

### Аутентификация
- JWT tokens (access + refresh)
- Автоматическое обновление токенов
- Безопасное хранение в SharedPreferences

### Кэширование
- Кэш товаров с TTL 5 минут
- Кэш корзины в памяти
- Автоматическая инвалидация при логауте

### API Endpoints

#### Auth
- `POST /auth/register` - Регистрация
- `POST /auth/login` - Вход
- `POST /auth/refresh` - Обновление токена
- `POST /auth/logout` - Выход

#### Sellers
- `GET /clients/sellers` - Список продавцов
- `GET /clients/sellers/{id}` - Детали продавца

#### Products
- `GET /products/by-seller/{sellerId}` - Товары продавца

#### Cart
- `GET /orders/cart/seller/{sellerId}` - Корзина продавца
- `POST /orders/cart/items` - Добавить в корзину
- `PUT /orders/cart/items/{itemId}` - Обновить количество
- `DELETE /orders/cart/items/{itemId}` - Удалить из корзины

#### Orders
- `POST /orders/submit` - Создать заказ
- `GET /orders` - Список заказов
- `GET /orders/{orderId}` - Детали заказа

#### Addresses
- `GET /api/v1/addresses` - Список адресов
- `POST /api/v1/addresses` - Создать адрес
- `PUT /api/v1/addresses` - Обновить адрес
- `DELETE /api/v1/addresses/{id}` - Удалить адрес

## Обработка ошибок

Приложение использует иерархию кастомных ошибок:

- `AppError` - Базовый класс
- `NetworkError` - Сетевые ошибки
- `AuthError` - Ошибки аутентификации
- `ValidationError` - Ошибки валидации
- `BusinessLogicError` - Бизнес-логика
- `CacheError` - Ошибки кэша

Все ошибки автоматически логируются и показываются пользователю через SnackBar.

## Логирование

Используется пакет `logger` с разными уровнями:

```dart
AppLogger.debug('Debug message');
AppLogger.info('Info message');
AppLogger.warning('Warning message');
AppLogger.error('Error message', error, stackTrace);

// Специальные логи
AppLogger.apiRequest('GET', '/endpoint');
AppLogger.apiResponse('GET', '/endpoint', 200);
AppLogger.navigation('Screen1', 'Screen2');
AppLogger.userAction('button_click', params: {'id': '123'});
```

## Валидация

Кастомные валидаторы для форм:

```dart
Validators.email(value);
Validators.password(value);
Validators.phone(value);
Validators.required(value);
Validators.minLength(5)(value);
Validators.numeric(value);
Validators.positiveNumber(value);
Validators.bin(value); // Kazakhstan BIN

// Комбинация валидаторов
Validators.combine([
  Validators.required,
  Validators.minLength(5),
])(value);
```

## Анимации

### Fade In
```dart
FadeInAnimation(
  duration: AppConstants.mediumAnimation,
  delay: Duration(milliseconds: 100),
  child: YourWidget(),
)
```

### Slide In
```dart
SlideInAnimation(
  direction: AxisDirection.up,
  child: YourWidget(),
)
```

### Shimmer Loading
```dart
ShimmerLoading(
  enabled: isLoading,
  child: YourWidget(),
)
```

## Кастомные виджеты

### Custom Button
```dart
CustomButton(
  onPressed: () {},
  text: 'Нажми меня',
  isLoading: false,
  icon: Icons.add,
)
```

### Custom TextField
```dart
CustomTextField(
  controller: controller,
  labelText: 'Email',
  prefixIcon: Icons.email,
  validator: Validators.email,
)
```

## Производительность

- Использование `const` конструкторов где возможно
- Lazy loading для списков
- Кэширование изображений
- Дебаунс для поиска
- Оптимизация rebuilds через Riverpod
- Shimmer loading вместо обычных индикаторов

## Безопасность

- JWT tokens в secure storage
- HTTPS only
- Автоматическое обновление токенов
- Защита от CSRF
- Валидация на клиенте и сервере
- Логирование всех ошибок безопасности

## Roadmap

- [ ] Интеграция с платежными системами
- [ ] Push-уведомления
- [ ] Офлайн режим
- [ ] Избранное/Wishlist
- [ ] Отзывы и рейтинги
- [ ] Мультиязычность
- [ ] Темная тема
- [ ] Analytics (Firebase/Amplitude)
- [ ] Crash reporting (Sentry)

## Вклад в проект

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Лицензия

Copyright 2024. All rights reserved.

## Контакты

Для вопросов и предложений создайте Issue в репозитории.

---

Сделано с ❤️ используя Flutter
