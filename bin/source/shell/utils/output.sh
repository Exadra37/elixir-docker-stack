#!/bin/sh

set -eu

Print_Text_With_Label()
{
  ############################################################################
  # INPUT
  ############################################################################

    local label_text="${1? Missing label to print!!!}"

    local text="${2? Missing text to print!!!}"

    local verbosity_print_level=${3? Missing verbosity print level!!!}

    local label_background_color="${4:-42}"

    local text_background_color="${5:-229}"


  ############################################################################
  # EXECUTION
  ############################################################################

    case ${verbosity_print_level} in
      1 )
        local label_background_color="40"
        ;;
      2 )
        local label_background_color="44"
        ;;
      3 )
        local label_background_color="45"
        ;;
      4 )
        local label_background_color="46"
        ;;
      * )
        local label_background_color="42"
    esac

    if [ ${verbosity_print_level} -le ${VERBOSE_LEVEL} ]; then
      printf "\n\e[1;${label_background_color}m ${label_text}:\e[30;48;5;${text_background_color}m ${text} \e[0m \n"
    fi
}

Print_Text()
{
  ############################################################################
  # INPUT
  ############################################################################

    local text="${1? Missing text to print!!!}"

    local verbosity_print_level=${2? Missing verbosity print level!!!}

    local text_color="${3:-44}"


  ############################################################################
  # EXECUTION
  ############################################################################

    if [ ${verbosity_print_level} -le ${VERBOSE_LEVEL} ]; then
      printf "\n\e[1;${text_color}m ${text} \e[0m \n"
    fi
}

Print_Fatal_Error()
{
  ############################################################################
  # INPUT
  ############################################################################

    local text="${1? Missing text to print for the Fatal Error!!!}"


  ############################################################################
  # EXECUTION
  ############################################################################

    printf "\n\e[1;41m FATAL ERROR:\e[30;48;5;229m ${text} \e[0m \n\n"
}
