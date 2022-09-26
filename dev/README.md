# Charts dev setup

Intended as a local environment to test changes to the charts. Not as a dev backend for the mobile app.
Currently successfully brings up charts - no guarantee that everything is working as in prod, but enough to do some refactorings or stuff like that.

## Dependencies

- k3d
- terraform
- kubectl

## Regtest

run in the `dev` folder:
```
direnv allow
make create-cluster
make init
make deploy-services
make deploy
```

### Test

#### Public endpoint

Forward the galoy API port:

```
k -n galoy-dev-galoy port-forward $(k get pods -A|grep api|awk '{print $2}'|head -1) 8080:4002
```
In an other terminal:

```
host=localhost
port=8080
curl --location -sSf --request POST "${host}:${port}/graphql"\
 --header 'Content-Type: application/json' \
 --data-raw '{"query":"query btcPrice { btcPrice { base currencyUnit formattedAmount offset } }","variables":{}}'
```

Expected output:
```
{"data":{"btcPrice":{"base":19171500000,"currencyUnit":"USDCENT","formattedAmount":"0.019171499999999998","offset":12}}}
```

#### Authenticated endpoint

Forward the nginx port:
```
kubectl -n galoy-dev-ingress port-forward svc/ingress-nginx-controller 8080:443
```
In an other terminal:
```
$ curl -k 'https://localhost:8080/graphql' -H 'Content-Type: application/json' -H 'Accept: application/json' --data-binary '{"query":"mutation login($input: UserLoginInput!) { userLogin(input: $input) { authToken } }","variables":{"input":{"phone":"+59981730222","code":"111111"}}}'
```

Expected output:
```
{"data":{"userLogin":{"authToken":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiI2MTc2YmQ2NmQ0MmFkYWIzNjM2MmEyY2QiLCJuZXR3b3JrIjoibWFpbm5ldCIsImlhdCI6MTYzNTE3MTY4Nn0.n-p5sA9meAmZrVOdngYr216jG3LKOFsFdJmVw6XND3A"}}}
```

Currently incomplete functionality - but depending on what you want to hack on it'll work


## Signet

run in the `dev` folder:
```
direnv allow
make create-cluster
make init
make deploy-signet-services
make deploy-signet
```

### Test

#### Public endpoint

Forward the api port:

```
k -n galoy-sig-galoy port-forward $(k get pods -A|grep api|awk '{print $2}'|head -1) 8080:4002
```
In an other terminal:

```
host=localhost
port=8080
curl --location -sSf --request POST "${host}:${port}/graphql"\
 --header 'Content-Type: application/json' \
 --data-raw '{"query":"query btcPrice { btcPrice { base currencyUnit formattedAmount offset } }","variables":{}}'
```

Expected output:
```
{"data":{"btcPrice":{"base":19171500000,"currencyUnit":"USDCENT","formattedAmount":"0.019171499999999998","offset":12}}}
```

#### Authenticated endpoint

Forward the nginx port:
```
kubectl -n galoy-sig-ingress port-forward svc/ingress-nginx-controller 38080:80
```

In an other terminal:
```
curl -k 'https://llocalhost:38080/graphql' -H 'Content-Type: application/json' -H 'Accept: application/json' --data-binary '{"query":"mutation login($input: UserLoginInput!) { userLogin(input: $input) { authToken } }","variables":{"input":{"phone":"+59981730222","code":"111111"}}}'
```

Expected output:
```
{"data":{"userLogin":{"authToken":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiI2MTc2YmQ2NmQ0MmFkYWIzNjM2MmEyY2QiLCJuZXR3b3JrIjoibWFpbm5ldCIsImlhdCI6MTYzNTE3MTY4Nn0.n-p5sA9meAmZrVOdngYr216jG3LKOFsFdJmVw6XND3A"}}}
```