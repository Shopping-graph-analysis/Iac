#!/bin/bash
set -e

echo "Starting Unit Quality Gate..."

# Check if we are in a Java environment for JaCoCo
if [ -f "pom.xml" ]; then
    echo "Detected Maven project. Running tests with JaCoCo..."
    # Ensure JaCoCo plugin is in pom.xml or pass it as an argument
    mvn clean test verify
    echo "JaCoCo report generated at target/site/jacoco/index.html"
elif [ -f "build.gradle" ]; then
    echo "Detected Gradle project. Running tests with JaCoCo..."
    ./gradlew test jacocoTestReport
    echo "JaCoCo report generated at build/reports/jacoco/test/html/index.html"
else
    echo "No Java build file found. Checking for Python..."
fi

# Check for Python environment
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
    echo "Detected Python project. Running tests..."
    if command -v pytest &> /dev/null; then
        pytest --cov=. --cov-report=html
        echo "Coverage report generated in htmlcov/"
    else
        echo "pytest not found. Please install pytest and pytest-cov."
        exit 1
    fi
fi

echo "Unit Quality Gate Passed!"
