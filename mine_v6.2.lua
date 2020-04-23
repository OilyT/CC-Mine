--digs 2x2 with 3d search
--collects ores specified within UI
--ejects cobble and 'ites'

--globals
local moves = {}
local index = 1
local DIR = 1
--defaults
local DISTANCE = 64
local TUNNELS = 4
local coal_num = 32
local ores_i =
{
  'minecraft:iron_ore',
  'minecraft:gold_ore',
  'minecraft:emerald_ore',
  'minecraft:coal_ore',
  'minecraft:redstone_ore',
  'minecraft:lapis_ore'
}
local ores_f = {'minecraft:diamond_ore'}


--core functions

function tunnel()
    dig()
    turtle.forward()
    inspect_d(1)
    change_d('left')
    dig()
    turtle.forward()
    inspect_d(1)
    inspect_d(2)
    digUp()
    turtle.up()
    inspect_d(2)
    inspect_d(3)
    change_d('right')
    change_d('right')
    dig()
    turtle.forward()
    inspect_d(3)
    inspect_d(2)
    turtle.down()
    inspect_d(2)
    change_d('left')
end

function dig()
    turtle.dig()
    while turtle.detect() == true do
        turtle.dig()
    end
end

function digUp()
    turtle.digUp()
    while turtle.detectUp() == true do
        turtle.digUp()
    end
end

function check(dir)
    local found = false
    if dir == 1 then
        is_block, data = turtle.inspectDown()
    elseif dir == 2 then
        is_block, data = turtle.inspect()
    elseif dir == 3 then
        is_block, data = turtle.inspectUp()
    end
    if is_block and string.sub(data.name, -3) == 'ore' then
        for i = 1, table.getn(ores_f) do
            if data.name == ores_f[i] then
                found = true
            end
            if data.name == 'minecraft:coal_ore' and get_coal then
                found = true
                refuel()
            end
        end
        return found
    end
end

function change_d(dir)
    if dir == 'left' then
        turtle.turnLeft()
        if DIR == 1 then
            DIR = 4
        else
            DIR = DIR -1
        end
    elseif dir == 'right' then
        turtle.turnRight()
        if DIR == 4 then
            DIR = 1
        else
            DIR = DIR + 1
        end
    end
end

function inspect_base(dir)
    local success = check(dir)
    if success and dir == 2 then
        turtle.dig()
        turtle.forward()
        moves[index] = DIR
        index = index + 1
    elseif success and dir == 1 then
        turtle.digDown()
        turtle.down()
        moves[index] = 5
        index = index + 1
    elseif success and dir == 3 then
        turtle.digUp()
        turtle.up()
        moves[index] = 6
        index = index + 1
    end
    return success
end

function inspect_loop()
    i = 1
    j = 2
    while moves[1] ~= nil do
        local found = inspect_base(j)
        if not found and j == 2 then
            change_d('right')
            i = i + 1
            if i == 5 then
                j = 1
            end
        elseif not found and j == 1 then
            j = 3
        elseif not found and j == 3 then
            reverse()
            i = 1
            j = 2
        else
            i = 1
            j = 2
        end
    end
end

function turn(goal)
    while DIR ~= goal do
        change_d('right')
    end
end

function reverse()
    index = index - 1
    goal = moves[index]
    if goal < 5 then
        turn(goal)
        turtle.back()
        moves[index] = nil
    else
        if goal == 5 then
            turtle.up()
            moves[index] = nil
        elseif goal == 6 then
            turtle.down()
            moves[index] = nil
        end
    end
end

function inspect_d(dir)
    local current_d = DIR
    local found = inspect_base(dir)
    if found then
        inspect_loop()
        turn(current_d)
    end
end

--aux functions

function refuel()
    turtle.select(1)
    local fuel_l = turtle.getFuelLevel()
    if (fuel_l < DISTANCE) and (DISTANCE >= 80) then
        turtle.refuel(1)
    elseif fuel_l < 80 then
        turtle.refuel(1)
    end
    if turtle.getItemCount() < coal_num then
        get_coal = true
    else
        get_coal = false
    end
end

function eject()
    for i = 1, 16 do
        turtle.select(i)
        local count = turtle.getItemCount()
        if count > 0 then
            local data = turtle.getItemDetail()
            local name = string.sub(data.name, -3)
            if (name == 'ite') or name == ('one') then
                 turtle.drop()
            end
        end
    end
end

function deposit()
    local success, data = turtle.inspect()
    if success and data.name == 'minecraft:chest' then
        for i = 2, 16 do
            turtle.select(i)
            turtle.drop()
        end
    end
end

function home(counts)
    if counts > 0 then
        turtle.turnRight()
        for i = 1, (counts * 4) do
            turtle.forward()
        end
        turtle.turnLeft()
    end
end

function gen_ores()
    local length = table.getn(ores_i)
    for i = 1, length do
        local name = string.sub(ores_i[i], 11, -5)
        print("collect "..name.."? y/n")
        local ans = read()
        if ans == 'y' then
            print("adding"..name.."...")
            table.insert(ores_f, ores_i[i])
        end
    end
end

function get_dims()
    print('enter length and number of tunnels')
    local values = read()
    if values ~= '' then
        local dimensions = {}
        for val in values:gmatch("%S+") do
            table.insert(dimensions, val)
        end
        DISTANCE = tonumber(dimensions[1])
        TUNNELS = tonumber(dimensions[2])
    end
end

--main functions

function run()
    refuel()
    local start = 1
    while turtle.detect() == false do
        turtle.forward()
        start = start + 1
    end
    for i = start, DISTANCE do
        tunnel()
        if (i % 5) == 0 then
            refuel()
        end
        print("current length:", i)
    end
    turtle.turnRight()
    turtle.turnRight()
    eject()
    refuel()
    for i = 1, DISTANCE do
        turtle.forward()
    end
end

function main()
    get_dims()
    gen_ores()
    for i = 1, TUNNELS do
        run()
        home(i - 1)
        deposit()
        if TUNNELS ~= i then
            turtle.turnLeft()
            local dist = (i * 4)
            for i = 1, dist do
                dig()
                turtle.forward()
            end
            turtle.turnLeft()
        end
    end
end

main()