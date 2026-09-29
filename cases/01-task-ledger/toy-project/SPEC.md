# Task ledger toy-project specification

## Goal

Build `tasklog`, a dependency-free Python 3 command-line task ledger. It should
be useful as a tiny real project rather than a one-file demo: commands, durable
state, validation, and automated tests should be present, readable, and easy to
run from a clean checkout.

## User-facing behavior

The entry point is:

```text
python -m tasklog <command> [options]
```

State is stored in `.tasklog.json` in the current working directory unless the
program exposes a documented path override. The `--state PATH` option is global
(`python -m tasklog --state PATH <command>`) and is also accepted after a
subcommand for convenience. The file is created on the first successful write.
JSON should be human-readable and deterministic enough for a user to inspect in
version control. A missing file means a fresh ledger; an existing empty file is
treated as possible truncation and is rejected without replacement.

Required commands:

1. `add TEXT`
   - create one open task;
   - accept a multiword description either as one quoted argument or as
     multiple trailing arguments joined with single spaces;
   - assign a stable positive integer id; command-line ids use ASCII decimal
     digits with an optional sign and must be positive;
   - print a concise confirmation beginning with `Added task <ID>`, substituting
     the created numeric id and including the task description.
2. `list`
   - show open tasks in ascending id order;
   - print each row with a right-aligned four-character ID, a space, `[ ]`, a
     space, and the task text; for example: `   1 [ ] write the docs`;
   - end with the exact summary `<N> open`, counting only displayed open tasks;
   - `list --all` shows open tasks with `[ ]` and completed tasks with `[x]`,
     then ends with the exact summary `<N> open, <M> done`;
   - an empty `list` succeeds and prints `No open tasks`; an empty `list --all`
     succeeds and prints `No tasks`.
3. `done ID`
   - mark an existing open task complete;
   - be idempotent for an already-completed task or report that state clearly;
   - on success, print a confirmation beginning with `Completed task <ID>`;
   - reject a missing or malformed id without changing the ledger.
4. `remove ID`
   - delete an existing task;
   - reject a missing or malformed id without changing the ledger.
   - on success, print a confirmation beginning with `Removed task <ID>`.

The CLI must also provide `--help` text and non-zero exit status for malformed
commands or missing required arguments. Error messages go to stderr and should
identify the corrective action where practical.

Malformed IDs must be rejected unless they use ASCII decimal digits and denote
a positive integer. Their error text must contain `invalid id` and explain the
accepted form.

## Data and safety requirements

- Use only the Python standard library.
- Do not silently discard a valid existing task when an input is invalid.
- Keep task ids stable after removal; the next added task must not reuse an id
  that could make an old reference ambiguous.
- Keep completed tasks in the state file until explicitly removed.
- A failed command must not leave a partially written JSON document.

## Evaluation

The project succeeds when all of the following are true:

- `python -m unittest discover -s tests -v` passes from the project root.
- A clean smoke sequence can add two tasks, list them, complete one, list with
  `--all`, remove the other, and observe the expected durable state across
  separate Python processes.
- Invalid ids and missing arguments return non-zero status, write an actionable
  error to stderr, and leave `.tasklog.json` byte-for-byte unchanged.
- A fresh directory can run `python -m tasklog list` without crashing or
  requiring a pre-created state file.
- `python -m tasklog --help` documents the available commands and persistence
  behavior.

## Deliberate non-goals

- due dates, priorities, tags, dependencies, or recurring tasks;
- multiple users, locking, synchronization, or a server;
- third-party packages;
- migrations from another task manager;
- a polished TUI.

