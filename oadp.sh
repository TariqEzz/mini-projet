#!/bin/bash
set -e

NAMESPACE="oadp"

echo "1️⃣ Création du namespace OADP..."
oc get ns $NAMESPACE &>/dev/null || oc create namespace $NAMESPACE

echo "2️⃣ Création de l'OperatorGroup..."
oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: oadp-operatorgroup
  namespace: $NAMESPACE
spec:
  targetNamespaces:
  - $NAMESPACE
EOF

echo "3️⃣ Création de la Subscription OADP..."
oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: oadp-subscription
  namespace: $NAMESPACE
spec:
  channel: stable
  name: oadp-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  installPlanApproval: Automatic
EOF

echo "4️⃣ Attente de l'installation de l'Operator (cela peut prendre quelques minutes)..."
while true; do
    CSV=$(oc get csv -n $NAMESPACE -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "")
    if [[ "$CSV" == "Succeeded" ]]; then
        echo "✅ OADP Operator installé avec succès !"
        break
    else
        echo "⏳ Installation en cours, attente 15s..."
        sleep 15
    fi
done
