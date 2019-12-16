#!/bin/bash -e

has() { command -v "$1" > /dev/null; }

if [ "$TRAVIS" = true ]; then
  folded() {
    FOLD=$((FOLD+1))
    echo -e "travis_fold:start:cppsm.$FOLD\033[33;1m$1\033[0m"
    travis_time_start
    shift
    echo "$@"
    "$@"
    travis_time_finish
    echo -e "\ntravis_fold:end:cppsm.$FOLD\r"
  }
else
  folded() {
    shift
    "$@"
  }
fi

build-1ml() {
  git clone --depth 1 https://github.com/1ml-prime/1ml.git
  pushd 1ml
  make
  export PATH="$PWD:$PATH"
  popd
}

has 1ml || folded "Build 1ML" build-1ml

install-1ml-mode() {
  git clone --depth 1 https://github.com/1ml-prime/1ml-mode.git
  export PATH="$PWD/1ml-mode/bin:$PATH"
}

has 1ml-check || folded "Install 1ML mode and scripts" install-1ml-mode

folded "Check snippets" 1ml-check

for f in src/examples/*.1ml; do
  folded "$f" 1ml-run "$f"
done
