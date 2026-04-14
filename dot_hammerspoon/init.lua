-- Dropdown terminal toggle
local droptermWindow = nil
local launching = false

local function positionDropterm(win)
    local screen = hs.screen.mainScreen():frame()
    win:setFrame(hs.geometry.rect(screen.x, screen.y, screen.w, screen.h / 3))
end

-- Window filter that includes minimized windows
local wf = hs.window.filter.new(false):setAppFilter("Alacritty", {allowTitles = "dropterm", visible = nil})

local function findDroptermWindow()
    local wins = wf:getWindows()
    if #wins > 0 then
        droptermWindow = wins[1]
        return droptermWindow
    end
    droptermWindow = nil
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
