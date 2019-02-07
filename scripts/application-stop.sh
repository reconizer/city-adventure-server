#!/bin/bash

if pgrep gameinn > /dev/null 2>&1
then
  sudo initctl stop gameinn
fi
