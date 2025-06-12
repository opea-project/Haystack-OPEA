#!/bin/bash

# Copyright (C) 2025 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

set -xe

WORKPATH=$(dirname "$PWD")
ip_address=$(hostname -I | awk '{print $1}')
LOG_PATH="$WORKPATH/tests"

function build_integration_package() {
  cd $WORKPATH
  echo $(pwd)
  python3 -m venv /tmp/temp_env
  source /tmp/temp_env/bin/activate
  pip install --upgrade --force-reinstall poetry==2.1.2
  poetry install --with test
  if [ $? -ne 0 ]; then
    echo "Package installation fail"
    exit 1
  else
    echo "Package installation successful"
  fi
}

function start_service() {
  export EMBEDDING_MODEL_ID="BAAI/bge-base-en-v1.5"
  export LLM_MODEL_ID="Qwen/Qwen2.5-0.5B"
  export EMBEDDER_PORT=6000
  export TEI_EMBEDDING_ENDPOINT="http://tei-embedding-serving:80"
  docker compose -f $WORKPATH/.github/workflows/compose/compose.yaml up -d
  sleep 20s
}

function validate_service() {
  opea_embedding_port=6000

  result=$(http_proxy="" curl http://${ip_address}:$opea_embedding_port/v1/embeddings \
    -X POST \
    -d '{"input":"What is Deep Learning?"}' \
    -H 'Content-Type: application/json')
  if [[ $result == *"embedding"* ]]; then
    echo "Result correct."
  else
    echo "Result wrong. Received was $result"
    docker logs tei-embedding-server
    exit 1
  fi

  opea_llm_port=9000

  result=$(http_proxy="" curl http://${ip_address}:${opea_llm_port}/v1/chat/completions \
    -X POST \
    -d '{"model": "Qwen/Qwen2.5-0.5B", "messages": "What is Deep Learning?", "max_tokens":17, "stream":false}' \
    -H 'Content-Type: application/json')
  if [[ $result == *"\"total_tokens\":22"* ]]; then
    echo "Result correct."
  else
    echo "Result wrong. Received was $result"
    docker logs llm-textgen-server >>${LOG_PATH}/llm-tgi.log
    exit 1
  fi

}

function validate_package() {
  cd "$WORKPATH/"
  poetry run pytest tests/
  if [ $? -ne 0 ]; then
    echo "Package Tests failed"
    exit 1
  else
    echo "Package Tests successful"
  fi

}

function remove_integration_package() {
  cd "$WORKPATH/"
  deactivate
  rm -rf /tmp/temp_env
  if [ $? -ne 0 ]; then
    echo "Package removal fail"
    exit 1
  else
    echo "Package removal successful"
  fi

}

function stop_docker() {
  cid=$(docker ps -aq --filter "name=test-comps-integration-*")
  if [[ ! -z "$cid" ]]; then docker stop $cid && docker rm $cid && sleep 1s; fi

  ports=(6006 9009 6000 9000)
  for port in "${ports[@]}"; do
    docker ps --format "{{.ID}}" | while read -r container_id; do
      if docker port "$container_id" | grep ":$port"; then
        echo "Stopping container ($container_id)"
        docker stop "$container_id"
        echo "Removing container ($container_id)"
        docker rm "$container_id"
      fi
    done
  done

}

function main() {

  stop_docker

  build_integration_package

  start_service

  validate_service

  validate_package

  remove_integration_package

  stop_docker

  echo y | docker system prune

}

main
