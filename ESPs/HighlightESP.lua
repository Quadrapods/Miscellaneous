---------------------------------------------------------------------------------------------------- // Dependencies
local ESP = loadstring(syn.request({Url = 'https://raw.githubusercontent.com/Quadrapods/ESP-Library/main/Library.lua', Method = 'GET'}).Body)();

---------------------------------------------------------------------------------------------------- // Declarations
local a = game:GetService('Players').LocalPlayer;
local b = game:GetService('UserInputService');
local c = game:GetService('HttpService');
local d = game:GetService('RunService');
local e = game:GetService('Players');

local f = Color3.fromHSV;
local g = Color3.fromRGB;

---------------------------------------------------------------------------------------------------- // Tables
local Colors = {Default = g(255, 127, 255), Outline = g(0, 0, 0)};

local Properties = {
    Enabled = true,
    FillColor = Colors.Default,
    OutlineColor = Colors.Outline,
    FillTransparency = 0.65,
    OutlineTransparency = 0.85,
}

---------------------------------------------------------------------------------------------------- // Functions
function ESP.Rainbow(a)
    while (a) do
        task.wait()

        local b = ((os.clock() * 128 % 255) / 255);
        local c = f(b, 1, 1);

        a.FillColor = c;
        a.OutlineColor = c;
    end
end

function ESP.Add(a)
    local b = ESP:Spotlight(a, Properties); task.spawn(ESP.Rainbow, b);
end

local function CharacterAdded(a)
    if (a and a:IsA('Player')) then
        a.CharacterAdded:Connect(ESP.Add)
    end
end
---------------------------------------------------------------------------------------------------- // Runtime
for _, v in ipairs(e:GetPlayers()) do
    if (v and v.Character and v ~= a) then
        local x = v.Character; ESP.Add(x); CharacterAdded(v);
    end
end

e.PlayerAdded:Connect(CharacterAdded);