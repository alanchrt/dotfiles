-- Dropdown terminal toggle
-- Tracks the dropterm window by its window ID after creation.
local droptermWindowID = nil
local launching = false

local function positionDropterm(win)
    local screen = hs.screen.mainScreen():frame()
    win:setFrame(hs.geometry.rect(screen.x, screen.y, screen.w, screen.h / 3))
end

local function findDroptermWindow()
    if droptermWindowID then
        local win = hs.window.get(droptermWindowID)
        if win then return win end
        droptermWindowID = nil
    end
    return nil
end

local function getAlacrittyWindowIDs()
    local ids = {}
    for _, win in ipairs(hs.window.allWindows()) do
        local app = win:application()
        if app and app:name() == "Alacritty" then
            ids[win:id()] = true
        end
    end
    return ids
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
    local existingIDs = getAlacrittyWindowIDs()
    local home = os.getenv("HOME")
    hs.execute(string.format(
        'export PATH="/opt/homebrew/bin:$PATH" && nohup /Applications/Alacritty.app/Contents/MacOS/alacritty --config-file %s/.config/alacritty/dropterm.toml -T dropterm --command %s/.local/bin/dropterm </dev/null >/dev/null 2>&1 &',
        home, home
    ))

    hs.timer.doAfter(2, function()
        launching = false
        -- Find the new Alacritty window that wasn't there before
        for _, win in ipairs(hs.window.allWindows()) do
            local app = win:application()
            if app and app:name() == "Alacritty" and not existingIDs[win:id()] then
                droptermWindowID = win:id()
                positionDropterm(win)
                win:focus()
                return
            end
        end
    end)
end)
