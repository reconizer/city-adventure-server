#!/bin/bash
set -ev

psql -c "CREATE DATABASE city_adventure_test;" -U postgres
psql -c "CREATE EXTENSION postgis;" -U postgres
