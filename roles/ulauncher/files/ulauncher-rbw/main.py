import re
import json
import subprocess
from time import sleep
from ulauncher.api.client.Extension import Extension
from ulauncher.api.client.EventListener import EventListener
from ulauncher.api.shared.event import KeywordQueryEvent, ItemEnterEvent
from ulauncher.api.shared.item.ExtensionResultItem import ExtensionResultItem
from ulauncher.api.shared.action.RenderResultListAction import RenderResultListAction
from ulauncher.api.shared.action.ExtensionCustomAction import ExtensionCustomAction
from ulauncher.api.shared.action.OpenUrlAction import OpenUrlAction
from ulauncher.api.shared.action.DoNothingAction import DoNothingAction


class RbwExtension(Extension):

    def __init__(self):
        super(RbwExtension, self).__init__()
        self.subscribe(KeywordQueryEvent, KeywordQueryEventListener())
        self.subscribe(ItemEnterEvent, ItemEnterEventListener())


class KeywordQueryEventListener(EventListener):

    def on_event(self, event, extension):
        query = event.get_argument()

        proc = subprocess.run(
            (
                "rbw list --fields id,name,user,folder | " +
                "ugrep --fuzzy --ignore-case --sort=best '{}' | "
                "head -n 10"
            ).format(query),
            shell=True,
            capture_output=True,
            text=True)

        items = []
        for line in proc.stdout.splitlines():
            [id, name, user, folder] = line.split('\t')

            data = {
                'id': id,
                'name': name,
                'user': user,
                'folder': folder,
            }

            items.append(ExtensionResultItem(icon='images/pass.png',
                                             name='{} ({})'.format(
                                                 name, folder) if folder else name,
                                             description=user,
                                             on_enter=ExtensionCustomAction({
                                                 'action': 'password',
                                                 **data}),
                                             on_alt_enter=ExtensionCustomAction({
                                                 'action': 'menu',
                                                 **data}, keep_app_open=True)))

        return RenderResultListAction(items)


class ItemEnterEventListener(EventListener):

    def on_event(self, event, extension):
        data = event.get_data()

        action = data.pop('action')

        if action == 'password':
            password = subprocess.run(
                ['rbw', 'get', data['id']],
                capture_output=True,
                text=True).stdout.strip()

            subprocess.run(['ydotool', 'type', password])

            return DoNothingAction()

        if action == 'user':
            subprocess.run(['ydotool', 'type', data['user']])

            return DoNothingAction()

        elif action == 'menu':
            items = [
                ExtensionResultItem(icon='images/user.png',
                                    name='Insert Username',
                                    description=data['user'],
                                    on_enter=ExtensionCustomAction({
                                        'action': 'user',
                                        **data})),
            ]

            proc = subprocess.run(
                ['rbw', 'get', '--full', data['id']],
                capture_output=True,
                text=True)

            for line in proc.stdout.splitlines():
                if line.startswith('URI: '):
                    url = re.sub(r'^URI\:\s', '', line.strip())
                    items.append(ExtensionResultItem(icon='images/www.png',
                                                     name='Open URL',
                                                     description=url,
                                                     on_enter=OpenUrlAction(url)))

            return RenderResultListAction(items)



if __name__ == '__main__':
    RbwExtension().run()
