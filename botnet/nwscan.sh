#!/bin/bash

is_alive_ping()
{
  ping -c 1 $1 > /dev/null
  [ $? -eq 0 ] && echo $i
}

for i in $1{2..254}
do
is_alive_ping $i & disown
done

