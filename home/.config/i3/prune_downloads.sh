#!/usr/bin/env bash
while true
do
    find $HOME/Downloads -not -path $HOME/Downloads -mtime +7 -delete
    sleep 1800
done
