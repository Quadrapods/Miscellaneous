---------------------------------------------------------------------------------------------------- // Dependencies
local GetTarget = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/Quadrapods/Miscellaneous/main/Get-Closest-Player.lua'))()

---------------------------------------------------------------------------------------------------- // Declarations
local a = game:GetService('Players').LocalPlayer
local b = game:GetService('UserInputService')
local c = game:GetService('HttpService')
local d = game:GetService('RunService')
local e = game:GetService('Workspace')
local f = game:GetService('Players')

local g = a:GetMouse()
local h

---------------------------------------------------------------------------------------------------- // Functions
h = hookmetamethod(a, '__index', function(...)
    local x = {...}

    if (not checkcaller() and rawequal(x[2], 'Hit')) then
        local y = GetTarget(500)

        if (y) then
            return y.Character:WaitForChild('HumanoidRootPart').CFrame
        end
    end
    return h(...)
end)