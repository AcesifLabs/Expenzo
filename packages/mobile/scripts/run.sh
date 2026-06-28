adb kill-server && adb start-server && sleep 3 && adb -s RF8RA0DTA3Z reverse tcp:3000 tcp:3000 && flutter clean && flutter run -d RF8RA0DTA3Z
