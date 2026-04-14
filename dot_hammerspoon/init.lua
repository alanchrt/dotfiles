-- Dropdown terminal toggle
-- Kill to dismiss, relaunch to show. The tmux session persists
-- so reopening on any Space reattaches instantly.
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

hs.hotkey.bind({"alt"}, "u", function()
    if launching then return end

    local win = findDroptermWindow()

    if win then
        local pid = win:application():pid()
        os.execute("kill " .. pid)
        droptermWindowID = nil
        return
    end

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
                droptermWindowID = w:id()
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
