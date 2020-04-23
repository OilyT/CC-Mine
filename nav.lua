--globals

local POS = vector.new(0, 0, 0)
local DIR = 1
X, Y, Z = 1, 2, 3
L, R = 1, 2
N, E, S, W, U, D = 1, 2, 3, 4, 5, 6
local digs = {turtle.dig, turtle.dig, turtle.dig, turtle.dig, turtle.digUp, turtle.digDown}
local directions = {{turn = turtle.turnLeft, num = -1}, {turn = turtle.turnRight, num = 1}}
local Vectors =
{
    {move = turtle.forward, delta = {1, 0, 0}},
    {move = turtle.forward, delta = {0, 0, 1}},
    {move = turtle.forward, delta = {-1, 0, 0}},
    {move = turtle.forward, delta = {0, 0, -1}},
    {move = turtle.up, delta = {0, 1, 0}},
    {move = turtle.down, delta = {0, -1, 0}}
}

--vector functions

function move(dir, dig) -- moves one block in specified direction, optional argument for dig
    turn_d(dir)
    local success = false
    while success == false do
        if dig then
            digs[dir]()
        end
        success = Vectors[dir].move()
    end
    move_u(dir)
end

function forward(dig) -- goes one block forward in current direction, optional argument for dig
    if dig then
        turtle.dig()
    end
    if turtle.forward() then
        move_u(DIR)
        return true
    else
        return false
    end
end

function gen_v(target) -- generates a vector from current position to target position
    local vector = target - POS
    return vector
end

function go_axis(vector, axis, dig) -- moves along a single specified axis of a vector, optional dig
    local vs = convert_v_t(vector)
    local V = vs[axis]
    local orientation = est_or(V, axis)
    if V ~= 0 then
        turn_d(orientation)
    end
    local i = 0
    while i < math.abs(V) do
        if dig then
            digs[orientation]()
        end
        local success = Vectors[orientation].move()
        if success then
            move_u(orientation)
            i = i + 1
        end
    end
end

function go_vector(axis1, axis2, axis3, vector, dig) -- moves along vector in specified axis order, optional dig
    go_axis(vector, axis1, dig)
    go_axis(vector, axis2, dig)
    go_axis(vector, axis3, dig)
end

function est_or(value, axis)
    local vs = {{1, 3}, {5, 6}, {2, 4}}
    local v = vs[axis]
    local orientation = nil
    if value < 0 then
        orientation = v[2]
    else
        orientation = v[1]
    end
    return orientation
end

function move_u(dir)
    local delta = Vectors[dir].delta
    local x, y, z = delta[1], delta[2], delta[3]
    local d = vector.new(x, y, z)
    POS = POS + d
end

--turning functions

function fig_d(dir)
    local diff = (dir - DIR)
    if (diff == 3) or (diff == -1) then
        return L
     else
        return R
    end
end

function turn(dir) -- turns left or right
    directions[dir].turn()
    local num = directions[dir].num
    DIR = DIR + num
    if DIR == 5 then
        DIR = 1
    elseif DIR == 0 then
        DIR = 4
    end
end

function turn_d(dir) -- turns in specified direction
    if dir < 5 then
        local d = fig_d(dir)
        while dir ~= DIR do
            turn(d)
        end
    end
end

--returning values

function get_POS()
    return POS
end

function get_DIR()
    return DIR
end

function get_delta()
    return Vectors[DIR].delta
end

function get_delta_v() -- generates a vector from current direction delta
    local delta = Vectors[DIR].delta
    local x, y, z = delta[1], delta[2], delta[3]
    local v = vector.new(x, y, z)
    return v
end

function convert_v_t(vector) -- converts vector to table
    local vs = {vector.x, vector.y, vector.z}
    return vs
end

function convert_t_v(table) -- converts table to vector
    local vec = vector.new(table[1], table[2], table[3])
    return vec
end