-- User: dugging
SCL = require 'HC'
Cam = require 'camera'
Cardinal = require 'Cardinal'
require 'Classes'
require 'Load'

Keys = {}
camScale = 2
MouseCollide = SCL.circle(0, 0, 30)


function love.load()
    love.window.setMode(1280,720,{resizable =true,})
    love.graphics.setBackgroundColor( 255,000,255)

    --Textures
    Cardinal.textures = loadTextures()
    --Items
    Cardinal.Items = loadItems()
    --Entities
    Cardinal.players[1] = Player:new{x=400, y=300, sprite=Cardinal.textures.player, collisions={solid= SCL.rectangle(400,300,100,60), interact=SCL.rectangle(350,250,300,260), pickUp=SCL.circle(400,300,250)}, angle=0}
    --Objects
    Cardinal.Objects = loadObjects()

    for i=1,len(Cardinal.Objects) do
        Cardinal.Objects[i]:updateSolidCollision()
    end
end

function love.draw()
    camera:set()
    camera:setPosition(Cardinal.players[1].x-love.graphics.getWidth()*(camScale/2), Cardinal.players[1].y-love.graphics.getHeight()*(camScale/2))
    camera:setScale(camScale, camScale)

    --Debugging
    MouseCollide:draw('line')
    Cardinal.players[1].collisions.interact:draw('line')
    Cardinal.players[1].collisions.solid:draw('line')
    Cardinal.players[1].collisions.pickUp:draw('line')

    --Player
    love.graphics.draw(Cardinal.players[1].sprite, Cardinal.players[1].x, Cardinal.players[1].y, Cardinal.players[1].angle, 1, 1, Cardinal.players[1].sprite:getWidth()/2, Cardinal.players[1].sprite:getHeight()/2)


    --Objects
    for i=1,len(Cardinal.Objects) do
        love.graphics.draw(Cardinal.Objects[i].sprite, Cardinal.Objects[i].x, Cardinal.Objects[i].y)
        Cardinal.Objects[i].collisions.solid:draw('line')
    end

    --Items
    for i=1, len(Cardinal.ItemInstances) do
        if Cardinal.ItemInstances[i].draw then
            love.graphics.draw(Cardinal.ItemInstances[i].sprite, Cardinal.ItemInstances[i].x, Cardinal.ItemInstances[i].y)
            Cardinal.ItemInstances[i].collisions.interact:draw('line')
        end
    end

    --GUI
    love.graphics.draw(Cardinal.textures.HealthBar,Cardinal.players[1].x-love.graphics.getWidth()*(camScale/2)+30,Cardinal.players[1].y-love.graphics.getHeight()*(camScale/2)+30, 0, 2, 2)
    love.graphics.draw(Cardinal.textures.GUIEquip, Cardinal.players[1].x+love.graphics.getWidth()*(camScale/2)-750, Cardinal.players[1].y-love.graphics.getHeight()*(camScale/2)+30)
    Cardinal.players[1]:drawEquipment(Cardinal.players[1].x+love.graphics.getWidth()*(camScale/2)-750, Cardinal.players[1].y-love.graphics.getHeight()*(camScale/2)+30)
    Cardinal.players[1]:drawInventory(Cardinal.players[1].x+love.graphics.getWidth()*(camScale/2)-750, Cardinal.players[1].y-love.graphics.getHeight()*(camScale/2)+30+Cardinal.textures.GUIEquip:getHeight())

    camera:unset()
end

function love.update(dt)
    local x, y = camera:mousePosition()
    local newWPos = {y= Cardinal.players[1].y + (y- Cardinal.players[1].y)*dt,x = Cardinal.players[1].x + (x- Cardinal.players[1].x)*dt}
    local newSPos = {y= Cardinal.players[1].y - (y- Cardinal.players[1].y)*dt,x = Cardinal.players[1].x - (x- Cardinal.players[1].x)*dt }

    MouseCollide:moveTo(x, y)

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
    if love.mouse.isDown(1) then
        local collides = {}
        if Cardinal.players[1].collisions.pickUp:collidesWith(MouseCollide) then
            for i=1, len(Cardinal.ItemInstances) do
                if Cardinal.ItemInstances[i].pickUp then
                    if Cardinal.ItemInstances[i].collisions.interact ~= nil then
                        if Cardinal.players[1].collisions.pickUp:collidesWith(Cardinal.ItemInstances[i].collisions.interact) then
                            table.insert(collides, Cardinal.ItemInstances[i])
                        end
                    end
                end
            end
            for i=1,len(collides) do
                print("processing: "..tostring(collides[i].type))
                Cardinal.players[1]:processItem(collides[i])
            end
            --print_r(collides)
        end
    end
    if Keys["e"] then
        print_r(Cardinal.players[1].Inventory)
    end
    if Keys["f"] then
        print_r(Cardinal.players[1].Equipment)
    end
    --End Key Handling
end



function love.keypressed(key)
    Keys[key] = true
end
function love.keyreleased(key)
    Keys[key] = false
end