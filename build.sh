#!/bin/bash
# =====================================================================
#  Adaptive Personalised Learning Path Recommender - build and deploy
#
#  Usage:  ./build.sh          compile only
#          ./build.sh deploy   compile, then copy into Tomcat
#          ./build.sh test     compile, then run the rule engine tests
#          ./build.sh integration-test  also check assessment transactions in MySQL
#
#  In Eclipse you do not need this file - a Dynamic Web Project with
#  "src" as the source folder and "web" as the content folder does the
#  same thing automatically.
# =====================================================================
set -e

# ---- change this if Tomcat is installed somewhere else ----
TOMCAT="${TOMCAT:-/opt/homebrew/opt/tomcat/libexec}"
APP_NAME="AdaptiveLearning"

HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE"

echo "==> compiling Java sources"
mkdir -p web/WEB-INF/classes
javac -encoding UTF-8 \
      -cp "$TOMCAT/lib/*:web/WEB-INF/lib/*" \
      -d web/WEB-INF/classes \
      $(find src -name "*.java")
echo "    $(find src -name '*.java' | wc -l | tr -d ' ') files compiled"

if [ "$1" = "test" ]; then
    echo "==> running the rule engine tests"
    mkdir -p build/test
    javac -d build/test -cp web/WEB-INF/classes test/RuleEngineTest.java
    java -cp build/test:web/WEB-INF/classes RuleEngineTest
fi

if [ "$1" = "integration-test" ]; then
    echo "==> running assessment persistence test against MySQL"
    mkdir -p build/test
    javac -d build/test -cp "web/WEB-INF/classes:web/WEB-INF/lib/*" test/AssessmentPersistenceTest.java
    java -cp "build/test:web/WEB-INF/classes:web/WEB-INF/lib/*" AssessmentPersistenceTest
fi

if [ "$1" = "deploy" ]; then
    echo "==> deploying to $TOMCAT/webapps/$APP_NAME"
    rm -rf "$TOMCAT/webapps/$APP_NAME"
    mkdir -p "$TOMCAT/webapps/$APP_NAME"
    cp -R web/. "$TOMCAT/webapps/$APP_NAME/"
    echo "    open http://localhost:8080/$APP_NAME/"
fi

echo "==> done"
