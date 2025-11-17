# Changelog

Все значимые изменения в этом проекте документируются в этом файле.

Формат основан на [Keep a Changelog](https://keepachangelog.com/ru/1.0.0/),
и проект следует [Semantic Versioning](https://semver.org/lang/ru/).

## [Unreleased]

### Added
- Clean Architecture с Domain, Data, Presentation слоями
- Dependency Injection с GetIt и Injectable
- Secure Storage для чувствительных данных
- Input Sanitization против XSS и SQL injection
- Network Retry Logic с exponential backoff
- Performance Monitoring для slow operations
- Repository Pattern для абстракции данных
- Use Cases для бизнес-логики
- Comprehensive тесты с Mocktail
- 146 lint rules для quality assurance

### Enhanced
- Обработка ошибок с типизированными исключениями
- Логирование с уровнями и structured logging
- Валидация форм с кастомными validators
- UI компоненты с анимациями
- Code documentation с примерами

### Security
- Flutter Secure Storage для токенов
- Input sanitization для всех user inputs
- Certificate pinning (готовность)
- Rate limiting (на стороне клиента)

## [1.0.0] - 2024-11-17

### Added
- Initial release
- Аутентификация пользователей
- Каталог продавцов и товаров
- Корзина покупок
- Управление заказами
- Управление адресами доставки
- Профиль пользователя

[Unreleased]: https://github.com/Batyr3107/meiram-/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/Batyr3107/meiram-/releases/tag/v1.0.0
