#!/usr/bin/env sh

kustomize build --enable-alpha-plugins --enable-exec $1 | kubeconform --summary
