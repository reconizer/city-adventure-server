#!/bin/bash
set -ev

psql -c "CREATE DATABASE city_adventure_test;" -U travis
psql -c "CREATE EXTENSION postgis;" -U travis
