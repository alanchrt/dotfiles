Address inline review annotations that were added in Emacs using annotate.el.

## How to use this skill

The annotations have already been exported to `.claude/iterate.md` in the project root by running `M-x my/wst-export-iterate` (or `SPC r i`) in Emacs. Each line has the format:

```
- `path/to/file.py:42`: the review comment
```

## What to do

1. Read `.claude/iterate.md` to get the full annotation list.
2. For each annotation:
   - Open the referenced file and read the code around the specified line for context.
   - Address the comment — fix, refactor, clarify, or respond as appropriate.
   - If a comment is a question rather than a clear action, use your best judgment and note the decision in your summary.
3. After addressing all annotations, delete `.claude/iterate.md`.
4. Summarize what you changed, file by file.

Do not commit. Do not touch `.annotations` (that is Emacs's file). Only delete `.claude/iterate.md` when all items are done.
