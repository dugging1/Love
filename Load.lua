function loadTextures()
    local temp = {}
    temp.GUIEquip = love.graphics.newImage("Textures/GUI.png")
    temp.HealthBar = love.graphics.newImage("Textures/HealthBar.png")
    temp.player=love.graphics.newImage("Textures/Player.png")
    temp.wall1=love.graphics.newImage("Textures/Wall.png")
    temp.chest1=love.graphics.newImage("Textures/Chest.png")
    temp.item1={sprite=love.graphics.newImage("Textures/Sword_1.png"), icon=love.graphics.newImage("Textures/ItemIcon.png") }
    temp.Ditem={sprite=love.graphics.newImage("Textures/Item.png"), icon=love.graphics.newImage("Textures/ItemIcon.png") }
    temp.Inventory=love.graphics.newImage("Textures/Inventory.png")

    return temp
end

function loadItems()
    local temp = {}
    temp[1] = Item:new({sprite=Cardinal.textures.item1.sprite, icon=Cardinal.textures.item1.icon, image=Cardinal.textures.item1.sprite, rarity=1, fn=function() print("Item1 activate.") end, collisions={interact=SCL.circle(100,100, 100)}, draw=false})
    temp[2] = Backpack:new({sprite=Cardinal.textures.Ditem.sprite, icon=Cardinal.textures.Ditem.icon, image=Cardinal.textures.Ditem.sprite, rarity=1, fn=function() print("Item2 activate.") end, collisions={interact=SCL.circle(100,100, 100)}, draw=false, Bsize=2})

    return temp
end

function loadObjects()
    local temp = {}
    table.insert(temp, Wall:new{x=0, y=0, sprite=Cardinal.textures.wall1, collisions={solid= SCL.rectangle(100,200,350,240)}})
    table.insert(temp, Chest:new{x=600, y=800, sprite=Cardinal.textures.chest1, collisions={solid= SCL.rectangle(600,800,60,85), interact=SCL.rectangle(550,750,160,185)}, items={Cardinal.Items[1], Cardinal.Items[2]}})

    return temp
end

function loadEqualibrium()
    local total = {Items={}, Mobs={}}
    total.Items.rarity = 100
    total.Mobs.EXP = 100

    return total
end