local _f = require(script.Parent)

local marketplaceService = game:GetService('MarketplaceService')
local players = game:GetService('Players')
local network = _f.Network
local purchaseHistory = {}

marketplaceService.ProcessReceipt = function(receiptInfo)
	local purchaseId = receiptInfo.PlayerId .. '_' .. receiptInfo.PurchaseId
	if purchaseHistory[purchaseId] then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	for _, p in pairs(players:GetPlayers()) do
		if p.UserId == receiptInfo.PlayerId and _f.PlayerDataService[p] then
			_f.PlayerDataService[p]:onDevProductPurchased(receiptInfo.ProductId)
			--			network:post('PurchaseCompleted', p, receiptInfo.ProductId, true)
			purchaseHistory[purchaseId] = true
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	end
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

marketplaceService.PromptPurchaseFinished:connect(function(player, assetId, isPurchased)
	if isPurchased then
		_f.PlayerDataService[player]:onAssetPurchased(assetId)
	end
	--	network:post('PromptPurchaseFinished', player, assetId, isPurchased)
end)

return 0