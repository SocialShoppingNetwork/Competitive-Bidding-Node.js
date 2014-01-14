#! /usr/bin/env sh
pwd="$( cd "$( dirname "$0" )" && pwd )/../fixture"

mongoexport --jsonArray -d exhibia -c categories -o $pwd/categories.json
mongoexport --jsonArray -d exhibia -c chatmessages -o $pwd/chatmessages.json
mongoexport --jsonArray -d exhibia -c items -o $pwd/items.json
mongoexport --jsonArray -d exhibia -c products -o $pwd/products.json
mongoexport --jsonArray -d exhibia -c transactions -o $pwd/transactions.json
mongoexport --jsonArray -d exhibia -c users -o $pwd/users.json
