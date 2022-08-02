local a = game:GetService('Players').LocalPlayer;
local b = debug.getconstants;
local c = getscriptclosure;

return function(x, y)
    local d;

    for _, v in ipairs(a:GetDescendants()) do
        if (v and v:IsA('LocalScript') and #b(c(v)) >= tonumber(x)) then
            if (y) then
                if (not table.find(y, v.Name)) then
                    d = v;
                    break;
                end
            else
                d = v;
                break;
            end
        end
    end

    if (d == nil) then
        error(string.format('No LocalScripts found with >= %s constants!', tostring(x)));
    end

    return (d);
end
