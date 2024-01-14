ecommerce-eks

export K_CLUSTER_ENDPOINT="https://518EC9CC229732BA066A7F29AA6A489F.gr7.ap-northeast-2.eks.amazonaws.com"
export KARPENTER_AWS_REGION="ap-northeast-2"
export k_ekscluster_name="ecommerce-eks"
export ACCOUNT_ID="531744930393"




export KARPENTER_VERSION=v0.33.0
curl https://raw.githubusercontent.com/aws/karpenter-provider-aws/"${KARPENTER_VERSION}"/website/content/en/preview/getting-started/getting-started-with-karpenter/cloudformation.yaml > cloudformation.yaml



aws ec2 create - tags--resources "$k_PublicSubnet01" --tags Key = "karpenter.sh/discovery", Value = "${k_ekscluster_name}" --region ap - northeast - 1
aws ec2 create - tags--resources "$k_PublicSubnet02" --tags Key = "karpenter.sh/discovery", Value = "${k_ekscluster_name}" --region ap - northeast - 1
aws ec2 create - tags--resources "$k_PublicSubnet03" --tags Key = "karpenter.sh/discovery", Value = "${k_ekscluster_name}" --region ap - northeast - 1


karpenter.sh/discovery
ecommerce-eks


eksctl utils associate-iam-oidc-provider \
    --region ${KARPENTER_AWS_REGION} \
    --cluster ${k_ekscluster_name} \
    --approve
    

## Karpenter Node에 Role을 적용하기 위한 Template 다운로드를 합니다.
mkdir /Users/chiholee/Desktop/Project/chiholee-eks/eks/karpenter
export KARPENTER_CF="/Users/chiholee/Desktop/Project/chiholee-eks/eks/karpenter/k-node-iam-role.yaml"
echo ${KARPENTER_CF}
curl -fsSL https://karpenter.sh/v0.27.5/getting-started/getting-started-with-karpenter/cloudformation.yaml  > $KARPENTER_CF
curl -fsSL https://raw.githubusercontent.com/aws/karpenter-provider-aws/"${KARPENTER_VERSION}"/website/content/en/preview/getting-started/getting-started-with-karpenter/cloudformation.yaml > $KARPENTER_CF
## sed -i 's/\${ClusterName}/k-eksworkshop/g' $KARPENTER_CF

## 구성한 Node Role Template을 생성합니다.
aws cloudformation deploy \
  --region ${KARPENTER_AWS_REGION} \
  --stack-name "Karpenter-${k_ekscluster_name}" \
  --template-file "${KARPENTER_CF}" \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides "ClusterName=${k_ekscluster_name}"


eksctl create iamidentitymapping \
--region ${KARPENTER_AWS_REGION} \
--username system:node:{{EC2PrivateDNSName}} \
--cluster ${k_ekscluster_name} \
--arn "arn:aws:iam::${ACCOUNT_ID}:role/KarpenterNodeRole-${k_ekscluster_name}" \
--group system:bootstrappers \
--group system:nodes



### Service Account를 위한 IAM Role을 매핑합니다.

eksctl create iamserviceaccount \
  --region ${KARPENTER_AWS_REGION} \
  --cluster "${k_ekscluster_name}" --name karpenter --namespace karpenter \
  --role-name "${k_ekscluster_name}-karpenter" \
  --attach-policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/KarpenterControllerPolicy-${k_ekscluster_name}" \
  --role-only \
  --override-existing-serviceaccounts \
  --approve

# KARPENTER IAM ROLE ARN을 변수에 저장해 둡니다. 
export KARPENTER_IAM_ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${k_ekscluster_name}-karpenter"
echo ${KARPENTER_IAM_ROLE_ARN}
echo "export export KARPENTER_IAM_ROLE_ARN=${KARPENTER_IAM_ROLE_ARN}" | tee -a ~/.bash_profile

cd ~/environment
curl -L https://git.io/get_helm.sh | bash -s -- --version v3.8.2

helm repo add karpenter https://charts.karpenter.sh/
helm repo update

docker logout public.ecr.aws
helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter --version ${KARPENTER_VERSION} --namespace karpenter --create-namespace \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=${KARPENTER_IAM_ROLE_ARN} \
  --set settings.aws.clusterName=${k_ekscluster_name} \
  --set settings.aws.clusterEndpoint=${K_CLUSTER_ENDPOINT} \
  --set settings.aws.defaultInstanceProfile=KarpenterNodeInstanceProfile-${k_ekscluster_name} \
  --set settings.aws.interruptionQueueName=${k_ekscluster_name} \
  --debug \
  --wait 

  helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter --version ${KARPENTER_VERSION} --namespace karpenter \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=${KARPENTER_IAM_ROLE_ARN} \
  --set settings.aws.clusterName=${k_ekscluster_name} \
  --set settings.aws.clusterEndpoint=${K_CLUSTER_ENDPOINT} \
  --set settings.aws.defaultInstanceProfile=KarpenterNodeInstanceProfile-${k_ekscluster_name} \
  --set settings.aws.interruptionQueueName=${k_ekscluster_name} \
  --wait


helm template karpenter oci://public.ecr.aws/karpenter/karpenter \
    --version ${KARPENTER_VERSION} \
    --namespace karpenter \
    --set settings.aws.defaultInstanceProfile=KarpenterNodeInstanceProfile-${k_ekscluster_name} \
    --set settings.aws.clusterName=${k_ekscluster_name} \
    --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=${KARPENTER_IAM_ROLE_ARN} \
    --set controller.resources.requests.cpu=1 \
    --set controller.resources.requests.memory=1Gi \
    --set controller.resources.limits.cpu=1 \
    --set controller.resources.limits.memory=1Gi \
    --set replicas=2 > karpenter.yaml


export KARPENTER_VERSION="v0.25.0"

kubectl create -f \
    https://raw.githubusercontent.com/aws/karpenter/$KARPENTER_VERSION/pkg/apis/crds/karpenter.sh_provisioners.yaml    
    
kubectl create -f \
    https://raw.githubusercontent.com/aws/karpenter/$KARPENTER_VERSION/pkg/apis/crds/karpenter.k8s.aws_awsnodetemplates.yaml

kubectl api-resources \
    --categories karpenter \
    -o wide






-------------------------------------------------------------


export CLUSTER_NAME="ecommerce-eks"

export AWS_PARTITION="aws"
export AWS_REGION="ap-northeast-2"
export OIDC_ENDPOINT="$(aws eks describe-cluster --name ${CLUSTER_NAME} \
    --query "cluster.identity.oidc.issuer" --output text)"
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' \
    --output text)

echo '{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}' > node-trust-policy.json


aws iam create-role \
    --role-name "KarpenterNodeRole-${CLUSTER_NAME}" \
    --assume-role-policy-document file://node-trust-policy.json

aws iam attach-role-policy \
    --role-name "KarpenterNodeRole-${CLUSTER_NAME}" \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy    

aws iam attach-role-policy \
    --role-name "KarpenterNodeRole-${CLUSTER_NAME}" \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy    

aws iam attach-role-policy \
    --role-name "KarpenterNodeRole-${CLUSTER_NAME}" \
    --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly

aws iam attach-role-policy \
    --role-name "KarpenterNodeRole-${CLUSTER_NAME}" \
    --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore




aws iam create-instance-profile \
    --instance-profile-name "KarpenterNodeInstanceProfile-${CLUSTER_NAME}"

aws iam add-role-to-instance-profile \
    --instance-profile-name "KarpenterNodeInstanceProfile-${CLUSTER_NAME}" \
    --role-name "KarpenterNodeRole-${CLUSTER_NAME}"    



 cat << EOF > controller-trust-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/${OIDC_ENDPOINT#*//}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "${OIDC_ENDPOINT#*//}:aud": "sts.amazonaws.com",
                    "${OIDC_ENDPOINT#*//}:sub": "system:serviceaccount:karpenter:karpenter"
                }
            }
        }
    ]
}
EOF


cat << EOF > controller-policy.json
{
    "Statement": [
        {
            "Action": [
                "ssm:GetParameter",
                "ec2:DescribeImages",
                "ec2:RunInstances",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeLaunchTemplates",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeInstanceTypeOfferings",
                "ec2:DescribeAvailabilityZones",
                "ec2:DeleteLaunchTemplate",
                "ec2:CreateTags",
                "ec2:CreateLaunchTemplate",
                "ec2:CreateFleet",
                "ec2:DescribeSpotPriceHistory",
                "pricing:GetProducts"
            ],
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "Karpenter"
        },
        {
            "Action": "ec2:TerminateInstances",
            "Condition": {
                "StringLike": {
                    "ec2:ResourceTag/Name": "*karpenter*"
                }
            },
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "ConditionalEC2Termination"
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:${AWS_PARTITION}:iam::${AWS_ACCOUNT_ID}:role/KarpenterNodeRole-${CLUSTER_NAME}",
            "Sid": "PassNodeIAMRole"
        },
        {
            "Effect": "Allow",
            "Action": "eks:DescribeCluster",
            "Resource": "arn:${AWS_PARTITION}:eks:${AWS_REGION}:${AWS_ACCOUNT_ID}:cluster/${CLUSTER_NAME}",
            "Sid": "EKSClusterEndpointLookup"
        }
    ],
    "Version": "2012-10-17"
}
EOF



- groups:
  - system:bootstrappers
  - system:nodes
  rolearn: arn:aws:iam::531744930393:role/KarpenterNodeRole-ecommerce-eks
  username: system:node:{{EC2PrivateDNSName}}



helm template karpenter oci://public.ecr.aws/karpenter/karpenter \
    --version ${KARPENTER_VERSION} \
    --namespace karpenter \
    --set settings.aws.defaultInstanceProfile=KarpenterNodeInstanceProfile-${CLUSTER_NAME} \
    --set settings.aws.clusterName=${CLUSTER_NAME} \
    --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="arn:${AWS_PARTITION}:iam::${AWS_ACCOUNT_ID}:role/KarpenterControllerRole-${CLUSTER_NAME}" \
    --set controller.resources.requests.cpu=1 \
    --set controller.resources.requests.memory=1Gi \
    --set controller.resources.limits.cpu=1 \
    --set controller.resources.limits.memory=1Gi \
    --set replicas=2 > karpenter.yaml





kubectl apply -f https://raw.githubusercontent.com/aws/karpenter/main/pkg/apis/crds/karpenter.sh_nodepools.yaml
kubectl apply -f https://raw.githubusercontent.com/aws/karpenter/main/pkg/apis/crds/karpenter.sh_nodeclaims.yaml
kubectl apply -f https://raw.githubusercontent.com/aws/karpenter/main/pkg/apis/crds/karpenter.k8s.aws_ec2nodeclasses.yaml


kubectl create -f \
    https://raw.githubusercontent.com/aws/karpenter/$KARPENTER_VERSION/pkg/apis/crds/karpenter.sh_provisioners.yaml



kubectl create -f https://raw.githubusercontent.com/aws/karpenter-provider-aws/v0.31.3/pkg/apis/crds/karpenter.sh_provisioners.yaml
kubectl create -f https://raw.githubusercontent.com/aws/karpenter-provider-aws/v0.31.3/pkg/apis/crds/karpenter.sh_machines.yaml
kubectl create -f https://raw.githubusercontent.com/aws/karpenter-provider-aws/v0.31.3/pkg/apis/crds/karpenter.k8s.aws_awsnodetemplates.yaml    




export KARPENTER_VERSION=v0.25.0





            - matchExpressions:
              - key: eks.amazonaws.com/nodegroup
                operator: In
                values:
                - ecommerce-ng-public-01




helm repo add christianknell https://christianknell.github.io/helm-charts
helm repo update
kubectl create namespace kube-tools
helm install my-release christianknell/kube-ops-view \
--namespace kube-tools \
--set service.type=LoadBalancer \
--set service.annotations."kubernetes.io/ingress.class"="alb" \
--set service.annotations."alb.ingress.kubernetes.io/scheme"="internet-facing" \
--set service.annotations."alb.ingress.kubernetes.io/target-type"="ip" \
--set service.annotations."alb.ingress.kubernetes.io/subnets"="subnet-07251a05c91ef4a15"



kubectl create namespace kube-tools
helm install my-release christianknell/kube-ops-view \
--namespace kube-tools \
--set service.type=LoadBalancer \
--set nodeSelector.nodegroup-type=ecommerce-ng-public-03 \
--set rbac.create=True \
--set service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-scheme"="internet-facing"






kubectl create namespace kube-tools
helm install my-release christianknell/kube-ops-view \
--namespace kube-tools \
--set service.type=LoadBalancer \
--set nodeSelector.nodegroup-type=ecommerce-ng-public-01 \
--set rbac.create=True \
--set service.annotations."service.beta.kubernetes.io/aws-load-balancer-type"="external" \
--set service.annotations."service.beta.kubernetes.io/aws-load-balancer-nlb-target-type"="ip" \
--set service.annotations."service.beta.kubernetes.io/aws-load-balancer-scheme"="internet-facing"









karpenter.sh/discovery

--set service.annotations."service.beta.kubernetes.io/aws-load-balancer-eip-allocations"="eipalloc-0d8f2c0f17aeb24da,eipalloc-086f78e84e2130bde

kubectl -n kube-tools get svc my-release-kube-ops-view  | tail -n 1 | awk '{ print "my-release-kube-ops-view URL = http://"$4 }'
 

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl get apiservice v1beta1.metrics.k8s.io -o yaml

helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller

helm repo add geek-cookbook https://geek-cookbook.github.io/charts/
helm install kube-ops-view geek-cookbook/kube-ops-view --version 1.2.2 --set env.TZ="Asia/Seoul" --namespace kube-system
kubectl patch svc -n kube-system kube-ops-view -p '{"spec":{"type":"LoadBalancer"}}'
kubectl annotate service kube-ops-view -n kube-system "external-dns.alpha.kubernetes.io/hostname=kubeopsview.$MyDomain"
echo -e "Kube Ops View URL = http://kubeopsview.$MyDomain:8080/#scale=1.5"  


kubectl create namespace helm-test
helm install helm-nginx bitnami/nginx \
--namespace helm-test \
--set service.type=LoadBalancer \
--set service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-scheme"="internet-facing"


kubectl create namespace kube-tools
helm install my-release christianknell/kube-ops-view \
--namespace kube-tools \
--set service.type=LoadBalancer \
--set service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-scheme"="internet-facing"


kubectl create namespace kube-tools
helm install my-release k8s-at-home/kube-ops-view \
--namespace kube-tools \
--set service.type=LoadBalancer \
--set nodeSelector.nodegroup-type=ecommerce-ng-public-01 \
--set service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-scheme"="internet-facing"


helm install my-release christianknell/kube-ops-view \
--namespace kube-tools \
--set service.type=LoadBalancer \
--set nodeSelector.nodegroup-type=ecommerce-ng-public-01 \
--set service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-scheme"="internet-facing"

kubectl create namespace kube-tools
helm install kube-ops-view christianknell/kube-ops-view -n kube-tools \
--set service.port=8080 \
--set service.type=NodePort 
k get all -n kube-tools 
kubectl port-forward $POD_NAME 8080:8080


apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: "kube-ops-view"
  namespace: kube-tools
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/group.name: kube-ops-view
    alb.ingress.kubernetes.io/group.order: '1'
    alb.ingress.kubernetes.io/subnets: subnet-07251a05c91ef4a15,subnet-026db71e8eb67b36c,subnet-092b9af9778a2c97f
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: "kube-ops-view"
            port:
              number: 80
    


kubectl create namespace kube-tools
helm install kube-ops-view christianknell/kube-ops-view -n kube-tools \
--set service.port=8080 \
--set service.type=LoadBalancer \
--set nodeSelector.nodegroup-type=ecommerce-ng-public-01 \
--set service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-scheme"="internet-facing"



cat << EOF > karpenter-provisioner1.yaml
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: provisioner1
spec:
  requirements:
    - key: karpenter.sh/capacity-type
      operator: In
      values: ["spot"]
  limits:
    resources:
      cpu: 1000
  provider:
    subnetSelector:
      karpenter.sh/discovery: ${k_ekscluster_name}
    securityGroupSelector:
      karpenter.sh/discovery: ${k_ekscluster_name}
  ttlSecondsAfterEmpty: 30
EOF


aws iam create-service-linked-role --aws-service-name spot.amazonaws.com || true





kubectl create namespace karpenter-inflate
cat << EOF > karpenter-inflate1.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: inflate1
  namespace: karpenter-inflate  
spec:
  replicas: 0
  selector:
    matchLabels:
      app: inflate1
  template:
    metadata:
      labels:
        app: inflate1
    spec:
      terminationGracePeriodSeconds: 0
      containers:
        - name: inflate1
          image: public.ecr.aws/eks-distro/kubernetes/pause:3.2
          resources:
            requests:
              cpu: 1
      nodeSelector:
        karpenter.sh/capacity-type: spot
EOF
## 생성된 karpenter-inflate.yaml을 실행합니다. 
kubectl apply -f karpenter-inflate1.yaml


kubectl -n karpenter-inflate scale deployment inflate1 --replicas 5

kubectl logs -f -n karpenter -l app.kubernetes.io/name=karpenter -c controller



kubectl -n ecommerce scale deployment inflate1 --replicas 5
