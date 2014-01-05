function init(v)
  self.jumpt = 0
  self.boostPower = entity.configParameter("boostPower")
  self.jumpSound = entity.configParameter("jumpSound")
end

function firstValidEntity(eids)
  local valid = { "monster", "npc" }
  for i, id in ipairs(eids) do
    local et = world.entityType(id)
    for j, vt in ipairs(valid) do
      if (et == vt) and not world.callScriptedEntity(id, "entity.onGround") then return id end
    end
  end
  return nil
end

function process(offset)
  local eids = world.entityQuery(entity.toAbsolutePosition({ 0.5, offset }), 2, { notAnObject = true, order = "nearest" })
  local id = firstValidEntity(eids)
  if id ~= nil then
    local e = entityProxy.create(id)
    local v = e.velocity()
    if v ~= nil then
      if v[2] < -self.boostPower then v[2] = -v[2] * 1.05
      elseif v[2] < 0 then v[2] = -v[2] + self.boostPower
      else return end
      e.setVelocity(v)
      self.jumpt = 5
    end
  end
end

function main()
  if self.jumpt > 0 then self.jumpt = self.jumpt - 1
  else
    process(2.5)
    if self.jumpt == 0 then process(1.5) end
  end
  local state = entity.animationState("jumpState")
  if state == "idle" and self.jumpt > 0 then
    entity.setAnimationState("jumpState", "jump")
    entity.playImmediateSound(self.jumpSound)
  elseif state == "jump" and self.jumpt < 1 then entity.setAnimationState("jumpState", "idle") end
end