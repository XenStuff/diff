#!/bin/bash

set -euo pipefail

find_real_rewrapper() {
  if [[ -n "${RBE_WRAPPER_REAL:-}" ]]; then
    printf '%s\n' "${RBE_WRAPPER_REAL}"
    return
  fi

  if [[ -n "${RBE_DIR:-}" ]]; then
    printf '%s\n' "${RBE_DIR}/rewrapper"
    return
  fi

  printf '%s\n' "prebuilts/remoteexecution-client/live/rewrapper"
}

find_exec_root() {
  local arg
  for arg in "$@"; do
    case "${arg}" in
      -exec_root=*)
        printf '%s\n' "${arg#-exec_root=}"
        return
        ;;
    esac
  done

  if [[ -n "${RBE_exec_root:-}" ]]; then
    printf '%s\n' "${RBE_exec_root}"
    return
  fi

  pwd
}

rewrite_args() {
  local workdir="$1"
  shift

  local -a args=("$@")
  local keep_input="${workdir}/.keep"
  local -a rewritten=()
  local saw_inputs=0
  local cmd_start=-1
  local i arg

  for ((i = 0; i < ${#args[@]}; i++)); do
    arg="${args[i]}"
    if [[ "${arg}" == "--" ]]; then
      cmd_start=$((i + 1))
      break
    fi
  done

  if (( cmd_start < 0 )); then
    for ((i = 0; i < ${#args[@]}; i++)); do
      arg="${args[i]}"
      if [[ "${arg}" != -* ]] || [[ "${arg}" == "-" ]]; then
        cmd_start="${i}"
        break
      fi
    done
  fi

  if (( cmd_start < 0 )); then
    printf '%s\0' "${args[@]}"
    return 0
  fi

  for ((i = 0; i < cmd_start; i++)); do
    arg="${args[i]}"
    if [[ "${arg}" == "--" ]]; then
      continue
    fi
    case "${arg}" in
      -inputs=*)
        saw_inputs=1
        rewritten+=("-inputs=${keep_input},${arg#-inputs=}")
        ;;
      *)
        rewritten+=("${arg}")
        ;;
    esac
  done

  if (( saw_inputs == 0 )); then
    rewritten+=("-inputs=${keep_input}")
  fi

  for ((i = cmd_start; i < ${#args[@]}; i++)); do
    rewritten+=("${args[i]}")
  done

  printf '%s\0' "${rewritten[@]}"
}

main() {
  local exec_root real_rewrapper shim_dir workdir

  exec_root="$(find_exec_root "$@")"
  real_rewrapper="$(find_real_rewrapper)"
  if [[ "${real_rewrapper}" != /* ]]; then
    real_rewrapper="${exec_root}/${real_rewrapper}"
  fi
  shim_dir="${exec_root}/.rbe_shim"
  workdir="${shim_dir}/wd"

  mkdir -p "${workdir}"
  : > "${workdir}/.keep"

  local entry name target
  for entry in "${exec_root}"/* "${exec_root}"/.[!.]* "${exec_root}"/..?*; do
    [[ -e "${entry}" ]] || continue
    name="${entry##*/}"
    [[ "${name}" == ".rbe_shim" ]] && continue
    target="${workdir}/${name}"
    ln -sfnT "../../${name}" "${target}"
  done

  local -a rewritten
  mapfile -d '' -t rewritten < <(rewrite_args ".rbe_shim/wd" "$@")

  cd "${workdir}"
  exec "${real_rewrapper}" "${rewritten[@]}"
}

main "$@"
