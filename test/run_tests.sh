#!/bin/bash

# Test Runner Script for Shop App
# Runs all tests with coverage and generates reports

set -e

echo "🧪 Starting Test Suite..."
echo "================================"

# Clean previous coverage
echo "📦 Cleaning previous coverage data..."
rm -rf coverage
mkdir -p coverage

# Run all tests with coverage
echo "🏃 Running tests with coverage..."
flutter test --coverage --reporter expanded

# Check if coverage was generated
if [ -f "coverage/lcov.info" ]; then
    echo "✅ Coverage data generated successfully"

    # Generate HTML report (requires lcov to be installed)
    if command -v genhtml &> /dev/null; then
        echo "📊 Generating HTML coverage report..."
        genhtml coverage/lcov.info -o coverage/html
        echo "📁 Coverage report available at: coverage/html/index.html"
    else
        echo "⚠️  genhtml not found. Install lcov to generate HTML reports."
    fi

    # Show coverage summary
    if command -v lcov &> /dev/null; then
        echo ""
        echo "📈 Coverage Summary:"
        echo "================================"
        lcov --summary coverage/lcov.info
    fi
else
    echo "❌ Coverage data not generated"
    exit 1
fi

echo ""
echo "✅ All tests completed successfully!"
echo "================================"
