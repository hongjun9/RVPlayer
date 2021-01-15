302: 154 offline-reproduce? hovering normal
305: 155 offline-reproduce, hovering small effect
315: 160 offline-reproduce, using solo simulation parameters, sycn 3 states (better)
317: 160 offline-reproduce, using solo simulation parameters, sycn 6 states
321: 190 reproduce, solo param, sycn 3 states, unfiltered disturbance (better)
322: 190 reproduce, solo param, sycn 3 states, disturbance filter window: 20
324: 190 reproduce, solo param, no disturbance and sycn, baseline

=========solo param=============
330: 190 reproduce, no disturbance and sycn, baseline
331: 190 reproduce, sync 3 states at 1Hz, disturbance filter window: 10
335: 190 reproduce, sync 3 states at 2Hz, disturbance filter window: 10 (not so much difference)

=======no air resistence, disturbance filter window: 10 ========
336: 190 reproduce, sync 3 states at 1Hz, disturbance filter window: 10 (good)
337: 190 reproduce, sync 6 states at 10Hz, disturbance filter window: 10 
338: 190 reproduce, sync 6 states at 1Hz, disturbance filter window: 10 
339: 190 reproduce, no disturbance and sycn, baseline

340: 154 reproduce, sync 6 states at 1Hz
345: 156 reproduce, sync 3 states at 1Hz

=========skip first 3s sync and disturb ============
346: 156 reproduce, sync 3 states at 1Hz, skip first 3s sync and disturb (good)
347: 156 reproduce, sync 6 states at 1Hz, skip first 3s sync and disturb (good)

348: 155 reproduce, sync 3 states at 1Hz, skip first 3s sync and disturb (good)

349: 157 reproduce, sync 3 states at 1Hz, skip first 3s sync and disturb (better)
351: 157 reproduce, sync 6 states at 1Hz, skip first 3s sync and disturb 

352: 159 reproduce, sync 3 states at 1Hz, skip first 3s
355: 159 reproduce, sync 3 position states and 3 angle speed at 1Hz, skip first 3s (better but still not good)
356: 159 reproduce, sync 6 states at 10Hz, skip first 3s (better), split-second attack case study

==========adaptive disturbance log ===================
358: 190 reproduce, sync 3 states at 1Hz
359: 155 reproduce, sync 3 states at 1Hz
360: 156 reproduce, sync 3 states at 1Hz
361: 157 reproduce, sync 3 states at 1Hz


374: 189 reproduce, sync 3 states at 1 Hz
375: 189 reproduce, sync 6 states at 1 Hz (better), param attack case study
376: 189 reproduce, sync 6 states at 10 Hz

382: 163 reproduce, sync 3 states at 1 Hz. GPS attack case study.
383: 163 reproduce, sync 6 states at 2 Hz (1Hz doesn't work). GPS attack case study.

==========what if reasoning =================
399: 245 reproduce, task 8
400: 245 reproduce, task 8, initial 23 degrees
401: 239-244 replay, task 5, initial 26 degrees

420: 217 reproduce, sync 3 states at 1 Hz. Zig-zag trace
421: 217 reproduce, sync 3 states at 2 Hz. Zig-zag trace
422: 217 reproduce, sync 3 states at 1 Hz. Zig-zag trace, pos disturbance (better)
428: 219 reproduce, sync 3 states at 1 Hz. Zig-zag trace
429: 219 reproduce, sync 3 states at 1 Hz. Zig-zag trace, pos disturbance(better)

437: 217 reproduce baseline, zig-zag trace
438: 219 reproduce baseline, StarSix trace
439: 155-157 small, medium, strong effect reference. small: 8-15s; medium: 20-30; strong: 14-19s;