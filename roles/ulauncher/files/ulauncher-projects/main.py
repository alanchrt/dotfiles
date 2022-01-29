import os
import subprocess
from ulauncher.api.client.Extension import Extension
from ulauncher.api.client.EventListener import EventListener
from ulauncher.api.shared.event import KeywordQueryEvent, ItemEnterEvent
from ulauncher.api.shared.item.ExtensionResultItem import ExtensionResultItem
from ulauncher.api.shared.action.RenderResultListAction import RenderResultListAction
from ulauncher.api.shared.action.ExtensionCustomAction import ExtensionCustomAction
from ulauncher.api.shared.action.DoNothingAction import DoNothingAction


class RbwExtension(Extension):

    def __init__(self):
        super(RbwExtension, self).__init__()
        self.subscribe(KeywordQueryEvent, KeywordQueryEventListener())
        self.subscribe(ItemEnterEvent, ItemEnterEventListener())


class KeywordQueryEventListener(EventListener):

    def on_event(self, event, _):
        query = event.get_argument()

        proc = subprocess.run(
            (
                "printf '%s\n' ~/Projects/* | " +
                "cut -d '/' -f 5,7 |"
                "fzf --filter '{}' | "
                "head -n 10"
            ).format(query),
            shell=True,
            capture_output=True,
            text=True)

        items = []
        for line in proc.stdout.splitlines():
            project = line.strip()
            items.append(ExtensionResultItem(icon='images/icon.png',
                                             name=project,
                                             on_enter=ExtensionCustomAction(project)))

        return RenderResultListAction(items)


class ItemEnterEventListener(EventListener):

    def on_event(self, event, _):
        project = event.get_data()
        home = os.getenv('HOME')

        subprocess.run([
            'tilix',
            '--maximize',
            '--title', project,
            '--command', 'byobu new-session -c {}/Projects/{} -s {}'.format(home, project, project)])

        return DoNothingAction()


if __name__ == '__main__':
    RbwExtension().run()
