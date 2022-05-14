return function(x)
    local a = game:GetService('Players').LocalPlayer;
    local b = debug.getconstants;
    local c = getscriptclosure;
    local d;

    for _, v in ipairs(a:GetDescendants()) do
        if (v and v:IsA('LocalScript') and #b(c(v)) >= tonumber(x)) then
            d = v;
        end
    end
    return (d)
end
