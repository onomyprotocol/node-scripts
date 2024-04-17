# syntax=docker/dockerfile:1

FROM ubuntu:24.04

RUN apt-get update
RUN apt-get -y install jq crudini curl wget lz4

###########################################################
# Chain Config
###########################################################
ARG NODE_BINARY_NAME=onomyd
ARG NODE_BINARY_URL=
ENV NODE_BINARY_NAME=${NODE_BINARY_NAME}
ENV NODE_BINARY_URL=${NODE_BINARY_URL}

###########################################################
# Cosmovisor config
###########################################################
ARG COSMOVISOR_BINARY_URL=
ARG DAEMON_RESTART_AFTER_UPGRADE=true
ENV COSMOVISOR_BINARY_URL=${COSMOVISOR_BINARY_URL}
ENV DAEMON_RESTART_AFTER_UPGRADE=${DAEMON_RESTART_AFTER_UPGRADE}

###########################################################
# Paths config
###########################################################
ARG NODE_HOME=/chain
ARG SCRIPTS_HOME=/scripts
ENV NODE_HOME=${NODE_HOME}
ENV SCRIPTS_HOME=${SCRIPTS_HOME}

ARG LISTEN_P2P_PORT=26656
ARG LISTEN_RPC_PORT=26657
ENV LISTEN_P2P_PORT=${LISTEN_P2P_PORT}
ENV LISTEN_RPC_PORT=${LISTEN_RPC_PORT}

COPY ./scripts ${SCRIPTS_HOME}

ENV HOME ${NODE_HOME}
WORKDIR /tmp

ENV DAEMON_HOME=${NODE_HOME}
ENV PATH=${PATH}:${DAEMON_HOME}/cosmovisor/genesis/bin:${DAEMON_HOME}/bin:${SCRIPTS_HOME}:${SCRIPTS_HOME}/cosmovisor/genesis/bin:${SCRIPTS_HOME}/bin
ENV DAEMON_NAME=${NODE_BINARY_NAME}

RUN  ${SCRIPTS_HOME}/image-setup.sh

ENTRYPOINT ["/scripts/entrypoint.sh"]