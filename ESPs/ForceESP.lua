---------------------------------------------------------------------------------------------------- // Dependencies
local ESP = loadstring(syn.request({Url = 'https://raw.githubusercontent.com/Quadrapods/ESP-Library/main/Library.lua', Method = 'GET'}).Body)();

---------------------------------------------------------------------------------------------------- // Declarations
getgenv().TRINKET_ESP_ENABLED = true;

local a = game:GetService('Players').LocalPlayer;
local b = game:GetService('UserInputService');
local c = game:GetService('HttpService');
local d = game:GetService('RunService');
local e = game:GetService('Workspace');

local g = Color3.fromRGB;
local h = Color3.new;

local i = Vector3.new;
local j = Vector2.new;

local k = j(e.CurrentCamera.ViewportSize.X / 2, e.CurrentCamera.ViewportSize.Y - 135);

---------------------------------------------------------------------------------------------------- // Tables
local Colors = {
    Color_1 = g(255, 255, 255),
    Color_2 = g(127, 255, 127),
    Color_3 = g(0, 127, 255),
    Color_4 = g(255, 127, 0),
    Color_5 = g(0, 0, 0),
}

local Properties = {
    Line = {
        From         = k,
        Color        = Colors.Color_1,
        ZIndex       = 3,
        Thickness    = 1.5,
        Transparency = 0.5,
    },
    Text = {
        Size         = 18,
        Font         = Drawing.Fonts.UI,
        Color        = Colors.Color_1,
        ZIndex       = 1,
        Center       = true,
        Outline      = true,
        OutlineColor = Colors.Color_5,
        Transparency = 1,
    },
    TSub = {
        Size         = 16,
        Font         = Drawing.Fonts.UI,
        Color        = Colors.Color_1,
        ZIndex       = 2,
        Center       = true,
        Outline      = true,
        OutlineColor = Colors.Color_5,
        Transparency = 1,
    },
    Circle = {
        Color        = Colors.Color_1,
        ZIndex       = 4,
        Radius       = 10,
        Filled       = false,
        NumSides     = 30,
        Thickness    = 1.5,
        Transparency = 0.5,
    },
}

---------------------------------------------------------------------------------------------------- // Functions
local function GetRarity(a)
    if (a and a:IsA('BasePart')) then
        local b = a:FindFirstChild('Rarity');

        if (b) then
            local c = b.Value;

            if (string.len(c) > 0) then
                return (c);
            end
        end
    end

    return ('Unknown');
end

local function UpdateESP(a, b, c)
    local x = false
    local y

    y = d.RenderStepped:Connect(function()
        if (a.Parent ~= nil) then
            if (ESP:GetObjectRender(a) and TRINKET_ESP_ENABLED) then
                b.Part1.Position = ESP:GetObjectVector(a, 0, 40);
                b.Part2.Position = ESP:GetObjectVector(a, 0, 25);
                b.Part3.Position = ESP:GetObjectVector(a);

                b.Part2.Text = string.format('[%s] [%s]', ESP:GetMagnitude(a), c)

                if (not x) then
                    for _, v in pairs(b) do
                        v.Visible = true;
                    end
                    x = true;
                end
            else
                if (x) then
                    for _, v in pairs(b) do
                        v.Visible = false;
                    end
                end
                x = false;
            end
        else
            for _, v in pairs(b) do
                v:Remove();
            end
            y:Disconnect();
        end
    end)
end

function ESP.Create(a, b, c, d, e, ...)
    local x = {...};
    local y = {
        Part1 = ESP.new('Text', x[1]),
        Part2 = ESP.new('Text', x[2]),
        Part3 = ESP.new('Circle', x[3]),
    }

    y.Part1.Text = tostring(b);

    for _, v in pairs(y) do
        v.Color = c;
        v.ZIndex = d;
    end

    task.spawn(UpdateESP, a, y, e);
end

function ESP.Add(a)
    local b = GetRarity(a);

    if (b == 'Rare') then
        ESP.Create(a, 'Trinket', Colors.Color_3, 3, b, Properties.Text, Properties.TSub, Properties.Circle);
    end
    if (b == 'Uncommon') then
        ESP.Create(a, 'Trinket', Colors.Color_2, 2, b, Properties.Text, Properties.TSub, Properties.Circle);
    end
    if (b == 'Common') then
        ESP.Create(a, 'Trinket', Colors.Color_1, 1, b, Properties.Text, Properties.TSub, Properties.Circle);
    end
    if (b == 'Unknown') then
        ESP.Create(a, 'Trinket', Colors.Color_4, 4, b, Properties.Text, Properties.TSub, Properties.Circle);
    end
end

---------------------------------------------------------------------------------------------------- // Runtime
for _, v in ipairs(e:GetChildren()) do
    if (v and v:IsA('BasePart')) then
        local a = v:FindFirstChildWhichIsA('ProximityPrompt');
        local b = v:FindFirstChild('Rarity');

        if (a and b) then
            ESP.Add(v);
        end
    end
end

e.ChildAdded:Connect(function(v)
    d.RenderStepped:Wait()
    if (TRINKET_ESP_ENABLED) then
        if (v and v:IsA('BasePart')) then
            local a = v:FindFirstChildWhichIsA('ProximityPrompt');
            local b = v:FindFirstChild('Rarity');
    
            if (a and b) then
                ESP.Add(v);
            end
        end
    end
end)