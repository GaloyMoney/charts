# Charts dev setup

Intended as a local environment to test changes to the charts. Not as a dev backend for the mobile app.
Currently successfully brings up charts - no guarantee that everything is working as in prod, but enough to do some refactorings or stuff like that.

## Dependencies

- k3d
- terraform
- kubectl

## Regtest
* run in the `dev` folder:
  ```
  direnv allow
  make create-cluster
  make init
  make deploy-services
  make deploy
  ```

### Test

#### Forward the oathkeeper-proxy port:
* Run and keep open:
  ```
  kubectl -n galoy-dev-galoy port-forward svc/galoy-oathkeeper-proxy  8080:4455
  ```
#### Test the galoy-api

1. get session token
    ```
    curl -ksS 'http://localhost:8080/graphql' -H 'Content-Type: application/json' -H 'Accept: application/json' --data-binary '{"query":"mutation login($input: UserLoginInput!) { userLogin(input: $input) { authToken } }","variables":{"input":{"phone":"+59981730222","code":"111111"}}}' | jq '.data.userLogin.authToken'
    ```

    Example result:
    ```
    "CrDr5orsnFLg3SL3Jpk9cH0wXENAWqbY"
    ```
2. query an authenticated endpoint (fill out the `session_token` from above)
    ```
    session_token="CrDr5orsnFLg3SL3Jpk9cH0wXENAWqbY"
    curl -k 'http://localhost:8080/graphql' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Authorization: bearer ${session_token}' --data-binary '{"query": "{ me { phone } }" }'
    ```
    Expected result:
    ```
    {"data":{"me":{"phone":"+59981730222"}}}
    ```
#### Test the graphql-admin api

1. get session token
    ```
    curl -ksS 'http://localhost:8080/admin/graphql' -H 'Content-Type: application/json' -H 'Accept: application/json' --data-binary '{"query":"mutation login($input: UserLoginInput!) { userLogin(input: $input) { authToken } }","variables":{"input":{"phone":"+59981730222","code":"111111"}}}' | jq '.data.userLogin.authToken'
    ```

    Example result:
    ```
    "Beo2lGQZO4nZKzIyZRlVFIQ6jAeo9bNu"
    ```

## Signet

* run in the `dev` folder:
  ```
  direnv allow
  make create-cluster
  make init
  make deploy-signet-services
  make deploy-signet
  ```

## RTL access
-
  ```
  env=galoy-dev

  # get the password
  k -n ${env}-bitcoin get secrets rtl-pass -o jsonpath='{.data.password}' | base64 -d; echo

  # forward the port from the pod
  k -n ${env}-bitcoin port-forward svc/rtl 3000:3000

  # access RTL on http://localhost:3000
  ```

## Grafana access
-
  ```
  env=galoy-dev

  the user is: `admin` (https://github.com/bitnami/charts/blob/main/bitnami/grafana/values.yaml#L76)

  # get the password
  k -n ${env}-monitoring get secrets monitoring-grafana -o jsonpath='{.data.admin-password}' | base64 -d; echo

  # forward the port from the pod
  k -n ${env}-monitoring port-forward svc/monitoring-grafana 3000:80

  # access Grafana on http://localhost:3000
  ```

## Port access from a remote computer
-
  ```
  # port forward with ssh
  localport=3000      # chosen port on the desktop with the web browser
  user=k3d            # remote user (example)
  host=192.168.3.170  # the IP address of the server (example)

  ssh -L $localport:127.0.0.1:3000 $user@$host

  # access the service on http://localhost:$localport
  ```
