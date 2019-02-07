#!/bin/bash

if pgrep app > /dev/null 2>&1
then
  sudo service app stop
fi
