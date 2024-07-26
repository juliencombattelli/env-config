# This file must be run after p10k.zsh when the .zshrc sources all files in
# $EC_TARGET_INSTALL_DIR/etc/profile.d/ directory.
# To guarantee this, the file name must be lexicographically greater than
# p10k.zsh, hence the .post extension.
# It must also be run only in a Zsh environment, hence the second .zsh
# extension.

() {
  emulate -L zsh -o extended_glob

  # Add aosp and tmux segment just before context segment (user@hostname)
  POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[(i)context]}]=(aosp tmux set_cursor_style context)

  # Override the status Ok symbols from recent p10k versions which is purple
  # with the Hack-NF font for some reasons...
  POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION='✓'
  POWERLEVEL9K_STATUS_OK_PIPE_VISUAL_IDENTIFIER_EXPANSION='✓'

  function prompt_aosp {
    local aosp_product
    if [ -z "${ANDROID_BUILD_TOP+x}" ] || [ -z "${TARGET_PRODUCT+x}" ]; then
      return
    fi
    p10k segment -f "darkolivegreen2" -ri "ANDROID_ICON" -t "${TARGET_PRODUCT}"
  }

  function prompt_tmux {
    if [ -z "$TMUX" ]; then
      return
    fi
    p10k segment -f "green" -t "tmux"
  }

  function prompt_set_cursor_style {
    # Workaround for a Windows Terminal bug
    # https://github.com/microsoft/terminal/issues/10754
    printf "\e[0 q"
  }

  (( ! $+functions[p10k] )) || p10k reload
}

