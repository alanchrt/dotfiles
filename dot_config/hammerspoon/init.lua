-- Dropdown terminal toggle
hs.hotkey.bind({"alt"}, "u", function()
    local app = hs.application.find("Alacritty")

    if app and app:isFrontmost() then
        app:hide()
        return
    end

    if not app then
        -- Launch Alacritty with dropterm script
        hs.task.new("/usr/bin/open", nil, {"-na", "Alacritty", "--args", "--command", os.getenv("HOME") .. "/.local/bin/dropterm"}):start()
        -- Wait for it to launch, then position
        hs.timer.doAfter(1, function()
            local win = hs.application.find("Alacritty"):mainWindow()
            if win then
                local screen = hs.screen.mainScreen():frame()
                win:setFrame(hs.geometry.rect(screen.x, screen.y, screen.w, screen.h * 0.4))
            end
        end)
    else
        -- App exists, show and focus it
        local win = app:mainWindow()
        if win then
            local screen = hs.screen.mainScreen():frame()
            win:setFrame(hs.geometry.rect(screen.x, screen.y, screen.w, screen.h * 0.4))
            win:focus()
        else
            app:activate()
        end
    end
end)
