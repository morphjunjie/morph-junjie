local npcPed = nil
local npcCoords = vector4(410.53, -954.45, 28.46, 267.31)

local damageTexts = {}

local lastHealth = 100
local lastArmour = 100


function SpawnNPC()

    local model = GetHashKey("s_m_m_security_01")

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    npcPed = CreatePed(4, model, npcCoords.x, npcCoords.y, npcCoords.z, npcCoords.w, false, true)

    SetBlockingOfNonTemporaryEvents(npcPed, true)
    FreezeEntityPosition(npcPed, true)

    -- normalize health
    SetEntityMaxHealth(npcPed, 200)
    SetEntityHealth(npcPed, 200)

    SetPedArmour(npcPed, 100)

    lastHealth = 100
    lastArmour = 100

end



-- DRAW BAR (txadmin style)
function DrawBar(sx,sy,width,height,value,max,r,g,b)

    local pct = value / max

    -- background
    DrawRect(sx,sy,width,height,20,20,20,200)

    -- bar
    DrawRect(
        sx - (width/2) + (pct * width)/2,
        sy,
        pct * width,
        height,
        r,g,b,255
    )

end



-- DAMAGE TEXT
function DrawFloatingText(x,y,z,text,r,g,b,a)

    local onScreen,_x,_y = World3dToScreen2d(x,y,z)

    if onScreen then

        SetTextScale(0.45,0.45)
        SetTextFont(4)

        SetTextColour(r,g,b,a)
        SetTextOutline()

        SetTextCentre(true)

        BeginTextCommandDisplayText("STRING")
        AddTextComponentString(text)
        EndTextCommandDisplayText(_x,_y)

    end

end



CreateThread(function()

    while true do
        Wait(0)

        if npcPed and DoesEntityExist(npcPed) then

            local coords = GetEntityCoords(npcPed)

            local rawHealth = GetEntityHealth(npcPed)
            local armour = GetPedArmour(npcPed)

            -- convert health GTA → 100 system
            local health = math.max(0, rawHealth - 100)

            local headZ = coords.z + 1.2

            local onScreen,sx,sy = World3dToScreen2d(coords.x,coords.y,headZ)

            if onScreen then

                -- HEALTH BAR
                DrawBar(sx,sy,0.09,0.008,health,100,255,255,255)

                -- ARMOUR BAR
                DrawBar(sx,sy+0.012,0.09,0.008,armour,100,90,150,255)

            end



            -- DAMAGE DETECT
            local healthDiff = lastHealth - health
            local armourDiff = lastArmour - armour


            if armourDiff > 0 then

                local bone = GetPedBoneCoords(npcPed,57005,0.15,0.0,0.0)

                table.insert(damageTexts,{
                    x = bone.x,
                    y = bone.y,
                    z = bone.z,
                    text = "-"..armourDiff,
                    r = 90,
                    g = 150,
                    b = 255,
                    alpha = 255,
                    offset = 0
                })

            elseif healthDiff > 0 then

                local bone = GetPedBoneCoords(npcPed,57005,0.15,0.0,0.0)

                table.insert(damageTexts,{
                    x = bone.x,
                    y = bone.y,
                    z = bone.z,
                    text = "-"..healthDiff,
                    r = 255,
                    g = 255,
                    b = 255,
                    alpha = 255,
                    offset = 0
                })

            end


            lastHealth = health
            lastArmour = armour



            -- RENDER DAMAGE
            for k,v in pairs(damageTexts) do

                DrawFloatingText(
                    v.x,
                    v.y,
                    v.z + v.offset,
                    v.text,
                    v.r,
                    v.g,
                    v.b,
                    v.alpha
                )

                v.offset = v.offset + 0.02
                v.alpha = v.alpha - 5

                if v.alpha <= 0 then
                    damageTexts[k] = nil
                end

            end



            -- RESPAWN
            if IsEntityDead(npcPed) then

                Wait(1000)

                DeleteEntity(npcPed)
                damageTexts = {}

                SpawnNPC()

            end

        end

    end

end)


CreateThread(function()
    SpawnNPC()
end)