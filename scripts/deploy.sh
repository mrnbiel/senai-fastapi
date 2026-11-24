#!/usr/bin/env bash
set -euo pipefail

image=$1
port=$2
name=senai-fastapi
previous=senai-fastapi-previous

exec 9>"$HOME/.senai-fastapi-deploy.lock"
flock 9

docker pull "$image"

if docker container inspect "$previous" >/dev/null 2>&1; then
    if ! docker container inspect "$name" >/dev/null 2>&1; then
        docker rename "$previous" "$name"
        docker start "$name"
    else
        echo "A implantação anterior precisa ser reconciliada." >&2
        exit 1
    fi
fi

if docker container inspect "$name" >/dev/null 2>&1; then
    docker stop "$name"
    docker rename "$name" "$previous"
fi

healthy() {
    curl --fail --silent --max-time 2 "http://127.0.0.1:$port/health" |
        python3 -c 'import json, sys; assert json.load(sys.stdin)["status"] == "healthy"'
}

if docker run --detach --restart unless-stopped --name "$name"     --publish "$port:8000" "$image"; then
    for attempt in {1..15}; do
        if healthy 2>/dev/null; then
            if docker container inspect "$previous" >/dev/null 2>&1; then
                docker rm "$previous"
            fi
            echo "Health check OK na porta $port"
            exit 0
        fi
        sleep 2
    done
fi

docker logs --tail 30 "$name" >&2 || true
docker rm --force "$name" >/dev/null 2>&1 || true
if docker container inspect "$previous" >/dev/null 2>&1; then
    docker rename "$previous" "$name"
    docker start "$name"
fi
exit 1
