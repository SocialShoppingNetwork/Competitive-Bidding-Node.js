# Handy commands

```
# List all listening thread
sudo netstat -lnptu # Ubuntu
sudo lsof -n -i4TCP | grep LISTEN # OSX
```
# Proper way to start/stop redis on EC2 instance
sudo /etc/init.d/redis_6379 start
Logfile /var/log/redis_6379.log
