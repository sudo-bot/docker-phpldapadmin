#!/bin/sh

set -eu

DID_FAIL=0

checkUrl() {
    set +e
    if [ "$2" = "form" ]; then
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

checkUrl "http://${TEST_ADDR}/" -I
checkUrl "http://${TEST_ADDR}/.nginx/status" -I
checkUrl "http://${TEST_ADDR}/.phpfpm/status" -I
checkUrl "http://${TEST_ADDR}/index.php" -I
checkUrl "http://${TEST_ADDR}/robots.txt" -I

checkUrl "http://${TEST_ADDR}/index.php" -L | grep -q -F "1.2.6.4"
checkUrl "http://${TEST_ADDR}/htdocs/cmd.php" "form" "cmd=login&server_id=1&nodecode%5Blogin_pass%5D=1&login=cn%3Dadmin%2Cdc%3Dexample%2Cdc%3Dorg&login_pass=ldapadminpass&submit=Authenticate" | grep -q -F "Successfully logged into server."

if [ $DID_FAIL -gt 0 ]; then
    echo "Some URLs failed"
    exit 1
fi
