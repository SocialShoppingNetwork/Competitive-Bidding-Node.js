#! /usr/bin/env sh
pwd="$( cd "$( dirname "$0" )" && pwd )/../fixture"

# drop the whole collection
mongo exhibia --eval "db.dropDatabase()"

mongoimport --jsonArray --upsert -d exhibia -c categories $pwd/categories.json
mongoimport --jsonArray --upsert -d exhibia -c chatmessages $pwd/chatmessages.json
mongoimport --jsonArray --upsert -d exhibia -c items $pwd/items.json
mongoimport --jsonArray --upsert -d exhibia -c products $pwd/products.json
mongoimport --jsonArray --upsert -d exhibia -c transactions $pwd/transactions.json
mongoimport --jsonArray --upsert -d exhibia -c users $pwd/users.json
