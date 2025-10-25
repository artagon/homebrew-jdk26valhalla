#!/usr/bin/env bash
# Run local validation for the JDK 26 EA tap.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TAP_USER="artagon"
TAP_REPO="homebrew-jdk26ea"
TAP_FULL="${TAP_USER}/${TAP_REPO}"
FORMULA_NAME="jdk26ea"
FORMULA_FULL="${TAP_USER}/jdk26ea/${FORMULA_NAME}"
CASK_FULL="${TAP_USER}/jdk26ea/${FORMULA_NAME}"

log() {
  printf '==> %s\n' "$*"
}

abort() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

command -v brew >/dev/null 2>&1 || abort "Homebrew is required to run these tests."

cleanup_cmds=()
register_cleanup() {
  cleanup_cmds+=("$*")
}

run_cleanup() {
  local status=$?
  for (( idx=${#cleanup_cmds[@]}-1; idx>=0; idx-- )); do
    eval "${cleanup_cmds[$idx]}" || true
  done
  exit "$status"
}
trap run_cleanup EXIT

link_tap_to_repo() {
  local tap_dir
  tap_dir="$(brew --repository)/Library/Taps/${TAP_USER}/${TAP_REPO}"

  if [[ -e "$tap_dir" && ! -L "$tap_dir" ]]; then
    abort "Existing tap checkout found at ${tap_dir}; move it before running these tests."
  fi

  if [[ -L "$tap_dir" ]]; then
    local current_target
    current_target="$(readlink "$tap_dir")"
    if [[ "$current_target" != "$ROOT" ]]; then
      register_cleanup "ln -snf \"${current_target}\" \"${tap_dir}\""
      ln -snf "$ROOT" "$tap_dir"
    fi
  else
    mkdir -p "$(dirname "$tap_dir")"
    ln -s "$ROOT" "$tap_dir"
    register_cleanup "rm -f \"${tap_dir}\""
  fi
}

run_style_and_audit() {
  log "Running brew style checks"
  brew style "${ROOT}/Casks/${FORMULA_NAME}.rb"
  brew style "${ROOT}/Formula/${FORMULA_NAME}.rb"

  log "Running brew audit for formula ${FORMULA_FULL}"
  brew audit --formula "${FORMULA_FULL}"

  if [[ "$(uname -s)" == "Darwin" ]]; then
    log "Running brew audit for cask ${CASK_FULL}"
    brew audit --cask "${CASK_FULL}"
  else
    log "Skipping cask audit on non-macOS host"
  fi
}

test_formula_install() {
  log "Installing formula ${FORMULA_FULL}"
  brew install "${FORMULA_FULL}"
  register_cleanup "brew uninstall --formula ${FORMULA_FULL} >/dev/null 2>&1 || true"

  log "Running brew test for ${FORMULA_FULL}"
  brew test "${FORMULA_FULL}"
}

test_cask_install() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    log "Skipping cask install on non-macOS host"
    return
  fi

  log "Installing cask ${CASK_FULL}"
  brew install --cask "${CASK_FULL}"
  register_cleanup "brew uninstall --cask ${CASK_FULL} >/dev/null 2>&1 || true"

  local app_path="/Library/Java/JavaVirtualMachines/jdk-26-ea.jdk/Contents/Home/bin/java"
  if [[ -x "$app_path" ]]; then
    log "Cask install verification: printing java version"
    "$app_path" -version
  else
    abort "Expected java binary at ${app_path} was not found."
  fi
}

log "Linking tap ${TAP_FULL} to local repository"
link_tap_to_repo

run_style_and_audit
test_formula_install
test_cask_install

log "All checks completed successfully"
