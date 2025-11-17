/// Custom validators for form fields
class Validators {
  /// Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email обязателен';
    }

    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Неверный формат email';
    }

    return null;
  }

  /// Password validation
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пароль обязателен';
    }

    if (value.length < 6) {
      return 'Пароль должен содержать минимум 6 символов';
    }

    return null;
  }

  /// Phone validation (Kazakhstan format)
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Телефон обязателен';
    }

    // Remove all non-digit characters
    final String digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    // Check if it matches Kazakhstan phone format
    // +7 XXX XXX XX XX or 8 XXX XXX XX XX
    if (digitsOnly.length != 11) {
      return 'Неверный формат телефона';
    }

    if (!digitsOnly.startsWith('7') && !digitsOnly.startsWith('8')) {
      return 'Телефон должен начинаться с 7 или 8';
    }

    return null;
  }

  /// Required field validation
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName обязателен'
          : 'Поле обязательно для заполнения';
    }
    return null;
  }

  /// Minimum length validation
  static String? Function(String?) minLength(int min, {String? fieldName}) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return null; // Use required() for emptiness check
      }

      if (value.length < min) {
        return fieldName != null
            ? '$fieldName должен содержать минимум $min символов'
            : 'Минимум $min символов';
      }

      return null;
    };
  }

  /// Maximum length validation
  static String? Function(String?) maxLength(int max, {String? fieldName}) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return null;
      }

      if (value.length > max) {
        return fieldName != null
            ? '$fieldName должен содержать максимум $max символов'
            : 'Максимум $max символов';
      }

      return null;
    };
  }

  /// Numeric validation
  static String? numeric(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (double.tryParse(value) == null) {
      return 'Введите числовое значение';
    }

    return null;
  }

  /// Positive number validation
  static String? positiveNumber(String? value) {
    final String? numericError = numeric(value);
    if (numericError != null) {
      return numericError;
    }

    if (value != null && double.parse(value) <= 0) {
      return 'Значение должно быть больше нуля';
    }

    return null;
  }

  /// BIN validation (Kazakhstan Business Identification Number)
  static String? bin(String? value) {
    if (value == null || value.isEmpty) {
      return 'БИН обязателен';
    }

    // Remove all non-digit characters
    final String digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length != 12) {
      return 'БИН должен содержать 12 цифр';
    }

    return null;
  }

  /// Confirm password validation
  static String? Function(String?) confirmPassword(String originalPassword) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Подтвердите пароль';
      }

      if (value != originalPassword) {
        return 'Пароли не совпадают';
      }

      return null;
    };
  }

  /// Combine multiple validators
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final String? Function(String?) validator in validators) {
        final String? error = validator(value);
        if (error != null) {
          return error;
        }
      }
      return null;
    };
  }
}
