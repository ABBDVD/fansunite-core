#!/usr/bin/env bash

set -o errexit

trap cleanup EXIT

cleanup() {
  if [ ! -z "$ganache_pid" ]; then
    kill -9 $ganache_pid
  fi
}

is_running() {
  nc -z localhost 8545
}

start_ganache() {
  node_modules/.bin/ganache-cli -i 15 --gasLimit 90000000 > /dev/null &
  ganache_pid=$!
}

init() {
  if is_running; then
    echo "Using existing ganache instance"
  else
    echo "Starting our own ganache instance"
    start_ganache
  fi

  if [ "$SOLIDITY_COVERAGE" = true ]; then
    node_modules/.bin/solidity-coverage
  else
    node_modules/.bin/truffle test --network dev "$@"
  fi

  cleanup
}

init
