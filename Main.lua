-- User: dugging
SCL = require 'HC'
Cam = require 'camera'
Cardinal = require 'Cardinal'
require 'Classes'

Keys = {}
camScale = 2


function love.load()
    love.window.setMode(1280,720,{resizable =true,})
    love.graphics.setBackgroundColor( 255,000,255)

    --Textures
    Cardinal.textures = {player=love.graphics.newImage("Textures/Player.png"),wall1=love.graphics.newImage("Textures/Wall.png"),chest1=love.graphics.newImage("Textures/Chest.png"), item1={sprite=love.graphics.newImage("Textures/Sword_1.png"), icon=love.graphics.newImage("Textures/ItemIcon.png")}}
    --Items
    Cardinal.Items[1] = Item:new({sprite=Cardinal.textures.item1.sprite, icon=Cardinal.textures.item1.icon, image=Cardinal.textures.item1.sprite, rarity=1, fn=function() print("Item1 activate.") end, collisions={interact=SCL.circle(100,100, 25), draw=false}})
    --Entities
    table.insert(Cardinal.players, Player:new{x=400, y=300, sprite=Cardinal.textures.player, collisions={solid= SCL.rectangle(400,300,100,60), interact=SCL.rectangle(350,250,200,160)}, angle=0})
    --Objects
    table.insert(Cardinal.Objects, Wall:new{x=0, y=0, sprite=Cardinal.textures.wall1, collisions={solid= SCL.rectangle(100,200,350,240)}})
    table.insert(Cardinal.Objects, Chest:new{x=600, y=800, sprite=Cardinal.textures.chest1, collisions={solid= SCL.rectangle(600,800,60,85), interact=SCL.rectangle(550,750,160,185)}, items={Cardinal.Items[1]}})

    for i=1,len(Cardinal.Objects) do
        Cardinal.Objects[i]:updateSolidCollision()
    end
end

function love.draw()
    camera:set()
    camera:setPosition(Cardinal.players[1].x-love.graphics.getWidth()*(camScale/2), Cardinal.players[1].y-love.graphics.getHeight()*(camScale/2))
    camera:setScale(camScale, camScale)

    --Player
    love.graphics.draw(Cardinal.players[1].sprite, Cardinal.players[1].x, Cardinal.players[1].y, Cardinal.players[1].angle, 1, 1, Cardinal.players[1].sprite:getWidth()/2, Cardinal.players[1].sprite:getHeight()/2)
    love.graphics.rectangle("line", Cardinal.players[1].x- Cardinal.players[1].sprite:getWidth()/2, Cardinal.players[1].y- Cardinal.players[1].sprite:getHeight()/2, Cardinal.players[1].sprite:getWidth(), Cardinal.players[1].sprite:getHeight())

    --Objects
    for i=1,len(Cardinal.Objects) do
        love.graphics.draw(Cardinal.Objects[i].sprite, Cardinal.Objects[i].x, Cardinal.Objects[i].y)
    end

    --Items
    for i=1, len(Cardinal.ItemInstances) do
        if Cardinal.ItemInstances[i].draw then
            love.graphics.draw(Cardinal.ItemInstances[i].sprite, Cardinal.ItemInstances[i].x, Cardinal.ItemInstances[i].y)
        end
    end

    camera:unset()
end

function love.update(dt)
    local x, y = camera:mousePosition()
    local newWPos = {y= Cardinal.players[1].y + (y- Cardinal.players[1].y)*dt,x = Cardinal.players[1].x + (x- Cardinal.players[1].x)*dt}
    local newSPos = {y= Cardinal.players[1].y - (y- Cardinal.players[1].y)*dt,x = Cardinal.players[1].x - (x- Cardinal.players[1].x)*dt}

    Cardinal.players[1]:update()

    --Key Handling
    if Keys["w"] then
        Cardinal.players[1]:Move(newWPos)
    end
    if Keys["s"] then
        Cardinal.players[1]:Move(newSPos)
    end
    if Keys["]"] then
        camScale = camScale + 0.2
    end
    if Keys["["] then
        camScale = camScale - 0.2
    end
    if Keys["q"] then
        Cardinal.players[1]:interactCheck()
    end
    if Keys["o"] then
        print_r(Cardinal)
    end
    --End Key Handling
end




function love.keypressed(key)
    Keys[key] = true
end
function love.keyreleased(key)
    Keys[key] = false
end