#! /usr/bin/env sh
pwd="$( cd "$( dirname "$0" )" && pwd )/../fixture"

mongoexport -h hipaise-1/127.0.0.1 --jsonArray -d exhibia-test -c categories -o $pwd/categories.json
mongoexport -h hipaise-1/127.0.0.1 --jsonArray -d exhibia-test -c chatmessages -o $pwd/chatmessages.json
mongoexport -h hipaise-1/127.0.0.1 --jsonArray -d exhibia-test -c items -o $pwd/items.json
mongoexport -h hipaise-1/127.0.0.1 --jsonArray -d exhibia-test -c products -o $pwd/products.json
mongoexport -h hipaise-1/127.0.0.1 --jsonArray -d exhibia-test -c transactions -o $pwd/transactions.json
mongoexport -h hipaise-1/127.0.0.1 --jsonArray -d exhibia-test -c users -o $pwd/users.json
