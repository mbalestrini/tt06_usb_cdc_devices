#!/bin/sh
echo "Serial ports by path:"
ls /dev/serial/by-path/
echo "\nSerial ports by id:"
ls /dev/serial/by-id/
