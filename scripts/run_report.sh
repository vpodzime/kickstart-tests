#!/bin/gawk -f

BEGIN {
    printf("\n\n\n%-30s | %-10s | %s\n", "TEST", "RESULT", "EXPLANATION");
    printf("-------------------------------+------------+--------------------------------------------------------\n");
    FS=":";
    count=0;
    failed=0;
    timed_out=0;
}
/^RESULT:/ { if ($4 == "Test timed out.") {
                 result = "TIMED OUT";
                 explanation = "";
                 timed_out++;
             } else if (match($0, "Traceback")) {
                 result = "FAILED";
                 explanation = "Traceback";
                 failed++;
             } else if (match($0, "SUCCESS")) {
                 result = $3;
                 explanation = "";
             } else {
                 result = $3;
                 explanation = substr($0, index($0, $4), 55);
                 failed++;
             }

             printf("%-30s | %-10s | %s\n", $2, result, explanation);
             count++
           }
END {
    printf("\n");
    printf("============================================================================\n");
    printf("Test souite for kickstart tests summary:\n");
    printf("============================================================================\n");
    printf("# TOTAL:      %s\n", count);
    printf("# PASS:       %s\n", count - failed - timed_out);
    printf("# FAILED:     %s\n", failed);
    printf("# TIMED OUT:  %s\n", timed_out);
    printf("============================================================================\n");
    printf("\n\n");
}
