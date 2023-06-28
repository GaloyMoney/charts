mkdir -p smoketest-settings

kubectl -n galoy-dev-smoketest get secret ${CHART}-smoketest -o json | jq -r '.data' > smoketest-settings/data.json

cat <<EOF > smoketest-settings/helpers.sh
function setting() {
  cat smoketest-settings/data.json | jq -r ".\$1" | base64 --decode
}
function setting_exists() {
  cat smoketest-settings/data.json | jq -r ".\$1 // null"
}
EOF

chmod -R 777 smoketest-settings
