

### namespace 를 나누면 service alias 로 통신이 되지 않음
```
cat /etc/resolv.conf
```
### Create or update the kubeconfig file for your cluster
```
aws eks --region ap-northeast-2 update-kubeconfig --name chiholee-product
aws eks --region ap-northeast-2 update-kubeconfig --name chiholee-dev
```
### kubeconfig view
```
~/.kube/config
kubectl config view
```
### current kubeconfig view
```
kubectl config current-context
```
### use kubeconfig
```
kubectl config use-context arn:aws:eks:ap-northeast-2:531744930393:cluster/chiholee-product
kubectl config use-context arn:aws:eks:ap-northeast-2:531744930393:cluster/chiholee-dev
```
### create namespace
```
kubectl create namespace order
kubectl create namespace customer
kubectl create namespace product

kubectl get namespace
```
### order service apply
```
kubectl apply -f order/service.yaml
kubectl get svc -n order
```
### product service apply
```
kubectl apply -f product/service.yaml
kubectl get svc -n product
```
### customer service apply
```
kubectl apply -f customer/service.yaml
kubectl get svc -n customer
```
### create database info configmap
```
kubectl create cm database-env-config --from-env-file=.database_env -n order
kubectl create cm database-env-config --from-env-file=.database_env -n product
kubectl create cm database-env-config --from-env-file=.database_env -n customer
kubectl create cm database-env-config --from-env-file=.database_env

kubectl delete cm database-env-config -n order
kubectl delete cm database-env-config -n product
kubectl delete cm database-env-config -n customer
kubectl delete cm database-env-config 
```
### configmap check
```
kubectl get configmap 
kubectl get configmap database-env-config -o yaml
```

### locust configmap delete -> create, pod create
kubectl delete configmap locust-config;kubectl create configmap locust-config --from-file=/Users/ken/Project/chiholee-eks/source/locust/locust-tasks/configs;kubectl delete -f /Users/ken/Project/chiholee-eks/eks/locust/deployment.yaml;kubectl apply -f /Users/ken/Project/chiholee-eks/eks/locust/deployment.yaml

### order deployee
```
kubectl apply -f order/deployment.yaml
kubectl delete -f order/deployment.yaml
kubectl get pods -o wide -n order
kubectl logs -f order-8bd75b7f9-b8qd4 -n order
```
### pod error check
```
kubectl get events --namespace=kube-system
```
### product deployee
```
kubectl apply -f product/deployment.yaml
kubectl delete -f product/deployment.yaml
kubectl get pods -o wide -n product
kubectl logs -f product-8bd75b7f9-b8qd4 -n product

```
### customer deployee
```
kubectl apply -f customer/deployment.yaml
kubectl delete -f customer/deployment.yaml
kubectl get pods -o wide -n customer
kubectl logs -f customer-8bd75b7f9-b8qd4 -n customer
```
### shell access
```
kubectl exec -n product -it product-bc7c85ddd-66f68 -- /bin/bash

```
### exteranl service 
```
kubectl apply -f product/communicate.yaml
```
### port-forward
```
kubectl port-forward service/order 8000:80 -n order
```
### ingress apply
```
kubectl apply -f product/ingress.yaml
kubectl get ingress -n product -o wide
```
### LB IAM OIDC
```
eksctl utils associate-iam-oidc-provider \
    --region ap-northeast-2 \
    --cluster chiholee-prod \
    --approve

aws eks describe-cluster --name chiholee-prod --query "cluster.identity.oidc.issuer" --output text

(aws iam list-open-id-connect-providers | grep 8A6E78112D7F1C4DC352B1B511DD13CF)

curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.4/docs/install/iam_policy.json

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam-policy.json

eksctl create iamserviceaccount \
    --cluster chiholee-prod \
    --namespace kube-system \
    --name aws-load-balancer-controller \
    --attach-policy-arn arn:aws:iam::531744930393:policy/AWSLoadBalancerControllerIAMPolicy \
    --override-existing-serviceaccounts \
    --approve
```
### cert manager install
```
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.5.4/cert-manager.yaml

v2_4_4_full.yaml 편집
- cluster-name
- ServiceAccount yaml spec 삭제

kubectl apply -f v2_4_4_full.yaml

kubectl get deployment -n kube-system aws-load-balancer-controller

kubectl get sa aws-load-balancer-controller -n kube-system -o yaml

kubectl logs -n kube-system $(kubectl get po -n kube-system | egrep -o "aws-load-balancer[a-zA-Z0-9-]+")

ALBPOD=$(kubectl get pod -n kube-system | egrep -o "aws-load-balancer[a-zA-Z0-9-]+")

kubectl describe pod -n kube-system ${ALBPOD}
```
### deployment scale
```
kubectl scale deployment order -n order --replicas=10
```

