import i3
import subprocess
import sys

visible = 'visible' in sys.argv
window_id = subprocess.check_output(['xdotool', 'getwindowfocus']).decode('utf-8').strip()
i3.move('scratchpad')


def i3_msg(*args):
    window_args = ('[id={}]'.format(window_id),) + args
    i3.command(*window_args)


dimensions = next(output['rect'] for output in i3.get_outputs() if output['active'])
width, height = dimensions['width'], dimensions['height']

i3_msg('move', 'absolute', 'position', str(int(width / 2 - 400)), '0')
i3_msg('move', 'scratchpad')
i3_msg('resize', 'set', '800', str(dimensions['height']))
i3_msg('sticky', 'enable')

if visible:
    i3.scratchpad('show')
