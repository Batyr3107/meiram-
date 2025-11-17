#!/bin/bash
echo "=== Проверка импортов в новых файлах ==="
echo ""

# Функция для проверки импортов
check_imports() {
    local file="$1"
    local filename=$(basename "$file")
    echo "📄 $filename"
    
    # Извлекаем все импорты
    grep "^import" "$file" | while read -r import_line; do
        # Извлекаем имя пакета
        package=$(echo "$import_line" | sed -n "s/import 'package:\([^/]*\).*/\1/p")
        
        if [ -n "$package" ]; then
            # Проверяем наличие пакета в pubspec.yaml
            if grep -q "^\s*$package:" /home/user/meiram-/pubspec.yaml; then
                echo "  ✓ $package"
            else
                echo "  ✗ $package (НЕ НАЙДЕН В PUBSPEC)"
            fi
        fi
    done
    echo ""
}

# Проверяем все новые файлы
check_imports "/home/user/meiram-/lib/core/logger/app_logger.dart"
check_imports "/home/user/meiram-/lib/core/error/app_error.dart"
check_imports "/home/user/meiram-/lib/core/error/error_handler.dart"
check_imports "/home/user/meiram-/lib/widgets/common/shimmer_loading.dart"

echo "=== Проверка завершена ==="
