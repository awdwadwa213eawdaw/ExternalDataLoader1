local SyncUrl = "https://pastebin.com/raw/TfhL3kT1" --Put Your Game Configuration Pastebin Here
local HttpService = game:GetService("HttpService")
local Folder = Instance.new("Folder");Folder.Name="Identification";Folder.Parent=workspace

local function createIntegerValue(name, value)
	local intValue = Instance.new("IntValue")
	intValue.Name = name
	intValue.Value = value
	intValue.Parent = Folder
end

local function loadJSONFromPastebin(pastebinURL)    
	local success, result = pcall(function ()
		local jsonData = HttpService:GetAsync(pastebinURL)
		return jsonData
	end)
	if not success then
		loadJSONFromPastebin(pastebinURL)
		wait(1)
	else
		return HttpService:JSONDecode(result)
	end
end

local jsonTable = loadJSONFromPastebin(SyncUrl)

for name, value in pairs(jsonTable) do
	createIntegerValue(name, value)
end

if not Folder:FindFirstChild("CommunityGroup") then
	local CommunityGroup = Instance.new("IntValue");
	CommunityGroup.Name = "CommunityGroup";
	CommunityGroup.Parent = Folder;	
end

local LoadedF = Instance.new("Folder")
LoadedF.Name = "Loaded"
LoadedF.Parent = Folder