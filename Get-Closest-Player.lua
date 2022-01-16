-- Forked from https://github.com/yesok3877/Miscellaneous/blob/master/Get-Closest-To-Cursor.lua

return function()
    local a = game:GetService('Workspace')
    local b = game:GetService('Players')

    local c = b.LocalPlayer
    local d = c:GetMouse()

    local e = b:GetPlayers()
    local f, g = math.huge

    for i = 1, table.getn(e) do
        local h = rawget(e, i)

        if (h and h ~= c and h.Character and h.Character.PrimaryPart) then
            local i, j = a.CurrentCamera:WorldToViewportPoint(h.Character.PrimaryPart.CFrame.Position)

            if (j) then
                local k = Vector2.new((i.X - d.X), (i.Y - d.Y)).Magnitude

                if (k <= f) then
                    f = k
                    g = h
                end
            end
        end
    end
    return (g)
end
