-- Dropdown terminal toggle
-- Uses a separate Alacritty window with a unique title to distinguish
-- it from regular terminal windows.
local droptermWindow = nil

local function positionDropterm(win)
    local screen = hs.screen.mainScreen():frame()
    win:setFrame(hs.geometry.rect(screen.x, screen.y, screen.w, screen.h * 0.4))
end

local function findDroptermWindow()
    if droptermWindow and droptermWindow:isVisible() then
        return droptermWindow
    end
    -- Search all windows for one with "dropterm" in the title
    local wins = hs.window.filter.new("Alacritty"):getWindows()
    for _, win in ipairs(wins) do
        if win:title():find("dropterm") then
            droptermWindow = win
            return win
        end
    end
    return nil
end

hs.hotkey.bind({"alt"}, "u", function()
    local win = findDroptermWindow()

    if win then
        if win:isVisible() and win == hs.window.focusedWindow() then
            win:minimize()
        else
            win:unminimize()
            positionDropterm(win)
            win:focus()
        end
        return
    end

    -- No dropterm window found, launch a new one
    local home = os.getenv("HOME")
    os.execute(string.format(
        'eval "$(/opt/homebrew/bin/brew shellenv)" && /Applications/Alacritty.app/Contents/MacOS/alacritty --config-file %s/.config/alacritty/dropterm.toml -T dropterm --command %s/.local/bin/dropterm &',
        home, home
    ))

    hs.timer.doAfter(1.5, function()
        local w = findDroptermWindow()
        if w then
            positionDropterm(w)
            w:focus()
        end
    end)
end)
