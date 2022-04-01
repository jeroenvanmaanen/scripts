# Call awk -v delim=';' csv-to-flat.awk file.csv

BEGIN {
    if (delim == "") {
        delim = ",";
    }
    if (key_indices == "") {
        key_indices = "1";
    }
#    printf("Key indices: [%s]\n", key_indices);
    key_indices_nr = split(key_indices, key_indices_array, /,/);
    for (i = 1; i <= key_indices_nr; i++) {
#        printf("Convert to int: %s: %s\n", i, key_indices_array[i]);
        key_indices_array[i] = int(key_indices_array[i]);
    }
    headers_nr = split("", headers); # Initialize empty headers array
    partial_line = "";
    string_content_re = "([^\"]|\"\")*";
    field_re = "([^\"" delim "]*|\"" string_content_re "\")";
    fields_re = "(" field_re delim ")*";
    incomplete_re = fields_re "\"" string_content_re
    continue_incomplete_re = "^" string_content_re "(\"" delim incomplete_re ")?$";
    incomplete_re = "^" incomplete_re "$"
}

partial_line == "" && $0 ~ incomplete_re {
#    printf("Incomplete: [%s]\n", $0);
    partial_line = $0;
    next;
}

partial_line != "" && $0 ~ continue_incomplete_re {
#    printf("Continue incomplete: [%s]\n", $0);
    partial_line = partial_line "\n" $0;
    next;
}

{
#    printf("Complete: [%s]\n", $0);
    line = $0;
    if (partial_line != "") {
#        printf("Prepend partial line\n");
        line = partial_line "\n" $0
    }
#    printf(">>> [%s]\n", line);

    add_headers = 0;
    if (headers_nr < 1) {
        add_headers = 1;
    }

    field_nr = 0;
    while (line != "") {
        remainder = line;
        sub("^" field_re, "", remainder);
        field = substr(line, 1, length(line) - length(remainder));
        if (field ~ "^\".*\"") {
            field = substr(field, 2, length(field) - 2);
            gsub(/""/, "\"", field);
        }
        field_nr = field_nr + 1;
#        printf(">>> Field: %s: %s\n", field_nr, field);

        if (add_headers) {
            headers[field_nr] = field;
            headers_nr = field_nr;
        } else {
            record[field_nr] = field;
        }

        line = remainder;
        if (line != "") {
            sep = substr(line, 1, 1);
            if (sep == delim) {
                sub(/./, "", line);
            } else {
                break;
            }
        }
    }
#    if (line != "") {
#        printf(">>> Remainder: %s\n", line);
#    }
    if (!add_headers) {
        prefix = record[key_indices_array[1]];
        for (i = 2; i <= key_indices_nr; i++) {
            prefix = prefix "/" record[key_indices_array[i]];
        }
        gsub(/\n/, "|", prefix);
#        printf("Field number of last field: %s\n", field_nr);
        for (i = 1; i <= field_nr; i++) {
#            printf("Field number: %s\n", i);
            field_name = headers[i];
            field_prefix = prefix "[" i ":" field_name "]"
            field = record[i];
            split(field, field_lines, /\n/);
            if (length(field_lines) < 2) {
                printf("%s:: %s\n", field_prefix, field);
            } else {
                for (line_nr = 1; line_nr <= length(field_lines); line_nr++) {
                    printf("%s:%s: %s\n", field_prefix, line_nr, field_lines[line_nr]);
                }
            }
        }
        printf("\n");
    }
    partial_line = "";
}
