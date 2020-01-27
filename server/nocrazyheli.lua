local reset_physics_ms = 150

local helitable = {}

function getdistbetween(last,cur)
   local distbetween = 0

   local lastis = false
   local curis = false

   local lastisbiggerthancur = false


                if last > 0 then
                   lastis=true
                end
                if cur > 0 then
                  curis=true
                end
                if (lastis and curis) then
                   if last>=cur then
                    lastisbiggerthancur=true
                      distbetween=last-cur
                   else
                    distbetween=cur-last
                   end
                end
                if (lastis==false and curis==false) then
                   local convlast = last*-1
                   local convcur = cur*-1
                   if convlast>=convcur then
                    lastisbiggerthancur=true
                    distbetween=convlast-convcur
                 else
                  distbetween=convcur-convlast
                 end
                end
                if (lastis and curis==false) then
                    local convcur = cur*-1
                    if last>=convcur then
                        lastisbiggerthancur=true
                         distbetween=last-convcur
                    else
                       distbetween=convcur-last
                    end
                end
                if (lastis==false and curis) then
                     local convlast = last*-1
                     if convlast>=cur then
                        lastisbiggerthancur=true
                         distbetween=convlast-cur
                     else
                        distbetween=cur-convlast
                     end
                end

   return distbetween,lastisbiggerthancur
end

function reloadvehphysics(veh)
   if (GetVehicleDriver(veh) ~=0 and GetVehicleDriver(veh) ~=false) then
      local ply = GetVehicleDriver(veh)
      RemovePlayerFromVehicle(GetVehicleDriver(veh))
      StopVehicleEngine(veh)
      Delay(reset_physics_ms,function()
         if IsValidPlayer(ply) then
            SetVehicleRotation(veh, 0, 0, 0)
             SetPlayerInVehicle(ply, veh)
             StartVehicleEngine(veh)
         end
      end)
    end
end

AddEvent("OnGameTick",function()
    for i,v in ipairs(helitable) do
        local foundheli = false
       for i2,v2 in ipairs(GetAllVehicles()) do
          if v.id == v2 then
             foundheli=true
          end
       end
       if foundheli==false then
          table.remove(helitable,i)
       end
    end

    for i,veh in ipairs(GetAllVehicles()) do
        if (GetVehicleModelName(veh)=="Helicopter_01" or GetVehicleModelName(veh)=="Helicopter_02") then
            local rx,ry,rz = GetVehicleRotation(veh)
            local found = false
            local index = 0
            for i,v in ipairs(helitable) do
               if v.id == veh then
                   index=i
                  found=true
               end
            end
            if found==false then
                insert = {}
                insert.id = veh
                insert.lastrz = rz
                insert.lastrx = rx
               table.insert(helitable,insert)
            else
            lastrz = helitable[index].lastrz
            lastrx = helitable[index].lastrx
            local distbetween,lastisbiggerthancur = getdistbetween(lastrz,rz)
            local distbetween2,lastisbiggerthancur2 = getdistbetween(lastrx,rx)

            helitable[index].lastrz=rz
            helitable[index].lastrx=rx
            if distbetween~=0.0 then
            if distbetween>20 then
                SetVehicleRotation(veh, 0, 0, 0)
                SetVehicleLinearVelocity(veh, reset_physics_ms*3, 0, reset_physics_ms*3,true)
                if lastisbiggerthancur then
                SetVehicleAngularVelocity(veh, distbetween,0,0,true)
                else
                  SetVehicleAngularVelocity(veh, -distbetween,0,0,true)
                end
                reloadvehphysics(veh)
            end
            end
            if distbetween2~=0.0 then
                if distbetween2>20 then
                  SetVehicleRotation(veh, 0, 0, 0)
                  SetVehicleLinearVelocity(veh, reset_physics_ms*3, 0, reset_physics_ms*3,true)
                  if lastisbiggerthancur2 then
                     SetVehicleAngularVelocity(veh, 0,distbetween2,0,true)
                     else
                       SetVehicleAngularVelocity(veh, 0,-distbetween2,0,true)
                     end
                  reloadvehphysics(veh)
                end
            end

            end
        end
    end
end)