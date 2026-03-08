---@diagnostic disable: undefined-global
local sdk = sdk
local re = re
local imgui = imgui
local json = json

local CONFIG_PATH = 'hunt_solo_config.json'
local MAX_LOG_LINES = 100

local LANG = {
    ENG = 1,
    SPA = 2,
    JAP = 3,
    CHI = 4,
}

local LANG_OPTIONS = {
    "English",
    "Español",
    "日本語",
    "中文",
}


local CONFIG = {
    mod_name = 'Hunt Solo',
    version = '2.1.1',
    author = 'Cylfox',
    language = LANG.ENG,
    show_log_window = false,
    show_json_dump_window = false,
    is_advisor_target_skipped = true,
    is_advisor_target_skipped_in_camp_areas = true,
    is_npc_support_hunters_target_skipped = true,
    is_npc_support_hunters_target_skipped_in_mainstory = false,
    is_standby_otomo_behavior_blocked = true,
    is_standby_otomo_behavior_blocked_in_camp_areas = true,
    is_porter_invisible_when_fishing = true,
    is_porter_invisible_when_not_riding = true,
    is_porter_invisible_in_camp_areas = true,
}

local TEMP = {
    is_config_updated = false,
    log_list = {},
    json_dump = {},

    is_player_in_base_camp = false,
    is_player_fishing = false,
    is_player_dead = false,

    is_player_riding_porter = false,
    is_porter_called = false,
    is_player_finished_riding_porter = true,

    is_loading_npc_manager = false,
    is_loading_player_manager = false,

    is_quest_end_showing = false,

    otomo_standby_active = false,
    otomo_standby_cooldown = false,
    otomo_character = nil,

    otomo_locked_position = nil,
}


local CACHE = {
    mission_type = { max_time = 5 },
    tent_area_info = { max_time = 3 },
}

local TIMER = {
    npc_manager_loading = { delay = 10 },
    player_manager_loading = { delay = 10 },
    otomo_standby_cooldown = { delay = 4 },

    call_porter = { delay = 6 },
    ride_porter = { delay = 3 },
    player_dead = { delay = 3 }
}

local DUMP = {}


local STRINGS = {
    language = {
        [LANG.ENG] = 'Language',
        [LANG.SPA] = 'Idioma',
        [LANG.JAP] = '言語',
        [LANG.CHI] = '语言',
    },
    is_advisor_target_skipped = {
        [LANG.ENG] = 'Skip Alma tracking',
        [LANG.SPA] = 'Saltar seguimiento de Alma',
        [LANG.JAP] = 'アルマ追跡をスキップ',
        [LANG.CHI] = '跳过阿尔玛追踪',
    },
    is_advisor_target_skipped_in_camp_areas = {
        [LANG.ENG] = 'Skip Alma tracking in camp areas (caution)',
        [LANG.SPA] = 'Saltar seguimiento de Alma en campamentos (cuidado)',
        [LANG.JAP] = 'キャンプエリアでアルマ追跡をスキップ（注意）',
        [LANG.CHI] = '在营地区域跳过阿尔玛追踪（注意）',
    },
    is_npc_support_hunters_target_skipped = {
        [LANG.ENG] = 'Skip NPC Support Hunters tracking',
        [LANG.SPA] = 'Saltar seguimiento de Cazadores de apoyo (NPC)',
        [LANG.JAP] = 'NPCサポートハンターの追跡をスキップ',
        [LANG.CHI] = '跳过NPC支援猎人追踪',
    },
    is_npc_support_hunters_target_skipped_in_mainstory = {
        [LANG.ENG] = 'Skip NPC Support Hunters tracking in main story quests (caution)',
        [LANG.SPA] = 'Saltar seguimiento de Cazadores de apoyo en misiones principales (cuidado)',
        [LANG.JAP] = 'メインクエストでNPCサポートハンターの追跡をスキップ（注意）',
        [LANG.CHI] = '在主线任务中跳过NPC支援猎人追踪（注意）',
    },
    is_standby_otomo_behavior_blocked = {
        [LANG.ENG] = 'True Standby Palico',
        [LANG.SPA] = 'Palico en espera de verdad',
        [LANG.JAP] = '真のスタンバイアイルー',
        [LANG.CHI] = '真实待命随从猫',
    },
    is_standby_otomo_behavior_blocked_in_camp_areas = {
        [LANG.ENG] = 'True Standby Palico in camp areas (caution)',
        [LANG.SPA] = 'Palico en espera de verdad en campamentos (cuidado)',
        [LANG.JAP] = 'キャンプエリアで真のスタンバイアイルー（注意）',
        [LANG.CHI] = '在营地区域真实待命随从猫（注意）',
    },
    is_porter_invisible_when_fishing = {
        [LANG.ENG] = 'Hide Seikret when fishing',
        [LANG.SPA] = 'Ocultar Seikret al pescar',
        [LANG.JAP] = '釣り中にセクレトを非表示',
        [LANG.CHI] = '钓鱼时隐藏塞克雷特',
    },
    is_porter_invisible_when_not_riding = {
        [LANG.ENG] = 'Hide Seikret when not riding it',
        [LANG.SPA] = 'Ocultar Seikret mientras no se monte',
        [LANG.JAP] = '騎乗していないときにセクレトを非表示',
        [LANG.CHI] = '未骑乘时隐藏塞克雷特',
    },
    is_porter_invisible_in_camp_areas = {
        [LANG.ENG] = 'Hide Seikret in camp areas',
        [LANG.SPA] = 'Ocultar Seikret en campamentos',
        [LANG.JAP] = 'キャンプエリアでセクレトを非表示',
        [LANG.CHI] = '在营地区域隐藏塞克雷特',
    },
    show_log_window = {
        [LANG.ENG] = 'Show log window',
        [LANG.SPA] = 'Mostrar logs',
        [LANG.JAP] = 'ログウィンドウを表示',
        [LANG.CHI] = '显示日志窗口',
    },
    show_json_dump_window = {
        [LANG.ENG] = 'Show dump window',
        [LANG.SPA] = 'Mostrar ventana con las variables',
        [LANG.JAP] = 'ダンプウィンドウを表示',
        [LANG.CHI] = '显示转储窗口',
    },
}


-- UTILS

local function get_mod_name()
    local mod_name = CONFIG and CONFIG.mod_name or 'Hunt Solo'
    local version = CONFIG and CONFIG.version or 'X.X.X'
    return mod_name .. ' v' .. version
end

local function init_config()
    if json ~= nil then
        local config_file = json.load_file(CONFIG_PATH)
        if config_file ~= nil then
            if config_file.version ~= CONFIG.version then
                -- save new config first
                config_file.version = CONFIG.version
                json.dump_file(CONFIG_PATH, CONFIG)
            end

            CONFIG = config_file
        else
            json.dump_file(CONFIG_PATH, CONFIG)
        end
    end
end

local function save_config()
    if TEMP.is_config_updated and json ~= nil then
        json.dump_file(CONFIG_PATH, CONFIG)
        TEMP.is_config_updated = false
    end
end

local function log(text)
    if show_log_window == false then
        return
    end

    local safe_text = text ~= nil and tostring(text) or '[nil]'
    table.insert(TEMP.log_list, safe_text)

    while #TEMP.log_list > MAX_LOG_LINES do
        table.remove(TEMP.log_list, 1)
    end
end

local function log_dump_count(key)
    DUMP[key] = (DUMP[key] or 0) + 1
end

local function display_json(data)
    if type(data) ~= 'table' then
        imgui.text('Invalid JSON data! Expected table.')
        return
    end

    for key, value in pairs(data) do
        if type(value) == 'table' then
            if imgui.tree_node(key) then
                display_json(value)
                imgui.tree_pop()
            end
        elseif type(value) == 'string' then
            imgui.text(string.format('%s: %s', key, value))
        elseif type(value) == 'number' then
            local key_lc = tostring(key):lower()
            if key_lc:find('time') or key_lc:find('clock') then
                imgui.text(string.format('%s: %.2f (s)', key, value))
            elseif value == math.floor(value) then
                imgui.text(string.format('%s: %d', key, value))
            else
                imgui.text(string.format('%s: %.2f', key, value))
            end
        elseif type(value) == 'boolean' then
            imgui.text(string.format('%s: %s', key, value and 'true' or 'false'))
        elseif value == nil then
            imgui.text(string.format('%s: nil', key))
        else
            imgui.text(string.format('%s: <%s>', key, tostring(value)))
        end
    end
end

local function setup_timer(key)
    if not TIMER[key] then
        TIMER[key] = {
            ready = nil,
            assign = nil,
        }
        log('> Setup timer for ' .. key)
    end

    return TIMER[key]
end

local function update_timer(delayed_variable)
    local timer = setup_timer(delayed_variable)
    timer.ready = os.clock()
    local latest_ready_time = timer.ready or os.clock()
    timer.assign = latest_ready_time + timer.delay
    log('> Delay ' .. delayed_variable .. ' ' .. tostring(timer.delay) .. 's')
end

local function evaluate_timer(delayed_variable, fn)
    local current_time = os.clock()
    local timer = TIMER[delayed_variable]
    if timer and timer.assign and current_time >= timer.assign then
        fn()
        timer.assign = nil
        timer.ready = nil
        log('> Delay ' .. delayed_variable .. ' finished')
    end
end

local function setup_var_cache(key)
    if not CACHE[key] then
        CACHE[key] = {
            expiration_time = nil,
            value = nil,
        }
        log('> Setup cache for ' .. key)
    end

    return CACHE[key]
end

local function get_var_cache(key)
    setup_var_cache(key)

    local current_time = os.clock()
    if CACHE[key].expiration_time and current_time < CACHE[key].expiration_time then
        return CACHE[key].value
    end
    return nil
end

local function update_var_cache(key, new_value)
    local current_time = os.clock()

    CACHE[key].value = new_value
    CACHE[key].expiration_time = current_time + CACHE[key].max_time

    log('> update_var_cache() ' .. key)
end

local function apply_config_changes(changes)
    for _, change in ipairs(changes) do
        local is_changed, key, value = table.unpack(change)
        if is_changed then
            CONFIG[key] = value
            TEMP.is_config_updated = true
        end
    end

    return TEMP.is_config_updated
end

local function get_string(key)
    local entry = STRINGS[key]
    if not entry then
        return 'error:missing_entry'
    end
    return entry[CONFIG.language] or entry[LANG.ENG] or key
end

local function render_checkbox(config_key)
    local label = get_string(config_key)
    local is_changed, value = imgui.checkbox(label, CONFIG[config_key])
    return is_changed, config_key, value
end

local function render_combobox(config_key, options)
    local label = get_string(config_key)
    local is_changed, value = imgui.combo(label, CONFIG[config_key], options)
    return is_changed, config_key, value
end

local function render_log_window()
    if imgui.begin_window(get_mod_name() .. ' - Logs') then
        if imgui.button('Clear Log', 100, 30) then
            TEMP.log_list = {}
        end
        if imgui.begin_list_box(label, imgui.get_window_size()) then
            if TEMP.log_list then
                for i, item in ipairs(TEMP.log_list) do
                    imgui.text(item)
                    imgui.set_scroll_y(imgui.get_scroll_max_y())
                end
            end
            imgui.end_list_box()
        end

        imgui.end_window()
    end
end

local function render_json_dump_window()
    if imgui.begin_window(get_mod_name() .. ' - Dump') then
        display_json(TEMP.json_dump)
        imgui.end_window()
    end
end

local function is_game_loading()
    if TEMP.is_loading_npc_manager or TEMP.is_loading_player_manager then
        return true
    end
    return false
end

local function safe_prehook(prehook)
    return function(args)
        if is_game_loading() then
            return sdk.PreHookResult.CALL_ORIGINAL
        end
        return prehook(args)
    end
end


-- GAME FUNCTIONS

local function get_npc_id(npc_accessor)
    -- Known NpcIds
    --
    -- 8 - Alma
    -- 6 - Rosso
    -- 9 - Olivia
    -- 27 - Alessa

    -- app::NpcAccessor
    if not npc_accessor then return nil end

    -- _ContextHolder (app::cNpcContextHolder*)
    local context_holder = npc_accessor:get_field('_ContextHolder')
    if not context_holder then return nil end

    -- _Npc (app::cNpcContext*)
    local npc_context = context_holder:get_field('_Npc')
    if not npc_context then return nil end

    -- NpcID (int32_t)
    local npc_id = npc_context:get_field('NpcID')

    return npc_id
end

local function is_master_player(hunter_character)
    -- local is_master = hunter_character:get_IsMaster()
    local is_user_control = hunter_character:get_IsUserControl()

    local hunter_extend = hunter_character:get_HunterExtend()

    local is_master = hunter_extend:get_IsMaster()
    local is_npc = hunter_extend:get_IsNpc()
    local is_advisor = hunter_extend:get_IsAdvisor()
    local is_quest_partner = hunter_extend:get_IsQuestPartner()

    return is_master and is_user_control and not is_npc and not is_advisor and not is_quest_partner
end

local function is_otomo_accompany()
    local otomo_manager = sdk.get_managed_singleton("app.OtomoManager")
    local master_otomo_info = otomo_manager:getMasterOtomoInfo()
    local is_accompany = false
    if master_otomo_info ~= nil then
        is_accompany = master_otomo_info._ContextHolder:get_Otomo():get_IsAccompany()
    end

    return is_accompany
end

local function is_my_otomo(otomo_character)
    if not otomo_character then return false end
    local otomo_context = otomo_character:get_OtomoContext()

    local is_master = otomo_context:get_IsMaster()
    local is_master_my_otomo = otomo_context:get_IsMasterMyOtomo()
    local is_npc = otomo_context:get_IsNPC()
    -- local member_index_valid = otomo_context:get_MemberIndexValid()

    return is_master and is_master_my_otomo and not is_npc
end

local function get_tent_area_info()
    local cached_var = get_var_cache('tent_area_info')
    if cached_var then return cached_var end

    local manager = sdk.get_managed_singleton('app.PlayerManager')
    if not manager then return nil end

    local master_player_info = manager:getMasterPlayerInfo()
    if not master_player_info then return nil end

    local character = master_player_info:get_Character()
    if not character then return nil end

    local context = character:get_HunterContext()
    if not context then return nil end

    local tent_area_info = context:get_TentAreaInfo()
    if not tent_area_info then return nil end

    update_var_cache('tent_area_info', tent_area_info)

    return tent_area_info
end

local function is_player_in_tent_area()
    local tent_area_info = get_tent_area_info()

    if not tent_area_info then
        log('> no TentAreaInfo')
        return false
    end

    return tent_area_info:get_IsInTentArea() or false
end

local function is_player_in_camp_areas()
    return TEMP.is_player_in_base_camp or is_player_in_tent_area()
end

local function get_current_quest_type()
    -- Types:
    --
    -- 0 - MAINSTORY
    -- 1 - SIDESTORY
    -- 2 - FREEQUEST
    -- 3 - TUTORIAL
    -- 4 - KEEPQUEST
    -- 5 - INSTANTQUEST
    -- 6 - STREAM_EVENTQUEST
    -- 7 - STREAM_CHALLENGEQUEST
    -- 8 - TOURNAMENTQUEST
    -- 9 - TA_FREEQUEST
    -- 10 - TRIALQUEST
    -- 11 - MAX

    local cached_var = get_var_cache('mission_type')
    if cached_var then return cached_var end

    local mission_manager = sdk.get_managed_singleton('app.MissionManager')
    if not mission_manager then return -1 end

    local quest_director = mission_manager:get_QuestDirector()
    if not quest_director then return -2 end

    TEMP.is_quest_end_showing = quest_director:isQuestEndShowing()
    -- DUMP.isPlayingQuest = quest_director:isPlayingQuest()
    -- DUMP.isQuestClearShowing = quest_director:isQuestClearShowing()
    -- DUMP.isQuestResult = quest_director:isQuestResult()

    local quest_data = quest_director:get_QuestData()
    if not quest_data then return -3 end

    local mission_type = quest_data:get_MissionType() or -4

    update_var_cache('mission_type', mission_type)

    return mission_type
end

local function is_current_quest_mainstory()
    return get_current_quest_type() == 0
end

local function is_otomo_original_behavior_enabled()
    if is_otomo_accompany() or
        TEMP.is_player_dead or
        is_current_quest_mainstory() then
        return true
    end

    local in_camp = is_player_in_camp_areas()

    -- In camp areas: use camp toggle independently
    if in_camp then
        if not CONFIG.is_standby_otomo_behavior_blocked_in_camp_areas then
            return true
        end
        return false
    end

    -- Outside camp: use main toggle independently
    if not CONFIG.is_standby_otomo_behavior_blocked then
        return true
    end

    return false
end

local function is_porter_invisible_when_not_riding_enabled()
    if not CONFIG.is_porter_invisible_when_not_riding or
        TEMP.is_porter_called or
        TEMP.is_player_riding_porter or
        not TEMP.is_player_finished_riding_porter or
        (not CONFIG.is_porter_invisible_in_camp_areas and is_player_in_camp_areas()) or
        TEMP.is_player_dead or
        TEMP.is_quest_end_showing or
        is_current_quest_mainstory() then
        return false
    end
    return true
end

local function start_otomo_standby_cooldown()
    TEMP.otomo_standby_cooldown = true
    TEMP.otomo_standby_active = false
    TEMP.otomo_character = nil
    TEMP.otomo_locked_position = nil
    update_timer('otomo_standby_cooldown')
    log('> Otomo standby cooldown started')
end

local function otomo_controller_entity_handler(args)
    if TEMP.otomo_standby_cooldown then return sdk.PreHookResult.CALL_ORIGINAL end
    local master_otomo_controller_entity = sdk.to_managed_object(args[2])
    -- local otomo_character = controller:get_field('<Character>k__BackingField')
    local otomo_character = master_otomo_controller_entity:get_Character()

    if not is_my_otomo(otomo_character) or
        is_otomo_original_behavior_enabled() then
        return sdk.PreHookResult.CALL_ORIGINAL
    end

    -- these does not work but might be related to stop otomo motion once started
    -- master_otomo_controller_entity:stopNavigation()
    -- master_otomo_controller_entity:setGoaTreePause()
    -- master_otomo_controller_entity:resetDesireAll()
    -- master_otomo_controller_entity:resetStackMoveInfoList()
    -- master_otomo_controller_entity:resetBattle()

    log('SKIP > otomo_controller_entity_handler() OTOMO')
    return sdk.PreHookResult.SKIP_ORIGINAL
end

local function otomo_entity_update_handler(args)
    if TEMP.otomo_standby_cooldown then return sdk.PreHookResult.CALL_ORIGINAL end

    local master_otomo_controller_entity = sdk.to_managed_object(args[2])
    local otomo_character = master_otomo_controller_entity:get_Character()

    if not is_my_otomo(otomo_character) or
        is_otomo_original_behavior_enabled() then
        if TEMP.otomo_standby_active then
            TEMP.otomo_standby_active = false
            TEMP.otomo_character = nil
            TEMP.otomo_locked_position = nil
        end
        return sdk.PreHookResult.CALL_ORIGINAL
    end

    TEMP.otomo_standby_active = true
    TEMP.otomo_character = otomo_character

    -- Only interfere when palico is on the ground.
    -- If it's on the Seikret (fast travel) get_Landed() returns false — release the lock
    -- so the game can handle travel and spawning at the destination freely.
    if not otomo_character:get_Landed() then
        if TEMP.otomo_locked_position then
            log('> Otomo not landed while locked (Seikret?), starting cooldown')
            start_otomo_standby_cooldown()
        end
        return sdk.PreHookResult.CALL_ORIGINAL
    end

    -- Palico is on the ground.
    if TEMP.otomo_locked_position then
        local go = otomo_character:get_GameObject()
        local transform = go and go:get_Transform()
        if not transform then
            -- Transform unavailable — palico may be spawning; release lock to be safe
            start_otomo_standby_cooldown()
            return sdk.PreHookResult.CALL_ORIGINAL
        end
        local pos = transform:get_Position()
        if not pos then
            start_otomo_standby_cooldown()
            return sdk.PreHookResult.CALL_ORIGINAL
        end
        local lp = TEMP.otomo_locked_position
        local dx = pos.x - lp.x
        local dz = pos.z - lp.z
        if dx*dx + dz*dz > 25 then  -- moved >5 units from locked position
            log('> Otomo moved from locked position, starting cooldown')
            start_otomo_standby_cooldown()
            return sdk.PreHookResult.CALL_ORIGINAL
        end
        master_otomo_controller_entity:selectTarget(32)
        return sdk.PreHookResult.SKIP_ORIGINAL
    end

    -- Not yet locked — clear follow target and wait for idle
    master_otomo_controller_entity:selectTarget(32)  -- THINK_TARGET_TYPE.NONE = 32

    local ok, action = pcall(function() return otomo_character:get_CurrentAction() end)
    if ok and action then
        local ok2, aname = pcall(function() return action:get_type_definition():get_name() end)
        if ok2 and aname == 'cIdle' then
            local go = otomo_character:get_GameObject()
            local transform = go and go:get_Transform()
            if transform then
                local p = transform:get_Position()
                -- Store as plain Lua numbers so comparisons are always against the snapshot
                TEMP.otomo_locked_position = { x = p.x, y = p.y, z = p.z }
                log('> Locked otomo position in idle')
            end
        end
    end

    return sdk.PreHookResult.CALL_ORIGINAL
end

local function call_porter_handler(args)
    -- Note: Looks like cPlayerBTableCommandWork argument is called by any action?
    -- Other actions have as an argument the integer 1

    if args[3] == nil then
        return sdk.PreHookResult.CALL_ORIGINAL
    end

    local ok, int_val = pcall(sdk.to_int64, args[3])
    if ok and int_val == 1 then
        return sdk.PreHookResult.CALL_ORIGINAL
    end

    local player_b_table_command_work = sdk.to_managed_object(args[3])
    if not player_b_table_command_work then
        return sdk.PreHookResult.CALL_ORIGINAL
    end

    if not player_b_table_command_work.get_Character then
        return sdk.PreHookResult.CALL_ORIGINAL
    end

    local hunter_character = player_b_table_command_work:get_Character()

    if not CONFIG.is_porter_invisible_when_not_riding or
        not is_master_player(hunter_character) then
        return sdk.PreHookResult.CALL_ORIGINAL
    end

    log('--> call porter!')
    TEMP.is_porter_called = true
    update_timer('call_porter')
end

local function do_call_porter_handler()
    if not CONFIG.is_porter_invisible_when_not_riding then
        return sdk.PreHookResult.CALL_ORIGINAL
    end

    log('--> call porter! (doCall)')
    TEMP.is_porter_called = true
    update_timer('call_porter')
end


init_config()


-- IS PLAYER IN BASE CAMP

sdk.hook(
    sdk.find_type_definition('app.snd_user_data.SoundLifeAreaMusicActionListData.LifeAreaMusicAction'):get_method(
        'executeEnterAction(System.Int32)'),
    function()
        -- Called by app.LifeAreaMusicManager.enterLifeArea()
        -- local enter_action_count = sdk.to_int64(args[3])
        log('--> executeEnterAction(...)')
        TEMP.is_player_in_base_camp = true
    end
)

sdk.hook(
    sdk.find_type_definition('app.snd_user_data.SoundLifeAreaMusicActionListData.LifeAreaMusicAction'):get_method(
        'executeExitAction(System.Int32)'),
    function()
        -- Called by app.LifeAreaMusicManager.updateStatus()
        -- local exit_action_count = sdk.to_int64(args[3])
        log('--> executeExitAction(...)')
        TEMP.is_player_in_base_camp = false
    end
)


-- IS PLAYER FISHING

sdk.hook(
    sdk.find_type_definition('app.PlayerCommonSubAction.cUseItemFishingRod'):get_method(
        'doEnter()'),
    function()
        log('--> cUseItemFishingRod.doEnter()')
        TEMP.is_player_fishing = true
    end
)

sdk.hook(
    sdk.find_type_definition('app.PlayerCommonSubAction.cEndItemFishingRod'):get_method(
        'doEnter()'),
    function()
        log('--> cEndItemFishingRod.doEnter()')
        TEMP.is_player_fishing = false
    end
)


-- IS GAME LOADING

sdk.hook(
    sdk.find_type_definition('app.NpcManager'):get_method('evLoadBefore()'),
    function()
        log('--> NpcManager.evLoadBefore()')
        TEMP.is_loading_npc_manager = true
        TEMP.otomo_warped_to_player = false
        start_otomo_standby_cooldown()
    end
)

sdk.hook(
    sdk.find_type_definition('app.NpcManager'):get_method('evLoadEnd()'),
    function()
        log('--> NpcManager.evLoadEnd()')
        update_timer('npc_manager_loading')
        update_timer('otomo_standby_cooldown')
    end
)

sdk.hook(
    sdk.find_type_definition('app.PlayerManager'):get_method('evLoadBefore()'),
    function()
        log('--> PlayerManager.evLoadBefore()')
        TEMP.is_loading_player_manager = true
        start_otomo_standby_cooldown()
    end
)

sdk.hook(
    sdk.find_type_definition('app.PlayerManager'):get_method('evLoadEnd()'),
    function()
        log('--> PlayerManager.evLoadEnd()')
        update_timer('player_manager_loading')
        update_timer('otomo_standby_cooldown')
    end
)


-- IS PLAYER DEAD

sdk.hook(
    sdk.find_type_definition("app.PlayerCommonAction.cDieBase"):get_method("doUpdate()"),
    function()
        log('> cDieBase.doUpdate()')
        TEMP.is_player_dead = true
        update_timer('player_dead')
    end)


-- ADVISOR AND SUPPORT HUNTERS BEHAVIOR

sdk.hook(
    sdk.find_type_definition('app.NpcPartnerUtil'):get_method(
        'getTarget(app.NpcAccessor, app.NpcPartnerDef.STREAK_TARGET_TYPE_Fixed)'),
    safe_prehook(function(args)
        local npc_accessor = sdk.to_managed_object(args[3])
        local npc_id = get_npc_id(npc_accessor)

        if CONFIG.is_advisor_target_skipped and npc_id == 8 then
            if (not CONFIG.is_advisor_target_skipped_in_camp_areas and is_player_in_camp_areas()) or
                is_current_quest_mainstory() then
                return sdk.PreHookResult.CALL_ORIGINAL
            end

            log('SKIP --> getTarget(...) ADVISOR')
            return sdk.PreHookResult.SKIP_ORIGINAL
        elseif (CONFIG.is_npc_support_hunters_target_skipped and npc_id ~= 8) or
            (CONFIG.is_npc_support_hunters_target_skipped_in_mainstory and npc_id ~= 8 and is_current_quest_mainstory()) then
            log('SKIP --> getTarget(...) OTHER(' .. npc_id .. ')')
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end)
)


-- OTOMO BEHAVIOR

-- Other useful functions
-- app.cMasterOtomoControllerEntity.selectTarget(app.OtomoDef.THINK_TARGET_TYPE)
-- app.cMasterOtomoControllerEntity.entityLateUpdate()
-- app.OtomoCharacter.setActionRequestVerify(ace.ACTION_ID, app.OtomoDef.APPEND_DATA_TYPE)

-- These two are for preventing movements
sdk.hook(
    sdk.find_type_definition('app.cMasterOtomoControllerEntity'):get_method(
        'startNavigation(System.Boolean)'),
    safe_prehook(otomo_controller_entity_handler)
)

sdk.hook(
    sdk.find_type_definition('app.cOtomoControllerEntityBase'):get_method(
        'entityStart()'),
    safe_prehook(otomo_controller_entity_handler)
)

-- Makes palico stuck and locks its position to prevent infinite run animation
sdk.hook(
    sdk.find_type_definition('app.cMasterOtomoControllerEntity'):get_method(
        'entityUpdate()'),
    safe_prehook(otomo_entity_update_handler)
)



-- PORTER BEHAVIOR

-- Other useful functions
-- app.PlayerCommonSubAction.cPorterRideStart.doEnter()
-- app.WpCommonSubAction.cCallPorter.doEnter()
-- app.PlayerCommonSubAction.cCallPorter.doUpdate()
-- app.btable.PlCommand.cPorterAskToRescure.enter(app.cPlayerBTableCommandWork)

sdk.hook(
    sdk.find_type_definition('app.btable.PlCommand.cPorterAskToRescure'):get_method(
        'callPorterRescue(app.cPlayerBTableCommandWork, System.Boolean)'),
    safe_prehook(call_porter_handler)
)

sdk.hook(
    sdk.find_type_definition('app.PlayerCommonSubAction.cCallPorter'):get_method(
        'doCall()'),
    safe_prehook(do_call_porter_handler)
)

sdk.hook(
    sdk.find_type_definition('app.PorterUtil'):get_method(
        'isVisibleInLifeArea(app.PorterCharacter)'),
    safe_prehook(function(args)
        local porter_character = sdk.to_managed_object(args[2])
        local context = porter_character:get_Context()
        local id = context:get_PtID()                  -- 0 player 1 advisor
        local unique_index = context:get_UniqueIndex() -- 0 player 103 advisor

        local storage = thread.get_hook_storage()
        storage['porter_id'] = id
        storage['porter_unique_index'] = unique_index

        -- NOTE: Id 0 is EVERY PLAYER SEIKRET
        if id ~= 0 and unique_index ~= 0 or not CONFIG.is_porter_invisible_when_not_riding then
            return sdk.PreHookResult.CALL_ORIGINAL
        end

        local was_player_riding = TEMP.is_player_riding_porter
        TEMP.is_player_riding_porter = porter_character:get_IsRiding()

        if TEMP.is_player_riding_porter and not was_player_riding then
            TEMP.is_player_finished_riding_porter = false
        end
        if TEMP.is_player_riding_porter and not TEMP.is_player_finished_riding_porter then
            update_timer('ride_porter')
        end
    end),
    function(retval)
        local storage = thread.get_hook_storage()
        local id = storage['porter_id']
        local unique_index = storage['porter_unique_index']
        if id and id == 0 and unique_index and unique_index == 0 then
            if (CONFIG.is_porter_invisible_when_fishing and TEMP.is_player_fishing) or
                (is_porter_invisible_when_not_riding_enabled()) then
                log('--> isVisibleInLifeArea(...) false')
                return false
            end
        end

        return retval
    end
)


re.on_frame(function()
    evaluate_timer('npc_manager_loading', function()
        TEMP.is_loading_npc_manager = false
    end)
    evaluate_timer('otomo_standby_cooldown', function()
        TEMP.otomo_standby_cooldown = false
        log('> Otomo standby cooldown ended')
    end)
    evaluate_timer('player_manager_loading', function()
        TEMP.is_loading_player_manager = false
    end)
    evaluate_timer('call_porter', function()
        TEMP.is_porter_called = false
    end)
    evaluate_timer('ride_porter', function()
        TEMP.is_player_finished_riding_porter = true
    end)
    evaluate_timer('player_dead', function()
        TEMP.is_player_dead = false
    end)

    -- No position forcing here — SKIP_ORIGINAL in entityUpdate holds the palico in place.
    -- Forcing position fought with the Seikret during fast travel, preventing the palico from traveling.
end)


re.on_draw_ui(function()
    local changes = {}

    if imgui.tree_node(get_mod_name()) then
        table.insert(changes, { render_combobox('language', LANG_OPTIONS) })
        imgui.spacing()
        table.insert(changes, { render_checkbox('is_advisor_target_skipped') })
        table.insert(changes, { render_checkbox('is_advisor_target_skipped_in_camp_areas') })
        table.insert(changes, { render_checkbox('is_npc_support_hunters_target_skipped') })
        table.insert(changes, { render_checkbox('is_npc_support_hunters_target_skipped_in_mainstory') })
        table.insert(changes, { render_checkbox('is_standby_otomo_behavior_blocked') })
        table.insert(changes, { render_checkbox('is_standby_otomo_behavior_blocked_in_camp_areas') })
        table.insert(changes, { render_checkbox('is_porter_invisible_when_fishing') })
        table.insert(changes, { render_checkbox('is_porter_invisible_when_not_riding') })
        table.insert(changes, { render_checkbox('is_porter_invisible_in_camp_areas') })
        imgui.spacing()
        if imgui.tree_node('Developer settings') then
            table.insert(changes, { render_checkbox('show_log_window') })
            table.insert(changes, { render_checkbox('show_json_dump_window') })
            imgui.tree_pop()
        end

        if apply_config_changes(changes) then
            save_config()
        end

        imgui.tree_pop()
    end

    if CONFIG.show_log_window then
        render_log_window()
    end

    if CONFIG.show_json_dump_window then
        TEMP.json_dump = {
            cache = CACHE,
            temp = TEMP,
            functions = {
                is_player_in_tent_area = is_player_in_tent_area(),
                is_game_loading = is_game_loading(),
                is_otomo_accompany = is_otomo_accompany(),
                get_current_quest_type = get_current_quest_type(),
                is_current_quest_mainstory = is_current_quest_mainstory(),
                is_otomo_original_behavior_enabled = is_otomo_original_behavior_enabled(),
                is_porter_invisible_when_not_riding_enabled = is_porter_invisible_when_not_riding_enabled()
            },
            timer = TIMER,
            dump = DUMP,
            targets = {},
        }

        render_json_dump_window()
    end
end)
