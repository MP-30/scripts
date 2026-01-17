#!/bin/bash

set -Eeuo pipefail

trap 'echo "Something bad happened"' ERR

ls /tmp | echo $?