#!/usr/bin/env bash
set -euo pipefail

FZAUDIO_REPO_URL="${FZAUDIO_REPO_URL:-https://github.com/saint0x/fzaudio.git}"
FZY_REPO_URL="${FZY_REPO_URL:-https://github.com/saint0x/fzy.git}"
FOZZY_REPO_URL="${FOZZY_REPO_URL:-https://github.com/ariacomputecompany/fozzy.git}"

SCRIPT_PATH="${BASH_SOURCE[0]}"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd -P)"
SCRIPT_NAME="$(basename "$SCRIPT_PATH")"
DEFAULT_PARENT="$(cd "$SCRIPT_DIR/.." && pwd -P)"
DEFAULT_FZAUDIO_DIR="$SCRIPT_DIR"
DEFAULT_INSTALL_BIN_DIR="${FZ_INSTALL_DIR:-$HOME/.local/bin}"

say() {
  printf '[%s] %s\n' "$SCRIPT_NAME" "$*"
}

fail() {
  printf '[%s] error: %s\n' "$SCRIPT_NAME" "$*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "missing required command: $1"
}

prompt_yes_no() {
  local prompt="$1"
  local default_answer="$2"
  local suffix="[y/N]"
  local reply normalized

  if [[ "$default_answer" == "yes" ]]; then
    suffix="[Y/n]"
  fi

  while true; do
    printf '%s %s ' "$prompt" "$suffix"
    IFS= read -r reply
    reply="$(trim_input "$reply")"
    if [[ -z "$reply" ]]; then
      [[ "$default_answer" == "yes" ]] && return 0
      return 1
    fi

    normalized="$(printf '%s' "$reply" | tr '[:upper:]' '[:lower:]')"
    case "$normalized" in
      y|yes) return 0 ;;
      n|no) return 1 ;;
    esac

    say "please answer yes or no"
  done
}

trim_input() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

unquote_input() {
  local value="$1"
  if [[ "$value" == \"*\" && "$value" == *\" ]]; then
    value="${value:1:${#value}-2}"
  elif [[ "$value" == \'*\' && "$value" == *\' ]]; then
    value="${value:1:${#value}-2}"
  fi
  printf '%s' "$value"
}

normalize_path() {
  local raw="${1:-}"
  local value
  value="$(trim_input "$raw")"
  value="$(unquote_input "$value")"
  value="$(trim_input "$value")"

  if [[ -z "$value" ]]; then
    value="$DEFAULT_PARENT"
  fi

  case "$value" in
    "~")
      value="$HOME"
      ;;
    "~/"*)
      value="$HOME/${value#~/}"
      ;;
  esac

  if [[ "$value" != /* ]]; then
    value="$PWD/$value"
  fi

  mkdir -p "$value"
  (
    cd "$value"
    pwd -P
  )
}

repo_remote_matches() {
  local repo_dir="$1"
  local expected_url="$2"

  if [[ ! -d "$repo_dir/.git" ]]; then
    return 1
  fi

  local actual_url normalized_expected normalized_actual
  actual_url="$(git -C "$repo_dir" config --get remote.origin.url || true)"
  normalized_expected="${expected_url%.git}"
  normalized_actual="${actual_url%.git}"

  [[ -n "$normalized_actual" && "$normalized_actual" == "$normalized_expected" ]]
}

current_checkout_is_expected_fzaudio() {
  if repo_remote_matches "$DEFAULT_FZAUDIO_DIR" "$FZAUDIO_REPO_URL"; then
    return 0
  fi

  [[ -f "$DEFAULT_FZAUDIO_DIR/fozzy.toml" && -f "$DEFAULT_FZAUDIO_DIR/fzaudio.toml" ]]
}

clone_or_update_repo() {
  local repo_name="$1"
  local repo_url="$2"
  local repo_dir="$3"

  if [[ -e "$repo_dir" && ! -d "$repo_dir" ]]; then
    fail "$repo_dir exists and is not a directory"
  fi

  if [[ -d "$repo_dir/.git" ]]; then
    if ! repo_remote_matches "$repo_dir" "$repo_url"; then
      fail "existing repo at $repo_dir has a different origin remote"
    fi
    say "updating existing $repo_name checkout at $repo_dir"
    git -C "$repo_dir" fetch --all --tags --prune
    return 0
  fi

  if [[ -d "$repo_dir" ]]; then
    if [[ -n "$(find "$repo_dir" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]]; then
      fail "$repo_dir already exists and is not an empty git checkout"
    fi
    rmdir "$repo_dir"
  fi

  say "cloning $repo_name into $repo_dir"
  git clone "$repo_url" "$repo_dir"
}

ensure_path_for_current_shell() {
  local dir="$1"
  if [[ -d "$dir" ]]; then
    case ":${PATH:-}:" in
      *":$dir:"*) ;;
      *)
        export PATH="$dir:$PATH"
        ;;
    esac
  fi
}

cargo_bin_dir() {
  if [[ -n "${CARGO_HOME:-}" ]]; then
    printf '%s/bin' "$CARGO_HOME"
    return 0
  fi
  printf '%s/.cargo/bin' "$HOME"
}

ensure_rust_toolchain() {
  if command -v cargo >/dev/null 2>&1 && command -v rustc >/dev/null 2>&1; then
    ensure_path_for_current_shell "$(cargo_bin_dir)"
    return 0
  fi

  say "Rust is required to build fzy, fzaudio, and optional fozzy."
  need_cmd curl

  if ! prompt_yes_no 'Install Rust now with rustup?' "yes"; then
    fail "Rust is required. Install rustup manually and rerun this script."
  fi

  curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs | sh -s -- -y --profile minimal

  if [[ -f "$HOME/.cargo/env" ]]; then
    # shellcheck disable=SC1090
    . "$HOME/.cargo/env"
  fi

  ensure_path_for_current_shell "$(cargo_bin_dir)"
  need_cmd cargo
  need_cmd rustc
}

verify_binary() {
  local bin_name="$1"
  command -v "$bin_name" >/dev/null 2>&1 || fail "expected $bin_name on PATH after installation"
}

install_fz() {
  local fzy_dir="$1"
  say "installing fz from local fzy checkout"
  bash "$fzy_dir/install.sh" --from-local-checkout "$fzy_dir"
  ensure_path_for_current_shell "$DEFAULT_INSTALL_BIN_DIR"
  verify_binary fz
  fz version
  fz env --json >/dev/null
}

install_fozzy() {
  local fozzy_dir="$1"
  say "installing fozzy from local checkout"
  (
    cd "$fozzy_dir"
    cargo install --locked --path .
  )
  ensure_path_for_current_shell "$(cargo_bin_dir)"
  verify_binary fozzy
  fozzy version --json >/dev/null
  fozzy env --json >/dev/null
}

build_fzaudio() {
  local fzaudio_dir="$1"
  say "running fz check for fzaudio"
  fz check "$fzaudio_dir" --json >/dev/null
  say "running deterministic fz test for fzaudio"
  fz test "$fzaudio_dir" --det --strict-verify --json >/dev/null
  say "building fzaudio with cranelift"
  fz build "$fzaudio_dir" --backend cranelift --json >/dev/null
}

main() {
  local install_fozzy_choice=0

  need_cmd bash
  need_cmd git

  cat <<EOF
This installer sets up the full fzaudio workspace:
  - fzaudio
  - fzy
  - fozzy

Press Enter to keep the current fzaudio checkout at:
  $DEFAULT_FZAUDIO_DIR

and clone/update the companion repos as siblings under:
  $DEFAULT_PARENT
EOF

  ensure_rust_toolchain

  printf 'Install parent directory [%s]: ' "$DEFAULT_PARENT"
  local user_input install_parent
  IFS= read -r user_input
  install_parent="$(normalize_path "$user_input")"

  if prompt_yes_no 'Install the optional fozzy testing engine too?' "yes"; then
    install_fozzy_choice=1
  fi

  local target_fzaudio_dir target_fzy_dir target_fozzy_dir
  target_fzaudio_dir="$install_parent/fzaudio"
  target_fzy_dir="$install_parent/fzy"
  target_fozzy_dir="$install_parent/fozzy"

  say "using install parent: $install_parent"

  if [[ "$install_parent" == "$DEFAULT_PARENT" && "$(basename "$DEFAULT_FZAUDIO_DIR")" == "fzaudio" ]] && current_checkout_is_expected_fzaudio; then
    target_fzaudio_dir="$DEFAULT_FZAUDIO_DIR"
    say "reusing current fzaudio checkout at $target_fzaudio_dir"
  else
    clone_or_update_repo "fzaudio" "$FZAUDIO_REPO_URL" "$target_fzaudio_dir"
  fi

  clone_or_update_repo "fzy" "$FZY_REPO_URL" "$target_fzy_dir"

  install_fz "$target_fzy_dir"

  if [[ "$install_fozzy_choice" -eq 1 ]]; then
    clone_or_update_repo "fozzy" "$FOZZY_REPO_URL" "$target_fozzy_dir"
    install_fozzy "$target_fozzy_dir"
  else
    say "skipping optional fozzy install"
  fi

  build_fzaudio "$target_fzaudio_dir"

  cat <<EOF

Setup complete.

Workspace:
  fzaudio: $target_fzaudio_dir
  fzy:     $target_fzy_dir
  fozzy:   $([[ "$install_fozzy_choice" -eq 1 ]] && printf '%s' "$target_fozzy_dir" || printf 'skipped')

Installed tools:
  fz:      $(command -v fz)
  fozzy:   $([[ "$install_fozzy_choice" -eq 1 ]] && command -v fozzy || printf 'skipped')
EOF
}

main "$@"
