local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
heyyServer = Tunnel.getInterface("heyy_vipcode")
--[[

  _    _                   _____              
 | |  | |                 / ____|             
 | |__| | ___ _   _ _   _| |     _______ _ __ 
 |  __  |/ _ \ | | | | | | |    |_  / _ \ '__|
 | |  | |  __/ |_| | |_| | |____ / /  __/ |   
 |_|  |_|\___|\__, |\__, |\_____/___\___|_|   
               __/ | __/ |                    
              |___/ |___/                     

		      Códigos VIP

]]

-----------------------------------------------------------------
-- NUI -- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-----------------------------------------------------------------
local menuactive = false
function ToggleActionMenu()
	menuactive = not menuactive
	if menuactive then
		SetNuiFocus(true,true)
		TransitionToBlurred(1000)
		SendNUIMessage({ action = "abrir" })
	else
		SetNuiFocus(false)
		TransitionFromBlurred(1000)
		SendNUIMessage({ action = "fechar" })
	end
end

RegisterNUICallback("validateCode", function(data, cb)
	cb(heyyServer.checkCode(data.code))
end)
RegisterNUICallback("selectVehicles", function(data, cb)
	cb(heyyServer.selectVehicles(data.code, data.vehicles))
end)

-- fechar
RegisterNUICallback("close", function(data)
	ToggleActionMenu()
end)

----------------------------------------------------------------
-- COMANDOS -- - - - - - - - - - - - - - - - - - - - - - - - - -
----------------------------------------------------------------
-- /ativar
RegisterCommand('ativar',function(source,args,rawCommand)   
    ToggleActionMenu()
end)