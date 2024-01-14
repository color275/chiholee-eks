Admin$1234

https://archive.eksworkshop.com/intermediate/230_logging/prereqs/

aws iam create-policy   \
  --policy-name fluent-bit-policy \
  --policy-document fluent-bit-policy.json


eksctl create iamserviceaccount \
    --name fluent-bit \
    --namespace logging \
    --cluster ecommerce-eks \
    --attach-policy-arn "arn:aws:iam::531744930393:policy/fluent-bit-policy" \
    --approve \
    --override-existing-serviceaccounts

eksctl create iamserviceaccount \
    --name fluent-bit \
    --namespace logging-es \
    --cluster ecommerce-eks \
    --attach-policy-arn "arn:aws:iam::531744930393:policy/fluent-bit-policy" \
    --approve \
    --override-existing-serviceaccounts

eksctl get iamserviceaccount --cluster ecommerce-eks --namespace logging -o json | jq '.[].status.roleARN' -r
aws opensearch describe-domain --domain-name ${ES_DOMAIN_NAME} --output text --query "DomainStatus.Endpoint"

# We need to retrieve the Fluent Bit Role ARN
export FLUENTBIT_ROLE=$(eksctl get iamserviceaccount --cluster ecommerce-eks --namespace logging -o json | jq '.[].status.roleARN' -r)

# Get the Amazon OpenSearch Endpoint
export ES_ENDPOINT=$(aws opensearch describe-domain --domain-name chiholee-opensearch --output text --query "DomainStatus.Endpoint")


export ES_DOMAIN_USER=admin
export ES_DOMAIN_PASSWORD=Admin12!!
# Update the Elasticsearch internal database
curl -sS -u "${ES_DOMAIN_USER}:${ES_DOMAIN_PASSWORD}" \
    -X PATCH \
    https://search-chiholee-opensearch-elml7637bqkta3abrluhtjggiq.ap-northeast-2.es.amazonaws.com/_opendistro/_security/api/rolesmapping/all_access?pretty \
    -H 'Content-Type: application/json' \
    -d'
[
  {
    "op": "add", "path": "/backend_roles", "value": ["'arn:aws:iam::531744930393:role/eksctl-ecommerce-eks-addon-iamserviceaccount--Role1-s1z71r4abm89'"]
  }
]
'


    [OUTPUT]
        Name  opensearch
        Match *
        Host  search-chiholee-opensearch-elml7637bqkta3abrluhtjggiq.ap-northeast-2.es.amazonaws.com
        Port  443
        Index accesslog
        Type  my_type
        AWS_Auth On
        AWS_Region us-west-2
        tls     On

output-elasticsearch.conf: |
    [OUTPUT]
        Name            opensearch
        Match           *
        Host            vpc-test-aponilxfo5qn2nfe6mitxf2rxu.ap-northeast-2.es.amazonaws.com
        Port            443
        Index           accesslog
        AWS_Auth        On
        AWS_Region      ap-northeast-2
        tls             On



output-kafka.conf: |
    [OUTPUT]
        Name           kafka
        Match          *
        Brokers        b-4.chiholeemsk.xmm8ve.c2.kafka.ap-northeast-2.amazonaws.com:9092,b-2.chiholeemsk.xmm8ve.c2.kafka.ap-northeast-2.amazonaws.com:9092,b-6.chiholeemsk.xmm8ve.c2.kafka.ap-northeast-2.amazonaws.com:9092
        Topics         accesslog
        Timestamp_Key  @timestamp
        Retry_Limit    false
        rdkafka.log.connection.close false
        rdkafka.queue.buffering.max.kbytes 10240
        rdkafka.request.required.acks 1


kubectl delete -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/output/kafka/fluent-bit-ds.yaml        
kubectl create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/output/kafka/fluent-bit-ds.yaml        


k edit configmap fluent-bit-config -n logging





helm repo add fluent https://fluent.github.io/helm-charts

k create ns amazon-opensearch

helm upgrade --install fluent-bit fluent/fluent-bit -n amazon-opensearch

k edit configmap fluent-bit-config -n logging
k edit configmap fluent-bit-config -n amazon-opensearch

kubectl --namespace amazon-opensearch port-forward pod/fluent-bit-28vwn 2020:2020


kubectl create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/output/kafka/fluent-bit-configmap.yaml


  output-kf.conf: |
    [OUTPUT]
        Name kinesis_firehose
        Match *
        region ap-northeast-2
        delivery_stream ecommerce-accesslog
        workers 2


https://mokpolar.tistory.com/48

helm repo add fluent https://fluent.github.io/helm-charts
helm show values fluent/fluent-bit > fluent-bit-values.yaml