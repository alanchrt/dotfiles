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
            win:application():hide()
        else
            win:application():unhide()
            positionDropterm(win)
            win:focus()
        end
        return
    end

    -- No dropterm window found, launch a new one
    launching = true
    local existingIDs = getAlacrittyWindowIDs()
    local home = os.getenv("HOME")
    local cmd = string.format(
        'export PATH="/opt/homebrew/bin:$PATH" && /Applications/Alacritty.app/Contents/MacOS/alacritty --config-file %s/.config/alacritty/dropterm.toml -T dropterm --command %s/.local/bin/dropterm &',
        home, home
    )
    io.popen(cmd)

    -- Poll quickly to catch the window as soon as it appears
    local attempts = 0
    hs.timer.doEvery(0.3, function(timer)
        attempts = attempts + 1
        for _, win in ipairs(hs.window.allWindows()) do
            local app = win:application()
            if app and app:name() == "Alacritty" and not existingIDs[win:id()] then
                droptermWindowID = win:id()
                positionDropterm(win)
                win:focus()
                launching = false
                timer:stop()
                return
            end
        end
        if attempts > 10 then
            launching = false
            timer:stop()
        end
    end)
end)
