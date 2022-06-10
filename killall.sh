#!/bin/bash

ps aux  |  grep -i clientmain |  awk '{print $2}'  |  xargs sudo kill -9
ps aux  |  grep -i master |  awk '{print $2}'  |  xargs sudo kill -9
ps aux  |  grep -i server |  awk '{print $2}'  |  xargs sudo kill -9
for pid in $(ps x | grep "bin\/master\|bin\/server\|bin\/.*client.*" | awk '{ print $1 }'); do
    kill -9 $pid
done
