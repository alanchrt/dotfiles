import i3
import sys

from collections import defaultdict

command = sys.argv[1]
direction = sys.argv[2]

outputs = defaultdict(list)

for workspace in i3.get_workspaces():
    output = outputs[workspace['output']]
    output.append(workspace)
    if workspace['focused']:
        current_workspace = workspace
        index_on_output = len(output) - 1

target_output = outputs[current_workspace['output']]
workspace_count = len(target_output)
if direction == 'prev':
    target_workspace = target_output[(index_on_output - 1) % workspace_count]
elif direction == 'next':
    target_workspace = target_output[(index_on_output + 1) % workspace_count]

if command == 'workspace':
    i3.command('workspace', target_workspace['name'])
elif command == 'move':
    i3.command('move', 'container', 'to', 'workspace', target_workspace['name'])
    i3.command('workspace', target_workspace['name'])
    i3.command('focus')
