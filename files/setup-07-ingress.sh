#!/bin/bash
# Copyright 2019 VMware, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-2

# Setup Contour / Ingress

set -euo pipefail

KEY_FILE=/root/config/knativeappliance.key
CERT_FILE=/root/config/knativeappliance.crt
CERT_NAME=knativeappliance-tls
CN_NAME=$(hostname -f)

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ${KEY_FILE} -out ${CERT_FILE} -subj "/CN=${CN_NAME}/O=${CN_NAME}"

kubectl -n vmware-system create secret tls ${CERT_NAME} --key ${KEY_FILE} --cert ${CERT_FILE}

# Knative Contour for Knative Embedded Broker
  echo -e "\e[92mDeploying Knative Contour ..." > /dev/console

  kubectl create -n contour-external secret tls default-cert --key ${KEY_FILE} --cert ${CERT_FILE}
  kubectl apply -f /root/download/contour-delegation.yaml
  kubectl patch configmap -n knative-serving config-contour -p '{"data":{"default-tls-secret":"contour-external/default-cert"}}'
  kubectl patch configmap -n knative-serving config-domain -p "{\"data\": {\"$CN_NAME\": \"\"}}"

# Ingress Route Configuration for Knative Embedded
INGRESS_CONFIG_YAML=/root/config/knative-embedded-ingressroute-gateway.yaml

if [ ! -z ${INGRESS_CONFIG_YAML} ]; then
  echo -e "\e[92mDeploying Ingress using configuration ${INGRESS_CONFIG_YAML} ..." > /dev/console
  sed -i "s/##HOSTNAME##/${HOSTNAME}/g" ${INGRESS_CONFIG_YAML}
  sed -i "s/##CERT_NAME##/${CERT_NAME}/g" ${INGRESS_CONFIG_YAML}
  kubectl create -f ${INGRESS_CONFIG_YAML}
else
  echo -e "\e[91mUnable to match a supported Ingress configuration ..." > /dev/console
  exit 1
fi