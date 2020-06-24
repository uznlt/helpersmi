script_name('Helper for Dvijenec family')
script_author('uznlt')
script_version("0.0.1")
require "lib.moonloader"
local sampev = require "lib.samp.events"
local inicfg = require 'inicfg'
local imgui = require 'imgui'
local encoding = require 'encoding'
			encoding.default = 'CP1251'
			u8 = encoding.UTF8
local directIni = "moonloader\\cfg.ini"
local dlstatus = require ('moonloader').download_status
local tag = "[DH] "
local main_color = 0xAFAFAFAA
local main_color_text = "{5A90CE}"
local color_smi = 0x33FF33AA
local white_color = 0xFFFFFF
local white_color_text = "{FFFFFF}"
local fake_rep_tag_red = "{FF6347}[Информация] "
local fake_rep_pod_red = "{FF6347}[Подсказка] "
local main_window_state = imgui.ImBool(false)
local text_buffer = imgui.ImBuffer(256)
update_state = false
local script_vers = 2
local script_vers_text = "1.11"
local update_url = "https://raw.githubusercontent.com/uznlt/helpersmi/master/update.ini"
local update_path = getWorkingDirectory() .. "/update.ini"
local script_url = "https://raw.githubusercontent.com/uznlt/helpersmi/master/helper.lua?raw=true"
local script_path = thisScript().path
function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end -- когда самп запущен (единоразовая проверка) / цикл с условием
	while not isSampAvailable() do wait (100) end
	downloadUrlToFile(update_url, update_path, function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			updateIni = inicfg.load(nil, update_path)
			if tonumber(updateIni.info.vers) > script_vers then
				sampAddChatMessage ("Есть обновление. Версия: " ..updateIni.info.vers_text, -1)
				update_state = true
			end
			os.remove(update_path)
		end
	end)
	sampAddChatMessage (tag .. "Скрипт успешно загружен. Версия скрипта: " ..script_vers_text ,  main_color)
	sampRegisterChatCommand("frep", cmd_frep)
	sampRegisterChatCommand("nick", cmd_nick)
	sampRegisterChatCommand("addcheck", cmd_addcheck)
	sampRegisterChatCommand("update1", cmd_update1)
	_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	nick = sampGetPlayerNickname(id)
	imgui.Process = false


	while true do -- бесконечная проверка (пока самп активен)
		wait (0)

	if update_state then
		downloadUrlToFile(script_url, script_path, function(id,status)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				sampAddChatMessage("Скрипт успешно обновлен. ",-1)
				thisScript():reload()
			end
		end)
		break
	end
			if main_window_state.v == false then -- close imgui
			imgui.Process = false
		end
	end
end
function cmd_frep (arg)
	local fake_admins = {"Dmitry_Newman", "Monte_Rizzo", "Daddy_Tensize", "Cheryl_Honda", "Leonardo_Termin", "Leo_Williams", "Kenneth_Disney", "Billy_Ramirez", "Alfredo_Williams", "Angel_Aguero", "Ryan_Becker", "Drake_Source", "Morrigan_Maguire", "Nathaniel_Norman", "Chase_Williams", "Jim_Moore", "Dmitriy_Mercer", "Antonio_Disney", "Mihail_Romanov", "Paul_Nicholson"} -- admins 1-2 lvl on 21.06.20
	fake_messanges_adm = {"Не оффтопьте", "Плохо :(", "Не оффтопьте, пожалуйста"}
	if #arg == 0 then
		sampAddChatMessage(tag .. "Синтаксис: /frep <текст>", main_color)
else
		math.randomseed(os.time())
		rand = math.random(1,4)
		randadm = math.random(1, #fake_admins)
		randmessagesadm = math.random(1,#fake_messanges_adm)
		sampAddChatMessage (fake_rep_tag_red .. "{FFFFFF}Вы отправили жалобу: " .. arg,  -1)
		sampAddChatMessage("На Ваш вопрос обязательно ответит администрация! Вы " .. rand ..  " в очереди!", -1)
		sampAddChatMessage("Если за Вами срочно нужно проследить, администрация сделает это вне очереди!", -1)
		lua_thread.create(function()
			wait (6500)
			sampAddChatMessage(fake_rep_pod_red .."{FFFFFF}Администратор " .. fake_admins[rand] .. "{FFFFFF} принялся за ваш репорт!", -1)
		end)
			lua_thread.create(function() -- новый поток
			 	wait(9000)
				--sampShowDialog(id, caption, text, button1, button2, style)
				sampShowDialog(1," ","{FFFFFF}Вам ответил администратор!\n\n{FFFFFF}Ваш вопрос:{c8e464} " .. arg .. "\n{FFFFFF}" ..fake_admins[rand].. ":{c8e464} " ..fake_messanges_adm[rand].. "\n\n","Спасибо", _,  0)
				randid = math.random(0,999)
			 	sampAddChatMessage("{FF6347}Администратор ".. fake_admins[rand] .. "[" .. randid .. "]: {FFFFFF}" .. fake_messanges_adm[rand], -1) -- Выводим текст в чат
	 	end)-- kill
end
end
function cmd_addcheck(arg)
	local mainIni = inicfg.load(nil,directIni)
	mainIni.config.nick=arg
	if inicfg.save(mainIni, directIni) then
	sampAddChatMessage(tag.. " "..arg.. " успешно добавлен", main_color)
end
end
function cmd_nick (arg)
		main_window_state.v = not main_window_state.v
		imgui.Process = main_window_state.v
end
	--sampAddChatMessage(tag .. "Ваш ник {FFFFFF}".. nick ..", ".. main_color_text .. "ваш ИД: {FFFFFF}".. id, main_color)
function cmd_update1(arg)
	sampShowDialog(1000,"Автообновление", "Обновление {FFFFAA} v2.0", "Закрыть",_,0)
end

function sampev.onPlayerJoin(ID)
	if checks then
		table.insert(cqueue, {ID, 0})
	end
end

function sampev.onServerMessage(color, text)
end

function imgui.OnDrawFrame()
	imgui.Begin(u8" ",main_window_state)
	imgui.Text(text_buffer.v)
	x,y,z = getCharCoordinates(PLAYER_PED)
	imgui.Text(u8("Позиция Х: " .. math.floor(x) .. ",Y: " .. math.floor(y) .. ",Z: " .. math.floor(z)))
	if imgui.Button(u8"Кнопка") then
		sampAddChatMessage(u8:decode(text_buffer.v),-1)
	end
	imgui.End()
end
