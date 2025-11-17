#!/bin/bash
echo "=== Проверка синтаксиса новых файлов ==="
echo ""

check_file() {
    local file="$1"
    echo "Проверка: $file"
    if [ -f "$file" ]; then
        # Проверка базового синтаксиса Dart (импорты, классы)
        if grep -q "^import" "$file" && grep -q "^class\|^abstract class" "$file"; then
            echo "  ✓ Базовая структура корректна"
        else
            echo "  ⚠ Возможная проблема со структурой"
        fi
        
        # Проверка на незакрытые скобки (базовая)
        open_braces=$(grep -o "{" "$file" | wc -l)
        close_braces=$(grep -o "}" "$file" | wc -l)
        if [ "$open_braces" -eq "$close_braces" ]; then
            echo "  ✓ Скобки сбалансированы ($open_braces открытых, $close_braces закрытых)"
        else
            echo "  ⚠ Несбалансированные скобки ($open_braces открытых, $close_braces закрытых)"
        fi
    else
        echo "  ✗ Файл не найден"
    fi
    echo ""
}

# Core files
check_file "/home/user/meiram-/lib/core/logger/app_logger.dart"
check_file "/home/user/meiram-/lib/core/error/app_error.dart"
check_file "/home/user/meiram-/lib/core/error/error_handler.dart"
check_file "/home/user/meiram-/lib/core/validators/validators.dart"
check_file "/home/user/meiram-/lib/core/constants/app_constants.dart"

# Widget files
check_file "/home/user/meiram-/lib/widgets/animations/fade_in_animation.dart"
check_file "/home/user/meiram-/lib/widgets/animations/slide_in_animation.dart"
check_file "/home/user/meiram-/lib/widgets/common/shimmer_loading.dart"
check_file "/home/user/meiram-/lib/widgets/common/custom_button.dart"
check_file "/home/user/meiram-/lib/widgets/common/custom_text_field.dart"

# Test file
check_file "/home/user/meiram-/test/core/validators_test.dart"

echo "=== Проверка завершена ==="
