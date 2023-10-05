local defaultDatabase = "https://amethyst-2d368-default-rtdb.firebaseio.com/"; --// Database URL
local authenticationToken = "w6uIM48UY37N9wgiTGN9UUeIoKJtpzDcPBqo6P0G"; --// Authentication Token

--== Variables;
local HttpService = game:GetService("HttpService");
local DataStoreService = game:GetService("DataStoreService");

local BreamService = {};
local UseBream = true;

function BreamService:SetUseBream(value)
	UseBream = value and true or false;
end

function BreamService:GetBream(name, database)
	database = database or defaultDatabase;
	local datastore = DataStoreService:GetDataStore(name);

	local databaseName = database..HttpService:UrlEncode(name);
	local authentication = ".json?auth="..authenticationToken;

	local Bream = {};

	function Bream.GetDatastore()
		return datastore;
	end

	--// Entries Start
	function Bream:GetAsync(directory)
		local data = nil;

		--== Bream Get;
		local getTick = tick();
		local tries = 0; repeat until pcall(function() tries = tries +1;
			data = HttpService:GetAsync(databaseName..HttpService:UrlEncode(directory and "/"..directory or "")..authentication, true);
		end) or tries > 2;
		if type(data) == "string" then
			if data:sub(1,1) == '"' then
				return data:sub(2, data:len()-1);
			elseif data:len() <= 0 then
				return nil;
			end
		end
		return tonumber(data) or data ~= "null" and data or nil;
	end

	function Bream:SetAsync(directory, value, header)
		if not UseBream then return end
		if value == "[]" then self:RemoveAsync(directory); return end;

		header = header or {["X-HTTP-Method-Override"]="PUT"};
		local replyJson = "";
		if type(value) == "string" and value:len() >= 1 and value:sub(1,1) ~= "{" and value:sub(1,1) ~= "[" then
			value = '"'..value..'"';
		end
		local success, errorMessage = pcall(function()
			replyJson = HttpService:PostAsync(databaseName..HttpService:UrlEncode(directory and "/"..directory or "")..authentication, value,
				Enum.HttpContentType.ApplicationUrlEncoded, false, header);
		end);
		if not success then
			warn("BreamService>> [ERROR] "..errorMessage);
			pcall(function()
				replyJson = HttpService:JSONDecode(replyJson or "[]");
			end)
		end
	end

	function Bream:RemoveAsync(directory)
		if not UseBream then return end
		self:SetAsync(directory, "", {["X-HTTP-Method-Override"]="DELETE"});
	end

	function Bream:IncrementAsync(directory, delta)
		delta = delta or 1;
		if type(delta) ~= "number" then warn("BreamService>> increment delta is not a number for key ("..directory.."), delta(",delta,")"); return end;
		local data = self:GetAsync(directory) or 0;
		if data and type(data) == "number" then
			data = data+delta;
			self:SetAsync(directory, data);
		else
			warn("BreamService>> Invalid data type to increment for key ("..directory..")");
		end
		return data;
	end

	function Bream:UpdateAsync(directory, callback)
		local data = self:GetAsync(directory);
		local callbackData = callback(data);
		if callbackData then
			self:SetAsync(directory, callbackData);
		end
	end

	return Bream;
end

return BreamService;
