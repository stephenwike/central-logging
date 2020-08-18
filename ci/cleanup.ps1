#!/usr/bin/env powershell

Push-Location ./dev/
    docker-compose down -v
Pop-Location