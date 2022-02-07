#!/bin/bash

label-studio -db postgresql --host ${HOST:-""} --port ${PORT} --username ${USERNAME} --password ${PASSWORD}
