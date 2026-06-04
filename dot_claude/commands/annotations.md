Address inline review annotations left in the code as `@agents:` comments.

## Reading the annotations

Annotations are plain code comments containing the marker `@agents:` followed by a
note, e.g. `// @agents: make this atomic — one transaction`. They live in the source
files themselves, at real repo paths, so no database or path remapping is needed.

Find them all from the repo root:

```
rg -n --no-heading -F '@agents:'
```

(Fall back to `grep -rn -F '@agents:' .` if `rg` is unavailable.) Each hit is
`path:line:<the line>`; the note is whatever follows `@agents:` on that line. If there
are no matches, tell the user there's nothing to address and stop.

## What to do

Work through the markers **one at a time**, and for each one:

1. Open the file at that line and read the surrounding code for context.
2. Address the note (make the change it asks for).
3. **Immediately remove that one marker** — the moment its work is done, before
   moving to the next:
   - If the marker is on its own comment line, delete the whole line.
   - If it's a trailing comment on a line of code, strip just the comment, leaving the
     code.
   Do not batch the removals to the end; each marker is deleted as soon as it's
   resolved, so progress is always reflected in the tree.
4. Move to the next marker. (Re-running the `rg` search as you go is a reliable way to
   pick up the next remaining one.)

When all markers are resolved, give a short summary of what changed per file. Do not
commit — a pre-commit hook blocks commits that still contain `@agents:` markers, so
leftover or unresolved markers will surface there.
