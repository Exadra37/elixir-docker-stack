#!/bin/sh

set -eu

Get_Last_Two_Segments() {

  local _string="${1? Missing string to parse last two segments from.}"
  local _segment_separator="${2? Missing segments separator.}"
  local _join_separator="${3:-${_segment_separator}}"

  # from `/home/user/project/app/acme` we will get `acme`
  local _last_segment="${_string##*${_segment_separator}}"

  # from `/home/user/project/app/acme` we will get `/home/user/project/app`
  local _other_segments="${_string%${_segment_separator}*}"

  # from `/home/user/project/app/acme` we will get `app/acme`
  local _last_two_segments="${_other_segments##*${_segment_separator}}${_join_separator}${_last_segment}"

  echo "${_last_two_segments}"
}
