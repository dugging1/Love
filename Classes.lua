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
Object = {type="Object",x=0,y=0,sprite="",collisions={solid={},interact={}}, angle=0}
function Object:collisionCheck(x, y, collision)
    local temp = false
    collision:moveTo(x, y)
    for i=1, len(Cardinal.Objects) do
        if Cardinal.Objects[i].collisions.solid:collidesWith(collision) then
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
function Object:updateSolidCollision()
    self.collisions.solid:moveTo(self.x+self.sprite:getWidth()/2, self.y+self.sprite:getHeight()/2)
    self.collisions.solid:rotate(self.angle)
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
            table.insert(items, Cardinal:PickItem(self.items))
            for ii,vv in pairs(self.items[i]) do
                items[i][ii] = vv
            end
            items[i].x = math.random(self.x-200, self.x+200)
            items[i].y = math.random(self.y-200, self.y+200)
            items[i].draw=true
            items[i].pickUp = true
            items[i]:updateCollision()
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
Player = Object:new({Equipment={}, Inventory={}})
Player.type = "Player"
function Player:Equip(Item)
    if Item.type == "Backpack" then
        if self.Equipment ~= nil then
            local a
            a, self.Equipment[1] = self.Equipment[1], Item
            return a
        else
            self.Equipment[1] = Item
        end
    else
        print("Finish Player:Equip()")
    end
end
function Player:update()
    self:Rotate()
    self.collisions.solid:moveTo(self.x, self.y)
    self.collisions.solid:setRotation(self.angle)
    self.collisions.interact:moveTo(self.x, self.y)
    self.collisions.interact:setRotation(self.angle)
    self.collisions.pickUp:moveTo(self.x, self.y)
    self.collisions.pickUp:setRotation(self.angle)
end
function Player:Move(newPos)
    if not self:collisionCheck(newPos.x, newPos.y, self.collisions.solid) then
        self.x = newPos.x
        self.y = newPos.y
    end
end
function Player:Rotate()
    local x, y = camera:mousePosition()
    Cardinal.players[1].angle = math.atan2(y - Cardinal.players[1].y, x - Cardinal.players[1].x)+(math.pi/2)
end
function Player:interactCheck()
    local collides = {}
    for i=1, len(Cardinal.Objects) do
        if Cardinal.Objects[i].collisions.interact ~= nil then
            if Cardinal.Objects[i].collisions.interact:collidesWith(self.collisions.interact) then
                table.insert(collides, {Cardinal.Objects[i], math.sqrt((Cardinal.Objects[i].x-self.x)^2+(Cardinal.Objects[i].y-self.y)^2)})
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
        return collides[key][1]:interact(collides[key][1])
    end
    return false
end
function Player:processItem(Item)
    if Item.type == "Backpack" and self.Equipment[1] == nil then
        self:Equip(Item)
        Item.draw=false
        Item.x = 0
        Item.y = 0
        Item.pickUp = false
        Item:updateCollision()
    elseif self.Equipment[1] ~= nil then
        if self:InvStore(Item) then
            Item.draw=false
            Item.x = 0
            Item.y = 0
            Item.pickUp = false
            Item:updateCollision()
        end
    end
end
function Player:InvStore(Item)
    if self.Equipment[1] ~= nil then
        if len(self.Inventory) < self.Equipment[1].Bsize then
            table.insert(self.Inventory, Item)
            return true
        end
    end
end
function Player:drawEquipment(x, y)
    if self.Equipment[1] ~= nil then
        love.graphics.draw(self.Equipment[1].icon, x+194, y+50)
    end
end
function Player:drawInventory(x, y)
    if self.Equipment[1] ~= nil then
        self.Equipment[1]:Inventory(Cardinal.textures.Inventory, x, y, Cardinal.textures.GUIEquip:getWidth(), self.Inventory)
    end
end
--End Player Class


--Item Class << Object
Item = Object:new({icon="", image="", stats={}, rarity=0, fn=function(...)error "Item function not defined" end, randWeight=0, Equalibrium={rarity=0}, pickUp=false})
Item.type="Item"
function Item:new(o)
    o = o or {}
    setmetatable(o, self)
    o.type = self.type
    self.__index = self
    self:Init()
    return o
end
function Item:Init()
    self.Equalibrium.rarity = self.rarity
end
function Item:updateCollision()
    if self.collisions.interact ~= nil then
        self.collisions.interact:moveTo(self.x+self.sprite:getWidth()/2,self.y+self.sprite:getHeight()/2)
    end
    if self.collisions.solid ~= nil then
        self.collisions.solid:moveTo(self.x+self.sprite:getWidth()/2,self.y+self.sprite:getHeight()/2)
    end
end
--End Item Class


--Backpack Class << Item
Backpack = Item:new({icon="", image="", stats={}, rarity=0, randWeight=0, Equalibrium={rarity=0}, Bsize=0})
Backpack.type = "Backpack"
function Backpack:Inventory(sprite, x, y, width, inventory)
    local i = 0
    local n = math.floor(width/sprite:getWidth())
    print(width)
    local Dx = x
    local Dy = y
    for a=1,math.ceil(self.Bsize/n) do
        for l=1, n do
            i = i + 1
            if i < self.Bsize+1 then
                love.graphics.draw(sprite, Dx, Dy)
                if inventory[i] ~= nil then
                    love.graphics.draw(inventory[i].icon, Dx,Dy)
                end
                Dx = Dx + sprite:getWidth()
            else
                break
            end
        end
        Dx = x
        Dy = Dy + sprite:getHeight()
    end
end
--End Backpack Class