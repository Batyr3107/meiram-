# Contributing to Shop App

Спасибо за интерес к улучшению проекта! 🎉

## Процесс разработки

1. **Fork репозитория**
2. **Создайте feature ветку** (`git checkout -b feature/amazing-feature`)
3. **Commit изменений** (`git commit -m 'Add amazing feature'`)
4. **Push в ветку** (`git push origin feature/amazing-feature`)
5. **Откройте Pull Request**

## Стандарты кода

### Dart/Flutter

- Следуйте [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Запускайте `flutter analyze` перед commit
- Запускайте `flutter test` перед commit
- Используйте `dart format .` для форматирования

### Commit Messages

Следуем [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add new feature
fix: bug fix
docs: documentation changes
style: formatting, missing semicolons, etc.
refactor: code restructuring
perf: performance improvements
test: adding tests
chore: maintain
```

### Code Review

- Все PR требуют review перед merge
- Минимум 1 approval
- Все тесты должны проходить
- Code coverage не должен падать

## Тестирование

### Unit Tests

```dart
test('should return valid result', () {
  // Arrange
  final input = 'test';
  
  // Act
  final result = function(input);
  
  // Assert
  expect(result, expectedValue);
});
```

### Widget Tests

```dart
testWidgets('should display text', (WidgetTester tester) async {
  await tester.pumpWidget(MyWidget());
  expect(find.text('Hello'), findsOneWidget);
});
```

## Документация

- Все public API должны иметь документацию
- Используйте `///` для documentation comments
- Добавляйте примеры использования

```dart
/// Validates email address
///
/// Returns error message if invalid, null if valid.
///
/// Example:
/// ```dart
/// final error = Validators.email('test@example.com');
/// if (error != null) {
///   print('Invalid email');
/// }
/// ```
String? email(String? value) {
  // implementation
}
```

## Вопросы?

Создайте [Issue](https://github.com/Batyr3107/meiram-/issues) для:
- Багов
- Feature requests
- Вопросов
- Предложений

Спасибо за contribution! 🚀
