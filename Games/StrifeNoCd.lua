---------------------------------------------------------------------------------------------------- // Dependencies
local GetScript = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/Quadrapods/Miscellaneous/main/Get-Closest-Constant.lua'))();

---------------------------------------------------------------------------------------------------- // Declarations
local a = GetScript(500);
local b = getsenv(a);

---------------------------------------------------------------------------------------------------- // Functions
local function GetKeyUpdate()
    local x = b.do1;
    local y;

    if (x) then
        local z;

        for _, v in pairs(debug.getupvalues(x)) do
            if (type(v) == 'table' and table.getn(v) == 4) then
                z = v;
                break
            end
        end

        if (z) then
            for _, v in pairs(getgc(true)) do
                if (type(v) == 'table' and v == z) then
                    y = v;
                    break
                end
            end
        end
    end

    if (y) then
        while (true) do
            task.wait()

            for i, _ in pairs(y) do
                y[i] = 100;
            end
        end
    end
end

---------------------------------------------------------------------------------------------------- // Runtime
GetKeyUpdate()