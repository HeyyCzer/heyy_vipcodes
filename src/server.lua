local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
heyy = {}
Tunnel.bindInterface("heyy_vipcode",heyy)

sCONCE = {}
Proxy.addInterface("vrp_dealership",sCONCE)

vRP._prepare("heyy/get_code","SELECT * FROM vrp_vipcode WHERE code = @code")
vRP._prepare("heyy/rem_code","DELETE FROM vrp_vipcode WHERE code = @code")

local cache = {}
local estoque

Citizen.CreateThread(function()
	estoque = exports["vrp_dealership"]:retrieveEstoque()
end)

function heyy.checkCode(code)
	local user_id = vRP.getUserId(source)
	if code then
        local codigos = vRP.query("heyy/get_code",{ code = code })
        if codigos[1] ~= nil and (cache[code] == nil or cache[code].user_id == user_id) then
			codigos = codigos[1]
			
			local data = {
				user_id = user_id,
				status = 200,
				type = codigos.type,
				vehicles = {},
			}

			if vips[codigos.type].veiculos then
				for vehicleType, amount in pairs(vips[codigos.type].veiculos) do
					if not vehicles[vehicleType].concessionaria then 
						for _, vehModel in pairs(vehicles[vehicleType].vehList) do
							data.vehicles[vehModel] = {
								model = vehModel,
								name = vRP.vehicleName(vehModel),
								type = vehicles[vehicleType].name,
							}
							Citizen.Wait(0)
						end
					else
						for _, vehModel in pairs(estoque) do
							data.vehicles[vehModel] = {
								model = vehModel,
								name = vRP.vehicleName(vehModel),
								type = vehicles[vehicleType].name,
							}
							Citizen.Wait(0)
						end
					end
				end
			end

			cache[code] = data
            return json.encode(data)
		end
		return 404
    end
end


function heyy.selectVehicles(code, selectedVehicles)
	local source = source
	local user_id = vRP.getUserId(source)

	local vipType = cache[code].type
	if selectedVehicles then
		local contagem = {}
		for _, vehicle in pairs(selectedVehicles) do
			local allowed = false
			for vehicleType, amount in pairs(vips[cache[code].type].veiculos) do
				if not vehicles[vehicleType].concessionaria then 
					for _, vehModel in pairs(vehicles[vehicleType].vehList) do
						if vehModel == vehicle then
							allowed = true
							contagem[vehicleType] = (contagem[vehicleType] or 0) + 1
							Citizen.Wait(0)
						end
					end
				else
					for _, vehModel in pairs(estoque) do
						-- for vehModel, _ in pairs(estoque[vehType]) do
							if vehModel == vehicle then
								allowed = true
								Citizen.Wait(0)
								contagem[vehicleType] = (contagem[vehicleType] or 0) + 1
							end
						-- end
					end
				end
			end	
			
			if not allowed then
				TriggerClientEvent("Notify", source, "negado", "Você não pode selecionar o veículo <b>" .. vehicle .. "</b>, ele não faz parte dos benefícios de sua doação!")
				return 403
			end
		end
		
		for tipo, quantidade in pairs(contagem) do
			if quantidade ~= vips[cache[code].type].veiculos[tipo] then
				TriggerClientEvent("Notify", source, "negado", "Você escolheu <b>" .. quantidade .. "/" .. vips[cache[code].type].veiculos[tipo] .. " " .. vehicles[tipo].name .. "</b>")
				return 201
			end
		end
	end

	heyy.deleteCode(code)

	local activatedVehicles = heyy.addVehicles(source, user_id, selectedVehicles)
	local activatedMoney = heyy.activateMoney(source, user_id, code)
	-- if vips[cache[code].type].setagem then
		-- vRP.addUserGroup(user_id, vips[cache[code].type].setagem)
	-- end
	
	sendActivationCode(user_id, code, activatedVehicles, activatedMoney)
	
	return 200
end

function heyy.addVehicles(source, user_id, vehicles)
	local activatedVehicles = ""
	for _, veh in pairs(vehicles) do
		veh = veh + "\n"
		vRP.execute("losanjos/add_vehicle",{ user_id = parseInt(user_id), vehicle = veh, ipva = parseInt(os.time()) })
		TriggerClientEvent("Notify",source,"importante","O veículo <b>" .. vRP.vehicleName(veh) .. "</b> foi adicionado em sua garagem", 10000)
		Citizen.Wait(5)
	end
	return activatedVehicles
end

function heyy.activateMoney(source, user_id, code)
	local activatedMoney = 0
	if vips[cache[code].type].dinheiro then
		activatedMoney = vips[cache[code].type].dinheiro
		vRP.giveBankMoney(user_id, vips[cache[code].type].dinheiro)
		TriggerClientEvent("Notify",source, "sucesso", "Sucesso! O dinheiro da ativação do VIP (<b>R$" .. vips[cache[code].type].dinheiro .. "</b>) foi adicionado em sua conta bancária", 20000)
	end
	return activatedMoney
end

function heyy.deleteCode(code)
	if code then
		vRP.execute("heyy/rem_code", { code = code })
		cache[code] = nil
	end
end


function sendActivationCode(user_id, activatedCode, selectedVehicles, money)
	local embed = {
		{
			["color"] = 16763648,
			["title"] = "VIP ativado",
			["description"] = "**Usuário**: " .. user_id .. "\n**Código:** " .. activatedCode .. "\n**Dinheiro ativado:** R$" .. money .. "\n\n**Veículos selecionados:**\n" .. selectedVehicles
		}
	}
	PerformHttpRequest('https://ptb.discord.com/api/webhooks/862353495570907207/QisX2S9vgoUXhUTOrFWTY07GlLG4edl_FiNkuiYBvaRkCFI8g30DzcpIYS80hbiI5Y1S', function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end