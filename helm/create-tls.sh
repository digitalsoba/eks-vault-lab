#!/bin/bash
# Run this script once per cluster to create a TLS certificate and key for a Vault cluster
set -e

# Create a vault namespace
kubectl create namespace vault

# Export variables 
export SERVICE=vault
export NAMESPACE=vault
export SECRET_NAME=vault-server-tls
export TMPDIR=/tmp
export CSR_NAME=vault-csr

# Use OpenSSL to generate a key for Kubernetes to sign
openssl genrsa -out ${TMPDIR}/vault.key 2048

# Create a CSR configuration inside /tmp/csr.conf
cat <<EOF >${TMPDIR}/csr.conf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = ${SERVICE}
DNS.2 = ${SERVICE}.${NAMESPACE}
DNS.3 = ${SERVICE}.${NAMESPACE}.svc
DNS.4 = ${SERVICE}.${NAMESPACE}.svc.cluster.local
IP.1 = 127.0.0.1
EOF

# Create CSR
openssl req -new -key ${TMPDIR}/vault.key -subj "/CN=${SERVICE}.${NAMESPACE}.svc" -out ${TMPDIR}/server.csr -config ${TMPDIR}/csr.conf

# Create a certificate for Kubernetes to sign
cat <<EOF >${TMPDIR}/csr.yaml
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: ${CSR_NAME}
spec:
  groups:
  - system:authenticated
  request: $(cat ${TMPDIR}/server.csr | base64 | tr -d '\n')
  usages:
  - digital signature
  - key encipherment
  - server auth
EOF

# Sleep for 10 seconds so Kubernetes can create the restore
sleep 10

# Apply and approve the CSR
kubectl -n vault create -f ${TMPDIR}/csr.yaml
kubectl certificate approve ${CSR_NAME}

# Create a vault CA, Certificate, and Key
serverCert=$(kubectl get csr ${CSR_NAME} -o jsonpath='{.status.certificate}')
echo "${serverCert}" | openssl base64 -d -A -out ${TMPDIR}/vault.crt
kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}' | base64 -d > ${TMPDIR}/vault.ca

sleep 10

# Create vault-server-tls secret for vault to mount
kubectl create secret generic ${SECRET_NAME} \
        --namespace ${NAMESPACE} \
        --from-file=vault.key=${TMPDIR}/vault.key \
        --from-file=vault.crt=${TMPDIR}/vault.crt \
        --from-file=vault.ca=${TMPDIR}/vault.ca