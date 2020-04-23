--digs 2x2 with 3d search
--collects ores specified within UI
--ejects cobble and 'ites'

os.loadAPI('nav.lua')

--globals
local moves = {}
local index = 1
local DIR = 1
--defaults
local DISTANCE = 4
local TUNNELS = 4
local coal_num = 32
local ores_dictionary =
{
  'iron_ore',
  'copper_ore',
  'tin_ore',
  'osmuim_ore',
  'gold_ore',
  'emerald_ore',
  'coal_ore',
  'redstone_ore',
  'lapis_ore',
  'diamond_ore'
}
local e_dictionary =
{
    'minecraft:cobblestone',
    'minecraft:diorite',
    'minecraft:andesite',
    'minecraft:granite',
    'minecraft:dirt',
    'minecraft:gravel'
}
local D, F, U = 1, 2, 3
local i_functions =
{
    {inspect = turtle.inspectDown, direction = nav.D},
    {inspect = turtle.inspect, direction = nav.get_DIR},
    {inspect = turtle.inspectUp, direction = nav.U}
}

--core functions

function tunnel()
    nav.move(nav.N, true)
    inspect_d(D)
    nav.move(nav.E, true)
    inspect_d(D)
    inspect_d(F)
    nav.move(nav.U, true)
    inspect_d(F)
    inspect_d(U)
    nav.move(nav.W, true)
    inspect_d(F)
    inspect_d(U)
    nav.move(nav.D, true)
    inspect_d(F)
end

function check(dir)
    local found = false
    local is_block, data = i_functions[dir].inspect()
    if is_block and string.sub(data.name, -3) == 'ore' then
        local t = split(data.name, ':')
        local name = t[2]
        for i = 1, table.getn(ores_dictionary) do
            if name == ores_dictionary[i] then
                found = true
            end
        end
        if name == 'coal_ore' and get_coal then
            found = true
            refuel()
        end
    end
    return found
end

function inspect_base(dir)
    local success = check(dir)
    if success then
        local h = 0
        if dir == 2 then
            h = i_functions[dir].direction()
        else
            h = i_functions[dir].direction
        end
        nav.move(h, true)
        moves[index] = {h, 0, 0}
        index = index + 1
    end
    return success
end

function inspect_loop()
    local i = 1
    local j = 2
    while moves[1] ~= nil do
        local found = inspect_base(j)
        if not found and j == 2 then
            nav.turn(nav.R)
            i = i + 1
            if i == 5 then
                j = 1
            end
        elseif not found and j == 1 then
            j = 3
        elseif not found and j == 3 then
            local i_j = reverse()
            i = i_j[1]
            j = i_j[2]
        else
            moves[index - 1][2] = i
            moves[index - 1][3] = j
            i = 1
            j = 2
        end
    end
end

function reverse()
    index = index - 1
    local goal = moves[index][1]
    if goal < 5 then
        nav.turn_d(goal)
        turtle.back()
    elseif goal == 5 then
        nav.move(6)
    elseif goal == 6 then
        nav.move(5)
    end
    local i_j = {moves[index][2], moves[index][3]}
    moves[index] = nil
    return i_j
end

function inspect_d(dir)
    local current_d = nav.get_DIR()
    local found = inspect_base(dir)
    if found then
        inspect_loop()
        nav.turn_d(current_d)
    end
end

-- aux functions

function refuel()
    turtle.select(1)
    local fuel_l = turtle.getFuelLevel()
    if fuel_l < 240 then
        turtle.refuel(2)
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
            local name = data.name
            for i, v in ipairs(e_dictionary) do
                if v == name then
                    turtle.dropUp()
                end
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

function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

function gen_ores()
    local length = table.getn(ores_dictionary)
    for i = 1, length do
        local name = ores_dictionary[i]
        print("collect "..name.."? y/n")
        local ans = read()
        if ans == 'y' then
            print("adding"..name.."...")
            table.insert(ores_f, name)
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

-- main functions

function run()
    refuel()
    local start = 1
    while (turtle.detect() == false) and (start < DISTANCE) do
        nav.forward()
        start = start + 1
    end
    for i = start, DISTANCE do
        tunnel()
        if i % 16 == 0 then
            refuel()
            eject()
        end
    end
    refuel()
    eject()
    local home = nav.gen_v(vector.new(0, 0, 0))
    nav.go_vector(nav.X, nav.Y, nav.Z, home)
    nav.turn_d(nav.S)
    deposit()
end

function main()
    get_dims()
    for i = 1, TUNNELS do
        local start = vector.new(0, 0, ((i - 1) * 4))
        nav.go_vector(nav.X, nav.Y, nav.Z, start, true)
        nav.turn_d(nav.N)
        run()
    end
end

main()

