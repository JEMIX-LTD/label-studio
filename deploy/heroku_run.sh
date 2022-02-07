#!/bin/bash

label-studio start my_project --init -db postgresql --host ${HOST:-""} --port ${PORT} --username ${USERNAME} --password ${PASSWORD}
