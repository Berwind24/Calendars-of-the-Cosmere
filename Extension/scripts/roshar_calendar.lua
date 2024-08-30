-- Function to check if the current calendar is the Rosharan calendar based on its name
function isRosharanCalendarActive()
    -- Attempt to get the current calendar date format
    local dateFormat = DB.getValue("calendar.data.dateformat", "")
    print("Current calendar date format: " .. (dateFormat or "Unknown"))

    -- Check if the date format matches the Rosharan calendar
    if dateFormat == "rosharan" then
        print("Rosharan Calendar is active.")
        return true
    else
        print("Rosharan Calendar is not active. Current date format: " .. dateFormat)
        return false
    end
end



-- Format the Rosharan date
function formatRosharanDate(nYear, nMonth, nDay, sEpoch, bShortOutput)
    local months = {"Jes", "Nan", "Chach", "Vev", "Palah", "Shash", "Betab", "Kak", "Tanat", "Ishi"}
    local rosharSuffixes = {"es", "an", "ach", "ev", "ah", "ash", "ab", "ak", "at", "ish"}
    local nWeek = math.floor((nDay - 1) / 5) + 1
    local nDayOfWeek = (nDay - 1) % 5 + 1

    -- Validate and construct the Rosharan date
    if months[nMonth] and rosharSuffixes[nWeek] and rosharSuffixes[nDayOfWeek] then
        local rosharanDate = months[nMonth] .. rosharSuffixes[nWeek] .. rosharSuffixes[nDayOfWeek]
        if bShortOutput then
            return rosharanDate
        else
            return nYear .. ", " .. rosharanDate .. ", " .. sEpoch
        end
    else
        return "Invalid Rosharan Date"
    end
end
