# TERRAFORM - COMO FAZER A AUTENTICAÇÃO DO K8S sem bugs

## 1- Devemos executar primeiramente tudos o procedimentos dentro da máquina do vault no cluster:

```
kubectl exec -it vault-0 -- /bin/sh  
```
- Habilitar a autenticação
```
vault auth enable kubernetes
```

- Aplicar os valores com o token, host e ca_cert do nosso cluster
```
vault write auth/kubernetes/config \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \ kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
```

- Aplicar a role da auth do Kubernetes

```
vault write auth/kubernetes/role/webapp \
        bound_service_account_names=vault-auth \
        bound_service_account_namespaces=default \
        policies=svc-policy \
        ttl=72h
```
- A partir daí temos uma noção do que importar para o nosso terraform.

## 2- Para executar o terraform, primeiramente devemos fazer o export das variáveis que utilizaremos no terraform

```
export VAULT_TOKEN=<token_do_vault>
```
```
export VAULT_ADDR=http://localhost:8200
```
```
export VAULT_SKIP_VERIFY=true    //caso seja https, ele não verifica de modo seguro
```
```
kubectl get secrets      //verificar e anotar o nome da secret, pois é ela que utilizaremos no próximo export (Obs.: caso tenha 
um namespace, utilizar por ex. -n vault apoś o kubectl. No nosso caso, como utilizaei em modo local e instando vault via helm o valor é  sh.helm.release.v1.vault.v1
```
```
export VAULT_SA_NAME=sh.helm.release.v1.vault.v1      //Para pegar o token jwt devemos entrar na maquina do vault via kubectl exec e utilizar o comando:

cat /var/run/secrets/kubernetes.io/serviceaccount/token
```
```
export TF_VAR_token_reviewer_jwt=token sem o "/" no final
```

O CA_CERT do k8s
```
export TF_VAR_kubernetes_ca_cert=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.certificate-authority-data}')
```

O kubernetes host:
Para pegar o valor, devemos verificar dentro do vault. Como fizemos a primeira configuração do aut_kubernetes de teste, devemos entrar na página do vault -> Access -> Kubernetes -> ... -> Edit Configuration -> Pegar o valor do Kubernetes host. Ex.: https://10.96.0.1:443
```
export TF_VAR_kubernetes_host=
```
3- Caso o terraform não tenha sido gerado, eu posso verificar esses valor realizando um terraform import. Caso ele tenha sido gerado, deletear o tfstate dele.

```
terraform import vault_kubernetes_auth_backend_config.example auth/kubernetes/config
```

Fonte:

Podemos utilizar como referência:

https://verifa.io/blog/secrets-handling-in-kubernetes-using-hashicorp-vault/index.html
