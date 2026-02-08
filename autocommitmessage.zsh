# autocommitmessage - Zinit/manual source compatible wrapper
# Source this file or use with zinit

# Get the directory where this script is located
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
AUTOCOMMITMESSAGE_DIR="${0:A:h}"

# Source the main plugin file
source "${AUTOCOMMITMESSAGE_DIR}/autocommitmessage.plugin.zsh"
