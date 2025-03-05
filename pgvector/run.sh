#!/bin/bash

set -e

tags=(
  pg16
)

platforms=(
  linux/amd64
  linux/arm64
)

ecr_repo=public.ecr.aws/j2p9b0v2/pgvector

for tag in "${tags[@]}"; do
  manifest=()

  for platform in "${platforms[@]}"; do
    plat_tag=$tag-$(echo $platform | sed 's/\//-/g')

    docker pull --platform "$platform" pgvector/pgvector:$tag
    docker tag pgvector/pgvector:$tag $ecr_repo:$plat_tag
    docker push --platform "$platform" $ecr_repo:$plat_tag

    manifest+=(--amend $ecr_repo:$plat_tag)

    echo ""
  done

  docker manifest create $ecr_repo:$tag \
    ${manifest[@]}

  docker manifest push $ecr_repo:$tag

  echo ""
done
