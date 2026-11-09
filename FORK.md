# okke-formsma/paseo fork

Personal fork of [getpaseo/paseo](https://github.com/getpaseo/paseo) with a few patches on top.

## Branches

- `main`: a mirror of `upstream/main`. Never commit here.
- `okke`: our patches, kept rebased on `upstream/main`. This is what we build and run.

Each patch is one commit on `okke` with a clear message, so a nightly rebase stays readable.
Once upstream merges an equivalent change, drop our commit.

## Nightly

A Paseo schedule (`paseo-fork-nightly`) runs at 03:00 and starts a fresh agent in this checkout:

1. `fork/sync.sh` updates fork `main` from upstream, rebases `okke` and force-pushes it.
2. If the rebase conflicts, the agent resolves it, runs the affected tests, continues and pushes.
3. `fork/build.sh` builds an ad-hoc signed `Paseo.app` into `packages/desktop/release/`.

The nightly job does **not** install the build: installing quits Paseo, which would kill the
agent running the job and any work in progress. When you're ready, run:

```bash
~/projects/paseo/fork/install.sh
```

The script detaches, quits Paseo, stops the daemon, moves the old app to
`~/.paseo/fork-backup/Paseo.app`, installs the new build and relaunches.
Its log is at `~/.paseo/fork-install.log`. To go back to the official app, move the backup
back to `/Applications` (or download it from paseo.sh).

## Patches

- **desktop: no upstream auto-update.** A fork build must not replace itself with an upstream
  release. The updater is off (`isPackaged: () => false` in `auto-updater.ts`), and publish
  points at this fork.

## Candidate upstream PRs to carry

- Inline rename for workspaces: getpaseo/paseo#4643 (double-click sidebar rename + shortcut),
  #8652 (rename in workspace header menu), #8121 (rename shortcut).
- Voice mode: #8411 (stop voice mode rewriting the system prompt), #9051, #5408.
