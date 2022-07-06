---------------------------------------------------------------------------------------------------- // Dependencies
local GetTarget = loadstring(syn.request({Url = 'https://raw.githubusercontent.com/Quadrapods/Miscellaneous/main/Get-Closest-Player.lua', Method = 'GET'}).Body)();

---------------------------------------------------------------------------------------------------- // Declarations
local a = game:GetService('Players').LocalPlayer;
local b = game:GetService('UserInputService');
local c = game:GetService('HttpService');
local d = game:GetService('RunService');
local e = game:GetService('Workspace');

local f = a:GetMouse();
local g;

---------------------------------------------------------------------------------------------------- // Functions
local function GetCharacter()
    local a = GetTarget(500);

    if (a) then
        local b = a.Character;

        if (b) then
            local c = b:FindFirstChild('HumanoidRootPart');

            if (c) then
                return (c.CFrame);
            end
        end
    end
end

---------------------------------------------------------------------------------------------------- // Runtime
g = hookmetamethod(game, '__index', function(...)
    local x = {...};

    if (not checkcaller()) then
        if (rawequal(x[1], f) and rawequal(x[2], 'Hit')) then
            local y = GetCharacter();

            if (y) then
                return (y);
            end
        end
    end

    return g(...);
end)
