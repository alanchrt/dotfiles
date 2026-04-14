-- Dropdown terminal toggle
-- Tracks the dropdown window separately from regular Alacritty windows
local droptermWindow = nil

hs.hotkey.bind({"alt"}, "u", function()
    -- Check if our tracked window still exists
    if droptermWindow and droptermWindow:application() then
        if droptermWindow:isVisible() then
            droptermWindow:application():hide()
        else
            local screen = hs.screen.mainScreen():frame()
            droptermWindow:setFrame(hs.geometry.rect(screen.x, screen.y, screen.w, screen.h * 0.4))
            droptermWindow:focus()
        end
        return
    end

    -- Launch a new Alacritty instance with the dropterm config
    hs.task.new("/Applications/Alacritty.app/Contents/MacOS/alacritty", nil, {
        "--config-file", os.getenv("HOME") .. "/.config/alacritty/dropterm.toml",
        "--command", os.getenv("HOME") .. "/.local/bin/dropterm"
    }):start()

    -- Wait for it to launch, then position and track it
    hs.timer.doAfter(1, function()
        local wins = hs.window.filter.new("Alacritty"):getWindows()
        for _, win in ipairs(wins) do
            if win:title():find("dropterm") then
                droptermWindow = win
                local screen = hs.screen.mainScreen():frame()
                win:setFrame(hs.geometry.rect(screen.x, screen.y, screen.w, screen.h * 0.4))
                win:focus()
                return
            end
        end
        -- Fallback: grab the most recent Alacritty window
        if #wins > 0 then
            droptermWindow = wins[1]
            local screen = hs.screen.mainScreen():frame()
            droptermWindow:setFrame(hs.geometry.rect(screen.x, screen.y, screen.w, screen.h * 0.4))
            droptermWindow:focus()
        end
    end)
end)
