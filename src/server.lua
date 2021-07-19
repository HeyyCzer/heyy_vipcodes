local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

local asdad = false
local warnedInvalid = false

vRP._prepare("heyy_punishments/get_identifier_by_id", "SELECT * FROM vrp_user_ids WHERE user_id = @user_id")

vRP._prepare("heyy_punishments/get_banid", "SELECT * FROM heyy_punishments WHERE banID = @banID AND revoked = 0")
vRP._prepare("heyy_punishments/check_identifier", "SELECT * FROM heyy_punishments WHERE identifier = @identifier AND revoked = 0")
vRP._prepare("heyy_punishments/add_banid", "INSERT INTO heyy_punishments (identifier, banID, reason, punishmentType) VALUES (@identifier, @banID, @reason, 2)")
vRP._prepare("heyy_punishments/add_tempbanid", "INSERT INTO heyy_punishments (identifier, banID, reason, punishmentType, endTime) VALUES (@identifier, @banID, @reason, 1, @endTime)")
vRP._prepare("heyy_punishments/rem_banid", "UPDATE heyy_punishments SET revoked = 1 WHERE banID = @banID AND revoked = 0")

----------------------------------------------------------------
---- FUNCTIONS -------------------------------------------------
----------------------------------------------------------------

function banUser(identifiers, reason)
    if asdad then
        local banID = generateBanIDCode()
        for _, identifier in pairs(identifiers) do
            vRP.execute("heyy_punishments/add_banid", {
                identifier = identifier,
                banID = banID,
                reason = reason
            })
        end
    end
end

function tempBanUser(identifiers, reason, endTime)
    if asdad then
        local banID = generateBanIDCode()
        for _, identifier in pairs(identifiers) do
            vRP.execute("heyy_punishments/add_tempbanid", {
                identifier = identifier,
                banID = banID,
                reason = reason,
                endTime = endTime
            })
        end
    end
end

function checkUser(identifiers)
    if asdad then
        for _, identifier in pairs(identifiers) do
            local bans = vRP.query("heyy_punishments/check_identifier", {
                identifier = identifier
            })
            if bans[1] ~= nil then
                return false, bans[1]
            end
            Citizen.Wait(0)
        end
    end
    return true
end
function checkBanID(banID)
    if asdad then
        local bans = vRP.query("heyy_punishments/get_banid", {
            banID = banID
        })
        if bans[1] ~= nil then
            return false, bans[1]
        end
        return true
    end
end

function unbanUserByIdentifiers(identifiers)
    if asdad then
        local allowed, data = checkUser(identifiers)
        if not allowed then
            vRP.execute("heyy_punishments/rem_banid", {
                banID = data.banID
            })
        end
    end
end

function unbanUserByBanID(banID)
    if asdad then
        vRP.execute("heyy_punishments/rem_banid", {
            banID = banID
        })
    end
end

----------------------------------------------------------------
---- CHECK ON JOIN ---------------------------------------------
----------------------------------------------------------------

function HeyyVerifyPunishments(name, setKickReason, deferrals)
    local player = source
    local identifiers = GetPlayerIdentifiers(player)

    if asdad then
        deferrals.defer()
        Wait(0)

        local verifyingCard = {
            type = "AdaptiveCard",
            body = {{
                type = "TextBlock",
                size = "ExtraLarge",
                weight = "Bolder",
                text = "Sistema de Punições"
            }, {
                type = "TextBlock",
                wrap = true,
                text = "Aguarde " .. name .. ", estamos verificando suas punições..."
                -- }, {
                -- type = "Image",
                -- url = "https://i.pinimg.com/originals/dc/cc/84/dccc846959dffafa30a836dfacf9bab9.gif",
                -- horizontalAlignment = "Center"
            }},
            ["$schema"] = "http://adaptivecards.io/schemas/adaptive-card.json",
            version = "1.3"
        }

        deferrals.presentCard(verifyingCard)

        local allowed, data = checkUser(identifiers)
        if not allowed then
            Wait(0)
            if data.punishmentType == 1 then
                if data.endTime > os.time() then
                    deferrals.done(string.format("\n\nSistema de Punições\n\nVocê foi temporariamente banido deste servidor. Verifique mais informações abaixo.\n\nMotivo: %s\nExpira em: %s\nTipo: Local\nCódigo do banimento: %s", data.reason, secondsToDate(data.endTime), data.banID))
                else
                    unbanUserByIdentifiers(identifiers)
                    deferrals.done()
                end
            elseif data.punishmentType == 2 then
                deferrals.done(string.format("\n\nSistema de Punições\n\nVocê foi permanentemente banido deste servidor. Verifique mais informações abaixo.\n\nMotivo: %s\nTipo: Local\nCódigo do banimento: %s", data.reason, data.banID))
            end
            return
        end
        Wait(0)
        deferrals.done()
    end
end
AddEventHandler("playerConnecting", HeyyVerifyPunishments)

----------------------------------------------------------------
----- COMMANDS -------------------------------------------------
----------------------------------------------------------------

RegisterCommand(config.commands.tempBan, function(source, args, rawCommand)
    local user_id = vRP.getUserId(source)
    if asdad then
        if vRP.hasPermission(user_id, config.permissions.tempBan) then
            if args[1] and args[2] and args[3] then
                if not tonumber(args[1]) or not tonumber(args[2]) then
                    TriggerClientEvent("Notify", source, "importante", "Uso incorreto do comando! Utilize <b>/" .. config.commands.tempBan .. " <ID> <dias> <motivo>")
                    return
                end

                local dias = tonumber(args[2])
                local target_id = tonumber(args[1])
                local results = vRP.execute("heyy_punishments/get_identifier_by_id", {
                    user_id = target_id
                })

                local identifiers = {}
                for k, v in ipairs(results) do
                    table.insert(identifiers, v.identifier)
                end

                if #identifiers <= 0 then
                    TriggerClientEvent("Notify", source, "aviso", "Estranho. Não encontrei nenhum identificador deste usuário pelo ID.")
                    return
                end

                local reason = extractReason(3, args)
                tempBanUser(identifiers, reason, os.time() + (dias * 86400))
                TriggerClientEvent("Notify", source, "sucesso", "Você baniu o jogador <b>" .. target_id .. "</b> por <b>" .. reason .. "</b> por <b>" .. dias .. " dias</b>. No total <b>" .. #identifiers .. " identificadores</b> foram banidos.")

                local nplayer = vRP.getUserSource(target_id)
                if nplayer then
                    DropPlayer(nplayer, "Você foi temporariamente banido do servidor por " .. dias .. " dia(s).\n\nMotivo:" .. reason)
                end
            else
                TriggerClientEvent("Notify", source, "importante", "Uso incorreto do comando! Utilize <b>/" .. config.commands.tempBan .. " <ID> <dias> <motivo>", 30000)
            end
        else
            TriggerClientEvent("Notify", source, "negado", "Você não tem permissão para usar este comando!")
        end
    else
        TriggerClientEvent("Notify", source, "negado", "Sua licença não é válida!")
    end
end)
RegisterCommand(config.commands.ban, function(source, args, rawCommand)
    local user_id = vRP.getUserId(source)
    if asdad then
        if vRP.hasPermission(user_id, config.permissions.ban) then
            if args[1] and args[2] then
                if not tonumber(args[1]) or not tonumber(args[2]) then
                    TriggerClientEvent("Notify", source, "importante", "Uso incorreto do comando! Utilize <b>/" .. config.commands.ban .. " <ID> <motivo>")
                    return
                end

                local target_id = tonumber(args[1])
                local results = vRP.execute("heyy_punishments/get_identifier_by_id", {
                    user_id = target_id
                })

                local identifiers = {}
                for k, v in ipairs(results) do
                    table.insert(identifiers, v.identifier)
                end

                if #identifiers <= 0 then
                    TriggerClientEvent("Notify", source, "aviso", "Estranho. Não encontrei nenhum identificador deste usuário pelo ID.")
                    return
                end

                local reason = extractReason(2, args)
                banUser(identifiers, reason)
                TriggerClientEvent("Notify", source, "sucesso", "Você baniu o jogador <b>" .. target_id .. "</b> permanentemente por <b>" .. reason .. "</b>. No total <b>" .. #identifiers .. " identificadores</b> foram banidos.")

                local nplayer = vRP.getUserSource(target_id)
                if nplayer then
                    DropPlayer(nplayer, "Você foi permanentemente banido do servidor.\n\nMotivo:" .. reason)
                end
            else
                TriggerClientEvent("Notify", source, "importante", "Uso incorreto do comando! Utilize <b>/" .. config.commands.ban .. " <ID> <motivo>", 30000)
            end
        else
            TriggerClientEvent("Notify", source, "negado", "Você não tem permissão para usar este comando!")
        end
    else
        TriggerClientEvent("Notify", source, "negado", "Sua licença não é válida!")
    end
end)

----------------------------------------------------------------
----- UTILS ----------------------------------------------------
----------------------------------------------------------------

function secondsToDate(seconds)
    return os.date("%H:%M %d/%m/%Y", seconds)
end

function generateStringNumber(format)
    local abyte = string.byte("A")
    local zbyte = string.byte("0")
    local number = ""
    for i = 1, #format do
        local char = string.sub(format, i, i)
        if char == "D" then
            number = number .. string.char(zbyte + math.random(0, 9))
        elseif char == "L" then
            number = number .. string.char(abyte + math.random(0, 25))
        else
            number = number .. char
        end
    end
    return number
end

function generateBanIDCode()
    local containsBanID = nil
    local banID = ""
    repeat
        banID = generateStringNumber("DDLLLDDD")
        containsBanID = not checkBanID(banID)
    until not containsBanID

    return banID
end

function validateLicense(verifySilent)
    PerformHttpRequest("https://license-validator2-heyyczer.vercel.app/licenses/" .. GetCurrentResourceName() .. "/" .. config.licenseKey, function(status, data, headers)
        data = json.decode(data)
        if status == 200 then
            if math.ceil((tonumber(data.endTime) / 1000 - os.time()) / 86400) > 0 then
                asdad = true
                if not verifySilent then print("^2[HeyyPunishments] ^7Licença autenticada com sucesso, sua licença é válida por mais ^2" .. (math.ceil((tonumber(data.endTime) / 1000 - os.time()) / 86400)) .. " dias^7.") end
                return
            end
        end
        if not warnedInvalid then print("^1[HeyyPunishments] ^7Sua licença não é válida! Entre em contato através de nosso Discord.") end
        asdad = false
		warnedInvalid = true
    end)
end

function extractReason(start, args)
    local reason = ""
    for i = start, #args, 1 do
        reason = reason .. "" .. args[i] .. " "
    end
    return reason
end

Citizen.CreateThread(function()
	local silent = false
	while true do
		validateLicense(silent)
		silent = true
		Citizen.Wait(10000)
	end
end)
