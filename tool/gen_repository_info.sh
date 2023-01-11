#! bin/bash

REPO_USER=google
REPO_NAME=material-design-icons
SYMBOLS_DIR=symbols/web

# >>> For test >>>
#
# REPO_USER=spebbe
# REPO_NAME=dartz
# SYMBOLS_DIR=example
#
# <<< For test <<<


if [ $# -ne 1 ]; then
  echo "usage: sh gen_repository_info.sh [output (relative path)]"
  exit 1
fi

OUTPUT=`pwd`/$1
TMP_DIR=`mktemp -d`
# https://stackoverflow.com/a/246128/20086982
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
DART_CLASS_GENERATOR=$SCRIPT_DIR/gen_repository_info_class.py

cd $TMP_DIR
git clone --depth=1 --sparse --no-checkout git@github.com:$REPO_USER/$REPO_NAME.git
cd $REPO_NAME 
git sparse-checkout add $SYMBOLS_DIR
git checkout --progress

PY_INPUT=$TMP_DIR/py_input.txt

# latest commit id
COMMIT_ID=`git log --format="%H" -n 1`
echo $COMMIT_ID > $PY_INPUT

# base-url
echo "https://raw.githubusercontent.com/${REPO_USER}/${REPO_NAME}/${COMMIT_ID}/${SYMBOLS_DIR}" \
 >> $PY_INPUT

# symbol names
find $SYMBOLS_DIR -type d -mindepth 1 -maxdepth 1 -exec basename {} \; \
 >> $PY_INPUT

cd $TMP_DIR

# generate a json file
cat $PY_INPUT | python $DART_CLASS_GENERATOR > $OUTPUT

rm -rf $TMP_DIR

echo "Generated -> ${OUTPUT}"