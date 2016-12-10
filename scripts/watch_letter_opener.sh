#!/usr/bin/env bash

while true
do
       touch  ./tmp/watch_letter_opener
       sleep 10
       find tmp/letter_opener/ -type f -name 'rich\.html' -cnewer ./tmp/watch_letter_opener -exec open {} \;
done
