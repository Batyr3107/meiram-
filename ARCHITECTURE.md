# Архитектура проекта

## Обзор

Проект следует **Clean Architecture** принципам с четким разделением ответственности.

## Диаграмма слоев

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Screens    │  │   Widgets    │  │   Providers  │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│                     Domain Layer                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  Use Cases   │  │  Entities    │  │ Repositories │  │
│  │              │  │              │  │ (Interface)  │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│                      Data Layer                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Repositories │  │     API      │  │    Cache     │  │
│  │    (Impl)    │  │   Clients    │  │              │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│                      Core Layer                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │    Logger    │  │    Error     │  │  Validators  │  │
│  ├──────────────┤  ├──────────────┤  ├──────────────┤  │
│  │   Security   │  │   Network    │  │ Performance  │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## Структура директорий

```
lib/
├── core/                     # Кросс-cutting concerns
│   ├── constants/            # Константы приложения
│   ├── di/                   # Dependency Injection
│   ├── error/                # Обработка ошибок
│   ├── logger/               # Логирование
│   ├── network/              # HTTP клиент, retry logic
│   ├── performance/          # Performance monitoring
│   ├── security/             # Secure storage, sanitization
│   └── validators/           # Валидаторы форм
│
├── domain/                   # Бизнес-логика (независима от фреймворка)
│   ├── entities/             # Бизнес-объекты
│   ├── repositories/         # Интерфейсы репозиториев
│   └── usecases/             # Use cases (бизнес-правила)
│
├── data/                     # Работа с данными
│   ├── datasources/          # API, Database, Cache
│   └── repositories/         # Имплементации репозиториев
│
├── presentation/             # UI слой
│   ├── providers/            # Riverpod providers
│   ├── notifiers/            # State notifiers
│   ├── screens/              # Экраны приложения
│   └── widgets/              # Переиспользуемые виджеты
│       ├── animations/       # Анимированные виджеты
│       └── common/           # Общие компоненты
│
├── api/                      # Legacy API clients (будет рефакторен)
├── dto/                      # Data Transfer Objects
├── models/                   # Data models
├── services/                 # Legacy services (будет рефакторен)
└── main.dart                 # Entry point
```

## Принципы

### 1. Dependency Rule

Зависимости направлены **внутрь**:
- Presentation → Domain ← Data
- Domain не зависит ни от кого
- Data зависит от Domain (через интерфейсы)

### 2. SOLID Principles

**Single Responsibility**
- Каждый класс решает одну задачу
- Use Cases инкапсулируют одну бизнес-операцию

**Open/Closed**
- Открыт для расширения, закрыт для модификации
- Используем интерфейсы (IAuthRepository)

**Liskov Substitution**
- Имплементации взаимозаменяемы
- MockRepository можно использовать вместо RealRepository

**Interface Segregation**
- Интерфейсы узкие и специфичные
- Нет "god interfaces"

**Dependency Inversion**
- Зависим от абстракций, не от конкретных реализаций
- Use Cases зависят от IRepository, не от конкретной имплементации

### 3. DRY (Don't Repeat Yourself)

- Переиспользуемые компоненты в widgets/common
- Общая логика в core
- Use Cases избегают дублирования

### 4. KISS (Keep It Simple, Stupid)

- Простые, понятные решения
- Избегаем over-engineering
- Код читается как проза

## Data Flow

### Пример: Login Flow

```
User Input (LoginScreen)
    ↓
Presentation Layer (LoginProvider)
    ↓
Domain Layer (LoginUseCase)
    ↓
    ├─→ Validate Input (Validators)
    ├─→ Sanitize Input (InputSanitizer)
    └─→ Call Repository (IAuthRepository)
          ↓
Data Layer (AuthRepositoryImpl)
    ↓
    ├─→ API Call (AuthApi)
    ├─→ Retry Logic (RetryInterceptor)
    └─→ Error Handling (NetworkError)
          ↓
    Save to Secure Storage
          ↓
    Return AuthResponse
          ↓
Update UI State
```

## Error Handling

```
Exception/Error
    ↓
ErrorHandler.handleError()
    ↓
    ├─→ AppError (ValidationError, AuthError, etc.)
    ├─→ Log Error (AppLogger)
    └─→ Show User Feedback (SnackBar)
```

## State Management

**Riverpod** для reactive state:

```dart
// Provider definition
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(...);

// Usage in widget
Consumer(
  builder: (context, ref, child) {
    final authState = ref.watch(authProvider);
    return ...;
  },
)
```

## Security

1. **Sensitive Data**: FlutterSecureStorage
2. **Input**: Sanitization перед обработкой
3. **Network**: Retry logic, timeout
4. **Validation**: На клиенте и сервере

## Performance

1. **const конструкторы** где возможно
2. **Performance monitoring** для slow operations
3. **Lazy loading** для списков
4. **Image caching** для изображений
5. **Rebuild optimization** через Riverpod

## Testing Strategy

```
Unit Tests       → Use Cases, Validators, Utils
Widget Tests     → UI Components
Integration Tests → Complete user flows
Golden Tests     → Visual regression
```

## Future Improvements

- [ ] Offline-first с Hive
- [ ] GraphQL вместо REST
- [ ] Feature flags
- [ ] A/B testing
- [ ] Analytics integration
- [ ] Crash reporting
- [ ] Push notifications
- [ ] Deep linking

## Полезные ссылки

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course)
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)
- [Riverpod Documentation](https://riverpod.dev/)
