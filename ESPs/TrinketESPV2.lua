---------------------------------------------------------------------------------------------------- // Dependencies
local ESP = loadstring(syn.request({Url = 'https://raw.githubusercontent.com/Quadrapods/ESP-Library/main/Library.lua', Method = 'GET'}).Body)();

---------------------------------------------------------------------------------------------------- // Declarations
local a = game:GetService('Players').LocalPlayer;
local b = game:GetService('UserInputService');
local c = game:GetService('HttpService');
local d = game:GetService('RunService');
local e = game:GetService('Workspace');

local f = e:WaitForChild('Trinkets');

local g = Color3.fromRGB;
local h = Color3.new;

local i = Vector3.new;
local j = Vector2.new;

local k = j(e.CurrentCamera.ViewportSize.X / 2, e.CurrentCamera.ViewportSize.Y - 135);

---------------------------------------------------------------------------------------------------- // Tables
local Artifacts = {
    Main = {
        'Amulet of the White King',
        'Philosopher\'s Stone',
        'Mysterious Artifact',
        'Lannis\'s Amulet',
        'Phoenix Feather',
        'Howler Friend',
        'Spider Cloak',
        'Night Stone',
        'Azael Horns',
        'Scroom Key',
        'Fairfrozen',
        'Rift Gem',
    },
    Sub = {
        'Phoenix Down',
        'Ice Essence',
        '???',
    },
    Reg = {
        'Idol of the Forgotten',
        'Old Amulet',
        'Old Ring',
        'Scroll',
        'Goblet',
        'Amulet',
        'Ring',
        'Opal',
        'Gem',
    },
}

local SizeChecks = {
    ['Amulet of the White King'] = i(0.195, 1.811, 1.04),
    ['Idol of the Forgotten'] = i(0.700989, 0.655492, 0.682998),
    ['Philosopher\'s Stone'] = i(0.443721, 0.44358, 0.43335),
    ['Lannis\'s Amulet'] = i(0.195154, 1.81078, 1.04045),
    ['Spider Cloak'] = i(1.9, 1.79, 1.81),
    ['Phoenix Down'] = i(0.444, 0.444, 0.433),
    ['Ice Essence'] = i(0.443721, 0.44358, 0.43335),
    ['Night Stone'] = i(0.443721, 0.44358, 0.43335),
    ['Scroom Key'] = i(0.600391, 0.200031, 1.40005),
    ['Fairfrozen'] = i(0.8, 0.8, 0.8),
    ['Old Amulet'] = i(0.853258, 0.0740985, 1.14774),
    ['Rift Gem'] = i(0.4816, 0.315448, 0.4816),
    ['Old Ring'] = i(0.363173, 0.429801, 0.231654),
    ['Scroll'] = i(0.208974, 0.554892, 0.457498),
    ['Goblet'] = i(0.905316, 1.55034, 0.901762),
    ['Amulet'] = i(0.633356, 0.116539, 1.5662),
    ['Ring'] = i(0.674558, 0.821674, 0.407528),
    ['Opal'] = i(0.4, 0.5, 0.3),
    ['Gem'] = i(0.8, 0.524, 0.8),
    ['???'] = i(0.17486, 0.17486, 0.17486),
    ['?'] = i(1, 1, 1),
}

local SpecialChecks = {
    'Philosopher\'s Stone',
    'Phoenix Down',
    'Night Stone',
    'Ice Essence',
}

local Colors = {
    Color_1 = g(255, 255, 255),
    Color_2 = g(255, 127, 0),
    Color_3 = g(255, 255, 0),
    Color_4 = g(0, 0, 0),
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
        OutlineColor = Colors.Color_4,
        Transparency = 1,
    },
    TSub = {
        Size         = 16,
        Font         = Drawing.Fonts.UI,
        Color        = Colors.Color_1,
        ZIndex       = 2,
        Center       = true,
        Outline      = true,
        OutlineColor = Colors.Color_4,
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
local function GetSpecialName(a, b)
    if (a.BrickColor.Name == 'Persimmon') then
        local c = a:FindFirstChild('OrbParticle');

        if (c) then
            return ('Ice Essence');
        else
            return ('Philosopher\'s Stone');
        end
    end
    if (a.BrickColor.Name == 'Black') then
        return ('Night Stone');
    end
    if (b == 'Phoenix Down') then
        local c = a:FindFirstChildWhichIsA('Attachment');

        if (c) then
            local d = c:FindFirstChildWhichIsA('ParticleEmitter');

            if (d) then
                local e = d.Color.Keypoints[1].Value;

                if (e == h(1, 0.8, 0)) then
                    return ('Phoenix Down');
                else
                    return ('Azael Horns');
                end
            end
        end
    end
end

local function GetTrinketName(a)
    for i, v in pairs(SizeChecks) do
        local b = v:FuzzyEq(a.Size, 0.0001);

        if (b) then
            if (table.find(SpecialChecks, i)) then
                return (GetSpecialName(a, i));
            end

            return (i);
        end
    end
end

local function UpdateESP(a, b, c)
    local x = false
    local y

    y = d.RenderStepped:Connect(function()
        if (a.Parent ~= nil) then
            if (ESP:GetObjectRender(a)) then
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
    local b = GetTrinketName(a);

    if (table.find(Artifacts.Main, b)) then
        ESP.Create(a, b, Colors.Color_3, 3, 'Artifact', Properties.Text, Properties.TSub, Properties.Circle);
    end
    if (table.find(Artifacts.Sub, b)) then
        ESP.Create(a, b, Colors.Color_2, 2, 'Artifact', Properties.Text, Properties.TSub, Properties.Circle);
    end
    if (table.find(Artifacts.Reg, b)) then
        ESP.Create(a, b, Colors.Color_1, 1, 'Trinket', Properties.Text, Properties.TSub, Properties.Circle);
    end
end

---------------------------------------------------------------------------------------------------- // Runtime
for _, v in ipairs(f:GetDescendants()) do
    if (v and v.Parent and v:IsA('ClickDetector')) then
        local a = v.Parent.Parent;

        if (a and a:IsA('BasePart')) then
            ESP.Add(a);
        end
    end
end

f.DescendantAdded:Connect(function(v)
    d.RenderStepped:Wait()
    if (v and v.Parent and v:IsA('ClickDetector')) then
        local a = v.Parent.Parent;

        if (a and a:IsA('BasePart')) then
            ESP.Add(a);
        end
    end
end)