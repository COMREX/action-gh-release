#!/bin/bash
# actions requires a node_modules dir https://github.com/actions/toolkit/blob/master/docs/javascript-action.md#publish-a-releasesv1-action
# but its recommended not to check these in https://github.com/actions/toolkit/blob/master/docs/action-versioning.md#recommendations
# as such the following hack is how we dill with it

if [[ $# -ne 1 ]]; then
	echo "please pass a release version. i.e. $0 v1"
	exit 1
fi

git checkout master
git branch -D releases/$1 || echo "No such branch"

git checkout -b releases/$1 # If this branch already exists, omit the -b flag
rm -rf node_modules
sed -i '/node_modules/d' .gitignore # Bash command that removes node_modules from .gitignore
npm install --production
git add node_modules -f .gitignore
git commit -m node_modules
git push origin releases/$1

git tag -d $1 || echo "No such local tag"
git push --delete origin $v1 || echo "No such remote tag"
git tag -a $1 $1
git push origin $1
