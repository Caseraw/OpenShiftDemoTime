# Demo technical notes

## AWS Elastic IP's

### Quota
Check AWS Elastic IP quota (per region).

Docs:
- https://docs.aws.amazon.com/eks/latest/best-practices/known_limits_and_service_quotas.html
- https://docs.redhat.com/en/documentation/red_hat_openshift_service_on_aws/4/html/prepare_your_environment/rosa-sts-required-aws-service-quotas

```shell
aws service-quotas get-service-quota \
  --service-code ec2 \
  --quota-code L-0263D0A3 \
  --region us-east-2 \
  --query 'Quota.Value' --output text
```

### Currently allocated

```shell
aws ec2 describe-addresses \
  --region us-east-2 \
  --query 'length(Addresses)' --output text
```

### Calculate available (specific region)

```shell
# Set your AWS region here
REGION="us-east-2"

# Get quota (may be floating point)
QUOTA=$(aws service-quotas get-service-quota \
  --service-code ec2 \
  --quota-code L-0263D0A3 \
  --region "$REGION" \
  --query 'Quota.Value' --output text)

# Convert quota to integer
QUOTA_INT=$(printf "%.0f" "$QUOTA")

# Get number of allocated EIPs
USED=$(aws ec2 describe-addresses \
  --region "$REGION" \
  --query "length(Addresses)" --output text)

# Calculate available
AVAILABLE=$((QUOTA_INT - USED))

echo "AWS Region:     $REGION"
echo "EIP Quota:      $QUOTA_INT"
echo "EIPs Allocated: $USED"
echo "EIPs Available: $AVAILABLE"
```

### Calculate available (all regions)

```shell
for REGION in $(aws ec2 describe-regions --query "Regions[].RegionName" --output text); do
  QUOTA=$(aws service-quotas get-service-quota \
    --service-code ec2 \
    --quota-code L-0263D0A3 \
    --region "$REGION" \
    --query 'Quota.Value' --output text 2>/dev/null)
  if [ -z "$QUOTA" ]; then continue; fi
  QUOTA_INT=$(printf "%.0f" "$QUOTA")
  USED=$(aws ec2 describe-addresses \
    --region "$REGION" \
    --query "length(Addresses)" --output text)
  AVAILABLE=$((QUOTA_INT - USED))
  echo "Region: $REGION | Quota: $QUOTA_INT | Used: $USED | Available: $AVAILABLE"
done
```