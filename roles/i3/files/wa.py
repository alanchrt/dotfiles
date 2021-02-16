#!/usr/bin/env python

import sys
from prompt_toolkit import PromptSession
from prompt_toolkit.history import FileHistory
from prompt_toolkit.styles import Style

style = Style.from_dict({
    # default
    '':          '#f8f8f2',

    # prompt
    'logo':    '#ff79c6',
    'colon': '#ff5555',
})

prompt_text = [
    ('class:logo', '𖣔 '),
    ('class:colon',    ': '),
]


def main():
    history = FileHistory('/tmp/.wa-history')
    session = PromptSession(history=history)

    while True:
        try:
            text = session.prompt(prompt_text, style=style)

            if text == 'exit':
                raise EOFError

            # TODO call wolfram alpha
            print("You said: %s" % text)

        except KeyboardInterrupt:
            continue

        except EOFError:
            sys.exit()


if __name__ == "__main__":
    main()
