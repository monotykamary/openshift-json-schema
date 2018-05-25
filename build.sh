#!/bin/bash -xe

# This script uses openapi2jsonschema to generate a set of JSON schemas for
# the specified Kubernetes versions in three different flavours:
#
#   X.Y.Z - URL referenced based on the specified GitHub repository
#   X.Y.Z-standalone - de-referenced schemas, more useful as standalone documents
#   X.Y.Z-local - relative references, useful to avoid the network dependency

REPO="monotykamary/openshift-json-schema"

declare -a arr=(master
                v3.9.0
                v3.8.0
                v3.7.2
                v3.7.1
                v3.7.0
                v3.6.1
                v3.6.0
                v1.5.1
                v1.5.0
                )

for version in "${arr[@]}"
do
    schema=https://raw.githubusercontent.com/openshift/origin/${version}/api/swagger-spec/openshift-openapi-spec.json
    prefix=https://raw.githubusercontent.com/${REPO}/master/${version}/_definitions.json

    if [ -d "$version"-standalone-strict ] && \
    [ -d "$version"-standalone ] && \
    [ -d "$version"-local ] && \
    [ -d "$version" ] && \
    [ "$version" != master ]; then
        echo 'Skipping schema generation'
    else
        openapi2jsonschema -o "${version}-standalone-strict" --kubernetes --stand-alone --strict "${schema}"
        openapi2jsonschema -o "${version}-standalone" --kubernetes --stand-alone "${schema}"
        openapi2jsonschema -o "${version}-local" --kubernetes "${schema}"
        openapi2jsonschema -o "${version}" --kubernetes --prefix "${prefix}" "${schema}"
    fi
done
