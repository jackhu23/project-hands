# Project HANDS

A tablet-based hand rehabilitation tool for post-stroke patients with partial hand mobility. Patients complete fine motor exercises, the app records their movement, and Occupational Therapists (OTs) review progress over time.

## Language

### People

**Patient**:
A person doing rehabilitation exercises on the tablet, identified only by a pseudonymous ID.
_Avoid_: User, player, client

### Structure of practice

**Exercise**:
A kind of rehabilitation task the app offers, such as Balloon Touch or Tracing.
_Avoid_: Game, activity, task

**Balloon Touch**:
The Exercise where the Patient touches on-screen targets with a designated finger. A balloon is popped by an Action that both starts and ends on the balloon's body.
_Avoid_: Target touch, balloon game, balloon pop

**Tracing**:
The Exercise where the Patient follows an on-screen path with a finger or stylus.
_Avoid_: Path following, drawing

**Session**:
One sitting in which a Patient completes one or more Exercise Runs, with a start and end time.
_Avoid_: Visit, workout

**Exercise Run**:
One continuous run of a single Exercise within a Session, played at a fixed set of difficulty settings.
_Avoid_: Round, level, game

**Plan**:
The list of Exercise Runs an OT sets for a Patient for one day, each with an Exercise, a Difficulty Level and a number of Trials. The Patient sees it as "Today's plan".
_Avoid_: Prescription (Patients read it as medication), program, schedule

**Plan item**:
One Exercise Run in a Plan. It is done by the first completed Exercise Run with the same Exercise, Difficulty Level and number of Trials, however that run was started; a stopped run never completes it.
_Avoid_: Quota, assignment

**Extra run**:
A completed Exercise Run that completes no Plan item, because none with its settings is left undone. It is recorded and shown like any other.
_Avoid_: Bonus run, free play

**Exercise Demo**:
A short animation, shown before or during an Exercise Run, of how to do the Exercise correctly, such as a finger popping a balloon and a lift-off that misses.
_Avoid_: Tutorial, video, demo (alone, which also names the original prototype)

**Difficulty Level**:
The setting, 1 to 4, chosen before an Exercise Run and fixed for all of it. In Balloon Touch, Difficulty Level N places most balloons in Zone N and the rest in the Zones inside it.
_Avoid_: Level (alone), stage, mode

**Zone**:
One of four nested regions of the Balloon Touch screen, numbered outward from the centre: the small central ellipse, two rings around it, and everything outside the largest ellipse.
_Avoid_: Ring, area, circle

**Trial**:
One thing presented to the Patient within an Exercise Run (one balloon, one path), together with its outcome, such as popped, timed out or completed. A Trial can have zero Actions.
_Avoid_: Repetition, target, task, attempt

### Movement

**Action**:
One continuous touch by the Patient, from finger or stylus touchdown to lift-off, made during a Trial.
_Avoid_: Tap, attempt, event, stroke

**Pop**:
The outcome of an Action in Balloon Touch that starts and ends on the balloon's body and is not an Overlapping Touch, which ends the Trial.
_Avoid_: Success, hit

**Miss**:
The outcome of an Action in Balloon Touch that is neither a Pop nor an Overlapping Touch, including one that starts on the balloon and lifts off outside it.
_Avoid_: Faulty touch, error, fail

**Overlapping Touch**:
The outcome of an Action that begins while another Action is already in progress, such as a second finger or the palm landing on the screen. It never pops a balloon.
_Avoid_: Stray, extra touch, accidental touch, double tap, multi-touch

**Touch Sample**:
One raw recorded point within an Action: position, time, pressure and whether a finger or stylus produced it.
_Avoid_: Point, event, data point

### Metrics

**Accuracy**:
Pops divided by Pops plus Misses, across the Actions in scope. Overlapping Touches are not counted.
_Avoid_: Success rate, hit rate

**Reaction Time**:
The time from a balloon appearing to the touchdown of the Action that pops it, not counting time spent paused.
_Avoid_: Response time, latency
