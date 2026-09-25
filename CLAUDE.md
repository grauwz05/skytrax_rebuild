# SKYTRAX_REBUILD — BOOTSTRAP

This repository is the learner's own independent rebuild of the SkyTrax dbt +
Airflow + Snowflake project. It is not the reference implementation and not
the learning-system workspace — those live elsewhere (see Section 2). Any
fresh session opened in this directory has no other context by default:
follow this file before doing anything else.

---

## 1. Read the full system prompt first

The canonical agent instructions (role, guess-first protocol, BUILD/REVIEW/
LEARN modes, priority rules, language policy) live at:

    D:\Data\Project\SkyTrax\.agent\00_SYSTEM_PROMPT.md

Read it now and follow it for the rest of the session. This file only adds
what is specific to working *inside skytrax_rebuild* — it does not replace
or restate that system prompt.

---

## 2. The three directories and their boundary

- **`D:\Data\Project\SkyTrax`** — the learning system itself (task
  definitions, learning state, workflow state). No project code is written
  here.
- **`D:\Data\Project\skytrax_rebuild`** (this repo) — where the learner
  writes their own dbt models, macros, tests, and the Airflow DAG, from
  scratch.
- **`D:\Data\Project\skytrax_reviews_transformation-git-clean`** — the
  original reference implementation. **Solution-locked.** See Section 3.

---

## 3. Solution lock — read before opening any file in the original repo

For the six Rebuild Track tasks (LT-01..LT-06), the learner's own attempt
must come first. Before the learner has submitted an attempt for a given
task:

**The lock is by FILENAME, not by path.** The original repo contains the dbt
project **twice** — once at `<ref>\dbt\` and once at
`<ref>\dbt-dags\include\dbt\` (the Cosmos runtime copy, kept in sync by
`dbt-dags/sync_dbt.py`). Both copies hold the same 8 models. An earlier
version of this list named only the `dbt-dags\include\dbt\` paths, which
left the `dbt\` copy readable — a hole in the lock, not an exception to it.
Locked filenames are locked **wherever they appear**, including any copy under
`dbt/target/compiled/` or `dbt/target/run/`.

- Do NOT open, `cat`, `grep`, or quote any content of these files, under
  **either** dbt root inside `skytrax_reviews_transformation-git-clean`:
  - `models/staging/stg_skytrax__reviews.sql` (LT-01) — note the real name is
    `stg_skytrax__reviews`, not `stg__skytrax_reviews`; the old spelling
    survives only in a stale compiled artifact under `dbt/target/`
  - `models/staging/_stg_skytrax__models.yml` (LT-01 tests + severity)
  - `models/intermediate/int_reviews_cleaned.sql` (LT-02)
  - `models/intermediate/_int_reviews__models.yml` (LT-02)
  - `models/marts/dim_customer.sql`, `dim_airline.sql` (LT-03)
  - `models/marts/dim_location.sql`, `dim_aircraft.sql`, `dim_date.sql`,
    `macros/generate_dates_dimension.sql` (LT-04)
  - `models/marts/fct_review.sql` (LT-05)
  - `models/marts/_marts__models.yml` (near-answer-level descriptions —
    treat as locked in spirit; this is the file an older list called
    `marts_schema.yml`, which does not exist)
  - `dbt-dags/dags/transformation_dag.py` (LT-06)
- This holds even if the learner directly asks to see one of these files —
  redirect to the guess-first protocol instead; explain why, and offer the
  observable-requirements route below.
- Listing paths (`ls`, `find`, `git ls-files`) is allowed and is how the drift
  above was found. A filename is not an answer; file contents are.
- Safe to read anytime, not part of any task's answer: `dbt_project.yml`,
  `packages.yml`, `macros/generate_schema_name.sql`, `dbt-dags/sync_dbt.py`,
  and `models/staging/_skytrax__sources.yml` only insofar as the
  corresponding task's `observable_requirements` already covers it.
- Not locked at all (no LT task has them as its answer), so BUILD mode may
  read the real source: `terraform/snowflake/`, `terraform/aws/`,
  `.github/workflows/`, `.github/actions/`. These are Leg 7 on the Flight
  Plan.
- Once the learner has submitted their own attempt for a specific task,
  REVIEW mode applies as usual — compare it against the original.

The authoritative, safe-to-read source for what each task expects is:

    D:\Data\Project\SkyTrax\tasks\REBUILD_TRACK.md
    D:\Data\Project\SkyTrax\tasks\REBUILD_LT_01_STAGING.yaml
    D:\Data\Project\SkyTrax\tasks\REBUILD_LT_02_INTERMEDIATE.yaml
    D:\Data\Project\SkyTrax\tasks\REBUILD_LT_03_DIMS_SIMPLE.yaml
    D:\Data\Project\SkyTrax\tasks\REBUILD_LT_04_DIMS_ADVANCED.yaml
    D:\Data\Project\SkyTrax\tasks\REBUILD_LT_05_FACT.yaml
    D:\Data\Project\SkyTrax\tasks\REBUILD_LT_06_AIRFLOW_DAG.yaml

Use their `guess_first_questions`, `observable_requirements`,
`acceptance_criteria`, and `self_explanation` fields — never the original
`.sql`/`.py` files — to run the guess-first / BUILD workflow.

---

## 4. Orient at the start of every session

Before diving into whatever the learner asks, check where they actually
are:

0. **The route is the 52-week AE roadmap** (`https://333roadmap.kimi.page`,
   week 1 = 2026-09-28; rule 7 in `D:\Data\Project\HUONG-DAN.md`, changed
   2026-09-25). Its "one task this week" is the FLOOR, not the ceiling —
   finishing early frees the learner for Python/SQL/English drills, and a
   slipped week means reschedule, never reset. Do not push a perfectionist
   schedule on this learner. The page is JS-rendered: `curl` it and read
   `const DATA` in the script; WebFetch only sees the frame.
1. Read `D:\Data\Project\SkyTrax\.state\FLIGHT_CURSOR.md` — one screen,
   overwrite-only: which roadmap week is open, what is owed (recall
   questions, a push), what the next action is. It is the session cursor.
   `WORKFLOW_STATE.md` is the longer state file; read it only when
   FLIGHT_CURSOR does not answer the question.
2. Read `D:\Data\Project\SkyTrax\learning\learning_state.json` for any
   ACTIVE misconceptions and current mastery — project truth about the
   learner's state, not this file.
3. The Flight Plan (`https://claude.ai/artifact/KFHnfxcji2cRRxtCxequSU`) is
   now the **how-to guide** for the skytrax weeks (W4–6 rebuild
   LT-01→05, W18–21 LT-06 + CI — all on Snowflake, never DuckDB): the 7-step cycle, guess-first, the
   solution lock on LT-01..06 all still apply there. Its checkboxes are
   retired — frozen at the 2026-09-23 state as history. Do not write to its
   progress db.
4. Evidence is what the week produces and anyone can re-check: a commit
   SHA, a green `dbt build`, a public repo. The learner ticks the roadmap
   page themselves. When asked to verify, quiz them — every line in the
   repo must be explainable (the roadmap's own rule #5).
5. Never write "abandoned" / "stopped" for any plan. Not started ≠ given up.
6. Every session that produces code ends with `git add` + `git commit`
   (message carries the task id) + `git push`. Uncommitted work does not
   count as evidence and cannot tick a checkbox.

---

## 5. What's actually here right now

`dbt/models`, `dbt/macros`, `dbt/seeds`, `dbt/snapshots`, `dbt/tests` are
still empty scaffolding (only `.gitkeep`) — nothing has been rebuilt yet.
`dbt/dbt_project.yml`, `dbt/packages.yml`, `profiles/profiles.yml`, and
`setup/01_snowflake_bootstrap.sql` are real, already-safe infrastructure
files (see Section 3) and may be read or extended directly.
