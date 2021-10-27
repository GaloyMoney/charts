# Charts dev setup

Intended as a local environment to test changes to the charts. Not as a dev backend for the mobile app.
Currently successfully brings up charts - no guarantee that everything is working as in prod, but enough to do some refactorings or stuff like that.

## How To

dependencies:
- k3d
- terraform
- kubectl

run in the `dev` folder:
```
direnv allow
make create-cluster
make init
make deploy-services
make deploy
```

Test if its working:
```
kubectl -n galoy-dev-ingress port-forward svc/ingress-nginx-controller 8080:80
```
In other terminal:
```
$ curl 'localhost:8080/graphql' -H 'Content-Type: application/json' -H 'Accept: application/json' --data-binary '{"query":"mutation login($input: UserLoginInput!) { userLogin(input: $input) { authToken } }","variables":{"input":{"phone":"+59981730222","code":"111111"}}}'
{"data":{"userLogin":{"authToken":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiI2MTc2YmQ2NmQ0MmFkYWIzNjM2MmEyY2QiLCJuZXR3b3JrIjoibWFpbm5ldCIsImlhdCI6MTYzNTE3MTY4Nn0.n-p5sA9meAmZrVOdngYr216jG3LKOFsFdJmVw6XND3A"}}}
```

Currently incomplete functionality - but depending on what you want to hack on it'll work
