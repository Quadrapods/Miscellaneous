---------------------------------------------------------------------------------------------------- // Dependencies
local GetScript = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/Quadrapods/Miscellaneous/main/Get-Closest-Constant.lua'))();

---------------------------------------------------------------------------------------------------- // Declarations
local a = game:GetService('Players').LocalPlayer:GetMouse();
local b = GetScript(150, {'LibLoader'});
local c = getsenv(b);

---------------------------------------------------------------------------------------------------- // Functions
local function GetKeyEnabled()
    local x = false;
    local y = {};
    local z;

    for i, _ in pairs(c) do
        if (string.find(i, 'enabled') or string.find(i, 'cooldown')) then
            table.insert(y, i);
            x = true;
        end
    end

    if (x) then
        z = type(c[y[1]]);

        if (z == 'boolean') then
            z = true;
        else
            z = false;
        end

        while (true) do
            task.wait()

            for _, v in ipairs(y) do
                c[v] = (z and true) or (100);
            end
        end
    end
end

local function GetKeyUpdate()
    local x = false;
    local y = {};
    local z;

    if (c.updateskills) then
        z = c.updateskills;
        x = true;
    end

    if (x) then
        for i, v in ipairs(debug.getupvalues(z)) do
            if (type(v) == 'number') then
                table.insert(y, i);
            end
        end
    end

    if (#y > 0) then
        while (true) do
            task.wait()

            for _, v in ipairs(y) do
                debug.setupvalue(z, v, 100);
            end
        end
    end
end

local function GetKeyDown()
    local x = getconnections(a.KeyDown)[1].Function;
    local y = false;
    local z = {};

    if (#debug.getconstants(x) >= 10) then
        y = true;
    end

    if (y) then
        for i, v in ipairs(debug.getupvalues(x)) do
            if (type(v) == 'number') then
                table.insert(z, i);
            end
        end
    end

    if (#z > 0) then
        while (true) do
            task.wait()

            for _, v in ipairs(z) do
                debug.setupvalue(x, v, 100);
            end
        end
    end
end

---------------------------------------------------------------------------------------------------- // Runtime
GetKeyEnabled(); GetKeyUpdate(); GetKeyDown();
