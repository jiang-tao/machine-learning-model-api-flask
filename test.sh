#!/bin/bash

curl -H 'Content-Type: application/json' -X POST http://localhost:8080/api/models/call-model -d '{"yearsExperience":10}'
