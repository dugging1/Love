require 'Classes'

--Cardinal Declaration
Cardinal = {Objects={}, Items={}, Entities={}, ItemInstances={}, EntInstances={},Equalibrium={total={Items={}, Mobs={}}, current={Items={}, Mobs={}}}, players={} }
function Cardinal:Init()
    self.Equalibrium.total.Items.rarity = 100

    for i,v in pairs(self.Equalibrium.total) do
        self.Equalibrium.current[i] = {}
        for ii in pairs(v) do
            self.Equalibrium.current[i][ii] = 0
        end
    end
end
function Cardinal:PickItem(Items)
    Items = Items or self.Items
    --Generate conditions
    local conditions = {}
    for i,v in pairs(self.Equalibrium.total.Items) do
        if self.Equalibrium.current.Items[i] == v then
            return false
        end
        conditions[i] = v - self.Equalibrium.current.Items[i]
    end
    --Generate Candidates
    local candidates = {}
    for i,v in pairs(Items) do
        local temp = true
        for ii,vv in pairs(conditions) do
            if v.Equalibrium[ii] > vv then
                temp = false
            end
        end
        if temp then
            candidates[i] = v
        end
    end
    --Weighted selection
    local Weighted = {}
    for i,v in pairs(candidates) do
        if v.rarity ~= 0 then
            Weighted[math.floor(1/v.rarity)+v.randWeight+math.random()*(v.rarity+v.randWeight)] = v
        end
    end
      --Pick Item
    local selected = false
    if len(Weighted) > 0 then
        local function max(t)
            local key, value = 1, t[1]
            for i,v in pairs(t) do
                if i > key then
                    key, value = i, v
                end
            end
            return value
        end
        selected = max(Weighted):new()
        self:InitItem(selected)
    end
    return selected
end
function Cardinal:InitItem(Item)
    table.insert(self.ItemInstances, Item)
    for i in pairs(self.Equalibrium.current.Items) do
        self.Equalibrium.current.Items[i] = self.Equalibrium.current.Items[i] + Item.Equalibrium[i]
    end
end


--End Cardinal Declaration
Cardinal:Init()
return Cardinal