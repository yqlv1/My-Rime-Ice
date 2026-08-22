# Repository guide for AI assistants

## Scope and source of truth

- This repository is the source of truth for personal Rime configuration.
- Files listed in `rime-links.txt` are deployed as NTFS hard links into the Rime user directory. By default that directory is the sibling folder `..\Rime`.
- Never assume that equal-looking files are still hard linked. File replacement can break a hard link even when paths and contents look correct.
- Do not modify upstream rime-ice files. In particular, leave `..\Rime\custom_phrase.txt` unchanged unless the user explicitly asks about it.
- Do not delete user databases (`*.userdb`), generated `build/` data, installation metadata, or synchronization data.

## Editing rules

- Keep YAML and Lua files UTF-8 encoded.
- Preserve tab separators in Rime table and dictionary files.
- Prefer `.custom.yaml` patches and personal files over editing upstream schemas.
- When adding or removing a personal file that must appear in the Rime directory, update `rime-links.txt` in the same change.
- Treat `cn_dicts/moe.dict.yaml` as a large generated/imported dictionary. Do not reformat or rewrite it without a specific reason.
- For a downloaded replacement of the Moe dictionary, use `scripts/update-moe-dict.ps1`. It overwrites the existing file contents so an intact hard link is preserved, then repairs all manifest links.

## Verification

Run these checks after relevant edits:

```powershell
git diff --check
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\relink-rime.ps1 -CheckOnly
```

If link repair is intended, run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\relink-rime.ps1 -Force
```

After configuration, Lua, table, or dictionary changes, redeploy Weasel and inspect the newest Rime log. A normal deployment should report all configured schemas successful and zero failures.

Before committing, make sure only files belonging to the requested change are staged. Use a concise Conventional Commit message where practical.
