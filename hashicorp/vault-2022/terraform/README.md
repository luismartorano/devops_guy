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
kubectl get sa      //não esquecer de geral um sa -> nesse caso gerei o vauth-auth para o kubernetes
```
```
export VAULT_SA_NAME=vault-auth  
```

Para pegar o token jwt devemos entrar na maquina do vault via kubectl exec e utilizar o comando:

cat /var/run/secrets/kubernetes.io/serviceaccount/token

Saia da máquina e cole o token sempre sem o '/' no final

```
export TF_VAR_token_reviewer_jwt=
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

3- Caso o terraform não tenha sido gerado, eu posso verificar esses valores realizando um terraform import. Caso ele tenha sido gerado, deletar o tfstate dele.
Aqui eu consigo verificar se realmente os exports foram atribuidos as variáveis do terraform.

```
terraform import vault_kubernetes_auth_backend_config.example auth/kubernetes/config
```

Fonte:

Podemos utilizar como referência:

https://verifa.io/blog/secrets-handling-in-kubernetes-using-hashicorp-vault/index.html
