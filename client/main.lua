ESX                           = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

local vaultType = {}

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

function OpenVaultInventoryMenu(data)
	if data.job == ESX.PlayerData.job.name or data.job == 'vault' then
		print(data.needItemLicense)
		vaultType = data
		ESX.TriggerServerCallback("monster_vault:getVaultInventory", function(inventory)
				if not inventory then
					exports['mythic_notify']:SendAlert('error', 'Not have license card')
				else
					TriggerEvent("monster_inventoryhud:openVaultInventory", inventory)
				end
			end,
			data
		)
	else
		exports['mythic_notify']:SendAlert('error', "you not have permission for this job", 5500)
		Citizen.Wait(8000)
	end
end

Citizen.CreateThread(function()
    while ESX == nil or ESX.PlayerData == nil or ESX.PlayerData.job == nil do
        Citizen.Wait(1000)
    end
    print('Object Vault Working')
    for k,v in pairs(Config.Vault) do
		ESX.Game.SpawnLocalObject(Config.VaultBox, v.coords, function(obj)
			SetEntityHeading(obj, v.heading)
			PlaceObjectOnGroundProperly(obj)
			FreezeEntityPosition(obj, true)
		end)
	end
    
end)

-- Key controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local coords = GetEntityCoords(PlayerPedId())
		for k,v in pairs(Config.Vault) do
			local dist = GetDistanceBetweenCoords(coords, v.coords, true)
			if dist < 2 then
				ESX.ShowHelpNotification("Druk op E om de kluis van de "..k.. " te openen")
				
				if IsControlJustReleased(0, 38) then
					OpenVaultInventoryMenu({job = k, needItemLicense = v.needItemLicense, InfiniteLicense = v.InfiniteLicense})
				else
					break
				end
			end
		end
		
	end
end)

function getMonsterVaultLicense()
	return vaultType
end
