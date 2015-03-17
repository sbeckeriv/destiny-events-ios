# destiny-events-ios
IOS App to display public events. Uses firebase as a proxy and Heroku Scheduler (10 of them every ten minutes rolling). 

Node: firebase-import command on heroku

curl http://destinypublicevents.com/ws/timerjson.php>~/tmp/temp.json && cat ~/tmp/temp.json && firebase-import -f https://**.firebaseio.com/ --force -a KEY -j ~/tmp/temp.json &> ~/tmp/output


Second IOS app. First with firebase. its a good example on how not to do it. 
