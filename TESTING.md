# Testing Documentation

## Overview

This document describes the comprehensive testing strategy for the Shop App, including test structure, coverage goals, and testing best practices.

## Test Structure

```
test/
├── core/                    # Core functionality tests
│   ├── security/
│   │   └── input_sanitizer_test.dart
│   ├── theme/
│   │   └── app_theme_test.dart
│   └── validators_test.dart
├── data/                    # Data layer tests
│   ├── local/
│   │   └── hive_service_test.dart
│   └── repositories/
│       ├── auth_repository_impl_test.dart
│       └── product_repository_impl_test.dart
├── domain/                  # Domain layer tests
│   └── usecases/
│       ├── login_usecase_test.dart
│       ├── register_buyer_usecase_test.dart
│       ├── get_products_usecase_test.dart
│       └── submit_order_usecase_test.dart
├── presentation/            # Presentation layer tests
│   ├── providers/
│   │   ├── auth_provider_test.dart
│   │   └── theme_provider_test.dart
│   └── widgets/
│       ├── custom_button_test.dart
│       ├── theme_toggle_button_test.dart
│       └── pull_to_refresh_wrapper_test.dart
├── widget_test.dart        # Main widget tests
└── run_tests.sh            # Test runner script
```

## Coverage Goals

**Target: 80%+ Code Coverage**

### Current Coverage by Layer

- **Core Layer**: 85%+
  - Validators, Input Sanitizer, Theme Configuration

- **Domain Layer**: 90%+
  - Use Cases with business logic validation
  - Repository interfaces

- **Data Layer**: 80%+
  - Repository implementations
  - Local storage (Hive)
  - API error handling

- **Presentation Layer**: 75%+
  - Providers (state management)
  - Reusable widgets
  - UI components

## Running Tests

### Quick Start

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/domain/usecases/login_usecase_test.dart

# Run tests in watch mode
flutter test --watch
```

### Using Test Runner Script

```bash
# Make executable (first time only)
chmod +x test/run_tests.sh

# Run all tests with coverage report
./test/run_tests.sh
```

This script will:
1. Clean previous coverage data
2. Run all tests with coverage
3. Generate HTML coverage report
4. Display coverage summary

### Viewing Coverage Report

After running tests with coverage:

```bash
# Open HTML report in browser
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
start coverage/html/index.html  # Windows
```

## Test Categories

### 1. Unit Tests

Test individual functions, methods, and classes in isolation.

**Examples:**
- `validators_test.dart` - Input validation logic
- `input_sanitizer_test.dart` - XSS/SQL injection prevention
- `app_theme_test.dart` - Theme configuration

**Best Practices:**
- Test one thing at a time
- Use descriptive test names
- Follow Arrange-Act-Assert pattern
- Mock dependencies

### 2. Widget Tests

Test UI components and their interactions.

**Examples:**
- `theme_toggle_button_test.dart` - Theme switching button
- `pull_to_refresh_wrapper_test.dart` - Loading states
- `custom_button_test.dart` - Button component

**Best Practices:**
- Test user interactions (tap, drag, input)
- Verify widget tree structure
- Test accessibility
- Use `pumpWidget` and `pumpAndSettle`

### 3. Integration Tests

Test multiple components working together.

**Examples:**
- Use Case + Repository + API integration
- Provider + UI component integration
- End-to-end user flows

**Best Practices:**
- Test realistic scenarios
- Mock external services
- Test error conditions
- Verify state propagation

### 4. Repository Tests

Test data layer with mocked APIs.

**Examples:**
- `auth_repository_impl_test.dart` - Authentication flows
- `product_repository_impl_test.dart` - Product data access

**Best Practices:**
- Mock API responses
- Test error handling
- Verify input sanitization
- Test caching behavior

### 5. Use Case Tests

Test business logic with mocked repositories.

**Examples:**
- `login_usecase_test.dart` - Login validation
- `register_buyer_usecase_test.dart` - Registration logic
- `submit_order_usecase_test.dart` - Order processing

**Best Practices:**
- Test validation rules
- Test error conditions
- Verify repository calls
- Test edge cases

### 6. Provider Tests

Test state management logic.

**Examples:**
- `auth_provider_test.dart` - Authentication state
- `theme_provider_test.dart` - Theme persistence

**Best Practices:**
- Test state transitions
- Test persistence
- Verify reactive updates
- Test error states

## Testing Tools

### Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.4    # Mocking library
  mockito: ^5.4.4     # Alternative mocking
```

### Mocktail vs Mockito

**Mocktail** (Recommended):
- No code generation
- Type-safe
- Easy to use
- Better error messages

**Mockito**:
- Requires code generation
- More established
- Better for complex scenarios

### Example: Using Mocktail

```dart
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  test('should login successfully', () async {
    // Arrange
    when(() => mockRepository.login(any(), any()))
        .thenAnswer((_) async => mockAuthResponse);

    // Act
    final result = await useCase.execute('test@example.com', 'password');

    // Assert
    expect(result, equals(mockAuthResponse));
    verify(() => mockRepository.login('test@example.com', 'password')).called(1);
  });
}
```

## Testing Patterns

### 1. Arrange-Act-Assert (AAA)

```dart
test('should update user profile', () async {
  // Arrange - Set up test data and mocks
  final user = User(id: '1', name: 'John');
  when(() => mockRepository.updateUser(user))
      .thenAnswer((_) async => user);

  // Act - Execute the functionality
  final result = await useCase.updateProfile(user);

  // Assert - Verify the outcome
  expect(result, equals(user));
  verify(() => mockRepository.updateUser(user)).called(1);
});
```

### 2. Given-When-Then (BDD Style)

```dart
test('given valid credentials, when login called, then returns auth response', () async {
  // Given
  const email = 'test@example.com';
  const password = 'password123';

  // When
  final result = await authRepository.login(email, password);

  // Then
  expect(result.accessToken, isNotEmpty);
});
```

### 3. Test Groups

```dart
group('AuthRepository', () {
  group('login', () {
    test('should succeed with valid credentials', () { });
    test('should fail with invalid credentials', () { });
    test('should sanitize email before login', () { });
  });

  group('logout', () {
    test('should clear tokens on logout', () { });
  });
});
```

## Code Coverage Best Practices

### 1. Aim for Meaningful Coverage

- Don't just chase 100% coverage
- Focus on critical business logic
- Test edge cases and error conditions
- Generated code doesn't need tests

### 2. What to Test

✅ **High Priority:**
- Business logic (Use Cases)
- Validation rules
- Error handling
- State management
- Security functions

✅ **Medium Priority:**
- Repository implementations
- API clients
- Utility functions
- Complex widgets

❌ **Low Priority:**
- Generated code (Freezed, json_serializable)
- Simple getters/setters
- Configuration files
- Third-party wrappers

### 3. Coverage Report Analysis

```bash
# Generate detailed coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# View uncovered lines
lcov --list coverage/lcov.info
```

### 4. Excluding Files from Coverage

Create `.lcovrc` file:

```
# Exclude generated files
geninfo_exclude = **.g.dart,**.freezed.dart

# Exclude test files
geninfo_exclude = **_test.dart
```

## Continuous Integration

### GitHub Actions Example

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.9.0'

      - name: Install dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: coverage/lcov.info
```

## Common Testing Scenarios

### Testing Async Code

```dart
test('should handle async operations', () async {
  // Use async/await
  final result = await asyncFunction();
  expect(result, isNotNull);
});
```

### Testing Streams

```dart
test('should emit values from stream', () async {
  // Use expectLater for streams
  final stream = cartService.getCartStream('seller1');

  expectLater(
    stream,
    emitsInOrder([
      isA<List<CartItem>>().having((list) => list.length, 'length', 0),
      isA<List<CartItem>>().having((list) => list.length, 'length', 1),
    ]),
  );

  await cartService.addToCart('seller1', product);
});
```

### Testing Exceptions

```dart
test('should throw exception for invalid input', () {
  expect(
    () => validator.validate(''),
    throwsA(isA<ArgumentError>()),
  );
});
```

### Testing Widgets with Providers

```dart
testWidgets('should display theme toggle button', (tester) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: ThemeToggleButton(),
      ),
    ),
  );

  expect(find.byType(IconButton), findsOneWidget);
});
```

## Performance Testing

### Measuring Test Execution Time

```bash
# Run with timing
flutter test --reporter json > test_results.json

# Analyze slow tests
cat test_results.json | jq '.[] | select(.testID != null) | {name: .test.name, time: .time}'
```

### Optimizing Test Performance

1. **Use `setUpAll` for expensive operations**
   ```dart
   setUpAll(() async {
     await initializeDatabase();
   });
   ```

2. **Mock expensive operations**
   ```dart
   when(() => mockApi.fetchLargeData())
       .thenAnswer((_) async => cachedData);
   ```

3. **Avoid unnecessary pumps**
   ```dart
   // Bad
   await tester.pump();
   await tester.pump();
   await tester.pump();

   // Good
   await tester.pumpAndSettle();
   ```

## Debugging Tests

### Print Debug Information

```dart
test('should debug', () {
  debugPrint('Current state: ${provider.state}');
  expect(provider.state.isLoading, true);
});
```

### Using `setUp` and `tearDown`

```dart
setUp(() {
  // Runs before each test
  mockRepository = MockAuthRepository();
});

tearDown(() {
  // Runs after each test
  reset(mockRepository);
});
```

### Running Single Test

```dart
// Use 'testOnly' to run one test
testOnly('focused test', () {
  expect(true, true);
});
```

## Test Maintenance

### 1. Keep Tests Updated

- Update tests when requirements change
- Refactor tests with production code
- Remove obsolete tests

### 2. Test Naming Conventions

```dart
// Good
test('should return user when login succeeds')
test('should throw AuthError when credentials are invalid')

// Bad
test('test1')
test('login test')
```

### 3. DRY Principle

```dart
// Extract common test setup
void setupMockAuth({bool shouldSucceed = true}) {
  when(() => mockAuth.login(any(), any())).thenAnswer(
    (_) async => shouldSucceed ? mockUser : throw AuthError(),
  );
}
```

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [Mocktail Package](https://pub.dev/packages/mocktail)
- [Flutter Widget Testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)

## Troubleshooting

### Common Issues

1. **"Bad state: No test is currently running"**
   - Use `TestWidgetsFlutterBinding.ensureInitialized()`

2. **"MissingPluginException"**
   - Mock platform channels or use `flutter test integration_test/`

3. **Tests hanging**
   - Check for unclosed streams or futures
   - Use timeout parameter

### Getting Help

- Check existing test files for examples
- Read error messages carefully
- Use `--verbose` flag for more details
- Ask team members for guidance

---

**Last Updated**: 2025-11-17
**Coverage Target**: 80%+
**Test Count**: 50+ tests across all layers
