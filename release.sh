#!/bin/bash

# actions requires a node_modules dir https://github.com/actions/toolkit/blob/master/docs/javascript-action.md#publish-a-releasesv1-action
# but its recommended not to check these in https://github.com/actions/toolkit/blob/master/docs/action-versioning.md#recommendations
# as such the following hack is how we dill with it

set +o xtrace

if [[ $# -ne 1 ]]; then
	echo "You must provide a version, like: $0 v1"
	exit 1
fi

git checkout master
git branch -D releases/$1 || echo "No such local branch"
git push origin --delete releases/$1 || echo "No such remote branch"

git checkout -b releases/$1
rm -rf node_modules
sed -i '.bak' '/node_modules/d' .gitignore # Remove node_modules from .gitignore
sed -i '.bak' '/dist/d' .gitignore # Remove dist from .gitignore

npm install
npm run build

git add node_modules dist -f .gitignore
git commit -m node_modules
git push origin releases/$1 --force

git tag -d $1 || echo "No such local tag"
git push --delete origin $1 || echo "No such remote tag"
git tag -a $1 -m $1
git push origin $1

git checkout master
git branch -D releases/$1
