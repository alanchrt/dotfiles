-- Dropdown terminal toggle
-- Each press launches a new dropterm on the current space or hides/closes it.
-- All instances share the same tmux "dropterm" session.
local droptermWindows = {} -- spaceID -> windowID
local launching = false

local function positionDropterm(win)
    local screen = hs.screen.mainScreen():frame()
    win:setFrame(hs.geometry.rect(screen.x, screen.y, screen.w, screen.h / 3))
end

hs.hotkey.bind({"alt"}, "u", function()
    if launching then return end

    local space = hs.spaces.focusedSpace()
    local winID = droptermWindows[space]

    -- Check if we have a tracked window on this space
    if winID then
        local win = hs.window.get(winID)
        if win then
            -- Close this instance (tmux session persists)
            win:close()
            droptermWindows[space] = nil
            return
        end
        -- Window is gone, clear stale reference
        droptermWindows[space] = nil
    end

    -- Launch a new dropterm instance
    launching = true
    local existingIDs = {}
    for _, w in ipairs(hs.window.allWindows()) do
        existingIDs[w:id()] = true
    end

    local home = os.getenv("HOME")
    io.popen(string.format(
        'export PATH="/opt/homebrew/bin:$PATH" && /Applications/Alacritty.app/Contents/MacOS/alacritty --config-file %s/.config/alacritty/dropterm.toml -T dropterm --command %s/.local/bin/dropterm &',
        home, home
    ))

    local attempts = 0
    hs.timer.doEvery(0.3, function(timer)
        attempts = attempts + 1
        for _, w in ipairs(hs.window.allWindows()) do
            local app = w:application()
            if app and app:name() == "Alacritty" and not existingIDs[w:id()] then
                droptermWindows[space] = w:id()
                positionDropterm(w)
                w:focus()
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
