-- Dropdown terminal toggle
-- Uses a separate Alacritty window with a unique title to distinguish
-- it from regular terminal windows.
local droptermWindow = nil
local launching = false

local function positionDropterm(win)
    local screen = hs.screen.mainScreen():frame()
    win:setFrame(hs.geometry.rect(screen.x, screen.y, screen.w, screen.h / 3))
end

local function findDroptermWindow()
    if droptermWindow and droptermWindow:application() and droptermWindow:id() then
        return droptermWindow
    end
    droptermWindow = nil
    local allWindows = hs.window.allWindows()
    for _, win in ipairs(allWindows) do
        if win:title() == "dropterm" then
            droptermWindow = win
            return win
        end
    end
    return nil
end

hs.hotkey.bind({"alt"}, "u", function()
    if launching then return end

    local win = findDroptermWindow()

    if win then
        if win:isVisible() then
            win:minimize()
        else
            win:unminimize()
            positionDropterm(win)
            win:focus()
        end
        return
    end

    -- No dropterm window found, launch a new one
    launching = true
    local home = os.getenv("HOME")
    hs.execute(string.format(
        'export PATH="/opt/homebrew/bin:$PATH" && nohup /Applications/Alacritty.app/Contents/MacOS/alacritty --config-file %s/.config/alacritty/dropterm.toml -T dropterm --command %s/.local/bin/dropterm </dev/null >/dev/null 2>&1 &',
        home, home
    ))

    hs.timer.doAfter(2, function()
        launching = false
        local w = findDroptermWindow()
        if w then
            positionDropterm(w)
            w:focus()
        end
    end)
end)
