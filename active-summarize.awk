function get_duration(start_minutes, end_minutes) {
    start_hour = start_minutes / 60;
    end_hour = end_minutes / 60;
    printf "start_hour: %s: end_hour: %s\n", start_hour, end_hour
    if (start_hour < 11 && end_hour > 13.5 && end_hour - start_hour > 5) {
        print "_\nLunch break";
        return end_minutes - start_minutes - 30;
    } else {
        return end_minutes - start_minutes;
    }
}

function print_duration(date, duration) {
    printf "%s %02.2d:%02.2d %.2f\n", date, int(duration/60), duration%60, duration/60
}

BEGIN {
    if (pattern == "") {
        pattern = "work";
    }
    print "Pattern: " pattern;
    FS = "|";
    previous_week = "";
    previous_date = "";
    previous_minutes = "";
    other_minutes = "";
    start = -1;
    day_total = 0.0;
    week_total = 0.0;
}
$0 !~ pattern {
    if ($1 == previous_date && other_minutes == "") {
        other_minutes = $2 * 60 + $3;
#       print ">> " $0 " [" other_minutes "]";
    }
    next;
}
$1 != previous_date {
    if (previous_date != "") {
        if (other_minutes != "" && other_minutes < previous_minutes + 30) {
#           printf "Midpoint: %.2f -- %.2f\n", previous_minutes, other_minutes;
            duration = get_duration(start, (previous_minutes + other_minutes) / 2);
        } else {
            duration = get_duration(start, previous_minutes + 15);
        }
        print_duration(previous_date, duration);
        day_total += duration/60;
        week_total += day_total;
        printf "%s total %.2f\n", previous_date, day_total
        if (previous_week != "" && $4 != previous_week) {
#           printf "Week %d: %.2f\n", previous_week, week_total;
            week_total = 0.0;
        }
        previous_week = $4;
    }
    previous_date = $1;
    start = -1;
    day_total = 0.0;
    other_minutes = "";
#   print "New date " $1;
}
{
    minutes = $2 * 60 + $3;
#   print "> " $0 " [" previous_minutes "/" other_minutes "/" minutes "]";
    if (start < 0) {
        start = minutes
    } else if (other_minutes != "" && other_minutes < previous_minutes + 30) {
#       printf "Midpoint: %.2f -- %.2f\n", previous_minutes, other_minutes;
        duration = get_duration(start, (previous_minutes + other_minutes) / 2);
        print_duration(previous_date, duration);
        day_total += duration/60;
        start = minutes
    } else if (previous_minutes + 17 < minutes) {
        duration = get_duration(start, previous_minutes + 15);
        print_duration(previous_date, duration);
        day_total += duration/60;
        start = minutes
    }
    previous_minutes = minutes;
    other_date = "";
    other_minutes = ""
}
END {
    if (start >= 0) {
        if (other_minutes != "" && other_minutes < previous_minutes + 30) {
#           printf "Midpoint: %.2f -- %.2f\n", previous_minutes, other_minutes;
            duration = get_duration(start, (previous_minutes + other_minutes) / 2);
        } else {
            duration = get_duration(start, previous_minutes + 15);
        }
        print_duration(previous_date, duration);
        day_total += duration/60;
        week_total += day_total;
        printf "%s total %.2f\n", previous_date, day_total
        if (previous_week != "") {
            printf "Week %d: %.2f\n", previous_week, week_total;
            week_total = 0.0;
        }
    }
}