#!/usr/bin/env bash

set -o errexit

trap cleanup EXIT

cleanup() {
  if [ ! -z "$ethrpc_pid" ]; then
    kill -9 $ethrpc_pid
  fi
}

is_running() {
  nc -z localhost 8545
}

start_ethrpc() {

  local accounts=(
    --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501200,1000000000000000000000000"
    --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501201,1000000000000000000000000"
    --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501202,1000000000000000000000000"
    --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501203,1000000000000000000000000"
    --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501204,1000000000000000000000000"
    --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501205,1000000000000000000000000"
    --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501206,1000000000000000000000000"
    --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501207,1000000000000000000000000"
    --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501208,1000000000000000000000000"
    --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501209,1000000000000000000000000"
  )

  if [ "$SOLIDITY_COVERAGE" = true ]; then
    node_modules/.bin/testrpc-sc --gasLimit 0xfffffffffff --port 8545 "${accounts[@]}" > /dev/null &
  else
    node_modules/.bin/ganache-cli -i 15 --gasLimit 90000000 "${accounts[@]}" > /dev/null &
  fi
  ethrpc_pid=$!
}

init() {
  if is_running; then
    echo "Using existing ethrpc instance"
  else
    echo "Starting our own ethrpc instance"
    start_ethrpc
  fi

  if [ "$SOLIDITY_COVERAGE" = true ]; then
    node_modules/.bin/solidity-coverage
  else
    node_modules/.bin/truffle test --network dev "$@"
  fi

  cleanup
}

init
