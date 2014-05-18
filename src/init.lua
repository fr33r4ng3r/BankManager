


--------------------------------------------------------------------------------
--  ***** Bank Manager *****
--
--  * Benjamin Creusot - Todo
--  * Creation : 17/04/2014 
--  * v2.7
--      Manage easily your bank. Automatically places items in your bank/inventory
--
--  * LICENSE MIT
--
--------------------------------------------------------------------------------


---------------------------------------------------------------------------
-- ** Function called when the events are raised **
-- bankOpening(eventCode, addOnName, isManual)
-- @eventCode : Int,     Code of the event
-- @addOnName : String,  Name of the addon
-- @isManual  : Boolean, If the function was not launch by us... I guess :)
---------------------------------------------------------------------------
function bankOpening(eventCode, addOnName, isManual)
    if isManual then
        return
    end

    --Display the toolbar
    if BankManager.Saved.toolBarDisplayed then
        showUI()
    end

    -- if the automatique push/pull is disable
    if not BankManager.Saved.autoTransfert then
        return
    end

    if BankManager.Saved.bankChoice == "BAG_BANK" and eventCode == EVENT_OPEN_BANK then
        ClearCursor()
        local status,err = pcall(moveItems,true,true,BankManager.Saved["defaultProfile"])
        if not status then
            cleanAll(err)
        end
    elseif BankManager.Saved.bankChoice == "BAG_GUILDBANK" and eventCode == EVENT_GUILD_BANK_ITEMS_READY  and BankManager.Saved["guildChoice"] then
        --We set the guild bank to work with
        --we check the permission
        if DoesPlayerHaveGuildPermission(BankManager.Saved["guildChoice"], GUILD_PERMISSION_BANK_DEPOSIT) and DoesPlayerHaveGuildPermission(BankManager.Saved["guildChoice"], GUILD_PERMISSION_BANK_WITHDRAW) then 
            SelectGuildBank(BankManager.Saved["guildChoice"])
            ClearCursor()
            local status,err = pcall(moveItems,true,true,BankManager.Saved["defaultProfile"])
            if not status then
                cleanAll(err)
            end
        else
            d(getTranslated("noPermission"))
        end
    end

end

------------------------------------------------
-- ** Function called when the bank is closed **
-- bankClose()
------------------------------------------------
function bankClose()
    hideUI()
end
---------------------------------------------------------------------------
-- ** Function called when an error is catch on the main loop, moveItems **
-- cleanAll(err)
-- @err the error catch
---------------------------------------------------------------------------
function cleanAll(err)
    counterMessageChat    = 0
    flagAlreadyPerforming = false
    --I have to print the error with the INGame system for a better communication between users and me
    assert(false,err)
end


------------------------------------------
-- ** Init Function **
-- init(eventCode, addOnName)
-- @eventCode : Int,     Code of the event
-- @addOnName : String,  Name of the addon
------------------------------------------
function init(eventCode, addOnName)
    if addOnName ~= BankManagerAppName then
        return
    end

    local initVarFalse              = NOTHING
    local defaults = {
        ["language"]                = getBaseLanguage(),
        ["toolBarDisplayed"]        = true,
        ["bankChoice"]              = "BAG_BANK",
        ["guildChoice"]             = GetGuildId(1),
        ["autoTransfert"]           = true,
        ["spamChat"]                = true,
        ["spamChatAll"]             = true,
        ["profilesNb"]              = 1,
        ["profilesNames"]           = {},
        ["defaultProfile"]          = 1,
        ["AllBM"]                   = {},
        ["fillStacks"]              = {}
    }
    
    for i=1,maxProfilesNb do
        defaults["AllBM"][i]      = NOTHING
        defaults["fillStacks"][i] = NOTHING
        for k,v in ipairs(craftingElements) do
            if defaults[v] == nil then
                 defaults[v] = {}
            end
            defaults[v][i] = initVarFalse
        end
        for k,v in ipairs(othersElements) do
            if defaults[v] == nil then
                 defaults[v] = {}
            end
            defaults[v][i] = initVarFalse
        end
    end
    BankManager.Saved = ZO_SavedVars:New(BankManagerVars, 2, nil, defaults, nil)
    
    options()
    InitializeGUI()


    EVENT_MANAGER:RegisterForEvent(BankManagerAppName, EVENT_OPEN_BANK              , bankOpening)
    EVENT_MANAGER:RegisterForEvent(BankManagerAppName, EVENT_CLOSE_BANK             , bankClose)
    --EVENT_MANAGER:RegisterForEvent(BankManagerAppName, EVENT_GUILD_BANK_ITEMS_READY, bankOpening)

end


EVENT_MANAGER:RegisterForEvent(BankManagerAppName, EVENT_ADD_ON_LOADED, init)