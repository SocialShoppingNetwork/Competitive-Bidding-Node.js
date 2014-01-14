#! /usr/bin/env sh
pwd="$( cd "$( dirname "$0" )" && pwd )/../fixture"

# drop the whole collection
mongo 10.234.33.215:27017/exhibia-test --eval "db.dropDatabase()"

mongoimport -h hipaise-1/127.0.0.1 --jsonArray --upsert -d exhibia-test -c categories $pwd/categories.json
mongoimport -h hipaise-1/127.0.0.1 --jsonArray --upsert -d exhibia-test -c chatmessages $pwd/chatmessages.json
mongoimport -h hipaise-1/127.0.0.1 --jsonArray --upsert -d exhibia-test -c items $pwd/items.json
mongoimport -h hipaise-1/127.0.0.1 --jsonArray --upsert -d exhibia-test -c products $pwd/products.json
mongoimport -h hipaise-1/127.0.0.1 --jsonArray --upsert -d exhibia-test -c transactions $pwd/transactions.json
mongoimport -h hipaise-1/127.0.0.1 --jsonArray --upsert -d exhibia-test -c users $pwd/users.json
