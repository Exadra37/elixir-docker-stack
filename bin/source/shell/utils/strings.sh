#!/bin/sh

set -eu

Random_Cookie_String() {
  local _length=${1:-128}
  local _carachter_set=":alpha:"

  local _cookie="$(strings /dev/urandom | grep -o "[[${_carachter_set}]]" | head -n ${_length} | tr -d '\n'; echo)"

  echo "${_cookie}"
}

Get_Last_Segment() {
  local _string="${1? Missing string to parse last segment from.}"
  local _segment_separator="${2? Missing segment separator.}"

  # from `/home/user/project/app/acme` we will get `acme`
  local _last_segment="${_string##*${_segment_separator}}"

  echo "${_last_segment}"
}

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
