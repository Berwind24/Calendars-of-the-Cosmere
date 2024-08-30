-- Main Calendar Handler Script: main_cosmere.lua

function onInit()
    -- Ensure OOBManager registration only on the GM side
    if Session.IsHost and OOBManager then
        OOBManager.registerOOBMsgHandler("customCalendarDate", handleCustomCalendarDate)
    end

    -- Hook into calendar changes
    CalendarManager.registerChangeCallback(onCalendarChanged)

    -- Perform initial calendar detection and update display
    detectActiveCalendarAndUpdateDisplay()
end

function onCalendarChanged()
    -- Detect active calendar and update the display when the calendar changes
    detectActiveCalendarAndUpdateDisplay()
end

-- Function to detect the active custom calendar and update the display
function detectActiveCalendarAndUpdateDisplay()
    local activeCalendar = detectActiveCalendar()

    if activeCalendar then
        print(activeCalendar.name .. " Calendar is active. Applying logic.")
        overrideCalendar(activeCalendar)
    else
        print("No custom calendar active, reverting to default logic.")
        -- Revert CalendarManager functions to their defaults
        revertCalendarLogic()
    end

    -- Refresh the display for all players
    refreshCalendarDisplayForPlayers()
end

-- Function to detect the active custom calendar
function detectActiveCalendar()
    local calendars = {
        {name = "Rosharan", isActive = rosharCal.isRosharanCalendarActive, formatter = rosharCal.formatRosharanDate},
        -- Add other calendars here
    }

    for _, calendar in ipairs(calendars) do
        if calendar.isActive() then
            return calendar
        end
    end

    return nil -- No custom calendar active
end

-- Function to override calendar logic
function overrideCalendar(calendar)
    if CalendarManager then
        print("Overriding CalendarManager.getDateString for " .. calendar.name .. " calendar.")
        
        -- Store original functions to revert back when needed
        local originalGetDateString = CalendarManager.getDateString
        local originalOutputDate = CalendarManager.outputDate

        -- Override the date string format
        CalendarManager.getDateString = function(sEpoch, nYear, nMonth, nDay, bAddWeekDay, bShortOutput)
            if calendar.isActive() then
                return calendar.formatter(nYear, nMonth, nDay, sEpoch, bShortOutput)
            else
                -- If a non-Cosmere calendar is active, revert to the original date formatting
                CalendarManager.getDateString = originalGetDateString
                return originalGetDateString(sEpoch, nYear, nMonth, nDay, bAddWeekDay, bShortOutput)
            end
        end

        -- Optionally, you can also handle outputDate if needed:
        CalendarManager.outputDate = function()
            if calendar.isActive() then
                outputCustomDate(calendar)
            else
                -- Revert to the original function if not a Cosmere calendar
                CalendarManager.outputDate = originalOutputDate
                originalOutputDate()
            end
        end
    else
        print("CalendarManager not initialized!")
    end
end

-- Revert CalendarManager logic to its original state
function revertCalendarLogic()
    CalendarManager.getDateString = CalendarManager.getDateString -- Restores original function
    CalendarManager.outputDate = CalendarManager.outputDate -- Restores original function
end

-- Function to refresh the calendar display for all players
function refreshCalendarDisplayForPlayers()
    if not Session.IsHost then
        local sDate = CalendarManager.getCurrentDateString()

        -- Ensure that sub_date and its subwindow are valid before setting the value
        if sub_date and sub_date.subwindow then
            sub_date.subwindow.viewdate.setValue(sDate)
        else
            print("sub_date or subwindow is not available, unable to update the date display.")
        end
    end
end

-- Function to output the custom calendar date to chat
function outputCustomDate(calendar)
    local nMonth = DB.getValue("calendar.current.month", 1)
    local nDay = DB.getValue("calendar.current.day", 1)
    local nYear = DB.getValue("calendar.current.year", 0)
    local sEpoch = DB.getValue("calendar.current.epoch", "")

    local customDate = calendar.formatter(nYear, nMonth, nDay, sEpoch, false)

    -- Output to both GM and Players
    local msg = {sender = "", font = "chatfont", icon = "portrait_gm_token", mode = "story"}
    msg.text = "Today's Date: " .. customDate
    Comm.deliverChatMessage(msg)
end

-- Function to handle custom calendar date messages
function handleCustomCalendarDate(msgOOB)
    ChatManager.SystemMessage("Today's Date: " .. msgOOB.date)
end
