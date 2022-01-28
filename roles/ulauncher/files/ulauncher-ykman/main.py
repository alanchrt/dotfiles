import subprocess
from ulauncher.api.client.Extension import Extension
from ulauncher.api.client.EventListener import EventListener
from ulauncher.api.shared.event import KeywordQueryEvent, ItemEnterEvent
from ulauncher.api.shared.item.ExtensionResultItem import ExtensionResultItem
from ulauncher.api.shared.action.RenderResultListAction import RenderResultListAction
from ulauncher.api.shared.action.ExtensionCustomAction import ExtensionCustomAction
from ulauncher.api.shared.action.DoNothingAction import DoNothingAction


class YubiKeyExtension(Extension):

    def __init__(self):
        super(YubiKeyExtension, self).__init__()
        self.subscribe(KeywordQueryEvent, KeywordQueryEventListener())
        self.subscribe(ItemEnterEvent, ItemEnterEventListener())


class KeywordQueryEventListener(EventListener):

    def on_event(self, event, _):
        query = event.get_argument()

        proc = subprocess.run(
            (
                "ykman oath accounts code --password $(secret-tool lookup ykman oath) | "
                "ugrep --fuzzy --ignore-case --sort=best '{}' | "
                "head -n 10"
            ).format(query),
            shell=True,
            capture_output=True,
            text=True)

        items = []
        for line in proc.stdout.splitlines():
            [account, code] = line.strip().split()
            [service, user] = account.split(':')

            data = {
                'service': service,
                'user': user,
                'code': code,
            }

            items.append(ExtensionResultItem(icon='images/code.png',
                                             name=service,
                                             description=user,
                                             on_enter=ExtensionCustomAction(data)))

        return RenderResultListAction(items)


class ItemEnterEventListener(EventListener):

    def on_event(self, event, _):
        data = event.get_data()
        subprocess.run(['ydotool', 'type', data['code']])
        return DoNothingAction()


if __name__ == '__main__':
    YubiKeyExtension().run()
