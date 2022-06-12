---------------------------------------------------------------------------------------------------- // Dependencies
local GetScript = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/Quadrapods/Miscellaneous/main/Get-Closest-Constant.lua'))();

---------------------------------------------------------------------------------------------------- // Declarations
local a = game:GetService('Players').LocalPlayer:GetMouse();
local b = GetScript(150, {'LibLoader'});
local c = getsenv(b);

---------------------------------------------------------------------------------------------------- // Tables
local d = {
    ['NewPaladin'] = {
        GetCustomCooldown = function()
            local x;
            local y;

            if (c.updateStanceStats) then
                x = c.updateStanceStats;
            end

            if (x) then
                y = debug.getupvalue(x, 1);

                if (y.Cooldowns) then
                    y = y.Cooldowns;
                end
            end

            if (y) then
                while (true) do
                    task.wait()

                    for _, v in pairs(y) do
                        for i, _ in pairs(v) do
                            v[i] = 100;
                        end
                    end
                end
            end
        end
    },
    ['Brawler'] = {
        GetCustomCooldown = function()
            local x = {};

            for i, v in pairs(c) do
                if (string.find(i, 'Ability')) then
                    table.insert(x, v);
                end
            end

            if (table.getn(x) > 0) then
                while (true) do
                    task.wait()

                    for _, v in ipairs(x) do
                        debug.setupvalue(v, 1, false);
                    end
                end
            end
        end
    },
    ['CyberStratosphere'] = {
        GetCustomCooldown = function()
            local x = getconnections(a.KeyDown)[1].Function;
            local y;

            if (table.getn(debug.getconstants(x)) >= 10) then
                for i, v in pairs(debug.getupvalues(x)) do
                    if (type(v) == 'table' and i > 9) then
                        y = v;
                        break;
                    end
                end
            end

            if (y) then
                while (true) do
                    task.wait()

                    for i, _ in pairs(y) do
                        y[i] = false;
                    end
                end
            end
        end
    },
}
---------------------------------------------------------------------------------------------------- // Functions
local function GetKeyEnabled()
    local x = {};
    local y;

    for i, v in pairs(c) do
        if (string.find(i, 'enabled')) or (string.find(i, 'cooldown')) then
            table.insert(x, i);
        end
    end

    if (table.getn(x) > 0) then
        local y = type(c[x[1]]);

        if (y == 'boolean') then
            y = true;
        else
            y = false;
        end

        while (true) do
            task.wait()

            for _, v in ipairs(x) do
                c[v] = (y and true) or (100);
            end
        end
    end
end

local function GetKeyUpdate()
    local x = {};
    local y;

    if (c.updateskills) then
        y = c.updateskills;
    end

    if (y) then
        for i, v in pairs(debug.getupvalues(y)) do
            if (type(v) == 'number') then
                table.insert(x, i);
            end
        end
    end

    if (table.getn(x) > 0) then
        while (true) do
            task.wait()

            for _, v in ipairs(x) do
                debug.setupvalue(y, v, 100);
            end
        end
    end
end

local function GetKeyDown()
    local x = getconnections(a.KeyDown)[1].Function;
    local y = {};

    if (table.getn(debug.getconstants(x)) >= 10) then
        for i, v in pairs(debug.getupvalues(x)) do
            if (type(v) == 'number') then
                table.insert(y, i);
            end
        end
    end

    if (table.getn(y) > 0) then
        while (true) do
            task.wait()

            for _, v in ipairs(y) do
                debug.setupvalue(x, v, 100);
            end
        end
    end
end

---------------------------------------------------------------------------------------------------- // Runtime
if (not d[b.Name]) then
    GetKeyEnabled(); GetKeyUpdate(); GetKeyDown();
else
    d[b.Name].GetCustomCooldown();
end
