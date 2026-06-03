Address inline review annotations added in Emacs with annotate.el.

## Reading the annotations

Annotations are stored in `.annotations` at the project root in Elisp format with character positions. Write the following script to a temp file and run it with `python3` from the project root to get them as readable `file:line: comment` entries:

```python
import re, os, sys

def tokenize(s):
    return re.findall(r'"(?:[^"\\]|\\.)*"|\(|\)|[^\s()"]+', s)

def parse(toks, i=0):
    if i >= len(toks): return None, i
    t = toks[i]
    if t == '(':
        lst, i = [], i + 1
        while i < len(toks) and toks[i] != ')':
            v, i = parse(toks, i)
            lst.append(v)
        return lst, i + 1
    if t.startswith('"'): return t[1:-1].replace('\\"', '"'), i + 1
    if t == 'nil': return None, i + 1
    if t == 't': return True, i + 1
    try: return int(t), i + 1
    except: return t, i + 1

def line_at(path, char):
    try:
        with open(path, errors='replace') as f:
            return f.read(char).count('\n') + 1
    except:
        return '?'

try:
    with open('.annotations') as f:
        data, _ = parse(tokenize(f.read()))
except FileNotFoundError:
    print('NO_ANNOTATIONS')
    sys.exit(0)

root = os.getcwd()
for rec in (data or []):
    if not isinstance(rec, list) or len(rec) < 2: continue
    path, anns = rec[0], rec[1]
    if not isinstance(anns, list): continue
    for ann in anns:
        if not isinstance(ann, list) or len(ann) < 3: continue
        start, text = ann[0], ann[2]
        if not isinstance(start, int) or not isinstance(text, str): continue
        print(f'- `{os.path.relpath(path, root)}:{line_at(path, start)}`: {text}')
```

## What to do

1. Run the script above to read annotations. If it prints `NO_ANNOTATIONS`, there is nothing to iterate on — say so and stop.
2. For each annotation, open the file at the given line, read the surrounding code for context, and address the comment.
3. After addressing everything, delete `.annotations`.
4. Summarize what changed.

Do not commit.
