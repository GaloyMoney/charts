#!/bin/bash

cd charts-repo/charts

for d in */ ; do

  pushd $d

  DEPS=$(helm dependency list | tail -n +2 | grep -v WARNING | xargs -n 4)

  TMPFILE=$(mktemp /tmp/helm-update.XXXXXXX) || exit 1

  echo $DEPS | xargs -n 4 | awk '{ print $1,$3 }' > $TMPFILE

  if [[ $(cat $TMPFILE | grep \\.) == "" ]]; then
    popd
    continue
  fi

  L=0
  while IFS="" read -r p || [ -n "$p" ]
  do
    dep=$(echo $p | cut -d' ' -f1)
    repo=$(echo $p | cut -d' ' -f2)

    helm repo add repository $repo

    VERSION=$(helm search repo repository/$dep -o json | jq -r '[.[]][0] | .version')
    yq -i ".dependencies[$L].version = \"$VERSION\"" Chart.yaml

    helm repo remove repository

    L=$((L+1))
  done < $TMPFILE

  rm $TMPFILE

  helm dependency update

  popd

done

if [[ -z $(git config --global user.email) ]]; then
  git config --global user.email "bot@galoy.io"
fi
if [[ -z $(git config --global user.name) ]]; then
  git config --global user.name "CI Bot"
fi


(cd $(git rev-parse --show-toplevel)
git merge --no-edit ${BRANCH}
git add -A
git status
git commit -m "chore(deps): update helm chart dependencies"
)
