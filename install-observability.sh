#!/bin/bash

NS=${NS:-open-cluster-management-observability}

# step 1
oc create namespace $NS

# step 2
# NOTE: the warning for export is just a warning, not an error
oc get secret multiclusterhub-operator-pull-secret -n open-cluster-management --export -o yaml | oc apply -n $NS -f -

# step 3
MCO_BUCKET=${MCO_BUCKET:-""}
MCO_S3_ENDPOINT=${MCO_S3_ENDPOINT:-"s3.amazonaws.com"}
MCO_S3_ACCESSKEY=${MCO_S3_ACCESSKEY:-""}
MCO_S3_SECRETKEY=${MCO_S3_SECRETKEY:-""}

if [ ! -f object-storage-data.txt ]; then
cat > object-storage-data.txt <<EOF
type: s3
config:
  bucket: ${MCO_BUCKET}
  endpoint: ${MCO_S3_ENDPOINT}
  insecure: false
  access_key: ${MCO_S3_ACCESSKEY}
  secret_key: ${MCO_S3_SECRETKEY}
EOF
fi

cat object-storage-data.txt
oc delete secret thanos-object-storage -n $NS
oc create secret generic thanos-object-storage --from-file=thanos.yaml=./object-storage-data.txt -n $NS
oc get secret thanos-object-storage -n $NS -o yaml

# step 4
cat > multiclusterobservability_cr.yaml <<EOF
apiVersion: observability.open-cluster-management.io/v1beta1
kind: MultiClusterObservability
metadata:
  name: observability
spec:
  storageConfigObject:
    metricObjectStorage:
      name: thanos-object-storage
      key: thanos.yaml
EOF

# step 5
oc project $NS
oc apply -f multiclusterobservability_cr.yaml
