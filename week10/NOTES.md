# NOTES

## Level 1: order of events

Predicted:
A, C, fetchStudents #1, (first frame), B, 6 students

Actual:
<вставьте, что вышло у вас>

main() ran to the end, the loop drew the first frame, and the two timers came later as events.

## Level 2: error without mounted

<первая строка ошибки setState() called after dispose() из вашей консоли>

## Level 4: countdown

With cancel() in dispose (version B): after Back at 7 the console stops at tick 7.
Without cancel(): after Back at 7 the console keeps printing tick 6, tick 5 ... tick 0 and setState() called after dispose() appears. That is the leak.
Version A (StreamBuilder): no cancel in my code, Back at 7, the console stops. StreamBuilder cancelled the subscription for me.

## Level 5: un-awaited save

<строка Unhandled Exception: Bad state: server rejected 6 из вашей консоли>
The user saw a success: the screen closed as if the save worked, but the server rejected it and nobody awaited the Future.