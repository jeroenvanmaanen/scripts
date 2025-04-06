#!/bin/bash

BIN="$(cd "$(dirname "$0")" || exit ; pwd)"

source "${BIN}/lib-verbose.sh"

function awk_script() {
  cat <<'EOT'
function timestamp_to_iso(timestamp,   year, month_name, month, day, time) {
  year = timestamp;
  gsub(/^[^,]*, [0-9][0-9]* *[A-Z][a-z][a-z] */, "", year);
  gsub(/ .*$/, "", year);
  month_name = timestamp;
  gsub(/^[^,]*, [0-9][0-9]* */, "", month_name);
  gsub(/ .*$/, "", month_name);
  for (month = 1; month <= 12; month++) {
    if (month_array[month] == month_name) {
      break;
    }
  }
  if (month < 10) {
    month = "0" month;
  } else {
    month = "" month;
  }
  day = timestamp;
  gsub(/^[^,]*, /, "", day);
  gsub(/ .*$/, "", day);
  if ((day + 0) < 10) {
    day = "0" day;
  }
  time = timestamp;
  gsub(/^[^,]*, [0-9][0-9]* *[A-Z][a-z][a-z] *[0-9][0-9]* */, "", time);
  gsub(/[-+ ].*$/, "", time);
  return "" year "-" month "-" day "T" time;
}
BEGIN {
  month_array[1] = "Jan";
  month_array[2] = "Feb";
  month_array[3] = "Mar";
  month_array[4] = "Apr";
  month_array[5] = "May";
  month_array[6] = "Jun";
  month_array[7] = "Jul";
  month_array[8] = "Aug";
  month_array[9] = "Sep";
  month_array[10] = "Oct";
  month_array[11] = "Nov";
  month_array[12] = "Dec";
  previous_file_name = "";
  fields = "";
}
$1 != previous_file_name {
  if (previous_file_name != "") {
    gsub(/^[.][\/]/, "", previous_file_name);
    gsub(/\/[^\/]*\/[^\/]*$/, "|File: &", previous_file_name);
    print "Folder: " previous_file_name "|" fields;
  }
  previous_file_name = $1;
  fields = "";
}
{
  file_name = $1;
  value = $0;
  sub(/^[^:]*:/, "", value);
  sub(/^[^:]*:/, "", value);
}
$2 == "Date" {
  value = timestamp_to_iso(value);
}
{
  field = $2 ": " value;
  if (fields == "") {
    fields = field;
  } else {
    fields = fields "|" field;
  }
}
END {
  if (previous_file_name != "") {
    gsub(/^[.][\/]/, "", previous_file_name);
    gsub(/\/[^\/]*\/[^\/]*$/, "|File: &", previous_file_name);
    print "Folder: " previous_file_name "|" fields;
  }
}
EOT
}

awk -F ':' "$(awk_script)" "$@"
