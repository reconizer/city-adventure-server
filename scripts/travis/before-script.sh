#!/bin/bash
set -ev

psql -c "CREATE DATABASE city_adventure_test;"
psql -c "CREATE EXTENSION postgis;"
