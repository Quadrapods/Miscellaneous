local UserInputService = game:GetService 'UserInputService'
local TweenService = game:GetService 'TweenService'
local HttpService = game:GetService 'HttpService'
local RunService = game:GetService 'RunService'
local Workspace = game:GetService 'Workspace'
local Players = game:GetService 'Players'
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local CFNew = CFrame.new
local C3New = Color3.new
local V2New = Vector2.new
local V3New = Vector3.new
local WTVP = Camera.WorldToViewportPoint
local Menu = {}
local MouseHeld = false
local LastRefresh = 0
local OptionsFile = 'IC3_ESP_SETTINGS.dat'
local Binding = false
local BindedKey = nil
local OIndex = 0
local LineBox = {}
local UIButtons = {}
local Sliders = {}
local ColorPicker = {Loading = false, LastGenerated = 0}
local Dragging = false
local DraggingUI = false
local Rainbow = false
local DragOffset = V2New()
local DraggingWhat = nil
local OldData = {}
local CustomColor = C3New(1, 0.75, 0.45)
local EnemyColor = C3New(1, 0, 0)
local TeamColor = C3New(0, 1, 0)
local Font = nil
local MenuLoaded = false
local TracerPosition = V2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 135)
local DragTracerPosition = false
local SubMenu = {}
local IsSynapse = syn
local Connections = {Active = {}}
local Signal = {}
Signal.__index = Signal

local GetMouseLocation = UserInputService.GetMouseLocation

local TInsert = table.insert
local TConcat = table.concat
local TFind = table.find

local Format = string.format
local Match = string.match
local Find = string.find
local GSub = string.gsub
local Sub = string.sub

local CurrentColorPicker
local GetCharacter
local Spectating

local IgnoreList = {LocalPlayer.Character, Mouse.TargetFilter, Camera}
local RaycastList = RaycastParams.new()
RaycastList.FilterDescendantsInstances = IgnoreList
RaycastList.FilterType = Enum.RaycastFilterType.Blacklist

local Executor = (identifyexecutor or (function()
        return ''
    end))()
local SupportedExploits = {'Synapse X', 'ScriptWare', 'Krnl', 'OxygenU', 'Temple'}
local QUAD_SUPPORTED_EXPLOIT = TFind(SupportedExploits, Executor) ~= nil

shared.MenuDrawingData = shared.MenuDrawingData or {Instances = {}}
shared.InstanceData = shared.InstanceData or {}
shared.RSName = shared.RSName or ('UnnamedESP_by_ic3-' .. HttpService:GenerateGUID(false))

local GetDataName = shared.RSName .. '-GetData'
local UpdateName = shared.RSName .. '-Update'

local Debounce =
    setmetatable(
    {},
    {
        __index = function(t, i)
            return rawget(t, i) or false
        end
    }
)

if shared.UESP_InputChangedCon then
    shared.UESP_InputChangedCon:Disconnect()
end
if shared.UESP_InputBeganCon then
    shared.UESP_InputBeganCon:Disconnect()
end
if shared.UESP_InputEndedCon then
    shared.UESP_InputEndedCon:Disconnect()
end
if shared.CurrentColorPicker then
    shared.CurrentColorPicker:Dispose()
end

local function FindFirstChild(Instance, Name)
    if Instance then
        local Children = Instance:GetChildren()

        for i, v in pairs(Children) do
            if v:IsA 'BasePart' and v.Name == Name then
                return v
            end
        end
    end

    return false
end

local function IsStringEmpty(String)
    if type(String) == 'string' then
        return Match(String, '^%s*$') ~= nil
    end

    return false
end

local function WorldToViewport(Number)
    return WTVP(Camera, Number)
end

local Teams = {}
local CustomTeams = {
    [2563455047] = {
        Initialize = function()
            Teams.Sheriffs = {}
            Teams.Bandits = {}
            local Func = game:GetService 'ReplicatedStorage':WaitForChild('RogueFunc', 1)
            local Event = game:GetService 'ReplicatedStorage':WaitForChild('RogueEvent', 1)
            local S, B = Func:InvokeServer 'AllTeamData'

            Teams.Sheriffs = S
            Teams.Bandits = B

            Event.OnClientEvent:Connect(
                function(id, PlayerName, Team, Remove)
                    if id == 'UpdateTeam' then
                        local TeamTable, NotTeamTable
                        if Team == 'Bandits' then
                            TeamTable = TDM.Bandits
                            NotTeamTable = TDM.Sheriffs
                        else
                            TeamTable = TDM.Sheriffs
                            NotTeamTable = TDM.Bandits
                        end
                        if Remove then
                            TeamTable[PlayerName] = nil
                        else
                            TeamTable[PlayerName] = true
                            NotTeamTable[PlayerName] = nil
                        end
                        if PlayerName == LocalPlayer.Name then
                            TDM.Friendlys = TeamTable
                            TDM.Enemies = NotTeamTable
                        end
                    end
                end
            )
        end,
        CheckTeam = function(Player)
            local LocalTeam = Teams.Sheriffs[LocalPlayer.Name] and Teams.Sheriffs or Teams.Bandits

            return LocalTeam[Player.Name] and true or false
        end
    },
    [5208655184] = {
        CheckTeam = function(Player)
            local LocalLastName = LocalPlayer:GetAttribute 'LastName'
            if not LocalLastName or IsStringEmpty(LocalLastName) then
                return true
            end
            local PlayerLastName = Player:GetAttribute 'LastName'
            if not PlayerLastName then
                return false
            end

            return PlayerLastName == LocalLastName
        end
    },
    [3541987450] = {
        CheckTeam = function(Player)
            local LocalStats = LocalPlayer:FindFirstChild 'leaderstats'
            local LocalLastName = LocalStats and LocalStats:FindFirstChild 'LastName'
            if not LocalLastName or IsStringEmpty(LocalLastName.Value) then
                return true
            end
            local PlayerStats = Player:FindFirstChild 'leaderstats'
            local PlayerLastName = PlayerStats and PlayerStats:FindFirstChild 'LastName'
            if not PlayerLastName then
                return false
            end

            return PlayerLastName.Value == LocalLastName.Value
        end
    },
    [6032399813] = {
        CheckTeam = function(Player)
            local LocalStats = LocalPlayer:FindFirstChild 'leaderstats'
            local LocalGuildName = LocalStats and LocalStats:FindFirstChild 'Guild'
            if not LocalGuildName or IsStringEmpty(LocalGuildName.Value) then
                return true
            end
            local PlayerStats = Player:FindFirstChild 'leaderstats'
            local PlayerGuildName = PlayerStats and PlayerStats:FindFirstChild 'Guild'
            if not PlayerGuildName then
                return false
            end

            return PlayerGuildName.Value == LocalGuildName.Value
        end
    },
    [5735553160] = {
        CheckTeam = function(Player)
            local LocalStats = LocalPlayer:FindFirstChild 'leaderstats'
            local LocalGuildName = LocalStats and LocalStats:FindFirstChild 'Guild'
            if not LocalGuildName or IsStringEmpty(LocalGuildName.Value) then
                return true
            end
            local PlayerStats = Player:FindFirstChild 'leaderstats'
            local PlayerGuildName = PlayerStats and PlayerStats:FindFirstChild 'Guild'
            if not PlayerGuildName then
                return false
            end

            return PlayerGuildName.Value == LocalGuildName.Value
        end
    }
}

local RenderList = {Instances = {}}

function RenderList:AddOrUpdateInstance(Instance, Obj2Draw, Text, Color)
    RenderList.Instances[Instance] = {ParentInstance = Instance, Instance = Obj2Draw, Text = Text, Color = Color}
    return RenderList.Instances[Instance]
end

local CustomPlayerTag
local CustomESP
local CustomCharacter
local GetHealth
local GetAliveState
local CustomRootPartName

local Modules = {
    [292439477] = {
        CustomESP = function()
            if type(shared.PF_Replication) ~= 'table' then
                local lastScan = shared.pfReplicationScan

                if (tick() - (lastScan or 0)) > 0.01 then
                    shared.pfReplicationScan = tick()

                    local gc = getgc(true)
                    for i = 1, #gc do
                        local gcObject = gc[i]
                        if type(gcObject) == 'table' and type(rawget(gcObject, 'getbodyparts')) == 'function' then
                            shared.PF_Replication = gcObject
                            break
                        end
                    end
                end

                return
            end

            for Index, Player in pairs(Players:GetPlayers()) do
                if Player == LocalPlayer then
                    continue
                end

                local Body = shared.PF_Replication.getbodyparts(Player)

                if type(Body) == 'table' and typeof(rawget(Body, 'torso')) == 'Instance' then
                    Player.Character = Body.torso.Parent
                    continue
                end

                Player.Character = nil
            end
        end,
        GetHealth = function(Player)
            if type(shared.pfHud) ~= 'table' then
                return false
            end

            return shared.pfHud:getplayerhealth(Player)
        end,
        GetAliveState = function(Player)
            if type(shared.pfHud) ~= 'table' then
                local lastScan = shared.pfHudScan

                if (tick() - (lastScan or 0)) > 0.1 then
                    shared.pfHudScan = tick()

                    local gc = getgc(true)
                    for i = 1, #gc do
                        local gcObject = gc[i]
                        if type(gcObject) == 'table' and type(rawget(gcObject, 'getplayerhealth')) == 'function' then
                            shared.pfHud = gcObject
                            break
                        end
                    end
                end

                return
            end

            return shared.pfHud:isplayeralive(Player)
        end,
        CustomRootPartName = 'Torso'
    },
    [2950983942] = {
        CustomCharacter = function(Player)
            if Workspace:FindFirstChild 'Players' then
                return Workspace.Players:FindFirstChild(Player.Name)
            end
        end
    },
    [2262441883] = {
        CustomESP = function()
            local Entities = Workspace:FindFirstChild 'MoneyPrinters'

            if Entities then
                for i, v in pairs(Entities:GetChildren()) do
                    local Int = v:FindFirstChild 'Int'
                    local Main = v:FindFirstChild 'Main'
                    local Owner = v:FindFirstChild 'TrueOwner'
                    local Money

                    if Int then
                        Money = Int:FindFirstChild 'Money'
                    end

                    if Main and Owner and Money then
                        local M = tostring(Money.Value)
                        local O = tostring(Owner.Value)

                        pcall(
                            RenderList.AddOrUpdateInstance,
                            RenderList,
                            v,
                            Main,
                            Format('[%s]\n[Owned By %s] [$%s]', v.Name, O, M),
                            CustomColor
                        )
                    end
                end
            end
        end,
        CustomPlayerTag = function(Player)
            local Name = ''
            local Job = Player:FindFirstChild 'Job'

            if Job then
                Name = Format('\n[%s]', Job.Value)
            end

            return Name
        end
    },
    [4581966615] = {
        CustomESP = function()
            local Entities = Workspace:FindFirstChild 'Entities'

            if Entities then
                for i, v in pairs(Entities:GetChildren()) do
                    if Match(v.Name, 'Printer') then
                        local Properties = v:FindFirstChild 'Properties'

                        if Properties then
                            local Main = v:FindFirstChild 'hitbox'
                            local Owner = Properties:FindFirstChild 'Owner'
                            local Money = Properties:FindFirstChild 'CurrentPrinted'

                            if Main and Owner and Money then
                                local M = tostring(Money.Value)
                                local O = Owner.Value and tostring(Owner.Value) or 'No One'

                                pcall(
                                    RenderList.AddOrUpdateInstance,
                                    RenderList,
                                    v,
                                    Main,
                                    Format('[%s]\n[Owned By %s] [$%s]', v.Name, O, M),
                                    CustomColor
                                )
                            end
                        end
                    end
                end
            end
        end
    },
    [4671157242] = {
        CustomPlayerTag = function(Player)
            local Name = ''
            local Stats = Player:FindFirstChild 'leaderstats'

            if Stats then
                local Rank = Stats:FindFirstChild 'Rank'
                local Spree = Stats:FindFirstChild 'Spree'

                if Rank and Spree then
                    Name = Format('\n[%s] [Spree: %s]', Rank.Value, Spree.Value)
                end
            end

            return Name
        end
    },
    [1458767429] = {
        CustomPlayerTag = function(Player)
            local Name = '\n'

            local CDs = {}
            local Moves = {}
            local Backpack = Player:FindFirstChild 'Backpack'

            if Backpack then
                for i, v in pairs(Backpack:GetChildren()) do
                    if v:IsA 'BackpackItem' then
                        TInsert(Moves, v)
                    end
                end
            end

            if #Moves > 0 then
                for i, v in pairs(Moves) do
                    local Cooldown = v:FindFirstChild 'CD'

                    if Cooldown then
                        TInsert(CDs, Format('[%s | %s/20]', v.Name, Cooldown.Value))
                    end
                end
            end

            if #CDs > 0 then
                Name = Name .. TConcat(CDs, ' ')
            end

            return Name
        end
    },
    [9187108855] = {
        CustomESP = function()
            local Living = Workspace:FindFirstChild 'Alive'
            local Player = {}

            for i, v in pairs(Players:GetPlayers()) do
                if v.Character then
                    TInsert(Player, v.Character)
                end
            end

            if Living then
                for i, v in pairs(Living:GetChildren()) do
                    if not TFind(Player, v) then
                        local Main = v:FindFirstChild 'HumanoidRootPart'
                        local Hum = v:FindFirstChild 'Humanoid'
                        local Tag = ''

                        if not Find(v.Name, 'Trainee') then
                            Tag = GSub(v.Name, '%d+', '')
                        end

                        if Main and Hum then
                            pcall(
                                RenderList.AddOrUpdateInstance,
                                RenderList,
                                v,
                                Main,
                                Format('[%s] [%s/%s]', Tag, math.floor(Hum.Health), Hum.MaxHealth),
                                CustomColor
                            )
                        end
                    end
                end
            end
        end,
        CustomPlayerTag = function(Player)
            local Name = ''
            local Character = GetCharacter(Player)

            if Character then
                local Reiatsu = Character:FindFirstChild 'Reiatsu'

                if Reiatsu then
                    Name = Format('\n[%s]', Reiatsu.Value)
                end
            end

            return Name
        end
    },
    [8860321655] = {
        CustomESP = function()
            local Living = Workspace:FindFirstChild 'Alive'
            local Player = {}

            for i, v in pairs(Players:GetPlayers()) do
                if v.Character then
                    TInsert(Player, v.Character)
                end
            end

            if Living then
                for i, v in pairs(Living:GetChildren()) do
                    if not TFind(Player, v) then
                        local Main = v:FindFirstChild 'HumanoidRootPart'
                        local Hum = v:FindFirstChild 'Humanoid'
                        local Tag = ''

                        if not Find(v.Name, 'Trainee') then
                            Tag = GSub(v.Name, '%d+', '')
                        end

                        if Main and Hum then
                            pcall(
                                RenderList.AddOrUpdateInstance,
                                RenderList,
                                v,
                                Main,
                                Format('[%s] [%s/%s]', Tag, math.floor(Hum.Health), Hum.MaxHealth),
                                CustomColor
                            )
                        end
                    end
                end
            end
        end,
        CustomPlayerTag = function(Player)
            local Name = ''
            local Character = GetCharacter(Player)

            if Character then
                local Reiatsu = Character:FindFirstChild 'Reiatsu'

                if Reiatsu then
                    Name = Format('\n[%s]', Reiatsu.Value)
                end
            end

            return Name
        end
    },
    [7056922815] = {
        CustomESP = function()
            local Living = Workspace:FindFirstChild 'Living'
            local Player = {}

            for i, v in pairs(Players:GetPlayers()) do
                if v.Character then
                    TInsert(Player, v.Character)
                end
            end

            if Living then
                for i, v in pairs(Living:GetChildren()) do
                    if not TFind(Player, v) then
                        local Main = v:FindFirstChild 'HumanoidRootPart'
                        local Hum = v:FindFirstChild 'Humanoid'

                        if Main and Hum then
                            pcall(
                                RenderList.AddOrUpdateInstance,
                                RenderList,
                                v,
                                Main,
                                Format('[%s] [%s/%s]', v.Name, math.floor(Hum.Health), Hum.MaxHealth),
                                CustomColor
                            )
                        end
                    end
                end
            end
        end,
        CustomPlayerTag = function(Player)
            local Name = ''
            local Stats = Player:FindFirstChild 'Status'

            if Stats then
                local Reiatsu = Stats:FindFirstChild 'Reiatsu'
                local MaxReiatsu = Stats:FindFirstChild 'MaxReiatsu'

                if Reiatsu and MaxReiatsu then
                    Name = Format('\n[%s/%s]', Reiatsu.Value, MaxReiatsu.Value)
                end
            end

            return Name
        end
    },
    [8934886191] = {
        CustomESP = function()
            local Living = Workspace:FindFirstChild 'Living'
            local Player = {}

            for i, v in pairs(Players:GetPlayers()) do
                if v.Character then
                    TInsert(Player, v.Character)
                end
            end

            if Living then
                for i, v in pairs(Living:GetChildren()) do
                    if not TFind(Player, v) then
                        local Main = v:FindFirstChild 'HumanoidRootPart'
                        local Hum = v:FindFirstChild 'Humanoid'

                        if Main and Hum then
                            pcall(
                                RenderList.AddOrUpdateInstance,
                                RenderList,
                                v,
                                Main,
                                Format('[%s] [%s/%s]', v.Name, math.floor(Hum.Health), Hum.MaxHealth),
                                CustomColor
                            )
                        end
                    end
                end
            end
        end,
        CustomPlayerTag = function(Player)
            local Name = ''
            local Stats = Player:FindFirstChild 'Status'

            if Stats then
                local Reiatsu = Stats:FindFirstChild 'Reiatsu'
                local MaxReiatsu = Stats:FindFirstChild 'MaxReiatsu'

                if Reiatsu and MaxReiatsu then
                    Name = Format('\n[%s/%s]', Reiatsu.Value, MaxReiatsu.Value)
                end
            end

            return Name
        end
    },
    [7719700868] = {
        CustomPlayerTag = function(Player)
            local Name = ''
            local Stats = Player:FindFirstChild 'leaderstats'

            local Specs = {}
            local Place = {}

            if Stats then
                local FirstName = Stats:FindFirstChild 'FirstName'
                local LastName = Stats:FindFirstChild 'LastName'

                if FirstName then
                    Name = FirstName.Value

                    if LastName then
                        Name = GSub(Format('%s %s', FirstName.Value, LastName.Value), '%s+$', '')
                    end

                    if Find(Name, utf8.char(8217)) then
                        Name = GSub(Name, utf8.char(8217), '\'')
                    end

                    Name = Format('\n[%s]', Name)
                end

                if not IsStringEmpty(Name) then
                    local Race = Stats:FindFirstChild 'Race'
                    local Class = Stats:FindFirstChild 'Class'
                    local Faction = Stats:FindFirstChild 'Faction'

                    local Planet = Stats:FindFirstChild 'Planet'
                    local Area = Stats:FindFirstChild 'Area'

                    if Race then
                        if not IsStringEmpty(Race.Value) then
                            TInsert(Specs, Race.Value)
                        end
                    end
                    if Class then
                        if not IsStringEmpty(Class.Value) then
                            TInsert(Specs, Class.Value)
                        end
                    end
                    if Faction then
                        if not IsStringEmpty(Faction.Value) then
                            TInsert(Specs, Faction.Value)
                        end
                    end

                    if Planet then
                        if not IsStringEmpty(Planet.Value) then
                            TInsert(Place, Planet.Value)

                            if Area then
                                if not IsStringEmpty(Area.Value) then
                                    TInsert(Place, Area.Value)
                                end
                            end
                        end
                    end
                end
            end

            if #Specs > 0 then
                Name = Name .. Format('\n[%s]', TConcat(Specs, '-'))
            end

            if #Place > 0 then
                Name = Name .. Format(' [%s]', TConcat(Place, '-'))
            end

            return Name
        end
    },
    [5208655184] = {
        CustomPlayerTag = function(Player)
            if game.PlaceVersion < 457 then
                return ''
            end

            local Name = ''
            local FirstName = Player:GetAttribute 'FirstName'

            if type(FirstName) == 'string' and #FirstName > 0 then
                local Prefix = ''
                local Extra = {}
                Name = Name .. '\n['

                if Player:GetAttribute 'Prestige' > 0 then
                    Name = Name .. '#' .. tostring(Player:GetAttribute 'Prestige') .. ' '
                end
                if not IsStringEmpty(Player:GetAttribute 'HouseRank') then
                    Prefix =
                        Player:GetAttribute 'HouseRank' == 'Owner' and
                        (Player:GetAttribute 'Gender' == 'Female' and 'Lady ' or 'Lord ') or
                        ''
                end
                if not IsStringEmpty(FirstName) then
                    Name = Name .. '' .. Prefix .. FirstName
                end
                if not IsStringEmpty(Player:GetAttribute 'LastName') then
                    Name = Name .. ' ' .. Player:GetAttribute 'LastName'
                end

                if not IsStringEmpty(Name) then
                    Name = Name .. ']'
                end

                local Character = GetCharacter(Player)

                if Character then
                    if Character and Character:FindFirstChild 'Danger' then
                        TInsert(Extra, 'D')
                    end
                    if Character:FindFirstChild 'ManaAbilities' and Character.ManaAbilities:FindFirstChild 'ManaSprint' then
                        TInsert(Extra, 'D1')
                    end

                    if Character:FindFirstChild 'Mana' then
                        TInsert(Extra, 'M' .. math.floor(Character.Mana.Value))
                    end
                    if Character:FindFirstChild 'Vampirism' then
                        TInsert(Extra, 'V')
                    end
                    if Character:FindFirstChild 'Observe' then
                        TInsert(Extra, 'ILL')
                    end
                    if Character:FindFirstChild 'Inferi' then
                        TInsert(Extra, 'NEC')
                    end
                    if Character:FindFirstChild 'World\'s Pulse' then
                        TInsert(Extra, 'DZIN')
                    end
                    if Character:FindFirstChild 'Shift' then
                        TInsert(Extra, 'MAD')
                    end
                    if Character:FindFirstChild 'Head' and Character.Head:FindFirstChild 'FacialMarking' then
                        local FM = Character.Head:FindFirstChild 'FacialMarking'
                        if FM.Texture == 'http://www.roblox.com/asset/?id=4072968006' then
                            TInsert(Extra, 'HEALER')
                        elseif FM.Texture == 'http://www.roblox.com/asset/?id=4072914434' then
                            TInsert(Extra, 'SEER')
                        elseif FM.Texture == 'http://www.roblox.com/asset/?id=4094417635' then
                            TInsert(Extra, 'JESTER')
                        elseif FM.Texture == 'http://www.roblox.com/asset/?id=4072968656' then
                            TInsert(Extra, 'BLADE')
                        end
                    end
                end
                if Player:FindFirstChild 'Backpack' then
                    if Player.Backpack:FindFirstChild 'Observe' then
                        TInsert(Extra, 'ILL')
                    end
                    if Player.Backpack:FindFirstChild 'Inferi' then
                        TInsert(Extra, 'NEC')
                    end
                    if Player.Backpack:FindFirstChild 'World\'s Pulse' then
                        TInsert(Extra, 'DZIN')
                    end
                    if Player.Backpack:FindFirstChild 'Shift' then
                        TInsert(Extra, 'MAD')
                    end
                end

                if #Extra > 0 then
                    Name = Name .. ' [' .. TConcat(Extra, '-') .. ']'
                end
            end

            return Name
        end
    },
    [3541987450] = {
        CustomPlayerTag = function(Player)
            local Name = ''

            if Player:FindFirstChild 'leaderstats' then
                Name = Name .. '\n['
                local Prefix = ''
                local Extra = {}
                if
                    Player.leaderstats:FindFirstChild 'Prestige' and Player.leaderstats.Prestige.ClassName == 'IntValue' and
                        Player.leaderstats.Prestige.Value > 0
                 then
                    Name = Name .. '#' .. tostring(Player.leaderstats.Prestige.Value) .. ' '
                end
                if
                    Player.leaderstats:FindFirstChild 'HouseRank' and Player.leaderstats:FindFirstChild 'Gender' and
                        Player.leaderstats.HouseRank.ClassName == 'StringValue' and
                        not IsStringEmpty(Player.leaderstats.HouseRank.Value)
                 then
                    Prefix =
                        Player.leaderstats.HouseRank.Value == 'Owner' and
                        (Player.leaderstats.Gender.Value == 'Female' and 'Lady ' or 'Lord ') or
                        ''
                end
                if
                    Player.leaderstats:FindFirstChild 'FirstName' and
                        Player.leaderstats.FirstName.ClassName == 'StringValue' and
                        not IsStringEmpty(Player.leaderstats.FirstName.Value)
                 then
                    Name = Name .. '' .. Prefix .. Player.leaderstats.FirstName.Value
                end
                if
                    Player.leaderstats:FindFirstChild 'LastName' and
                        Player.leaderstats.LastName.ClassName == 'StringValue' and
                        not IsStringEmpty(Player.leaderstats.LastName.Value)
                 then
                    Name = Name .. ' ' .. Player.leaderstats.LastName.Value
                end
                if
                    Player.leaderstats:FindFirstChild 'UberTitle' and
                        Player.leaderstats.UberTitle.ClassName == 'StringValue' and
                        not IsStringEmpty(Player.leaderstats.UberTitle.Value)
                 then
                    Name = Name .. ', ' .. Player.leaderstats.UberTitle.Value
                end

                if not IsStringEmpty(Name) then
                    Name = Name .. ']'
                end

                local Character = GetCharacter(Player)

                if Character then
                    if Character and Character:FindFirstChild 'Danger' then
                        TInsert(Extra, 'D')
                    end
                    if Character:FindFirstChild 'ManaAbilities' and Character.ManaAbilities:FindFirstChild 'ManaSprint' then
                        TInsert(Extra, 'D1')
                    end

                    if Character:FindFirstChild 'Mana' then
                        TInsert(Extra, 'M' .. math.floor(Character.Mana.Value))
                    end
                    if Character:FindFirstChild 'Vampirism' then
                        TInsert(Extra, 'V')
                    end
                    if Character:FindFirstChild 'Observe' then
                        TInsert(Extra, 'ILL')
                    end
                    if Character:FindFirstChild 'Inferi' then
                        TInsert(Extra, 'NEC')
                    end

                    if Character:FindFirstChild 'World\'s Pulse' then
                        TInsert(Extra, 'DZIN')
                    end
                    if Character:FindFirstChild 'Head' and Character.Head:FindFirstChild 'FacialMarking' then
                        local FM = Character.Head:FindFirstChild 'FacialMarking'
                        if FM.Texture == 'http://www.roblox.com/asset/?id=4072968006' then
                            TInsert(Extra, 'HEALER')
                        elseif FM.Texture == 'http://www.roblox.com/asset/?id=4072914434' then
                            TInsert(Extra, 'SEER')
                        elseif FM.Texture == 'http://www.roblox.com/asset/?id=4094417635' then
                            TInsert(Extra, 'JESTER')
                        end
                    end
                end
                if Player:FindFirstChild 'Backpack' then
                    if Player.Backpack:FindFirstChild 'Observe' then
                        TInsert(Extra, 'ILL')
                    end
                    if Player.Backpack:FindFirstChild 'Inferi' then
                        TInsert(Extra, 'NEC')
                    end
                    if Player.Backpack:FindFirstChild 'World\'s Pulse' then
                        TInsert(Extra, 'DZIN')
                    end
                end

                if #Extra > 0 then
                    Name = Name .. ' [' .. TConcat(Extra, '-') .. ']'
                end
            end

            return Name
        end
    },
    [9530846958] = {
        CustomPlayerTag = function(Player)
            local Name = ''
            local Data = Player:FindFirstChild 'Data'
            local Location = Player:FindFirstChild 'Location'

            local Specs = {}
            local Place = {}

            if Data then
                local FullName = Data:FindFirstChild 'oName'

                if FullName then
                    Name = Format('\n[%s]', GSub(FullName.Value, '%s+$', ''))
                end

                if not IsStringEmpty(Name) then
                    local Race = Data:FindFirstChild 'Race'
                    local Class = Data:FindFirstChild 'Class'
                    local Artifact = Data:FindFirstChild 'Artifact'

                    if Race then
                        TInsert(Specs, Race.Value)
                    end
                    if Class then
                        TInsert(Specs, Class.Value)
                    end
                    if Artifact then
                        if Artifact.Value ~= 'N/A' then
                            TInsert(Specs, Artifact.Value)
                        end
                    end

                    if Location then
                        TInsert(Place, Location.Value)
                    end
                end
            end

            if #Specs > 0 then
                Name = Name .. Format('\n[%s]', TConcat(Specs, '-'))
            end

            if #Place > 0 then
                Name = Name .. Format(' [%s]', TConcat(Place, '-'))
            end

            return Name
        end
    },
    [4691401390] = {
        CustomCharacter = function(Player)
            if Workspace:FindFirstChild 'Players' then
                return Workspace.Players:FindFirstChild(Player.Name)
            end
        end
    },
    [6032399813] = {
        CustomPlayerTag = function(Player)
            local Name = ''
            CharacterName = Player:GetAttribute 'CharacterName'

            if not IsStringEmpty(CharacterName) then
                Name = Format('\n[%s]', CharacterName)
                local Character = GetCharacter(Player)
                local Extra = {}

                if Character then
                    local Blood = Character:FindFirstChild 'Blood'
                    local Armor = Character:FindFirstChild 'Armor'

                    if Blood and Blood.ClassName == 'DoubleConstrainedValue' then
                        TInsert(Extra, Format('B%d', Blood.Value))
                    end

                    if Armor and Armor.ClassName == 'DoubleConstrainedValue' then
                        TInsert(Extra, Format('A%d', math.floor(Armor.Value / 10)))
                    end
                end

                local BackpackChildren = Player.Backpack:GetChildren()

                for index = 1, #BackpackChildren do
                    local Oath = BackpackChildren[index]
                    if Oath.ClassName == 'Folder' and Find(Oath.Name, 'Talent:Oath') then
                        local OathName = GSub(Oath.Name, 'Talent:Oath ', '')
                        TInsert(Extra, OathName)
                    end
                end

                if #Extra > 0 then
                    Name = Name .. ' [' .. TConcat(Extra, '-') .. ']'
                end
            end

            return Name
        end
    },
    [5735553160] = {
        CustomPlayerTag = function(Player)
            local Name = ''
            CharacterName = Player:GetAttribute 'CharacterName'

            if not IsStringEmpty(CharacterName) then
                Name = Format('\n[%s]', CharacterName)
                local Character = GetCharacter(Player)
                local Extra = {}

                if Character then
                    local Blood = Character:FindFirstChild 'Blood'
                    local Armor = Character:FindFirstChild 'Armor'

                    if Blood and Blood.ClassName == 'DoubleConstrainedValue' then
                        TInsert(Extra, Format('B%d', Blood.Value))
                    end

                    if Armor and Armor.ClassName == 'DoubleConstrainedValue' then
                        TInsert(Extra, Format('A%d', math.floor(Armor.Value / 10)))
                    end
                end

                local BackpackChildren = Player.Backpack:GetChildren()

                for index = 1, #BackpackChildren do
                    local Oath = BackpackChildren[index]
                    if Oath.ClassName == 'Folder' and Find(Oath.Name, 'Talent:Oath') then
                        local OathName = GSub(Oath.Name, 'Talent:Oath ', '')
                        TInsert(Extra, OathName)
                    end
                end

                if #Extra > 0 then
                    Name = Name .. ' [' .. TConcat(Extra, '-') .. ']'
                end
            end

            return Name
        end
    }
}

if Modules[game.PlaceId] ~= nil then
    local Module = Modules[game.PlaceId]
    CustomPlayerTag = Module.CustomPlayerTag or nil
    CustomESP = Module.CustomESP or nil
    CustomCharacter = Module.CustomCharacter or nil
    GetHealth = Module.GetHealth or nil
    GetAliveState = Module.GetAliveState or nil
    CustomRootPartName = Module.CustomRootPartName or nil
end

function GetCharacter(Player)
    return Player.Character or (CustomCharacter and CustomCharacter(Player))
end

local function MouseHoveringOver(Values)
    local X1, Y1, X2, Y2 = Values[1], Values[2], Values[3], Values[4]
    local MLocation = GetMouseLocation(UserInputService)
    return (MLocation.X >= X1 and MLocation.X <= (X1 + (X2 - X1))) and
        (MLocation.Y >= Y1 and MLocation.Y <= (Y1 + (Y2 - Y1)))
end

local function GetTableData(t)
    if type(t) ~= 'table' then
        return
    end

    return setmetatable(
        t,
        {
            __call = function(t, func)
                if type(func) ~= 'function' then
                    return
                end
                for i, v in pairs(t) do
                    func(i, v)
                end
            end
        }
    )
end

local function CalculateValue(Min, Max, Percent)
    return Min + math.floor(((Max - Min) * Percent) + .5)
end

local function NewDrawing(InstanceName)
    local Instance = Drawing.new(InstanceName)
    return (function(Properties)
        for i, v in pairs(Properties) do
            Instance[i] = v
        end
        return Instance
    end)
end

function Menu:AddMenuInstance(Name, DrawingType, Properties)
    local Instance

    if shared.MenuDrawingData.Instances[Name] ~= nil then
        Instance = shared.MenuDrawingData.Instances[Name]
        for i, v in pairs(Properties) do
            Instance[i] = v
        end
    else
        Instance = NewDrawing(DrawingType)(Properties)
    end

    shared.MenuDrawingData.Instances[Name] = Instance

    return Instance
end

function Menu:UpdateMenuInstance(Name)
    local Instance = shared.MenuDrawingData.Instances[Name]
    if Instance ~= nil then
        return (function(Properties)
            for i, v in pairs(Properties) do
                Instance[i] = v
            end
            return Instance
        end)
    end
end

function Menu:GetInstance(Name)
    return shared.MenuDrawingData.Instances[Name]
end

local Options =
    setmetatable(
    {},
    {
        __call = function(t, ...)
            local Arguments = {...}
            local Name = Arguments[1]
            OIndex = OIndex + 1
            rawset(
                t,
                Name,
                setmetatable(
                    {
                        Name = Arguments[1],
                        Text = Arguments[2],
                        Value = Arguments[3],
                        DefaultValue = Arguments[3],
                        AllArgs = Arguments,
                        Index = OIndex
                    },
                    {
                        __call = function(t, v, force)
                            local self = t

                            if type(t.Value) == 'function' then
                                t.Value()
                            elseif typeof(t.Value) == 'EnumItem' then
                                local BT = Menu:GetInstance(Format('%s_BindText', t.Name))
                                if not force then
                                    Binding = true
                                    local Val = 0
                                    while Binding do
                                        task.wait()
                                        Val = (Val + 1) % 17
                                        BT.Text = Val <= 8 and '|' or ''
                                    end
                                end
                                t.Value = force and v or BindedKey
                                if BT and t.BasePosition and t.BaseSize then
                                    BT.Text = Match(tostring(t.Value), '%w+%.%w+%.(.+)')
                                    BT.Position = t.BasePosition + V2New(t.BaseSize.X - BT.TextBounds.X - 20, -10)
                                end
                            else
                                local NewValue = v
                                if NewValue == nil then
                                    NewValue = not t.Value
                                end
                                rawset(t, 'Value', NewValue)

                                if Arguments[2] ~= nil and Menu:GetInstance 'TopBar'.Visible then
                                    if type(Arguments[3]) == 'number' then
                                        local AMT = Menu:GetInstance(Format('%s_AmountText', t.Name))
                                        if AMT then
                                            AMT.Text = tostring(t.Value)
                                        end
                                    else
                                        local Inner = Menu:GetInstance(Format('%s_InnerCircle', t.Name))
                                        if Inner then
                                            Inner.Visible = t.Value
                                        end
                                    end
                                end
                            end
                        end
                    }
                )
            )
        end
    }
)

local function Load()
    local _, Result = pcall(readfile, OptionsFile)

    if _ then
        local _, Table = pcall(HttpService.JSONDecode, HttpService, Result)
        if _ and type(Table) == 'table' then
            for i, v in pairs(Table) do
                if
                    type(Options[i]) == 'table' and Options[i].Value ~= nil and
                        (type(Options[i].Value) == 'boolean' or type(Options[i].Value) == 'number')
                 then
                    Options[i].Value = v.Value
                    pcall(Options[i], v.Value)
                end
            end

            if Table.TeamColor then
                TeamColor = C3New(Table.TeamColor.R, Table.TeamColor.G, Table.TeamColor.B)
            end
            if Table.EnemyColor then
                EnemyColor = C3New(Table.EnemyColor.R, Table.EnemyColor.G, Table.EnemyColor.B)
            end
            if Table.CustomColor then
                CustomColor = C3New(Table.CustomColor.R, Table.CustomColor.G, Table.CustomColor.B)
            end

            if type(Table.MenuKey) == 'string' then
                Options.MenuKey(Enum.KeyCode[Table.MenuKey], true)
            end
            if type(Table.ToggleKey) == 'string' then
                Options.ToggleKey(Enum.KeyCode[Table.ToggleKey], true)
            end
        end
    end
end

Options('Enabled', 'ESP Enabled', true)
Options('ShowTeam', 'Show Team', true)
Options('ShowTeamColor', 'Show Team Color', false)
Options('ShowName', 'Show Names', true)
Options('ShowDisplay', 'Show Displays', false)
Options('ShowDistance', 'Show Distance', true)
Options('ShowHealth', 'Show Health', true)
Options('ShowBoxes', 'Show Boxes', true)
Options('ShowTracers', 'Show Tracers', true)
Options('ShowArrows', 'Show FOV Arrows', false)
Options('Show2DBox', 'Show Dynamic Boxes', false)
Options('ShowDot', 'Show Head Dot', false)
Options('VisCheck', 'Visibility Check', false)
Options('Crosshair', 'Crosshair', false)
Options('TextOutline', 'Text Outline', true)
Options('MaxDistance', 'Max Distance', 10000, 100, 100000)
Options('TextSize', 'Text Size', syn and 18 or 14, 10, 24)
Options('RefreshRate', 'Refresh Rate (ms)', 5, 1, 200)
Options('YOffset', 'Y Offset', 0, -200, 200)
Options('MenuKey', 'Menu Key', Enum.KeyCode.F4, 1)
Options('ToggleKey', 'Toggle Key', Enum.KeyCode.F3, 1)
Options(
    'ChangeColors',
    'Change Colors',
    function()
        SubMenu:Show(
            GetMouseLocation(UserInputService),
            V2New(200, 165),
            'Unnamed Colors',
            {
                {
                    Type = 'Color',
                    Text = 'Team Color',
                    Color = TeamColor,
                    Function = function(Circ, Position)
                        if tick() - ColorPicker.LastGenerated < 1 then
                            return
                        end

                        if shared.CurrentColorPicker then
                            shared.CurrentColorPicker:Dispose()
                        end
                        local ColorPicker = ColorPicker.new(Position - V2New(-10, 50))
                        CurrentColorPicker = ColorPicker
                        shared.CurrentColorPicker = CurrentColorPicker
                        ColorPicker.ColorChanged:Connect(
                            function(Color)
                                Circ.Color = Color
                                TeamColor = Color
                                Options.TeamColor = Color
                            end
                        )
                    end
                },
                {
                    Type = 'Color',
                    Text = 'Enemy Color',
                    Color = EnemyColor,
                    Function = function(Circ, Position)
                        if tick() - ColorPicker.LastGenerated < 1 then
                            return
                        end

                        if shared.CurrentColorPicker then
                            shared.CurrentColorPicker:Dispose()
                        end
                        local ColorPicker = ColorPicker.new(Position - V2New(-10, 50))
                        CurrentColorPicker = ColorPicker
                        shared.CurrentColorPicker = CurrentColorPicker
                        ColorPicker.ColorChanged:Connect(
                            function(Color)
                                Circ.Color = Color
                                EnemyColor = Color
                                Options.EnemyColor = Color
                            end
                        )
                    end
                },
                {
                    Type = 'Color',
                    Text = 'Custom Color',
                    Color = CustomColor,
                    Function = function(Circ, Position)
                        if tick() - ColorPicker.LastGenerated < 1 then
                            return
                        end

                        if shared.CurrentColorPicker then
                            shared.CurrentColorPicker:Dispose()
                        end
                        local ColorPicker = ColorPicker.new(Position - V2New(-10, 50))
                        CurrentColorPicker = ColorPicker
                        shared.CurrentColorPicker = CurrentColorPicker
                        ColorPicker.ColorChanged:Connect(
                            function(Color)
                                Circ.Color = Color
                                CustomColor = Color
                                Options.CustomColor = Color
                            end
                        )
                    end
                },
                {
                    Type = 'Button',
                    Text = 'Reset Colors',
                    Function = function()
                        EnemyColor = C3New(1, 0, 0)
                        TeamColor = C3New(0, 1, 0)

                        local C1 = Menu:GetInstance 'Sub-ColorPreview.1'
                        if C1 then
                            C1.Color = TeamColor
                        end
                        local C2 = Menu:GetInstance 'Sub-ColorPreview.2'
                        if C2 then
                            C2.Color = EnemyColor
                        end
                    end
                },
                {
                    Type = 'Button',
                    Text = 'Rainbow Mode',
                    Function = function()
                        Rainbow = not Rainbow
                    end
                }
            }
        )
    end,
    2
)
Options(
    'ChangeFonts',
    'Change Fonts',
    function()
        SubMenu:Show(
            GetMouseLocation(UserInputService),
            V2New(200, 140),
            'Unnamed Fonts',
            {
                {
                    Type = 'Button',
                    Text = 'UI',
                    Function = function()
                        Font = 0
                    end
                },
                {
                    Type = 'Button',
                    Text = 'System',
                    Function = function()
                        Font = 1
                    end
                },
                {
                    Type = 'Button',
                    Text = 'Plex',
                    Function = function()
                        Font = 2
                    end
                },
                {
                    Type = 'Button',
                    Text = 'Monospace',
                    Function = function()
                        Font = 3
                    end
                }
            }
        )
    end,
    3
)
Options(
    'ResetSettings',
    'Reset Settings',
    function()
        for i, v in pairs(Options) do
            if
                Options[i] ~= nil and Options[i].Value ~= nil and Options[i].Text ~= nil and
                    (type(Options[i].Value) == 'boolean' or type(Options[i].Value) == 'number' or
                        typeof(Options[i].Value) == 'EnumItem')
             then
                Options[i](Options[i].DefaultValue, true)
            end
        end
    end,
    6
)
Options('LoadSettings', 'Load Settings', Load, 5)
Options(
    'SaveSettings',
    'Save Settings',
    function()
        local COptions = {}

        for i, v in pairs(Options) do
            COptions[i] = v
        end

        if typeof(TeamColor) == 'Color3' then
            COptions.TeamColor = {R = TeamColor.R, G = TeamColor.G, B = TeamColor.B}
        end
        if typeof(EnemyColor) == 'Color3' then
            COptions.EnemyColor = {R = EnemyColor.R, G = EnemyColor.G, B = EnemyColor.B}
        end
        if typeof(CustomColor) == 'Color3' then
            COptions.CustomColor = {R = CustomColor.R, G = CustomColor.G, B = CustomColor.B}
        end

        if typeof(COptions.MenuKey.Value) == 'EnumItem' then
            COptions.MenuKey = COptions.MenuKey.Value.Name
        end
        if typeof(COptions.ToggleKey.Value) == 'EnumItem' then
            COptions.ToggleKey = COptions.ToggleKey.Value.Name
        end

        writefile(OptionsFile, HttpService:JSONEncode(COptions))
    end,
    4
)

Load(1)

Options('MenuOpen', nil, true)

local function Combine(...)
    local Output = {}
    for i, v in pairs {...} do
        if type(v) == 'table' then
            table.foreach(
                v,
                function(i, v)
                    Output[i] = v
                end
            )
        end
    end
    return Output
end

function LineBox:Create(Properties)
    local Box = {Visible = true}

    local Properties =
        Combine(
        {
            Transparency = 1,
            Thickness = 3,
            Visible = true
        },
        Properties
    )

    Box['OutlineSquare'] = NewDrawing 'Square'(Properties)
    Box['Square'] = NewDrawing 'Square'(Properties)

    if QUAD_SUPPORTED_EXPLOIT then
        Box['Quad'] = NewDrawing 'Quad'(Properties)
    else
        Box['TopLeft'] = NewDrawing 'Line'(Properties)
        Box['TopRight'] = NewDrawing 'Line'(Properties)
        Box['BottomLeft'] = NewDrawing 'Line'(Properties)
        Box['BottomRight'] = NewDrawing 'Line'(Properties)
    end

    local TL = Box['TopLeft']
    local TR = Box['TopRight']
    local BL = Box['BottomLeft']
    local BR = Box['BottomRight']

    local Quad = Box['Quad']
    local Square = Box['Square']
    local Outline = Box['OutlineSquare']

    function Box:Update(CF, Size, Color, Properties, Parts)
        if not CF or not Size then
            return
        end

        if Options.Show2DBox.Value and type(Parts) == 'table' then
            local AllCorners = {}

            if Quad then
                if Quad.Visible then
                    Quad.Visible = false
                end
            end
            if TL and TR and BL and BR then
                if TL.Visible or TR.Visible or BL.Visible or BR.Visible then
                    TL.Visible = false
                    TR.Visible = false
                    BL.Visible = false
                    BR.Visible = false
                end
            end

            for i, v in pairs(Parts) do
                local CF, Size = v.CFrame, v.Size
                local Corners = {
                    V3New(CF.X + Size.X / 2, CF.Y + Size.Y / 2, CF.Z + Size.Z / 2),
                    V3New(CF.X - Size.X / 2, CF.Y + Size.Y / 2, CF.Z + Size.Z / 2),
                    V3New(CF.X - Size.X / 2, CF.Y - Size.Y / 2, CF.Z - Size.Z / 2),
                    V3New(CF.X + Size.X / 2, CF.Y - Size.Y / 2, CF.Z - Size.Z / 2),
                    V3New(CF.X - Size.X / 2, CF.Y + Size.Y / 2, CF.Z - Size.Z / 2),
                    V3New(CF.X + Size.X / 2, CF.Y + Size.Y / 2, CF.Z - Size.Z / 2),
                    V3New(CF.X - Size.X / 2, CF.Y - Size.Y / 2, CF.Z + Size.Z / 2),
                    V3New(CF.X + Size.X / 2, CF.Y - Size.Y / 2, CF.Z + Size.Z / 2)
                }

                for i, v in pairs(Corners) do
                    TInsert(AllCorners, v)
                end
            end

            local xMin, yMin = Camera.ViewportSize.X, Camera.ViewportSize.Y
            local xMax, yMax = 0, 0
            local Vs = true

            for i, v in pairs(AllCorners) do
                local Position, V = WorldToViewport(v)

                if Vs and not V then
                    Vs = false
                    break
                end

                if Position.X > xMax then
                    xMax = Position.X
                end
                if Position.X < xMin then
                    xMin = Position.X
                end
                if Position.Y > yMax then
                    yMax = Position.Y
                end
                if Position.Y < yMin then
                    yMin = Position.Y
                end
            end

            local xSize, ySize = xMax - xMin, yMax - yMin

            Square.Visible = Vs
            Square.Color = Color
            Square.Thickness = 1
            Square.Position = V2New(xMin, yMin)
            Square.Size = V2New(xSize, ySize)

            Outline.Visible = Vs
            Outline.Color = C3New(0.12, 0.12, 0.12)
            Outline.Transparency = 0.75
            Outline.Position = Square.Position
            Outline.Size = Square.Size

            return
        end

        if Square and Outline then
            if Square.Visible and Outline.Visible then
                Square.Visible = false
                Outline.Visible = false
            end
        end

        local TLPos, Visible1 = WorldToViewport((CF * CFNew(Size.X, Size.Y, 0)).Position)
        local TRPos, Visible2 = WorldToViewport((CF * CFNew(-Size.X, Size.Y, 0)).Position)
        local BLPos, Visible3 = WorldToViewport((CF * CFNew(Size.X, -Size.Y, 0)).Position)
        local BRPos, Visible4 = WorldToViewport((CF * CFNew(-Size.X, -Size.Y, 0)).Position)

        if QUAD_SUPPORTED_EXPLOIT then
            if Visible1 and Visible2 and Visible3 and Visible4 then
                Quad.Visible = true
                Quad.Color = Color
                Quad.PointA = V2New(TLPos.X, TLPos.Y)
                Quad.PointB = V2New(TRPos.X, TRPos.Y)
                Quad.PointC = V2New(BRPos.X, BRPos.Y)
                Quad.PointD = V2New(BLPos.X, BLPos.Y)
            else
                Quad.Visible = false
            end
        else
            Visible1 = TLPos.Z > 0
            Visible2 = TRPos.Z > 0
            Visible3 = BLPos.Z > 0
            Visible4 = BRPos.Z > 0

            if Visible1 then
                TL.Visible = true
                TL.Color = Color
                TL.From = V2New(TLPos.X, TLPos.Y)
                TL.To = V2New(TRPos.X, TRPos.Y)
            else
                TL.Visible = false
            end
            if Visible2 then
                TR.Visible = true
                TR.Color = Color
                TR.From = V2New(TRPos.X, TRPos.Y)
                TR.To = V2New(BRPos.X, BRPos.Y)
            else
                TR.Visible = false
            end
            if Visible3 then
                BL.Visible = true
                BL.Color = Color
                BL.From = V2New(BLPos.X, BLPos.Y)
                BL.To = V2New(TLPos.X, TLPos.Y)
            else
                BL.Visible = false
            end
            if Visible4 then
                BR.Visible = true
                BR.Color = Color
                BR.From = V2New(BRPos.X, BRPos.Y)
                BR.To = V2New(BLPos.X, BLPos.Y)
            else
                BR.Visible = false
            end
            if Properties and type(Properties) == 'table' then
                GetTableData(Properties)(
                    function(i, v)
                        TL[i] = v
                        TR[i] = v
                        BL[i] = v
                        BR[i] = v
                    end
                )
            end
        end
    end
    function Box:SetVisible(Boolean)
        for i, v in pairs(self) do
            if type(v) == 'table' and v.Visible then
                v.Visible = Boolean
            end
        end
    end
    function Box:Remove()
        self:SetVisible(false)
        for i, v in pairs(self) do
            if type(v) == 'table' then
                v:Remove()
            end
        end
    end

    return Box
end

local Colors = {
    White = Color3.fromHex('FFFFFF'),
    Primary = {
        Main = Color3.fromHex('424242'),
        Light = Color3.fromHex('6D6D6D'),
        Dark = Color3.fromHex('1B1B1B')
    },
    Secondary = {
        Main = Color3.fromHex('E0E0E0'),
        Light = Color3.fromHex('FFFFFF'),
        Dark = Color3.fromHex('AEAEAE')
    }
}

function Connections:Listen(Connection, Function)
    local NewConnection = Connection:Connect(Function)
    TInsert(self.Active, NewConnection)
    return NewConnection
end

function Connections:DisconnectAll()
    for Index, Connection in pairs(self.Active) do
        if Connection.Connected then
            Connection:Disconnect()
        end
    end

    self.Active = {}
end

function Signal.new()
    local self = setmetatable({_BindableEvent = Instance.new 'BindableEvent'}, Signal)

    return self
end

function Signal:Connect(Callback)
    assert(type(Callback) == 'function', 'function expected; got ' .. type(Callback))

    return self._BindableEvent.Event:Connect(
        function(...)
            Callback(...)
        end
    )
end

function Signal:Fire(...)
    self._BindableEvent:Fire(...)
end

function Signal:Wait()
    local Arguments = self._BindableEvent:Wait()

    return Arguments
end

function Signal:Disconnect()
    if self._BindableEvent then
        self._BindableEvent:Destroy()
    end
end

local function IsMouseOverDrawing(Drawing, MousePosition)
    local TopLeft = Drawing.Position
    local BottomRight = Drawing.Position + Drawing.Size
    local MousePosition = MousePosition or GetMouseLocation(UserInputService)

    return MousePosition.X > TopLeft.X and MousePosition.Y > TopLeft.Y and MousePosition.X < BottomRight.X and
        MousePosition.Y < BottomRight.Y
end

local ImageCache = {}

local function SetImage(Drawing, Url)
    local Data = IsSynapse and game:HttpGet(Url) or Url

    Drawing[IsSynapse and 'Data' or 'Uri'] = ImageCache[Url] or Data
    ImageCache[Url] = Data

    if not IsSynapse then
        repeat
            task.wait()
        until Drawing.Loaded
    end
end

local function CreateDrawingsTable()
    local Drawings = {__Objects = {}}
    local Metatable = {}

    function Metatable.__index(self, Index)
        local Object = rawget(self.__Objects, Index)

        if not Object or (IsSynapse and not Object.__SELF.__OBJECT_EXISTS) then
            local Type = Sub(Index, 1, (Find(Index, '-') - 1))

            local Success, Object = pcall(Drawing.new, Type)

            if not Object or not Success then
                return function()
                end
            end

            self.__Objects[Index] =
                setmetatable(
                {__SELF = Object, Type = Type},
                {
                    __call = function(self, Properties)
                        local Object = rawget(self, '__SELF')
                        if IsSynapse and not Object.__OBJECT_EXISTS then
                            return false, 'render object destroyed'
                        end

                        if Properties == false then
                            Object.Visible = false
                            Object.Transparency = 0
                            Object:Remove()

                            return true
                        end

                        if type(Properties) == 'table' then
                            for Property, Value in pairs(Properties) do
                                local CanSet = true

                                if
                                    self.Type == 'Image' and not IsSynapse and Property == 'Size' and
                                        typeof(Value) == 'Vector2'
                                 then
                                    CanSet = false

                                    task.spawn(
                                        function()
                                            repeat
                                                task.wait()
                                            until Object.Loaded
                                            if not self.DefaultSize then
                                                rawset(self, 'DefaultSize', Object.Size)
                                            end

                                            Property = 'ScaleFactor'
                                            Value = Value.X / self.DefaultSize.X

                                            Object[Property] = Value
                                        end
                                    )
                                end

                                if CanSet then
                                    Object[Property] = Value
                                end
                            end
                        end

                        return Object
                    end
                }
            )

            Object.Visible = true
            Object.Transparency = 1

            if Type == 'Text' then
                if Drawing.Fonts then
                    Object.Font = Drawing.Fonts.Monospace
                end
                Object.Size = 20
                Object.Color = C3New(1, 1, 1)
                Object.Center = true
                Object.Outline = true
            elseif Type == 'Square' or Type == 'Rectangle' then
                Object.Thickness = 2
                Object.Filled = false
            end

            return self.__Objects[Index]
        end

        return Object
    end

    function Metatable.__call(self, Delete, ...)
        local Arguments = {Delete, ...}

        if Delete == false then
            for Index, Drawing in pairs(rawget(self, '__Objects')) do
                Drawing(false)
            end
        end
    end

    return setmetatable(Drawings, Metatable)
end

local Images = {
    Ring = 'https://i.imgur.com/q4qx26f.png',
    Overlay = 'https://i.imgur.com/gOCxbsR.png'
}

function ColorPicker.new(Position, Size, Color)
    ColorPicker.LastGenerated = tick()
    ColorPicker.Loading = true

    local Picker = {Color = Color or C3New(1, 1, 1), HSV = {H = 0, S = 1, V = 1}}
    local Drawings = CreateDrawingsTable()
    local Position = Position or V2New()
    local Size = Size or 150
    local Padding = {10, 10, 10, 10}

    Picker.ColorChanged = Signal.new()

    local Background =
        Drawings['Square-Background'] {
        Color = Color3.fromRGB(33, 33, 33),
        Filled = false,
        Visible = false,
        Position = Position - V2New(Padding[4], Padding[1]),
        Size = V2New(Size, Size) + V2New(Padding[4] + Padding[2], Padding[1] + Padding[3])
    }
    local ColorPreview =
        Drawings['Circle-Preview'] {
        Position = Position + (V2New(Size, Size) / 2),
        Radius = Size / 2 - 8,
        Filled = true,
        Thickness = 0,
        NumSides = 20,
        Color = C3New(1, 0, 0)
    }
    local Main =
        Drawings['Image-Main'] {
        Position = Position,
        Size = V2New(Size, Size)
    }
    SetImage(Main, Images.Ring)
    local Preview =
        Drawings['Square-Preview'] {
        Position = Main.Position + (Main.Size / 4.5),
        Size = Main.Size / 1.75,
        Color = C3New(1, 0, 0),
        Filled = true,
        Thickness = 0
    }
    local Overlay =
        Drawings['Image-Overlay'] {
        Position = Preview.Position,
        Size = Preview.Size,
        Transparency = 1
    }
    SetImage(Overlay, Images.Overlay)
    local CursorOutline =
        Drawings['Circle-CursorOutline'] {
        Radius = 4,
        Thickness = 2,
        Filled = false,
        Color = C3New(0.2, 0.2, 0.2),
        Position = V2New(Main.Position.X + Main.Size.X - 10, Main.Position.Y + (Main.Size.Y / 2))
    }
    local Cursor =
        Drawings['Circle-Cursor'] {
        Radius = 3,
        Transparency = 1,
        Filled = true,
        Color = C3New(1, 1, 1),
        Position = CursorOutline.Position
    }
    local CursorOutline =
        Drawings['Circle-CursorOutlineSquare'] {
        Radius = 4,
        Thickness = 2,
        Filled = false,
        Color = C3New(0.2, 0.2, 0.2),
        Position = V2New(Preview.Position.X + Preview.Size.X - 2, Preview.Position.Y + 2)
    }
    Drawings['Circle-CursorSquare'] {
        Radius = 3,
        Transparency = 1,
        Filled = true,
        Color = C3New(1, 1, 1),
        Position = CursorOutline.Position
    }

    function Picker:UpdatePosition(Input)
        local MousePosition = V2New(Input.Position.X, Input.Position.Y + 33)

        if self.MouseHeld then
            if self.Item == 'Ring' then
                local Main = self.Drawings['Image-Main']()
                local Preview = self.Drawings['Square-Preview']()
                local Bounds = Main.Size / 2
                local Center = Main.Position + Bounds
                local Relative = MousePosition - Center
                local Direction = Relative.Unit
                local Position = Center + Direction * Main.Size.X / 2.15
                local H = (math.atan2(Position.Y - Center.Y, Position.X - Center.X)) * 60
                if H < 0 then
                    H = 360 + H
                end
                H = H / 360
                self.HSV.H = H
                local EndColor = Color3.fromHSV(H, self.HSV.S, self.HSV.V)
                if EndColor ~= self.Color then
                    self.ColorChanged:Fire(self.Color)
                end
                local Pointer = self.Drawings['Circle-Cursor'] {Position = Position}
                self.Drawings['Circle-CursorOutline'] {Position = Pointer.Position}
                Bounds = Bounds * 2
                Preview.Color = Color3.fromHSV(H, 1, 1)
                self.Color = EndColor
                self.Drawings['Circle-Preview'] {Color = EndColor}
            elseif self.Item == 'HL' then
                local Preview = self.Drawings['Square-Preview']()
                local HSV = self.HSV
                local Position =
                    V2New(
                    math.clamp(MousePosition.X, Preview.Position.X, Preview.Position.X + Preview.Size.X),
                    math.clamp(MousePosition.Y, Preview.Position.Y, Preview.Position.Y + Preview.Size.Y)
                )
                HSV.S = (Position.X - Preview.Position.X) / Preview.Size.X
                HSV.V = 1 - (Position.Y - Preview.Position.Y) / Preview.Size.Y
                local EndColor = Color3.fromHSV(HSV.H, HSV.S, HSV.V)
                if EndColor ~= self.Color then
                    self.ColorChanged:Fire(self.Color)
                end
                self.Color = EndColor
                self.Drawings['Circle-Preview'] {Color = EndColor}
                local Pointer = self.Drawings['Circle-CursorSquare'] {Position = Position}
                self.Drawings['Circle-CursorOutlineSquare'] {Position = Pointer.Position}
            end
        end
    end

    function Picker:HandleInput(Input, P, Type)
        if Type == 'Began' then
            if Input.UserInputType.Name == 'MouseButton1' then
                local Main = self.Drawings['Image-Main']()
                local SquareSV = self.Drawings['Square-Preview']()
                local MousePosition = V2New(Input.Position.X, Input.Position.Y + 33)
                self.MouseHeld = true
                local Bounds = Main.Size / 2
                local Center = Main.Position + Bounds
                local R = (MousePosition - Center)

                if R.Magnitude < Bounds.X and R.Magnitude > Bounds.X - 20 then
                    self.Item = 'Ring'
                end

                if
                    MousePosition.X > SquareSV.Position.X and MousePosition.Y > SquareSV.Position.Y and
                        MousePosition.X < SquareSV.Position.X + SquareSV.Size.X and
                        MousePosition.Y < SquareSV.Position.Y + SquareSV.Size.Y
                 then
                    self.Item = 'HL'
                end

                self:UpdatePosition(Input, P)
            end
        elseif Type == 'Changed' then
            if Input.UserInputType.Name == 'MouseMovement' then
                self:UpdatePosition(Input, P)
            end
        elseif Type == 'Ended' and Input.UserInputType.Name == 'MouseButton1' then
            self.Item = nil
        end
    end

    function Picker:Dispose()
        self.Drawings(false)
        self.UpdatePosition = nil
        self.HandleInput = nil
        Connections:DisconnectAll()
    end

    Connections:Listen(
        UserInputService.InputBegan,
        function(Input, Process)
            Picker:HandleInput(Input, Process, 'Began')
        end
    )
    Connections:Listen(
        UserInputService.InputChanged,
        function(Input, Process)
            if Input.UserInputType.Name == 'MouseMovement' then
                local MousePosition = V2New(Input.Position.X, Input.Position.Y + 33)
                local Cursor =
                    Picker.Drawings['Triangle-Cursor'] {
                    Filled = true,
                    Color = C3New(0.9, 0.9, 0.9),
                    PointA = MousePosition + V2New(0, 0),
                    PointB = MousePosition + V2New(12, 14),
                    PointC = MousePosition + V2New(0, 18),
                    Thickness = 0
                }
            end
            Picker:HandleInput(Input, Process, 'Changed')
        end
    )
    Connections:Listen(
        UserInputService.InputEnded,
        function(Input, Process)
            Picker:HandleInput(Input, Process, 'Ended')

            if Input.UserInputType.Name == 'MouseButton1' then
                Picker.MouseHeld = false
            end
        end
    )

    ColorPicker.Loading = false

    Picker.Drawings = Drawings
    return Picker
end

function SubMenu:Show(Position, Size, Title, Options)
    self.Open = true

    local Visible = true
    local BasePosition = Position
    local BaseSize = Size
    local End = BasePosition + BaseSize

    self.Bounds = {BasePosition.X, BasePosition.Y, End.X, End.Y}

    task.delay(
        0.025,
        function()
            if not self.Open then
                return
            end

            Menu:AddMenuInstance(
                'Sub-Main',
                'Square',
                {
                    Size = BaseSize,
                    Position = BasePosition,
                    Filled = false,
                    Color = Colors.Primary.Main,
                    Thickness = 3,
                    Visible = Visible
                }
            )
        end
    )
    Menu:AddMenuInstance(
        'Sub-TopBar',
        'Square',
        {
            Position = BasePosition,
            Size = V2New(BaseSize.X, 10),
            Color = Colors.Primary.Dark,
            Filled = true,
            Visible = Visible
        }
    )
    Menu:AddMenuInstance(
        'Sub-TopBarTwo',
        'Square',
        {
            Position = BasePosition + V2New(0, 10),
            Size = V2New(BaseSize.X, 20),
            Color = Colors.Primary.Main,
            Filled = true,
            Visible = Visible
        }
    )
    Menu:AddMenuInstance(
        'Sub-TopBarText',
        'Text',
        {
            Size = 20,
            Position = shared.MenuDrawingData.Instances['Sub-TopBarTwo'].Position + V2New(15, -3),
            Text = Title or '',
            Color = Colors.Secondary.Light,
            Visible = Visible
        }
    )
    Menu:AddMenuInstance(
        'Sub-Filling',
        'Square',
        {
            Size = BaseSize - V2New(0, 30),
            Position = BasePosition + V2New(0, 30),
            Filled = true,
            Color = Colors.Secondary.Main,
            Transparency = .75,
            Visible = Visible
        }
    )

    if Options then
        for Index, Option in pairs(Options) do
            local function GetName(Name)
                return Format('Sub-%s.%d', Name, Index)
            end
            local Position = shared.MenuDrawingData.Instances['Sub-Filling'].Position + V2New(20, Index * 25 - 10)

            if Option.Type == 'Color' then
                local ColorPreview =
                    Menu:AddMenuInstance(
                    GetName 'ColorPreview',
                    'Circle',
                    {
                        Position = Position,
                        Color = Option.Color,
                        Radius = 10,
                        NumSides = 10,
                        Filled = true,
                        Visible = true
                    }
                )
                local Text =
                    Menu:AddMenuInstance(
                    GetName 'Text',
                    'Text',
                    {
                        Text = Option.Text,
                        Position = ColorPreview.Position + V2New(15, -8),
                        Size = 16,
                        Color = Colors.Primary.Dark,
                        Visible = true
                    }
                )
                UIButtons[#UIButtons + 1] = {
                    FromSubMenu = true,
                    Option = function()
                        return Option.Function(ColorPreview, BasePosition + V2New(BaseSize.X, 0))
                    end,
                    Instance = Menu:AddMenuInstance(
                        Format('%s_Hitbox', GetName 'Button'),
                        'Square',
                        {
                            Position = Position - V2New(20, 12),
                            Size = V2New(BaseSize.X, 25),
                            Visible = false
                        }
                    )
                }
            elseif Option.Type == 'Button' then
                UIButtons[#UIButtons + 1] = {
                    FromSubMenu = true,
                    Option = Option.Function,
                    Instance = Menu:AddMenuInstance(
                        Format('%s_Hitbox', GetName 'Button'),
                        'Square',
                        {
                            Size = V2New(BaseSize.X, 20) - V2New(20, 0),
                            Visible = true,
                            Transparency = .5,
                            Position = Position - V2New(10, 10),
                            Color = Colors.Secondary.Light,
                            Filled = true
                        }
                    )
                }
                local Text =
                    Menu:AddMenuInstance(
                    Format('%s_Text', GetName 'Text'),
                    'Text',
                    {
                        Text = Option.Text,
                        Size = 18,
                        Position = Position + V2New(5, -10),
                        Visible = true,
                        Color = Colors.Primary.Dark
                    }
                )
            end
        end
    end
end

function SubMenu:Hide()
    self.Open = false

    for i, v in pairs(shared.MenuDrawingData.Instances) do
        if Sub(i, 1, 3) == 'Sub' then
            v.Visible = false

            if Sub(i, 4, 4) == ':' then
                v:Remove()
                shared.MenuDrawingData.Instance[i] = nil
            end
        end
    end

    for i, Button in pairs(UIButtons) do
        if Button.FromSubMenu then
            UIButtons[i] = nil
        end
    end

    task.spawn(
        function()
            for i = 1, 10 do
                if shared.CurrentColorPicker then
                    shared.CurrentColorPicker:Dispose()
                end
                task.wait(0.1)
            end
        end
    )

    CurrentColorPicker = nil
end

local function CreateMenu(NewPosition)
    MenuLoaded = false
    UIButtons = {}
    Sliders = {}

    local BaseSize = V2New(300, 725)
    local BasePosition =
        NewPosition or V2New(Camera.ViewportSize.X / 8 - (BaseSize.X / 2), Camera.ViewportSize.Y / 2 - (BaseSize.Y / 2))

    BasePosition =
        V2New(
        math.clamp(BasePosition.X, 0, Camera.ViewportSize.X),
        math.clamp(BasePosition.Y, 0, Camera.ViewportSize.Y)
    )

    Menu:AddMenuInstance(
        'CrosshairX',
        'Line',
        {
            Visible = false,
            Color = C3New(0, 1, 0),
            Transparency = 1,
            Thickness = 1
        }
    )
    Menu:AddMenuInstance(
        'CrosshairY',
        'Line',
        {
            Visible = false,
            Color = C3New(0, 1, 0),
            Transparency = 1,
            Thickness = 1
        }
    )

    task.delay(
        .025,
        function()
            Menu:AddMenuInstance(
                'Main',
                'Square',
                {
                    Size = BaseSize,
                    Position = BasePosition,
                    Filled = false,
                    Color = Colors.Primary.Main,
                    Thickness = 3,
                    Visible = true
                }
            )
        end
    )
    Menu:AddMenuInstance(
        'TopBar',
        'Square',
        {
            Position = BasePosition,
            Size = V2New(BaseSize.X, 15),
            Color = Colors.Primary.Dark,
            Filled = true,
            Visible = true
        }
    )
    Menu:AddMenuInstance(
        'TopBarTwo',
        'Square',
        {
            Position = BasePosition + V2New(0, 15),
            Size = V2New(BaseSize.X, 45),
            Color = Colors.Primary.Main,
            Filled = true,
            Visible = true
        }
    )
    Menu:AddMenuInstance(
        'TopBarText',
        'Text',
        {
            Size = 25,
            Position = shared.MenuDrawingData.Instances.TopBarTwo.Position + V2New(25, 10),
            Text = 'Unnamed ESP',
            Color = Colors.Secondary.Light,
            Visible = true,
            Transparency = 1,
            Outline = true,
        }
    )
    Menu:AddMenuInstance(
        'TopBarTextBR',
        'Text',
        {
            Size = 18,
            Position = shared.MenuDrawingData.Instances.TopBarTwo.Position + V2New(BaseSize.X - 75, 25),
            Text = 'by ic3w0lf',
            Color = Colors.Secondary.Light,
            Visible = true,
            Transparency = 1,
            Outline = true,
        }
    )
    Menu:AddMenuInstance(
        'Filling',
        'Square',
        {
            Size = BaseSize - V2New(0, 60),
            Position = BasePosition + V2New(0, 60),
            Filled = true,
            Color = Colors.Secondary.Main,
            Transparency = .5,
            Visible = true
        }
    )

    local CPos = 0

    GetTableData(Options)(
        function(i, v)
            if type(v.Value) == 'boolean' and not IsStringEmpty(v.Text) and v.Text ~= nil then
                CPos = CPos + 25
                local BaseSize = V2New(BaseSize.X, 30)
                local BasePosition = shared.MenuDrawingData.Instances.Filling.Position + V2New(30, v.Index * 25 - 10)
                UIButtons[#UIButtons + 1] = {
                    Option = v,
                    Instance = Menu:AddMenuInstance(
                        Format('%s_Hitbox', v.Name),
                        'Square',
                        {
                            Position = BasePosition - V2New(30, 15),
                            Size = BaseSize,
                            Visible = false
                        }
                    )
                }
                Menu:AddMenuInstance(
                    Format('%s_OuterCircle', v.Name),
                    'Circle',
                    {
                        Radius = 10,
                        Position = BasePosition,
                        Color = Colors.Secondary.Light,
                        Filled = true,
                        Visible = true
                    }
                )
                Menu:AddMenuInstance(
                    Format('%s_InnerCircle', v.Name),
                    'Circle',
                    {
                        Radius = 7,
                        Position = BasePosition,
                        Color = Colors.Secondary.Dark,
                        Filled = true,
                        Visible = v.Value
                    }
                )
                Menu:AddMenuInstance(
                    Format('%s_Text', v.Name),
                    'Text',
                    {
                        Text = v.Text,
                        Size = 20,
                        Position = BasePosition + V2New(20, -10),
                        Visible = true,
                        Color = Colors.Secondary.Light,
                        Transparency = 1,
                        Outline = true,
                    }
                )
            end
        end
    )
    GetTableData(Options)(
        function(i, v)
            if type(v.Value) == 'number' then
                CPos = CPos + 25

                local BaseSize = V2New(BaseSize.X, 30)
                local BasePosition = shared.MenuDrawingData.Instances.Filling.Position + V2New(0, CPos - 10)

                local Line =
                    Menu:AddMenuInstance(
                    Format('%s_SliderLine', v.Name),
                    'Square',
                    {
                        Color = Colors.Secondary.Light,
                        Filled = true,
                        Visible = true,
                        Position = BasePosition + V2New(15, -5),
                        Size = BaseSize - V2New(30, 10),
                        Transparency = 0.5
                    }
                )
                local Slider =
                    Menu:AddMenuInstance(
                    Format('%s_Slider', v.Name),
                    'Square',
                    {
                        Visible = true,
                        Filled = true,
                        Color = Colors.Primary.Dark,
                        Size = V2New(5, Line.Size.Y),
                        Transparency = 0.5
                    }
                )
                local Text =
                    Menu:AddMenuInstance(
                    Format('%s_Text', v.Name),
                    'Text',
                    {
                        Text = v.Text,
                        Size = 20,
                        Center = true,
                        Transparency = 1,
                        Outline = true,
                        Visible = true,
                        Color = Colors.White
                    }
                )
                Text.Position = Line.Position + (Line.Size / 2) - V2New(0, Text.TextBounds.Y / 1.75)
                local AMT =
                    Menu:AddMenuInstance(
                    Format('%s_AmountText', v.Name),
                    'Text',
                    {
                        Text = tostring(v.Value),
                        Size = 22,
                        Center = true,
                        Transparency = 1,
                        Outline = true,
                        Visible = true,
                        Color = Colors.White,
                        Position = Text.Position
                    }
                )

                local CSlider = {Slider = Slider, Line = Line, Min = v.AllArgs[4], Max = v.AllArgs[5], Option = v}
                local Dummy = Instance.new 'NumberValue'

                Dummy:GetPropertyChangedSignal 'Value':Connect(
                    function()
                        Text.Transparency = Dummy.Value
                        AMT.Transparency = 1 - Dummy.Value
                    end
                )

                Dummy.Value = 1

                function CSlider:ShowValue(Bool)
                    self.ShowingValue = Bool

                    TweenService:Create(
                        Dummy,
                        TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                        {Value = Bool and 0 or 1}
                    ):Play()
                end

                Sliders[#Sliders + 1] = CSlider
                Slider.Position = Line.Position + V2New(35, 0)

                v.BaseSize = BaseSize
                v.BasePosition = BasePosition
            end
        end
    )
    local FirstItem = false
    GetTableData(Options)(
        function(i, v)
            if typeof(v.Value) == 'EnumItem' then
                CPos = CPos + (not FirstItem and 30 or 25)
                FirstItem = true

                local BaseSize = V2New(BaseSize.X, FirstItem and 30 or 25)
                local BasePosition = shared.MenuDrawingData.Instances.Filling.Position + V2New(0, CPos - 10)

                UIButtons[#UIButtons + 1] = {
                    Option = v,
                    Instance = Menu:AddMenuInstance(
                        Format('%s_Hitbox', v.Name),
                        'Square',
                        {
                            Size = V2New(BaseSize.X, 20) - V2New(30, 0),
                            Visible = true,
                            Transparency = .5,
                            Position = BasePosition + V2New(15, -10),
                            Color = Colors.Secondary.Light,
                            Filled = true
                        }
                    )
                }
                local Text =
                    Menu:AddMenuInstance(
                    Format('%s_Text', v.Name),
                    'Text',
                    {
                        Text = v.Text,
                        Size = 20,
                        Position = BasePosition + V2New(20, -10),
                        Visible = true,
                        Color = Colors.Secondary.Light,
                        Transparency = 1,
                        Outline = true,
                    }
                )
                local BindText =
                    Menu:AddMenuInstance(
                    Format('%s_BindText', v.Name),
                    'Text',
                    {
                        Text = Match(tostring(v.Value), '%w+%.%w+%.(.+)'),
                        Size = 20,
                        Position = BasePosition,
                        Visible = true,
                        Color = Colors.Secondary.Light,
                        Transparency = 1,
                        Outline = true,
                    }
                )

                Options[i].BaseSize = BaseSize
                Options[i].BasePosition = BasePosition
                BindText.Position = BasePosition + V2New(BaseSize.X - BindText.TextBounds.X - 20, -10)
            end
        end
    )
    GetTableData(Options)(
        function(i, v)
            if type(v.Value) == 'function' then
                local BaseSize = V2New(BaseSize.X, 30)
                local BasePosition =
                    shared.MenuDrawingData.Instances.Filling.Position + V2New(0, CPos + (25 * v.AllArgs[4]) - 35)

                UIButtons[#UIButtons + 1] = {
                    Option = v,
                    Instance = Menu:AddMenuInstance(
                        Format('%s_Hitbox', v.Name),
                        'Square',
                        {
                            Size = V2New(BaseSize.X, 20) - V2New(30, 0),
                            Visible = true,
                            Transparency = .5,
                            Position = BasePosition + V2New(15, -10),
                            Color = Colors.Secondary.Light,
                            Filled = true
                        }
                    )
                }
                local Text =
                    Menu:AddMenuInstance(
                    Format('%s_Text', v.Name),
                    'Text',
                    {
                        Text = v.Text,
                        Size = 20,
                        Position = BasePosition + V2New(20, -10),
                        Visible = true,
                        Color = Colors.Secondary.Light,
                        Transparency = 1,
                        Outline = true,
                    }
                )
            end
        end
    )

    task.delay(
        .1,
        function()
            MenuLoaded = true
        end
    )

    Menu:AddMenuInstance(
        'Cursor1',
        'Line',
        {
            Visible = false,
            Color = C3New(1, 0, 0),
            Transparency = 1,
            Thickness = 2
        }
    )
    Menu:AddMenuInstance(
        'Cursor2',
        'Line',
        {
            Visible = false,
            Color = C3New(1, 0, 0),
            Transparency = 1,
            Thickness = 2
        }
    )
    Menu:AddMenuInstance(
        'Cursor3',
        'Line',
        {
            Visible = false,
            Color = C3New(1, 0, 0),
            Transparency = 1,
            Thickness = 2
        }
    )
end

CreateMenu()

shared.UESP_InputChangedCon =
    UserInputService.InputChanged:Connect(
    function(input)
        if input.UserInputType.Name == 'MouseMovement' and Options.MenuOpen.Value then
            for i, v in pairs(Sliders) do
                local Values = {
                    v.Line.Position.X,
                    v.Line.Position.Y,
                    v.Line.Position.X + v.Line.Size.X,
                    v.Line.Position.Y + v.Line.Size.Y
                }
                if MouseHoveringOver(Values) then
                    v:ShowValue(true)
                else
                    if not MouseHeld then
                        v:ShowValue(false)
                    end
                end
            end
        end
    end
)
shared.UESP_InputBeganCon =
    UserInputService.InputBegan:Connect(
    function(input)
        if input.UserInputType.Name == 'MouseButton1' and Options.MenuOpen.Value then
            MouseHeld = true
            local Bar = Menu:GetInstance 'TopBar'
            local Values = {
                Bar.Position.X,
                Bar.Position.Y,
                Bar.Position.X + Bar.Size.X,
                Bar.Position.Y + Bar.Size.Y
            }
            if MouseHoveringOver(Values) then
                DraggingUI = true
                DragOffset = Menu:GetInstance 'Main'.Position - GetMouseLocation(UserInputService)
            else
                for i, v in pairs(Sliders) do
                    local Values = {
                        v.Line.Position.X,
                        v.Line.Position.Y,
                        v.Line.Position.X + v.Line.Size.X,
                        v.Line.Position.Y + v.Line.Size.Y
                    }
                    if MouseHoveringOver(Values) then
                        DraggingWhat = v
                        Dragging = true
                        break
                    end
                end

                if not Dragging then
                    local Values = {
                        TracerPosition.X - 10,
                        TracerPosition.Y - 10,
                        TracerPosition.X + 10,
                        TracerPosition.Y + 10
                    }
                    if MouseHoveringOver(Values) then
                        DragTracerPosition = true
                    end
                end
            end
        end
    end
)
shared.UESP_InputEndedCon =
    UserInputService.InputEnded:Connect(
    function(input)
        if input.UserInputType.Name == 'MouseButton1' and Options.MenuOpen.Value then
            MouseHeld = false
            DragTracerPosition = false
            local IgnoreOtherInput = false

            if SubMenu.Open and not MouseHoveringOver(SubMenu.Bounds) then
                if CurrentColorPicker and IsMouseOverDrawing(CurrentColorPicker.Drawings['Square-Background']()) then
                    IgnoreOtherInput = true
                end
                if not IgnoreOtherInput then
                    SubMenu:Hide()
                end
            end

            if not IgnoreOtherInput then
                for i, v in pairs(UIButtons) do
                    if SubMenu.Open and MouseHoveringOver(SubMenu.Bounds) and not v.FromSubMenu then
                        continue
                    end

                    local Values = {
                        v.Instance.Position.X,
                        v.Instance.Position.Y,
                        v.Instance.Position.X + v.Instance.Size.X,
                        v.Instance.Position.Y + v.Instance.Size.Y
                    }
                    if MouseHoveringOver(Values) then
                        v.Option()
                        IgnoreOtherInput = true
                        break
                    end
                end
                for i, v in pairs(Sliders) do
                    if IgnoreOtherInput then
                        break
                    end

                    local Values = {
                        v.Line.Position.X,
                        v.Line.Position.Y,
                        v.Line.Position.X + v.Line.Size.X,
                        v.Line.Position.Y + v.Line.Size.Y
                    }
                    if not MouseHoveringOver(Values) then
                        v:ShowValue(false)
                    end
                end
            end
        elseif input.UserInputType.Name == 'MouseButton2' and Options.MenuOpen.Value and not DragTracerPosition then
            local Values = {
                TracerPosition.X - 10,
                TracerPosition.Y - 10,
                TracerPosition.X + 10,
                TracerPosition.Y + 10
            }
            if MouseHoveringOver(Values) then
                DragTracerPosition = false
                TracerPosition = V2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 135)
            end
        elseif input.UserInputType.Name == 'Keyboard' then
            if Binding then
                BindedKey = input.KeyCode
                Binding = false
            elseif
                input.KeyCode == Options.MenuKey.Value or
                    (input.KeyCode == Enum.KeyCode.Home and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl))
             then
                Options.MenuOpen()
            elseif input.KeyCode == Options.ToggleKey.Value then
                Options.Enabled()
            elseif input.KeyCode.Name == 'F1' and UserInputService:IsMouseButtonPressed(1) and shared.am_ic3 then
                local HD, LPlayer, LCharacter = 0.95

                for i, Player in pairs(Players:GetPlayers()) do
                    local Character = GetCharacter(Player)

                    if
                        Player ~= LocalPlayer and Player ~= Spectating and Character and
                            Character:FindFirstChild 'HumanoidRootPart'
                     then
                        local Head = Character:FindFirstChild 'Head'

                        if Head then
                            local Distance = (Camera.CFrame.Position - Head.Position).Magnitude

                            if Distance > Options.MaxDistance.Value then
                                continue
                            end

                            local Direction = -(Camera.CFrame.Position - Mouse.Hit.Position).Unit
                            local Relative = Character.Head.Position - Camera.CFrame.Position
                            local Unit = Relative.Unit

                            local DP = Direction:Dot(Unit)

                            if DP > HD then
                                HD = DP
                                LPlayer = Player
                                LCharacter = Character
                            end
                        end
                    end
                end

                if LPlayer and LPlayer ~= Spectating and LCharacter then
                    Camera.CameraSubject = LCharacter.Head
                    Spectating = LPlayer
                else
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass 'Humanoid' then
                        Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass 'Humanoid'
                        Spectating = nil
                    end
                end
            end
        end
    end
)

local function CameraCon()
    Workspace.CurrentCamera:GetPropertyChangedSignal 'ViewportSize':Connect(
        function()
            TracerPosition = V2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 135)
        end
    )
end

CameraCon()

local function ToggleMenu()
    if Options.MenuOpen.Value then
        GetTableData(shared.MenuDrawingData.Instances)(
            function(i, v)
                if OldData[v] then
                    v.Visible = true
                end
            end
        )
    else
        GetTableData(shared.MenuDrawingData.Instances)(
            function(i, v)
                OldData[v] = v.Visible
                if v.Visible then
                    v.Visible = false
                end
            end
        )
    end
end

local function CheckRay(Instance, Distance, Position, Unit)
    local Pass = true
    local Model = Instance

    if Distance > 999 then
        return false
    end

    if Instance.ClassName == 'Player' then
        Model = GetCharacter(Instance)
    end

    if not Model then
        Model = Instance.Parent

        if Model.Parent == Workspace then
            Model = Instance
        end
    end

    if not Model then
        return false
    end

    local Origin = Position
    local Direction = (Unit * Distance)
    local Hit = Workspace:Raycast(Origin, Direction, RaycastList)

    if Hit then
        local HitInstance = Hit.Instance

        if not HitInstance:IsDescendantOf(Model) then
            Pass = false

            if HitInstance.Transparency >= 0.3 or not HitInstance.CanCollide and HitInstance.ClassName ~= 'Terrain' then
                TInsert(IgnoreList, HitInstance)
                RaycastList.FilterDescendantsInstances = IgnoreList
            end
        end
    end

    return Pass
end

local function CheckTeam(Player)
    if Player.Neutral and LocalPlayer.Neutral then
        return true
    end
    return Player.TeamColor == LocalPlayer.TeamColor
end

local CustomTeam = CustomTeams[game.PlaceId]

if CustomTeam ~= nil then
    if CustomTeam.Initialize then
        CustomTeam.Initialize()
    end

    CheckTeam = CustomTeam.CheckTeam
end

local function CheckPlayer(Player, Character)
    if not Options.Enabled.Value then
        return false
    end

    local Pass = true
    local Distance = 0

    if Player ~= LocalPlayer and Character then
        if not Options.ShowTeam.Value and CheckTeam(Player) then
            Pass = false
        end

        local Head = FindFirstChild(Character, 'Head')

        if Pass and Character and Head then
            Distance = (Camera.CFrame.Position - Head.Position).Magnitude
            if Options.VisCheck.Value then
                Pass = CheckRay(Player, Distance, Camera.CFrame.Position, (Head.Position - Camera.CFrame.Position).Unit)
            end
            if Distance > Options.MaxDistance.Value then
                Pass = false
            end
        end
    else
        Pass = false
    end

    return Pass, Distance
end

local function CheckDistance(Instance)
    if not Options.Enabled.Value then
        return false
    end

    local Pass = true
    local Distance = 0

    if Instance ~= nil then
        Distance = (Camera.CFrame.Position - Instance.Position).Magnitude
        if Options.VisCheck.Value then
            Pass = CheckRay(Instance, Distance, Camera.CFrame.Position, (Instance.Position - Camera.CFrame.Position).Unit)
        end
        if Distance > Options.MaxDistance.Value then
            Pass = false
        end
    else
        Pass = false
    end

    return Pass, Distance
end

local function CheckRelative(Position, Instance)
    if not Options.Enabled.Value then
        return V2New()
    end

    local Vector = V2New()

    if Instance ~= nil and Instance.PrimaryPart ~= nil then
        local Relative
        local Pos = Instance.PrimaryPart.Position
        local CPos = Camera.CFrame.Position

        Relative = CFNew(V3New(Pos.X, CPos.Y, Pos.Z), CPos):PointToObjectSpace(Position)
        Vector = V2New(Relative.X, Relative.Z)
    end

    return Vector
end

local function RelativeToCenter(Number)
    local Relative
    Relative = (Camera.ViewportSize / 2) - Number

    return Relative
end

local function RotateVector(Vector, Rotation)
    local Radian = math.rad(Rotation)

    local RotationOne = Vector.X * math.cos(Radian) - Vector.Y * math.sin(Radian)
    local RotationTwo = Vector.X * math.sin(Radian) + Vector.Y * math.cos(Radian)

    return V2New(RotationOne, RotationTwo)
end

local function UpdatePlayerData()
    if (tick() - LastRefresh) > (Options.RefreshRate.Value / 1000) then
        LastRefresh = tick()
        if CustomESP and Options.Enabled.Value then
            CustomESP()
        end
        for i, v in pairs(RenderList.Instances) do
            if v.Instance ~= nil and v.Instance.Parent ~= nil and v.Instance:IsA 'BasePart' then
                local Data = shared.InstanceData[v.Instance:GetDebugId()] or {Instances = {}, DontDelete = true}

                Data.Instance = v.Instance

                Data.Instances['OutlineTracer'] =
                    Data.Instances['OutlineTracer'] or
                    NewDrawing 'Line' {
                        Transparency = 1,
                        Thickness = 3,
                        Color = C3New(0.1, 0.1, 0.1)
                    }
                Data.Instances['Tracer'] =
                    Data.Instances['Tracer'] or
                    NewDrawing 'Line' {
                        Transparency = 1,
                        Thickness = 1
                    }
                Data.Instances['NameTag'] =
                    Data.Instances['NameTag'] or
                    NewDrawing 'Text' {
                        Size = Options.TextSize.Value,
                        Center = true,
                        Outline = Options.TextOutline.Value,
                        Visible = true
                    }
                Data.Instances['DistanceTag'] =
                    Data.Instances['DistanceTag'] or
                    NewDrawing 'Text' {
                        Size = Options.TextSize.Value - 1,
                        Center = true,
                        Outline = Options.TextOutline.Value,
                        Visible = true
                    }
                Data.Instances['Arrow'] =
                    Data.Instances['Arrow'] or
                    NewDrawing 'Triangle' {
                        Transparency = 1,
                        Thickness = 1,
                        Filled = true
                    }

                local NameTag = Data.Instances['NameTag']
                local DistanceTag = Data.Instances['DistanceTag']
                local Tracer = Data.Instances['Tracer']
                local OutlineTracer = Data.Instances['OutlineTracer']
                local Arrow = Data.Instances['Arrow']

                local Pass, Distance = CheckDistance(v.Instance)
                local Relative = CheckRelative(v.Instance.CFrame.Position, GetCharacter(LocalPlayer)).Unit

                if Pass then
                    local ScreenPosition, Vis = WorldToViewport(v.Instance.Position)
                    local Color = v.Color
                    local OPos = Camera.CFrame:PointToObjectSpace(v.Instance.Position)

                    if ScreenPosition.Z < 0 then
                        local AT = math.atan2(OPos.Y, OPos.X) + math.pi
                        OPos =
                            CFrame.Angles(0, 0, AT):VectorToWorldSpace(
                            (CFrame.Angles(0, math.rad(89.9), 0):VectorToWorldSpace(V3New(0, 0, -1)))
                        )
                    end

                    local Position = WorldToViewport(Camera.CFrame:PointToWorldSpace(OPos))

                    local Base = Relative * math.clamp(Distance, 120, 180)
                    local Tip = Relative * (math.clamp(Distance, 120, 180) + 16)

                    local BaseL = Base + RotateVector(Relative, 90) * 8
                    local BaseR = Base + RotateVector(Relative, -90) * 8

                    if Options.ShowTracers.Value then
                        Tracer.Visible = true
                        Tracer.Transparency = math.clamp(1 - (Distance / 200), 0.25, 0.75)
                        Tracer.From = TracerPosition
                        Tracer.To = V2New(Position.X, Position.Y)
                        Tracer.Color = Color
                        OutlineTracer.From = Tracer.From
                        OutlineTracer.To = Tracer.To
                        OutlineTracer.Transparency = Tracer.Transparency - 0.15
                        OutlineTracer.Visible = true
                    else
                        Tracer.Visible = false
                        OutlineTracer.Visible = false
                    end

                    if Options.ShowArrows.Value then
                        Arrow.Visible = true
                        Arrow.Transparency = math.clamp(1 - (Distance / 200), 0.25, 0.75)
                        Arrow.PointA = RelativeToCenter(BaseL)
                        Arrow.PointB = RelativeToCenter(BaseR)
                        Arrow.PointC = RelativeToCenter(Tip)
                        Arrow.Color = Color
                    else
                        Arrow.Visible = false
                    end

                    if ScreenPosition.Z > 0 then
                        local ScreenPositionUpper = ScreenPosition

                        if Options.ShowName.Value then
                            LocalPlayer.NameDisplayDistance = 0
                            NameTag.Visible = true
                            NameTag.Text = v.Text
                            NameTag.Size = Options.TextSize.Value
                            NameTag.Outline = Options.TextOutline.Value
                            NameTag.Position = V2New(ScreenPositionUpper.X, ScreenPositionUpper.Y)
                            NameTag.Color = Color
                        else
                            LocalPlayer.NameDisplayDistance = 100
                            NameTag.Visible = false
                        end
                        if Options.ShowDistance.Value or Options.ShowHealth.Value then
                            DistanceTag.Visible = true
                            DistanceTag.Size = Options.TextSize.Value - 1
                            DistanceTag.Outline = Options.TextOutline.Value
                            DistanceTag.Color = C3New(1, 1, 1)

                            local Str = ''

                            if Options.ShowDistance.Value then
                                Str = Str .. Format('[%d] ', Distance)
                            end

                            DistanceTag.Text = Str
                            DistanceTag.Position =
                                V2New(ScreenPositionUpper.X, ScreenPositionUpper.Y) + V2New(0, NameTag.TextBounds.Y)
                        else
                            DistanceTag.Visible = false
                        end
                    else
                        NameTag.Visible = false
                        DistanceTag.Visible = false
                    end
                else
                    NameTag.Visible = false
                    DistanceTag.Visible = false
                    Tracer.Visible = false
                    OutlineTracer.Visible = false
                end

                Data.Instances['NameTag'] = NameTag
                Data.Instances['DistanceTag'] = DistanceTag
                Data.Instances['Tracer'] = Tracer
                Data.Instances['OutlineTracer'] = OutlineTracer
                Data.Instances['Arrow'] = Arrow

                shared.InstanceData[v.Instance:GetDebugId()] = Data
            end
        end
        for i, v in pairs(Players:GetPlayers()) do
            local Data = shared.InstanceData[v.Name] or {Instances = {}}

            Data.Instances['Box'] = Data.Instances['Box'] or LineBox:Create {Thickness = 4}
            Data.Instances['OutlineTracer'] =
                Data.Instances['OutlineTracer'] or
                NewDrawing 'Line' {
                    Transparency = 1,
                    Thickness = 3,
                    Color = C3New(0.1, 0.1, 0.1)
                }
            Data.Instances['Tracer'] =
                Data.Instances['Tracer'] or
                NewDrawing 'Line' {
                    Transparency = 1,
                    Thickness = 1
                }
            Data.Instances['HeadDot'] =
                Data.Instances['HeadDot'] or
                NewDrawing 'Circle' {
                    Filled = true,
                    NumSides = 30
                }
            Data.Instances['NameTag'] =
                Data.Instances['NameTag'] or
                NewDrawing 'Text' {
                    Size = Options.TextSize.Value,
                    Center = true,
                    Outline = Options.TextOutline.Value,
                    Visible = true
                }
            Data.Instances['DistanceHealthTag'] =
                Data.Instances['DistanceHealthTag'] or
                NewDrawing 'Text' {
                    Size = Options.TextSize.Value - 1,
                    Center = true,
                    Outline = Options.TextOutline.Value,
                    Visible = true
                }
            Data.Instances['Arrow'] =
                Data.Instances['Arrow'] or
                NewDrawing 'Triangle' {
                    Transparency = 1,
                    Thickness = 1,
                    Filled = true
                }

            local NameTag = Data.Instances['NameTag']
            local DistanceTag = Data.Instances['DistanceHealthTag']
            local Tracer = Data.Instances['Tracer']
            local OutlineTracer = Data.Instances['OutlineTracer']
            local HeadDot = Data.Instances['HeadDot']
            local Arrow = Data.Instances['Arrow']
            local Box = Data.Instances['Box']

            local Character = GetCharacter(v)
            local Pass, Distance = CheckPlayer(v, Character)

            if Pass and Character then
                local HumanoidRootPart = Character:FindFirstChild(CustomRootPartName or 'HumanoidRootPart')
                local Humanoid = Character:FindFirstChildOfClass 'Humanoid'
                local Head = FindFirstChild(Character, 'Head')

                local Dead = (Humanoid and Humanoid:GetState().Name == 'Dead')
                if type(GetAliveState) == 'function' then
                    Dead = (not GetAliveState(v))
                end

                if Character ~= nil and Head and HumanoidRootPart and not Dead then
                    local ScreenPosition, Vis = WorldToViewport(Head.Position)
                    local Color =
                        Rainbow and Color3.fromHSV(tick() * 128 % 255 / 255, 1, 1) or
                        (CheckTeam(v) and TeamColor or EnemyColor)
                    Color = Options.ShowTeamColor.Value and v.TeamColor.Color or Color
                    local OPos = Camera.CFrame:PointToObjectSpace(Head.Position)

                    if ScreenPosition.Z < 0 then
                        local AT = math.atan2(OPos.Y, OPos.X) + math.pi
                        OPos =
                            CFrame.Angles(0, 0, AT):VectorToWorldSpace(
                            (CFrame.Angles(0, math.rad(89.9), 0):VectorToWorldSpace(V3New(0, 0, -1)))
                        )
                    end

                    local Position = WorldToViewport(Camera.CFrame:PointToWorldSpace(OPos))
                    local Relative = CheckRelative(HumanoidRootPart.CFrame.Position, GetCharacter(LocalPlayer)).Unit

                    local Base = Relative * math.clamp(Distance, 120, 180)
                    local Tip = Relative * (math.clamp(Distance, 120, 180) + 16)

                    local BaseL = Base + RotateVector(Relative, 90) * 8
                    local BaseR = Base + RotateVector(Relative, -90) * 8

                    if Options.ShowTracers.Value then
                        if
                            TracerPosition.X >= Camera.ViewportSize.X or TracerPosition.Y >= Camera.ViewportSize.Y or
                                TracerPosition.X < 0 or
                                TracerPosition.Y < 0
                         then
                            TracerPosition = V2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 135)
                        end

                        Tracer.Visible = true
                        Tracer.Transparency = math.clamp(1 - (Distance / 200), 0.25, 0.75)
                        Tracer.From = TracerPosition
                        Tracer.To = V2New(Position.X, Position.Y)
                        Tracer.Color = Color
                        OutlineTracer.From = Tracer.From
                        OutlineTracer.To = Tracer.To
                        OutlineTracer.Transparency = Tracer.Transparency - 0.15
                        OutlineTracer.Visible = true
                    else
                        Tracer.Visible = false
                        OutlineTracer.Visible = false
                    end

                    if Options.ShowArrows.Value then
                        Arrow.Visible = true
                        Arrow.Transparency = math.clamp(1 - (Distance / 200), 0.25, 0.75)
                        Arrow.PointA = RelativeToCenter(BaseL)
                        Arrow.PointB = RelativeToCenter(BaseR)
                        Arrow.PointC = RelativeToCenter(Tip)
                        Arrow.Color = Color
                    else
                        Arrow.Visible = false
                    end

                    if ScreenPosition.Z > 0 then
                        local ScreenPositionUpper =
                            WorldToViewport(
                            (HumanoidRootPart:GetRenderCFrame() *
                                CFNew(0, Head.Size.Y + HumanoidRootPart.Size.Y + (Options.YOffset.Value / 25), 0)).Position
                        )
                        local Scale = Head.Size.Y / 2

                        if Options.ShowName.Value then
                            NameTag.Visible = true
                            NameTag.Text = v.Name
                            NameTag.Size = Options.TextSize.Value
                            NameTag.Outline = Options.TextOutline.Value
                            NameTag.Position =
                                V2New(ScreenPositionUpper.X, ScreenPositionUpper.Y) - V2New(0, NameTag.TextBounds.Y)
                            NameTag.Color = Color
                            NameTag.Color = Color
                            NameTag.OutlineColor = C3New(0.05, 0.05, 0.05)
                            NameTag.Transparency = 0.85
                            NameTag.Font = Font or 0

                            NameTag.Text = v.Name .. (Options.ShowDisplay.Value and ' [' .. v.DisplayName .. ']' or '')
                            NameTag.Text = NameTag.Text .. (CustomPlayerTag and CustomPlayerTag(v) or '')
                        else
                            NameTag.Visible = false
                        end
                        if Options.ShowDistance.Value or Options.ShowHealth.Value then
                            DistanceTag.Visible = true
                            DistanceTag.Size = Options.TextSize.Value - 1
                            DistanceTag.Outline = Options.TextOutline.Value
                            DistanceTag.Color = C3New(1, 1, 1)
                            DistanceTag.Transparency = 0.85

                            local Str = ''

                            if Options.ShowDistance.Value then
                                Str = Str .. Format('[%d] ', Distance)
                            end
                            if Options.ShowHealth.Value then
                                if typeof(Humanoid) == 'Instance' then
                                    Str =
                                        Str ..
                                        Format(
                                            '[%d/%d] [%s%%]',
                                            Humanoid.Health,
                                            Humanoid.MaxHealth,
                                            math.floor(Humanoid.Health / Humanoid.MaxHealth * 100)
                                        )
                                elseif type(GetHealth) == 'function' then
                                    local health, maxHealth = GetHealth(v)

                                    if type(health) == 'number' and type(maxHealth) == 'number' then
                                        Str =
                                            Str ..
                                            Format(
                                                '[%d/%d] [%s%%]',
                                                health,
                                                maxHealth,
                                                math.floor(health / maxHealth * 100)
                                            )
                                    end
                                end
                            end

                            DistanceTag.Text = Str
                            DistanceTag.OutlineColor = C3New(0.05, 0.05, 0.05)
                            DistanceTag.Position =
                                (NameTag.Visible and NameTag.Position + V2New(0, NameTag.TextBounds.Y) or
                                V2New(ScreenPositionUpper.X, ScreenPositionUpper.Y))
                        else
                            DistanceTag.Visible = false
                        end
                        if Options.ShowDot.Value and Vis then
                            local Top = WorldToViewport((Head.CFrame * CFNew(0, Scale, 0)).Position)
                            local Bottom = WorldToViewport((Head.CFrame * CFNew(0, -Scale, 0)).Position)
                            local Radius = math.abs((Top - Bottom).Y)

                            HeadDot.Visible = true
                            HeadDot.Color = Color
                            HeadDot.Position = V2New(ScreenPosition.X, ScreenPosition.Y)
                            HeadDot.Radius = Radius
                        else
                            HeadDot.Visible = false
                        end
                        if Options.ShowBoxes.Value and Vis and HumanoidRootPart then
                            local Body = {
                                Head,
                                FindFirstChild(Character, 'Left Leg') or FindFirstChild(Character, 'LeftLowerLeg'),
                                FindFirstChild(Character, 'Right Leg') or FindFirstChild(Character, 'RightLowerLeg'),
                                FindFirstChild(Character, 'Left Arm') or FindFirstChild(Character, 'LeftLowerArm'),
                                FindFirstChild(Character, 'Right Arm') or FindFirstChild(Character, 'RightLowerArm')
                            }
                            Box:Update(
                                HumanoidRootPart.CFrame,
                                V3New(2, 3, 1) * (Scale * 2),
                                Color,
                                nil,
                                Options.Show2DBox.Value and not TFind(Body, false) and Body
                            )
                        else
                            Box:SetVisible(false)
                        end
                    else
                        NameTag.Visible = false
                        DistanceTag.Visible = false
                        HeadDot.Visible = false

                        Box:SetVisible(false)
                    end
                else
                    NameTag.Visible = false
                    DistanceTag.Visible = false
                    HeadDot.Visible = false
                    Tracer.Visible = false
                    OutlineTracer.Visible = false
                    Arrow.Visible = false

                    Box:SetVisible(false)
                end
            else
                NameTag.Visible = false
                DistanceTag.Visible = false
                HeadDot.Visible = false
                Tracer.Visible = false
                OutlineTracer.Visible = false
                Arrow.Visible = false

                Box:SetVisible(false)
            end

            shared.InstanceData[v.Name] = Data
        end
    end
end

local LastInvalidCheck = 0

local function Update()
    if tick() - LastInvalidCheck > 0.3 then
        LastInvalidCheck = tick()

        if Camera.Parent ~= Workspace then
            Camera = Workspace.CurrentCamera
            CameraCon()
            WTVP = Camera.WorldToViewportPoint
        end

        for i, v in pairs(shared.InstanceData) do
            if not Players:FindFirstChild(tostring(i)) then
                if not shared.InstanceData[i].DontDelete then
                    GetTableData(v.Instances)(
                        function(i, obj)
                            obj.Visible = false
                            obj:Remove()
                            v.Instances[i] = nil
                        end
                    )
                    shared.InstanceData[i] = nil
                else
                    if shared.InstanceData[i].Instance == nil or shared.InstanceData[i].Instance.Parent == nil then
                        GetTableData(v.Instances)(
                            function(i, obj)
                                obj.Visible = false
                                obj:Remove()
                                v.Instances[i] = nil
                            end
                        )
                        shared.InstanceData[i] = nil
                    end
                end
            end
        end
    end

    local CX = Menu:GetInstance 'CrosshairX'
    local CY = Menu:GetInstance 'CrosshairY'

    if Options.Crosshair.Value then
        CX.Visible = true
        CY.Visible = true

        CX.To = V2New((Camera.ViewportSize.X / 2) - 8, (Camera.ViewportSize.Y / 2))
        CX.From = V2New((Camera.ViewportSize.X / 2) + 8, (Camera.ViewportSize.Y / 2))
        CY.To = V2New((Camera.ViewportSize.X / 2), (Camera.ViewportSize.Y / 2) - 8)
        CY.From = V2New((Camera.ViewportSize.X / 2), (Camera.ViewportSize.Y / 2) + 8)
    else
        CX.Visible = false
        CY.Visible = false
    end

    if Options.MenuOpen.Value and MenuLoaded then
        local MLocation = GetMouseLocation(UserInputService)
        shared.MenuDrawingData.Instances.Main.Color = Color3.fromHSV(tick() * 24 % 255 / 255, 1, 1)
        local MainInstance = Menu:GetInstance 'Main'

        local Values = {
            MainInstance.Position.X,
            MainInstance.Position.Y,
            MainInstance.Position.X + MainInstance.Size.X,
            MainInstance.Position.Y + MainInstance.Size.Y
        }

        if MainInstance and (MouseHoveringOver(Values) or (SubMenu.Open and MouseHoveringOver(SubMenu.Bounds))) then
            Debounce.CursorVis = true

            Menu:UpdateMenuInstance 'Cursor1' {
                Visible = true,
                From = V2New(MLocation.X, MLocation.Y),
                To = V2New(MLocation.X + 5, MLocation.Y + 6)
            }
            Menu:UpdateMenuInstance 'Cursor2' {
                Visible = true,
                From = V2New(MLocation.X, MLocation.Y),
                To = V2New(MLocation.X, MLocation.Y + 8)
            }
            Menu:UpdateMenuInstance 'Cursor3' {
                Visible = true,
                From = V2New(MLocation.X, MLocation.Y + 6),
                To = V2New(MLocation.X + 5, MLocation.Y + 5)
            }
        else
            if Debounce.CursorVis then
                Debounce.CursorVis = false

                Menu:UpdateMenuInstance 'Cursor1' {Visible = false}
                Menu:UpdateMenuInstance 'Cursor2' {Visible = false}
                Menu:UpdateMenuInstance 'Cursor3' {Visible = false}
            end
        end
        if MouseHeld then
            local MousePos = GetMouseLocation(UserInputService)

            if Dragging then
                DraggingWhat.Slider.Position =
                    V2New(
                    math.clamp(
                        MLocation.X - DraggingWhat.Slider.Size.X / 2,
                        DraggingWhat.Line.Position.X,
                        DraggingWhat.Line.Position.X + DraggingWhat.Line.Size.X - DraggingWhat.Slider.Size.X
                    ),
                    DraggingWhat.Slider.Position.Y
                )
                local Percent =
                    (DraggingWhat.Slider.Position.X - DraggingWhat.Line.Position.X) /
                    ((DraggingWhat.Line.Position.X + DraggingWhat.Line.Size.X - DraggingWhat.Line.Position.X) -
                        DraggingWhat.Slider.Size.X)
                local Value = CalculateValue(DraggingWhat.Min, DraggingWhat.Max, Percent)
                DraggingWhat.Option(Value)
            elseif DraggingUI then
                Debounce.UIDrag = true
                local Main = Menu:GetInstance 'Main'
                Main.Position = MousePos + DragOffset
            elseif DragTracerPosition then
                TracerPosition = MousePos
            end
        else
            Dragging = false
            DragTracerPosition = false
            if DraggingUI and Debounce.UIDrag then
                Debounce.UIDrag = false
                DraggingUI = false
                CreateMenu(Menu:GetInstance 'Main'.Position)
            end
        end
        if not Debounce.Menu then
            Debounce.Menu = true
            ToggleMenu()
        end
    elseif Debounce.Menu and not Options.MenuOpen.Value then
        Debounce.Menu = false
        ToggleMenu()
    end
end

RunService:UnbindFromRenderStep(GetDataName)
RunService:UnbindFromRenderStep(UpdateName)

RunService:BindToRenderStep(GetDataName, 300, UpdatePlayerData)
RunService:BindToRenderStep(UpdateName, 199, Update)
