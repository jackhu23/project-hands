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
The Exercise where the Patient touches on-screen targets with a designated finger.
_Avoid_: Target touch, balloon game

**Tracing**:
The Exercise where the Patient follows an on-screen path with a finger or stylus.
_Avoid_: Path following, drawing

**Session**:
One sitting in which a Patient completes one or more Exercise Runs, with a start and end time.
_Avoid_: Visit, workout

**Exercise Run**:
One continuous run of a single Exercise within a Session, played at a fixed set of difficulty settings.
_Avoid_: Round, level, game

**Trial**:
One thing presented to the Patient within an Exercise Run (one balloon, one path), together with its outcome, such as popped, timed out or completed. A Trial can have zero Actions.
_Avoid_: Repetition, target, task, attempt

### Movement

**Action**:
One continuous touch by the Patient, from finger or stylus touchdown to lift-off, made during a Trial.
_Avoid_: Tap, attempt, event, stroke

**Touch Sample**:
One raw recorded point within an Action: position, time, pressure and whether a finger or stylus produced it.
_Avoid_: Point, event, data point
