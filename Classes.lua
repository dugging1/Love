--Useful Functions
function len(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end
--End Useful functions

--Debugging functions
function print_r ( t )
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end
--End Debugging functions



--Object Base Class
Object = {type="Object",x=0,y=0,sprite="",collisions={solid={},interact={}} }
function Object:collisionCheck(x, y, collision)
    local temp = false
    collision:moveTo(x, y)
    for i=1, len(Objects) do
        if Objects[i].collisions.solid:collidesWith(collision) then
            temp = true
        end
    end
    return temp
end
function Object:rotateCollisionCheck(r, collision)
    local temp = false
    collision:rotate(r)
    for i=1, len(Objects) do
        if Objects[i].collisions.solid:collidesWith(collision) then
            temp = true
        end
    end
    return temp
end
function Object:new(o)
    o = o or {}
    setmetatable(o, self)
    o.type = self.type
    self.__index = self
    return o
end
--End Object Base Class



--Interact Object Class
IntObject = Object:new()
IntObject.type = "IntObject"
function IntObject:interact(...)
    error "IntObject interact not defined."
end
--End Interact Object Class


--Chest Class << IntObject
Chest = IntObject:new()
Chest.type = "Chest"
function Chest:createItems()
    local items = {}
    if not self.open then
        for i,v in pairs(self.items) do
            table.insert(items, v:new())
            for ii,vv in pairs(self.items[i]) do
                items[i][ii] = vv
            end
            items[i].x = math.random(items[i].x-items[i].sprite:getWidth()*2, items[i].x+items[i].sprite:getWidth()*3)
            items[i].y = math.random(items[i].y-items[i].sprite:getHeight()*2, items[i].y+items[i].sprite:getHeight()*3)
            items[i].draw=true
        end
        self.open = true
    end
    return items
end
function Chest:interact(...)
    return self:createItems()
end
--End Chest Class


--Wall Class << Object
Wall = Object:new()
Wall.type = "Wall"
--End Wall Class



--Player Class << Object
Player = Object:new()
Player.type = "Player"
function Player:update()
    self:Rotate()
    self.collisions.solid:moveTo(self.x, self.y)
    self.collisions.solid:rotate(self.angle)
    self.collisions.interact:moveTo(self.x, self.y)
    self.collisions.interact:rotate(self.angle)
end
function Player:Move(newPos)
    if not self:collisionCheck(newPos.x, newPos.y, self.collisions.solid) then
        self.x = newPos.x
        self.y = newPos.y
    end
end
function Player:Rotate()
    local x, y = camera:mousePosition()
    local temp = math.atan2(y - player.y, x -player.x)+(math.pi/2)
    if not self:rotateCollisionCheck(temp, self.collisions.solid) then
        player.angle = temp
    end
end
function Player:interactCheck()
    local collides = {}
    for i=1, len(Objects) do
        if Objects[i].collisions.interact ~= nil then
            if Objects[i].collisions.interact:collidesWith(self.collisions.interact) then
                table.insert(collides, {Objects[i], math.sqrt((Objects[i].x-self.x)^2+(Objects[i].y-self.y)^2)})
            end
        end
    end
    if collides ~= nil and len(collides) > 0 then
        local key, value = 0, 0
        for i=1, len(collides) do
            if collides[i][2] > value then
                key, value = i, collides[i][2]
            end
        end
        return collides[key][1].interact(collides[key][1])
    end
    return false
end
--End Player Class


--Item Class << Object
Item = Object:new({icon="", image="", stats={}, rarity=0, fn=function(...)error "Item function not defined" end})
Item.type="Item"
function Item:updateCollision()
    if self.collisions.interact ~= nil then
        self.collisions.interact:moveTo(self.x,self.y)
    end
    if self.collisions.solid ~= nil then
        self.collisions.solid:moveTo(solf.x,self.y)
    end
end
--End Item Class