repeat task.wait() until game:IsLoaded()
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x3fall3nangel/mercury-lib-edit/master/src.lua"))()

local GUI = Library:Create{
    Name = "Mercury",
    Size = UDim2.fromOffset(600, 400),
    Theme = Library.Themes.Serika,
    Link = "https://github.com/deeeity/mercury-lib"
}

local Main = GUI:tab{
    Name = "Main",
    Icon = "rbxassetid://8569322835" -- rbxassetid://2174510075 home icon
}

local Players = cloneref(game:GetService("Players"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local VirtualInputManager = cloneref(game:GetService("VirtualInputManager"))

local lp = Players.LocalPlayer
local Systems = ReplicatedStorage:WaitForChild("Systems")

local material

local Driveworld = {}

for i,v in pairs(getconnections(Players.LocalPlayer.Idled)) do
    if v["Disable"] then
        v["Disable"](v)
    elseif v["Disconnect"] then
        v["Disconnect"](v)
    end
end

local oldnamecall
oldnamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod() 
    if not checkcaller() and method == "InvokeServer" and self.Name == "QuitJob" then
        if (Driveworld["autodeliveryfood"] or Driveworld["autodelivery"]) then
            return wait(9e9)
        end
    end
    return oldnamecall(self, ...)
end))

local function getchar()
    return lp.Character or lp.CharacterAdded:Wait()
end

local function isvehicle()
    for i,v in next, workspace.Cars:GetChildren() do
        if (v:IsA("Model") and v:FindFirstChild("Owner") and v:FindFirstChild("Owner").Value == lp) then
            if v:FindFirstChild("CurrentDriver") and v:FindFirstChild("CurrentDriver").Value == lp then
                return true
            end
        end
    end
    return false
end

local function getvehicle()
    for i,v in next, workspace.Cars:GetChildren() do
        if v:IsA("Model") and v:FindFirstChild("Owner") and v:FindFirstChild("Owner").Value == lp then
            return v
        end
    end
    return
end

local function spawnvehicle()
    local Cars = ReplicatedStorage:WaitForChild("PlayerData"):WaitForChild(lp.Name):WaitForChild("Inventory"):WaitForChild("Cars")
    local Truck = Cars:FindFirstChild("FullE") or Cars:FindFirstChild("Casper")
    local normalcar = Cars:FindFirstChildWhichIsA("Folder")
    if Truck then
        Systems:WaitForChild("CarInteraction"):WaitForChild("SpawnPlayerCar"):InvokeServer(Truck)
    else
        Systems:WaitForChild("CarInteraction"):WaitForChild("SpawnPlayerCar"):InvokeServer(normalcar)
    end
end

Main:Toggle({
    Name = "Auto Delivery Truck",
	StartingState = false,
    Description = "Use Full-E or Casper for more money(work in USA map only) wait for 40 sec",
	Callback = function(state)
        Driveworld["autodelivery"] = state
    end
})

Main:Dropdown{
    Name = "Select Material",
    StartingText = "Select...",
    Description = nil,
    Items = {"Wood", "Steel"},
    Callback = function(item)
        material = item
    end
}

Main:Toggle({
    Name = "Auto Delivery Material",
	StartingState = false,
    Description = "wait 25 sec",
	Callback = function(state)
        Driveworld["autodeliverymaterial"] = state
        if state == false then
            ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Contracts"):WaitForChild("EndContract"):InvokeServer()
            ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Contracts"):WaitForChild("EndContract"):InvokeServer()
        end
    end
})

Main:Toggle({
    Name = "Auto Delivery Food",
	StartingState = false,
    Description = "wait for 20 sec",
	Callback = function(state)
        Driveworld["autodeliveryfood"] = state
    end
})


task.spawn(function()
    while task.wait(.1) do
        if Driveworld["autodelivery"] then
            local job = lp.PlayerGui.Score.Frame.Jobs
            local jobDistance
            local function getjobdistance(Completedistance)
                local jobDist
                local yeas = string.split(Completedistance, " ")
                for i,v in next, yeas do
                    if tonumber(v) then
                        jobDist = v
                        print("Truck Job Distance : " .. jobDist)
                    end
                end
                return jobDist
            end
            if isvehicle() == false then
                if not getvehicle() then
                    spawnvehicle()
                end
                getchar().HumanoidRootPart.CFrame = getvehicle().PrimaryPart.CFrame
                task.wait(1)
                VirtualInputManager:SendKeyEvent(true, "E", false, game)
                VirtualInputManager:SendKeyEvent(false, "E", false, game)
            end
            repeat task.wait(.1)
                if job.Visible == false then
                    ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Jobs"):WaitForChild("RequestJobStart"):InvokeServer(workspace:WaitForChild("Jobs"):WaitForChild("5ace"),workspace:WaitForChild("Jobs"):WaitForChild("5ace"):WaitForChild("StartPoints"))
                end
            until job.Visible == true or Driveworld["autodelivery"] == false
            print("Start Job")
            repeat task.wait(.1)
                if workspace:FindFirstChild("CompletionRegion") then
                    jobDistance = getjobdistance(workspace:FindFirstChild("CompletionRegion"):FindFirstChild("Primary"):FindFirstChild("DestinationIndicator"):FindFirstChild("Distance").Text)
                end
                if jobDistance and tonumber(jobDistance) < 2.1 then
                    ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Jobs"):WaitForChild("RequestJobStart"):InvokeServer(workspace:WaitForChild("Jobs"):WaitForChild("5ace"),workspace:WaitForChild("Jobs"):WaitForChild("5ace"):WaitForChild("StartPoints"))
                end
            until jobDistance and tonumber(jobDistance) >= 2.1 or Driveworld["autodelivery"] == false
            for i = 1, 40 do
                if not Driveworld["autodelivery"] or not getvehicle() or not getchar() or isvehicle() == false or job.Visible == false then
                    break
                end
                task.wait(1)
            end
            if workspace:FindFirstChild("CompletionRegion") and workspace:FindFirstChild("CompletionRegion"):FindFirstChild("Primary") then
                getvehicle():SetPrimaryPartCFrame(workspace:FindFirstChild("CompletionRegion"):FindFirstChild("Primary").CFrame * CFrame.new(0,3,0))
            end
            task.wait(.5)
            Systems:WaitForChild("Jobs"):WaitForChild("CompleteJob"):InvokeServer()
            task.wait(.5)
            if lp.PlayerGui.JobComplete.Enabled == true then
                Systems:WaitForChild("Jobs"):WaitForChild("CashBankedEarnings"):FireServer()
                for i,v in next, getconnections(lp.PlayerGui.JobComplete.Window.Content.Buttons.CloseButton.MouseButton1Click) do
                    v:Fire()
                end
            end
            print("Completed Job")
        end
    end
end)


GUI:Credit{
    Name = "x3Fall3nAngel",
    Description = "Made the script",
    V3rm = "https://v3rmillion.net/member.php?action=profile&uid=2270329",
    Discord = "https://discord.gg/b9QX5rnkT5"
}

GUI:set_status("Status | Active")
