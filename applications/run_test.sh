# Copyright 2016 Transwarp Inc. All rights reserved.

function usage() {
  echo "usage:"
  echo "$(basename $0) test|fmt|clean"
  echo "Commands"
  echo -e "\t$(basename $0) test [-d test_dir]\tconduct test on /bin templates"
  echo -e "\t$(basename $0) fmt\tconduct format on jsonnet templates"
  echo -e "\t$(basename $0) clean\tclean up temporary test files when conducting test"
  exit 1
}

FAILED=0
EXECUTED=0

JSONNET_CMD="${JSONNET_BIN:-jsonnet}"
# ARGS="--ext-code-file"
ARGS="--tla-code-file"
EXTER_VAR="config"

function clean() {
  for TEST_DIR in $(find "." -name "test-files"); do
  	for dir in $TEST_DIR/* ; do
  		if [[ -d $dir ]]; then
  			echo "cleaning directory: $dir/"
  			rm -r $dir
  		elif [[ $dir == *".jsonnet.test"* ]]; then
  			echo "cleaning tmp files: $dir"
  			rm $dir
  		fi
  	done
  done
	echo "All cleaned!"
	exit 0
}

# format jsonnet script
function fmt() {
	for f in $(find "." -name "*.jsonnet" -o -name "*.libsonnet"); do
		if [[ -r $f ]]; then
			$JSONNET_CMD "$1" -i -n 2 $f
		fi
	done
	echo "All formated!"
	exit 0
}

function count() {
  echo
  if [[ $FAILED -eq 0 ]]; then
  	echo "All $EXECUTED test scripts pass."
        exit 0
  else
  	echo "FAILED: $FAILED / $EXECUTED"
        exit 1
  fi
}

function scan_tests(){
  for file in $(find $1 \( -name "dependency.jsonnet" -or -name "application-main.jsonnet" \)); do
    if [[ -d $file ]]; then
        continue
    fi
    tpl_dir=$(dirname $file)
    for folder in $(find $tpl_dir -name "test*"); do
      if [[ -d $folder ]]; then

        # Template config tests
        for test_config in $(find $folder -name "config*.jsonnet" | grep -P "config\w*_[^\.]*\.jsonnet"); do
          template=$tpl_dir/$(echo $test_config | awk -F_ '{print $2}')
          test $template $test_config
        done

        # Unittests
        for test_module in $(find $folder -name "test_*.jsonnet"); do
          EXECUTED=$((EXECUTED + 1))
          TEST_OUTPUT="$($JSONNET_CMD "$test_module" 2>&1)"
          TEST_EXIT_CODE="$?"
          if [[ $TEST_EXIT_CODE == 1 ]]; then
            FAILED=$((FAILED + 1))
            echo $TEST_OUTPUT
          fi
        done
      fi
    done
  done
}

function test() {
  FILE="$1"
  TEST_CONFIG="$2"
  TEST_DIR=$(dirname $TEST_CONFIG)

  EXECUTED=$((EXECUTED+1))
  TEST_OUTPUT="$($JSONNET_CMD $FILE $ARGS $EXTER_VAR=$TEST_CONFIG 2>&1)"
  TEST_EXIT_CODE="$?"

  filename=$(basename "$TEST_CONFIG")
  # extension="${filename##*.}"
  filename=${filename%.*}

  echo
  if [[ $TEST_EXIT_CODE == 1 ]]; then
    FAILED=$((FAILED+1))
    echo -e "=== TEST CASE $EXECUTED $TEST_CONFIG \033[31m FAIL \033[0m=== "
    echo "$TEST_OUTPUT"
  else
    echo "$TEST_OUTPUT" > "${TEST_CONFIG}.test"
    DIFF="$(diff "${TEST_CONFIG}.test" "${TEST_CONFIG}.golden" 2>&1)"
    if [[ "$DIFF" != "" ]]; then
      FAILED=$((FAILED+1))
      echo -e "=== TEST CASE $EXECUTED $TEST_CONFIG \033[33m DIFF \033[0m=== "
      echo "diff ${TEST_CONFIG}.test ${TEST_CONFIG}.golden"
      echo "$DIFF"
      exit 1
    elif [[ "$DIFF" == "" ]]; then
      echo -e "=== TEST CASE $EXECUTED $TEST_CONFIG \033[32m PASS \033[0m=== "
      mkdir -p $TEST_DIR/$filename
      $JSONNET_CMD -m $TEST_DIR/$filename -e "$TEST_OUTPUT"
      rm "${TEST_CONFIG}.test"
    fi
  fi
}


if [[ $# -eq 0 ]]; then
  scan_tests `dirname $0`
  count
elif [[ "$1" == "test" ]]; then
  shift 1
  until [[ $# -eq 0 ]]; do
    case $1 in
    -d )
      TEST_DIR=$2
      shift 2
      ;;
    * )
      usage
      ;;
    esac
  done
  scan_tests $TEST_DIR
  count
elif [[ "$1" == "clean" ]]; then
  shift 1
  until [[ $# -eq 0 ]]; do
    case $1 in
    * )
      usage
      ;;
    esac
  done
  clean
elif [[ "$1" == "fmt" ]]; then
  shift 1
  until [[ $# -eq 0 ]]; do
    case $1 in
    * )
      usage
      ;;
    esac
  done
  fmt "fmt"
else
  usage
fi
