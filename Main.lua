-- User: dugging
SCL = require 'HC'
Cam = require 'camera'
require 'Classes'

Keys = {}
Objects = {}
Items = {}
Entities = {}
textures = {}
player = {}
camScale = 1


function love.load()
    love.window.setMode(1280,720,{resizable =true,})
    love.graphics.setBackgroundColor( 255,000,255)


    --Textures
    textures = {player=love.graphics.newImage("Player.png"),wall1=love.graphics.newImage("Wall.png"),chest1=love.graphics.newImage("Chest.png"), item1={sprite=love.graphics.newImage("Item.png"), icon=love.graphics.newImage("ItemIcon.png")}}
    --Items
    Items[1] = Item.new({sprite=textures.item1.sprite, icon=textures.item1.icon, image=textures.item1.sprite, rarity=1, fn=function() print("Item1 activate.") end, collisions={interact=SCL.circle(100,100, 25), draw=false}})
    --Entities
    player = Player:new{x=400, y=300, sprite=textures.player, collisions={solid= SCL.rectangle(400,300,128,128), interact=SCL.rectangle(350,250,228,228)}, angle=0}
    --Objects
    table.insert(Objects, Wall:new{x=100, y=200, sprite=textures.wall1, collisions={solid= SCL.rectangle(100,200,128,128)}})
    table.insert(Objects, Chest:new{x=600, y=800, sprite=textures.chest1, collisions={solid= SCL.rectangle(600,800,128,128), interact=SCL.rectangle(550,750,228,228)}, items={Items[1]}})
    end

function love.draw()
    camera:set()
    camera:setPosition(player.x-love.graphics.getWidth()*(camScale/2),player.y-love.graphics.getHeight()*(camScale/2))
    camera:setScale(camScale, camScale)
    --Player
    love.graphics.draw(player.sprite, player.x, player.y, player.angle, 1, 1, player.sprite:getWidth()/2,player.sprite:getHeight()/2)
    love.graphics.rectangle("line", player.x-player.sprite:getWidth()/2, player.y-player.sprite:getHeight()/2, player.sprite:getWidth(), player.sprite:getHeight())

    --Objects
    for i=1,len(Objects) do
        love.graphics.draw(Objects[i].sprite, Objects[i].x, Objects[i].y)
    end

    --Items
    for i=1, len(Items) do
        if Items[i].draw then
            love.graphics.draw(Items[i].sprite, Items[i].x, Items[i].y)
        end
    end

    camera:unset()
end

function love.update(dt)
    local x, y = camera:mousePosition()
    local newWPos = {y=player.y + (y-player.y)*dt,x = player.x + (x-player.x)*dt}
    local newSPos = {y=player.y - (y-player.y)*dt,x = player.x - (x-player.x)*dt}

    player:update()

    --Key Handling
    if Keys["w"] then
        player:Move(newWPos)
    end
    if Keys["s"] then
        player:Move(newSPos)
    end
    if Keys["]"] then
        camScale = camScale + 0.2
    end
    if Keys["["] then
        camScale = camScale - 0.2
    end
    if Keys["q"] then
        player:interactCheck()
    end
    --End Key Handling
end




function love.keypressed(key)
    Keys[key] = true
end
function love.keyreleased(key)
    Keys[key] = false
end