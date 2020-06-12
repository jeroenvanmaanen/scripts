function get_duration(start_minutes, end_minutes) {
    if (start_minutes < 11*60 && end minutes > 13.5 * 60 && end_minutes - start_minutes > 5 * 60) {
        print "----";
        return end_minutes - start_minutes - 30;
    } else {
        return end_minutes - start_minutes;
    }
}

function print_duration(date, duration) {
    printf "%s %02.2d:%02.2d %.2f\n", date, int(duration/60), duration%60, duration/60
}

BEGIN {
    FS = "|";
    previous_week = "";
    previous_date = "";
    previous_minutes = "";
    start = -1;
    day_total = 0.0;
    week_total = 0.0;
}
$1 != previous_date {
    if (previous_date != "") {
        duration = get_duration(start, previous_minutes + 15);
        print_duration(previous_date, duration);
        day_total += duration/60;
        week_total += day_total;
        printf "%s total %.2f\n", previous_date, day_total
        if (previous_week != "" && $4 != previous_week) {
            printf "Week %d: %.2f\n", previous_week, week_total;
            week_total = 0.0;
        }
        previous_week = $4;
    }
    previous_date = $1;
    start = -1;
    day_total = 0.0;
#   print "New date " $1;
}
{
    minutes = $2 * 60 + $3;
#   print "> " $0 " " minutes;
    if (start < 0) {
        start = minutes
    } else if (previous_minutes + 17 < minutes) {
        duration = get_duration(start, previous_minutes + 15);
        print_duration(previous_date, duration);
        day_total += duration/60;
        start = minutes
    }
    previous_minutes = minutes;
}
END {
    if (start >= 0) {
        duration = get_duration(start, previous_minutes + 15);
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