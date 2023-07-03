ARG KSOPS_VERSION="v4.1.1"

FROM viaductoss/ksops:$KSOPS_VERSION as ksops-builder

FROM alpine:latest

RUN apk update && apk add --no-cache curl wget

ENV kustomize_version v5.0.1
ENV kubeconform_version v0.6.2

RUN wget -q -O- https://zyedidia.github.io/eget.sh | sh && mv ./eget /usr/bin
RUN eget kubernetes-sigs/kustomize --tag ${kustomize_version} --to /usr/local/bin/
RUN eget yannh/kubeconform --tag ${kubeconform_version} --to /usr/local/bin/

RUN adduser kustomize -D \
  && apk add curl git openssh file \
  && git config --global url.ssh://git@github.com/.insteadOf https://github.com/

RUN mkdir ~/.ssh && ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

# Switch to root for the ability to perform install
USER root

# Set the kustomize home directory
ENV XDG_CONFIG_HOME=$HOME/.config
ENV KUSTOMIZE_PLUGIN_PATH=$XDG_CONFIG_HOME/kustomize/plugin/

ARG PKG_NAME=ksops

# Copy the plugin to kustomize plugin path
RUN curl -L --output /tmp/ksops_4.1.1_Linux_x86_64.tar.gz https://github.com/viaduct-ai/kustomize-sops/releases/download/v4.1.1/ksops_4.1.1_Linux_x86_64.tar.gz \
  && mkdir -p $KUSTOMIZE_PLUGIN_PATH/viaduct.ai/v1/${PKG_NAME} \
  && tar -xvzf /tmp/ksops_4.1.1_Linux_x86_64.tar.gz -C $KUSTOMIZE_PLUGIN_PATH/viaduct.ai/v1/${PKG_NAME} \
  && chmod 755 $KUSTOMIZE_PLUGIN_PATH/viaduct.ai/v1/${PKG_NAME}/ksops \
  && chown kustomize:kustomize $KUSTOMIZE_PLUGIN_PATH/viaduct.ai/v1/${PKG_NAME}/ksops ;

USER kustomize
WORKDIR /src

COPY ./run.sh /usr/local/bin
