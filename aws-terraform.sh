#!/bin/bash

set -e

usage() {
  echo "Usage: $0 [init|plan|apply|destroy|all]"
  echo "  default: all (init + plan + apply)"
  exit 1
}

TF_DIRS=(
  "./eks"
  "./ec2/batch"
  "./ecr"
)

ACTION=${1:-all}
ERRORS=0

for DIR in "${TF_DIRS[@]}"; do
  echo "=============================="
  echo "📂 Processing: $DIR"
  echo "=============================="

  if [ -d "$DIR" ]; then
    cd "$DIR"

    if [[ "$ACTION" == "init" || "$ACTION" == "all" ]]; then
      echo "🔧 terraform init"
      terraform init -upgrade
      if [ $? -ne 0 ]; then
        echo "❌ terraform init failed in $DIR"
        ERRORS=$((ERRORS+1))
        cd - > /dev/null
        continue
      fi
    fi

    if [[ "$ACTION" == "plan" || "$ACTION" == "all" ]]; then
      echo "📝 terraform plan"
      terraform plan -out=tfplan
      if [ $? -ne 0 ]; then
        echo "❌ terraform plan failed in $DIR"
        ERRORS=$((ERRORS+1))
        cd - > /dev/null
        continue
      fi
    fi

    if [[ "$ACTION" == "apply" || "$ACTION" == "all" ]]; then
      echo "✅ terraform apply"
      terraform apply -auto-approve tfplan
      if [ $? -ne 0 ]; then
        echo "❌ terraform apply failed in $DIR"
        ERRORS=$((ERRORS+1))
        cd - > /dev/null
        continue
      fi
    fi

    if [[ "$ACTION" == "destroy" ]]; then
      echo "⚠️ terraform destroy"
      terraform destroy -auto-approve
      if [ $? -ne 0 ]; then
        echo "❌ terraform destroy failed in $DIR"
        ERRORS=$((ERRORS+1))
        cd - > /dev/null
        continue
      fi
    fi

    cd - > /dev/null
  else
    echo "⚠️ Directory $DIR not found, skipping..."
    ERRORS=$((ERRORS+1))
  fi

  echo ""
done

if [ $ERRORS -ne 0 ]; then
  echo "❌ Script finished with $ERRORS error(s)"
else
  echo "🎉 All Terraform actions completed successfully!"
fi
