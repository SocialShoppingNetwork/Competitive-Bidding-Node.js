# Export

```
cd fixture
mongoexport --jsonArray -d exhibia -c users -o users.json
#mongoexport --jsonArray -d interests -c interests -o interests.json
```

Optionally, you can use Eclipse/Aptana/Titanium Studio IDE Source->Format (Cmnd-Shift-F) to make it
more human-readable

# Import

```
cd fixture
mongoimport --jsonArray --upsert -d exhibia -c users users.json
#mongoimport --jsonArray --upsert -d interests -c interests interests.json
```

# Import to testing database
mongoimport --jsonArray --upsert -d badger-testing -c users users.json
mongoimport --jsonArray --upsert -d badger-testing -c interests interests.json

#Drop database (eg. users database) (count to check first then drop)
```

cd fixture
mongo
use interests
db.users.count()
db.users.drop()
```
