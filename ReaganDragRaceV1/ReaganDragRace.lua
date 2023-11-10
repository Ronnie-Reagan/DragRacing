-----------------------------------------------------------------------------------
---------------------------Don Reagan's Drag Race Script---------------------------
-----------------------------------------------------------------------------------
local Timer = require("scripts/ReaganTimer")
DragMenu = menu.add_submenu("DragMenu")
local raceDistanceOptions = {}
local raceDistances = {
    ["1/8 Mile"] = 1609.34 / 8,
    ["1/4 Mile"] = 1609.34 / 4,
    ["1/2 Mile"] = 1609.34 / 2,
    ["Full Mile"] = 1609.34
}
local selectedDistance = "1/8 Mile"
local raceFinished = false
local raceDistance = raceDistances["1/8 Mile"]
local startPosition
local racerunning = false
speeds = {}
for name, _ in pairs(raceDistances) do
    table.insert(raceDistanceOptions, name)
end

local function rip()
    print("rip")
end

local function getWeightedAverage(t)
    local weightedSum = 0
    local totalWeights = 0
    for i, v in ipairs(t) do
        weightedSum = weightedSum + v * i
        totalWeights = totalWeights + i
    end
    return weightedSum / totalWeights
end

local function getCurrentSpeed(vehicle)
    local velocity = vehicle:get_velocity()
    local speedms = math.sqrt(velocity.x^2 + velocity.y^2 + velocity.z^2)
    return speedms
end

function getTimeInCar()
    return stats.get_int("MP"..stats.get_int("MPPLY_LAST_MP_CHAR").."_TIME_IN_CAR") 
end

local function startDragRace()
    local distanceName = raceDistanceOptions[selectedDistanceIndex]
    local distance = raceDistances[distanceName]
    local vehicle = localplayer:get_current_vehicle()
    if vehicle then
        raceDistance = distance
        DoDragRace()
    else
        rip()
    end
end

function getCurrentPosition()
    local vehicle = localplayer:get_current_vehicle()
    if vehicle then
        return vehicle:get_position()
    else
        rip()
        return nil
    end
end

function calculateDistance(pos1, pos2)
    if pos1 and pos2 then
        local dx = pos1.x - pos2.x
        local dy = pos1.y - pos2.y
        local dz = pos1.z - pos2.z
        return math.sqrt(dx * dx + dy * dy + dz * dz)
    else
        rip()
        return nil
    end
end

function updateLicensePlate(text)
    local vehicle = localplayer:get_current_vehicle()
    if vehicle then
        vehicle:set_number_plate_text(text)
    else
        rip()
    end
end

function formatTime(milliseconds)
    if type(milliseconds) == "number" then
        local seconds = math.floor(milliseconds / 1000)
        local remainingMilliseconds = milliseconds % 1000
        return string.format("%d.%03d", seconds, remainingMilliseconds)
    else
        rip()
        return nil
    end
end

function hasReachedFinishLine()
    local currentPosition = getCurrentPosition()
    if currentPosition then
        local distanceTravelled = calculateDistance(startPosition, currentPosition)
        if distanceTravelled then
            return distanceTravelled >= raceDistance
        else
            return false
        end
    else
        return false
    end
end

function updateRaceDistance()
    if raceStarted and racerunning then
        local currentPosition = getCurrentPosition()
        if currentPosition then
            local distanceTraveled = calculateDistance(startPosition, currentPosition)
            if distanceTraveled then
                raceDistance = distanceTraveled
            else
                rip()
            end
        else
            rip()
        end
    end
end

function showspeed()
    local vehicle = localplayer:get_current_vehicle()
    local currentSpeed = getCurrentSpeed(vehicle)
    table.insert(speeds, currentSpeed)
    if #speeds > 5
    then table.remove(speeds, 1)
    end
    local predictedSpeed = getWeightedAverage(speeds)
    local displayedSpeed = math.floor(predictedSpeed * 2.23694)
    local speedStr = string.format("%3s", displayedSpeed > 0 and tostring(displayedSpeed) or "")
    local plateText = speedStr.."  MPH"
    vehicle:set_number_plate_text(plateText)
end

function DoDragRace()
    raceFinished = false
    startPosition = getCurrentPosition()
    updateLicensePlate("0------0")
    sleep(0.5)
    updateLicensePlate("00----00")
    sleep(0.5)
    updateLicensePlate("000--000")
    sleep(0.5)
    updateLicensePlate("---GO---")
    Timer.start() -- Start the custom timer
    racerunning = true
        if startPosition ~= getCurrentPosition() then
            updateLicensePlate("JUMPED!")
            raceFinished = true
            racerunning = false
            print("Race Aborted: Jumped The Start")
        else
        sleep(0.25)
        while not raceFinished do
            local vehicle = localplayer:get_current_vehicle()
            if vehicle and startPosition then
                if hasReachedFinishLine() then
                    racerunning = false
                    raceFinished = true
                    local finalTime = Timer.elapsedTime()
                    local finalSpeed = getCurrentSpeed(vehicle)
                    updateLicensePlate(formatTime(finalTime))
                    print("Race finished! Time: " .. formatTime(finalTime))
                    print("Race Distance: " .. selectedDistance)
                    print("Final Speed: " .. (finalSpeed * 2.23694).. " MPH")
                    break
                else
                    showspeed()
                    sleep(0.025)
                end
            else
                print("Failure in script: No vehicle or position data available for race progress")
            end
            updateRaceDistance() -- Continuously update race distance
        end
    end
end
local function abortrace()
    raceFinished = true
    racerunning = false
    updateLicensePlate("ABORTED!")
    print("Race Aborted")
end
DragMenu:add_action("---------------------------------------------", rip)
DragMenu:add_action("------- Don Reagan's Drag Racing -------", rip)
DragMenu:add_array_item("Distance", raceDistanceOptions,
function()
return selectedDistanceIndex end, 
function(index)
    selectedDistanceIndex = index
    selectedDistance = raceDistanceOptions[index]
    raceDistance = raceDistances[selectedDistance]
    updateLicensePlate(selectedDistance)
end)
DragMenu:add_action("Start Drag Race", startDragRace)
DragMenu:add_action("CANCEL", abortrace)
DragMenu:add_action("---------------------------------------------", rip)
DragMenu:add_action("Enable LUA Debug in Menu Settings,", rip)
DragMenu:add_action("to view your recent race times.", rip)
DragMenu:add_action("Please Read The Instruction Set.", rip)
DragMenu:add_action("---------------------------------------------", rip)