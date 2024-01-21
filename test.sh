#!/bin/sh

set -eu

DID_FAIL=0

checkUrl() {
    set +e
    if [ "${2:-}" = "form" ]; then
        curl -# --cookie-jar /tmp/test.cookie-jar -b /tmp/test.cookie-jar --fail \
        -s \
        -H 'Content-Type: application/x-www-form-urlencoded' \
        -L \
        --data-raw "${3}" \
        "$1"
    else
        curl -# --cookie-jar /tmp/test.cookie-jar -b /tmp/test.cookie-jar --fail \
            -s \
            ${2:-} \
            -H 'Content-Type: application/x-www-form-urlencoded' \
            "$1"
    fi

    if [ $? -gt 0 ]; then
        DID_FAIL=1
        echo "ERR: for URL ${1}"
    fi
    set -e
}

echo "Running tests..."

echo "Checking /"
checkUrl "http://${TEST_ADDR}/" -I
echo "Checking nginx status"
checkUrl "http://${TEST_ADDR}/.nginx/status" -I
echo "Checking phpfpm status"
checkUrl "http://${TEST_ADDR}/.phpfpm/status" -I
echo "Checking index"
checkUrl "http://${TEST_ADDR}/index.php" -I
echo "Checking robots.txt"
checkUrl "http://${TEST_ADDR}/robots.txt" -I
echo "Checking logo small"
checkUrl "http://${TEST_ADDR}/images/default/logo-small.png" -I | grep -F "Cache-Control: max-age=315360000"

echo "Checking version"
checkUrl "http://${TEST_ADDR}/index.php" | grep -q -F "1.2.6.7"

echo "Checking login"
checkUrl "http://${TEST_ADDR}/cmd.php" "form" "cmd=login&server_id=1&nodecode%5Blogin_pass%5D=1&login=cn%3Dadmin%2Cdc%3Dexample%2Cdc%3Dorg&login_pass=ldapadminpass&submit=Authenticate" | grep -q -F "Successfully logged into server."

if [ $DID_FAIL -gt 0 ]; then
    echo "Some URLs failed"
    exit 1
fi
echo "All tests PASS"
