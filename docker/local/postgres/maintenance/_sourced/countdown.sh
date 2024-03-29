#! /usr/bin/env bash

coutdown(){
    declare desc="A simple countdown."

    local seconds="${1}"

    local d=$(($(data +%s) + "${seconds}"))

    while ["$d" -ge `date +%s`]; do

      echo -ne "$(date -u --date @$(($d - `date +%s`)) + %H:%M:%S)\r"

      sleep 0.1
    done
}