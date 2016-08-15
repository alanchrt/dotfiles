import i3
import sys

from collections import defaultdict

# Get cli params
command = sys.argv[1]
direction = sys.argv[2]

# Get the focused workspace and a list of workspaces on each output
outputs = defaultdict(list)
for workspace in i3.get_workspaces():
    output = outputs[workspace['output']]
    output.append(workspace)
    if workspace['focused']:
        current_workspace = workspace
        index_on_output = len(output) - 1

# Get the previous or next workspace on the current output
target_output = outputs[current_workspace['output']]
workspace_count = len(target_output)
if direction == 'prev':
    target_workspace = target_output[(index_on_output - 1) % workspace_count]
elif direction == 'next':
    target_workspace = target_output[(index_on_output + 1) % workspace_count]

# Take action on the target workspace
if command == 'workspace':
    i3.command('workspace', target_workspace['name'])
elif command == 'move':
    i3.command('move', 'container', 'to', 'workspace', target_workspace['name'])
    i3.command('workspace', target_workspace['name'])
    i3.command('focus')
