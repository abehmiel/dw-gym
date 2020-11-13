
debug = {
	hud = true,
  cheats_enabled = false,
  cheats = function()
    player:set_experience(65535)
    player:set_gold(65535)
    memory.writebyte(0xbe, 255) -- best equipment
    memory.writebyte(0xbf, 6)   -- 6 herbs
    memory.writebyte(0xc0, 6)   -- 6 keys
    memory.writebyte(0xc1, 14)  -- rainbow drop
  end 
}

features = {
  herb_store = false, -- buy herbs anywhere
  enemy_hp = false,  -- show enemy hit points
  repulsive = false, -- no lower level enemy encounters
}

levels = {}

Set = {}
Set.mt = {}
    
function Set.new (t)
  local set = {}
  for _, l in ipairs(t) do set[l] = true end
  setmetatable(set, Set.mt)
  return set
end
    
function Set.union (a,b)
  local res = Set.new{}
  for k in pairs(a) do res[k] = true end
  for k in pairs(b) do res[k] = true end
  return res
end
    
function Set.intersection (a,b)
  local res = Set.new{}
  for k in pairs(a) do
    res[k] = b[k]
  end
  return res
end

function Set.contains (obj, item)
  local val = false
  for k in pairs(obj) do
    if k == item then
      val = true
    end
  end
  return val
end

function Set.tostring (set)
  local s = "{"
  local sep = ""
  for e in pairs(set) do
    s = s .. sep .. e
    sep = ", "
  end
  return s .. "}"
end

Set.mt.__add = Set.union

function formatTimerString(hours, minutes, seconds)
  timerString = ""
  pixelWidth = 0 --we assume numbers are 6px wide and punctuation is 3px wide based on current release 2.2.3 of fceux

  --Hours
  if hours > 0 then --don't need to display hours at all if we're under 60 minutes
    timerString = timerString .. string.format("%.0f", hours)
    pixelWidth = pixelWidth + numberPixelLength(hours)

    if minutes < 10 then
      timerString = timerString .. ":0"
      pixelWidth = pixelWidth + 9
    else
      timerString = timerString .. ":"
      pixelWidth = pixelWidth + 3
    end
  end

  --Minutes
  timerString = timerString .. string.format("%.0f",minutes)
  if minutes < 10 then
    pixelWidth = pixelWidth + 6
  else
    pixelWidth = pixelWidth + 12
  end

  --Seconds
  if seconds < 10 then
    timerString = timerString .. ":0" .. string.format("%0.2f",seconds) --displaying the timer, we need a leading zero on the seconds
  else
    timerString = timerString .. ":" .. string.format("%0.2f",seconds) --we do not need a leading zero on the seconds
  end
  pixelWidth = pixelWidth + 30 --13+26+13+26 :00.00

  return {["pixelWidth"]=pixelWidth, ["timer"]=timerString}
end

function numberPixelLength(number)
  if number == 0 then
    return 1*6
  end

  length = 0
  if number < 0 then
    number = number -1 --this math doesn't work on negative numbers
    length = length + 5 --negative sign is 5 pixels wide
  end

  return math.floor(math.log10(number)+1) * 6 + length --conveniently, all numbers characters are 6 pixels wide (including spacing)
end

nesClockSpeed = (39375000/655171)
totalFrames = 0
timerstring = {["pixelwidth"]=0, ["timer"]="0:00:00"}

TILE = {
  GRASS = 0,
  DESERT = 1,
  HILLS = 2,
  STAIRS_UP = 3,
  TILES = 4,
  STAIRS_DOWN = 5,
  SWAMP = 6,
  TOWN = 7,
  CAVE = 8,
  CASTLE = 10,
  BRIDGE = 11,
  FOREST = 12,
  CHEST = 13,
  FORCE_FIELD = 14
}

tile_names = {
  "Grass",
  "Desert",
  "Hill",
  "Stairs Up",
  "Brick",
  "Stairs Down",
  "Swamp",
  "Town",
  "Cave",
  "Castle",
  "Bridge",
  "Forest",
  "Chest",
  "Barrier",
}

maps = {
  "Alefgard",
  "Charlock",
  "Hauksness",
  "Tantegel",
  "Tantegel Throne Room",
  "Charlock Throne Room",
  "Kol",
  "Brecconary",
  "Garinham",
  "Cantlin",
  "Rimuldar",
  "Tantegel Basement",
  "Northern Shrine",
  "Southern Shrine",
  "Charlock Cave Lv 1",
  "Charlock Cave Lv 2",
  "Charlock Cave Lv 3",
  "Charlock Cave Lv 4",
  "Charlock Cave Lv 5",
  "Charlock Cave Lv 6",
  "Swamp Cave",
  "Mountain Cave",
  "Mountain Cave Lv 2",
  "Garin's Grave Lv 1",
  "Garin's Grave Lv 2",
  "Garin's Grave Lv 3",
  "Garin's Grave Lv 4",
  "Erdrick's Cave",
  "Erdrick's Cave Lv 2"
}

map_encounters = {
    true,
    true,
    true,
    false,
    false,
    true,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true
}



strings = {
  encounter = {
    "A %s draws near!",
    "Hark! A %s approacheth!",
    "What is that I see? Why it's a %s!",
    "I have no quarrel with you Sir %s, but I must pass.",
    "You got something for me %s? Bring it!"
  },
  enemyrun = {
    "I suppose he didst not likest me much.",
    "Comest back here thee coward!",
    "Oh running away eh? Come back here and fight me! I'll bite your legs off!",
    "Oh comest on! Why did thee even comest over if thee were just to runnest away?",
    "It was in quite a hurry.",
    "That's right! You get on down the road and don't come back!",
    "Fine, just goest. Leavest me liketh everyone else. Well, excepteth that clingy princess.",
    "Wait what just happened? That %s just disappeared!"
  },
  playerrun = {
    "Whew! That was scary!",
    "I have made my escape from the vile %s",
    "I just felt like running. So I did.",
    "You can't catch me son! Don't even try!",
    "It was a fierce beast! With big fangs! What? Didn't you see the bones?",
    "I think I soiled my armor.",
    "Who, me? I wasn't running from it, I just had somewhere to be...that wasn't anywhere near that %s."
  },
  enemydefeat = {
    "I hath done well in defeating the %s.",
    "Oh! You got wrecketh bro!",
    "Thou just stayeth down there chump!",
    "There ain't gonna be no rematch!",
    "Did you see that? There were like 20 of them! No match for me though.",
    "That was easy.",
    "Seriously? That's all you got? Where's the REAL challenger?",
    "You can't touch this.",
    "I attack the %s! It's super effective!",
    "Who has two thumbs and just put thee down? This guy!",
    "Who's the hero? Who is the hero? That's right, I'm the hero."

  },
  lowhp = {
    "Uuungh... I don't feel so well",
    "MEDIC!",
    "I'm kinda losing a lot of blood here...",
    "'Tis but a scratch!",
    "Oh, it's just a flesh wound.",
    "It is getting dark...I am not long for this world! Oh, nevermind, my helmet was on backward.",
    'So what are "hit points" anyway? More is better, right?'
  },
  playerdefeat = {
    "Ouch.",
    "That really hurt, Charlie!",
    "Oy! Gevalt!",
    "I'll be back.",
    "I'm not quite dead yet. Oh, nevermind, yes I am.",
    "Oh great king! A little help here please!",
    "Well that didn't go quite like I envisioned it.",
    "Thou are at fault for this! Thou! Thou! Not I! Thou art a terrible tactician!",
    "They telleth me to goest toward the light..."
  }
}



function say(str) 
  print(string.format("%s\n", str))
end

function battle_message(strings, enemy_type)
--  if enemy_type == nil then
--    say(strings[math.random(#strings)])
--  else
--    local enemy_name = enemy.types[enemy_type]
--    if enemy_name ~= nil then
--      say(strings[math.random(#strings)]:format(enemy_name))
--    end
--  end
end


in_battle = false
pre_battle = false
function battle_mode (battling, reset_enemy_hp)
  if battling ~= nil then
    in_battle = battling
    pre_battle = battling
    player.valid_tile = false
    if not battling then
      if (reset_enemy_hp == true) then
        -- overwrite monster hp to avoid confusion
        enemy:set_hp(0)
      end
    end
  end
  return in_battle
end

Player = {
  level = 0,
  hp = 0,
  mp = 0,
  agi = 0,
  atk = 0,
  def = 0,
  gold = 0,
  experience = 0,
  change = {
    level = 0,
    hp = 0,
    mp = 0,
    gold = 0,
    experience = 0
  },
  herbs = 0,
  keys = 0,
  map_x = 0,
  map_y = 0,
--   player_x = 0,
--   player_y = 0,
--   current_map = 0,
  tile = 0,
  last_tile = 0,
  valid_tile = false,

}

function Player.update (self)

  --level cap
  if features.level_cap ~= nil then
    local exp_cap = self.levels[features.level_cap]
    if self:get_experience() > exp_cap then
      self:set_experience(exp_cap)
    end
  end

  -- read in the values from memory.
  local level = self:get_level()
  local hp = self:get_hp()
  local mp = self:get_mp()
  local agi = self:get_agi()
  local atk = self:get_atk()
  local def = self:get_def()
  local gold = self:get_gold()
  local experience = self:get_experience()

  -- update the changes.
  self.change.level = level - self.level
  self.change.hp = hp - self.hp
  self.change.mp = mp - self.mp
  self.change.gold = gold - self.gold
  self.change.experience = experience - self.experience

  -- update the object variables.
  self.level = level
  self.hp = hp
  self.mp = mp
  self.agi = agi
  self.atk = atk
  self.def = def
  self.gold = gold
  self.experience = experience

  self.herbs = self.get_herbs()
  self.keys = self:get_keys()

  self.last_tile = self.tile
  self.tile = self:get_tile()
  local map_x = self:get_x()
  local map_y = self.get_y()
  if (map_x ~= self.map_x or map_y ~= self.map_y) then
    if in_battle then
      battle_mode(false, true)
    end
    self.valid_tile = true
  end
  if (self.current_map ~= self.get_map()) then
    self.valid_tile = false
  end
  self.map_x = map_x
  self.map_y = map_y
--   self.player_x = memory.readbyte(0x3a)
--   self.player_y = memory.readbyte(0x3b)
   self.current_map = self:get_map()

  if hp == 0 and self.change.hp ~= 0 and player:get_map() > 0 then
    battle_message(strings.playerdefeat, player:get_tile()+1)
  end

end

function Player.get_tile(self)
  return memory.readbyte(0xe0)
end

function Player.get_x(self)
  return memory.readbyte(0x8e)
end

function Player.get_y(self)
  return memory.readbyte(0x8f)
end

function Player.get_herbs(self)
  return memory.readbyte(0xc0)
end

function Player.get_keys(self)
  return memory.readbyte(0xbf)
end

function Player.get_level(self)
  return memory.readbyte(0xc7)
end

function Player.next_level(self)
  if self:get_level() == features.level_cap then
    return 0
  end
  for i=1,#self.levels do
    if self.levels[i] > self:get_experience() then
      return self.levels[i] - self:get_experience()
    end
  end
  return 0
end

function Player.get_hp(self)
  return memory.readbyte(0xc5)
end

function Player.max_hp(self)
  return memory.readbyte(0xca)
end

function Player.get_mp(self)
  return memory.readbyte(0xc6)
end

function Player.get_agi(self)
  return memory.readbyte(0xc9)
end

function Player.get_atk(self)
  return memory.readbyte(0xcc)
end

function Player.get_def(self)
  return memory.readbyte(0xcd)
end

function Player.add_hp (self, amount)
  return self:set_hp(self.hp + amount)
end

function Player.set_hp (self, amount)
  if (amount > 255 or amount < 0) then
    return false
  end
  self.hp = amount
  memory.writebyte(0xc5, amount)
  return true
end

function Player.max_mp(self)
  return memory.readbyte(0xcb)
end

function Player.get_map(self)
  return memory.readbyte(0x45)
end

function Player.add_mp (self, amount)
  return self:set_mp(self.mp + amount)
end

function Player.set_mp (self, amount)
  if (amount > 255 or amount < 0) then
    return false
  end
  self.mp = amount
  memory.writebyte(0xc6, amount)
  return true
end

function Player.get_gold(self)
  return memory.readbyte(0xbd) * 256 + memory.readbyte(0xbc)
end

function Player.add_gold (self, amount)
  return self:set_gold(self.gold + amount)
end

function Player.set_gold (self, amount)
  if (amount > 65535 or amount < 0) then
    return false
  end
  self.gold = amount
  memory.writebyte(0xbd, amount / 256)
  memory.writebyte(0xbc, amount % 256)
  return true
end

function Player.get_experience(self)
  return memory.readbyte(0xbb) * 256 + memory.readbyte(0xba)
end

function Player.add_experience (self, amount)
  return self:set_experience(self.experience + amount)
end

function Player.set_experience (self, amount)
  if (amount > 65535 or amount < 0) then
    return false
  end
  self.experience = amount
  memory.writebyte(0xbb, self.experience / 256)
  memory.writebyte(0xba, self.experience % 256)
end


Enemy = {
  hp = 0,
  change = {
    hp = 0
  },
  types = {
    "Slime",  -- 0
    "Red Slime",
    "Drakee",
    "Ghost",
    "Magician",
    "Magidrakee", -- 5
    "Scorpion",
    "Druin",
    "Poltergeist",
    "Droll",
    "Drakeema",  --10
    "Skeleton",
    "Warlock",
    "Metal Scorpion",
    "Wolf",
    "Wraith",  --15
    "Metal Slime",
    "Specter",
    "Wolflord",
    "Druinlord",
    "Drollmagi",  --20
    "Wyvern",
    "Rogue Scorpion",
    "Wraith Knight",
    "Golem",
    "Goldman",  -- 25
    "Knight",
    "Magiwyvern",
    "Demon Knight",
    "Werewolf",
    "Green Dragon",  -- 30
    "Starwyvern",
    "Wizard",
    "Axe Knight",
    "Blue Dragon",
    "Stoneman", --35
    "Armored Knight",
    "Red Dragon",
    "Dragonlord",  --first form
    "Dragonlord"  --second form

  },
  abbrvs = {
    "Slime", --
    "RSlime",
    "Drakee",
    "Ghost",
    "Magici",
    "MDrake", --
    "Scorp",
    "Druin",
    "Polter",
    "Droll",
    "Drkema", --
    "Skelet",
    "Warloc",
    "MScorp",
    "Wolf",
    "Wraith", --
    "MSlime",
    "Spectr",
    "WolfLd",
    "DruinL",
    "DrollM", --
    "Wyvern",
    "RScorp",
    "WKnight",
    "Golem",
    "Goldmn", --
    "Knight",  
    "MWyvrn",
    "DKnight",
    "WWolf",
    "GDragn", --
    "SWyvrn",
    "Wizard",
    "AxKnit",
    "BDragn",
    "StoneM", --
    "ArKnit",
    "RDragn",
    "DragLd",
    "DragLd"
  }
}

function Enemy.update (self)
  -- read in the values from memory.
  hp = memory.readbyte(0xe2)
  -- update the changes.
  self.change.hp = hp - self.hp
  -- update the object variables.
  self.hp = hp
  self.index = memory.readbyte(0xe0)
  self.str = rom.readbyte(0x5e5b + self.index * 16)
  self.agi = rom.readbyte(0x5e5c + self.index * 16)

  -- update battle status
  if not in_battle and self.change.hp ~= 0 then
    battle_mode(true, false)
  end

  -- hit points wrap below zero, so check for large increases.
  if in_battle and (self.hp == 0 or self.change.hp > 160) then
    battle_mode(false, false)
    battle_message(strings.enemydefeat, player:get_tile()+1)
  end

end

function Enemy.show_hp (self)
  if (in_battle and features.enemy_hp) then 
    gui.drawbox(152, 134, 190, 144, "black")
    gui.text(154, 136, string.format( "HP %3d", self.hp), "white", "black")
  end
end

function Enemy.set_hp(self, hp)
  if (hp > 255 or hp < 0) then
    return false
  end
  self.hp = hp
  memory.writebyte(0xe2, hp)
  return true
end

function Enemy.get_str(self)
  return self.str
end

function Enemy.get_agi(self)
  return self.agi
end

function Enemy.get_abbr(self)
  return self.abbrvs[self.index + 1]
end

function Enemy.get_index(self)
  return self.index
end

function Enemy.get_group_factor(self)
  if self.index <= 19 then
    return 0.250
  elseif self.index <= 29 then
    return 0.375
  elseif self.index <= 34 then
    return 0.500
  else
    return 1.000
  end
end

function Enemy.hud (self)
  local enemy_type = enemy.types[self.index+1]
  lbound = 186
  if enemy_type ~= nil then
    gui.drawbox(lbound, 64, 260, 154, "black")
    gui.text(lbound, 64, enemy_type, "white", "black")
    gui.text(lbound, 74, string.format( "HP %3d", self.hp), "white", "black")
    gui.text(lbound, 84, string.format("Str %3d", self.str), "white", "black")
    gui.text(lbound, 94, string.format("Agi %3d", self.agi), "white", "black")
    gui.text(lbound, 104, "H Dmg "..calc_hero_dmg(), "white", "black")
    gui.text(lbound, 114, "E Dmg "..calc_enemy_dmg(), "white", "black")
    gui.text(lbound, 124, "Run "..calc_run_chance(), "white", "black")
    -- show the special attacks
    specialset1 = { "Sleep", "Stopspell", "Heal", "Healmore" }
    specialset2 = { "Hurt", "Hurtmore", "fire", "fire 2" }
    local specials = rom.readbyte(0x5e5e + self.index * 16)
    local ypos = 134
    local spectype = specialset1[math.floor(specials / 64) + 1]
    specchance = math.floor(specials / 16 % 4) * 25
    if specchance > 0 then
      gui.text(lbound, ypos, string.format("%s  %2d%%", spectype, specchance), 
        "white", "black")
      ypos = ypos + 10
    end
    spectype = specialset2[math.floor((specials / 4) % 4) + 1]
    specchance = (specials % 4) * 25
    if specchance > 0 then
      gui.text(lbound, ypos, string.format("%s  %2d%%", spectype, specchance), 
        "white", "black")
    end
  end
end

Encounters = {
  enc_zones = {},
  this_zone = nil
}

function Encounters.update(self)
  local zone = 0
  if map.index == 1 then
    zone = get_zone()
  end
  self.this_zone = string.format('%s%d', map.current_map, zone)

  if in_battle then
    local enemy_abbr = enemy:get_abbr()
    if (self.enc_zones[self.this_zone] == nil) and (map.encounters_allowed == true) then
      self.enc_zones[self.this_zone] = Set.new{enemy_abbr}
    elseif (not Set.contains(self.enc_zones[self.this_zone], enemy_abbr)) and (map.encounters_allowed == true) then
      self.enc_zones[self.this_zone] = self.enc_zones[self.this_zone] + Set.new{enemy_abbr}
    end
  end
end

Map = {
  index = memory.readbyte(0x45),
  current_map = nil,
  encounters_allowed = false
}

function Map.update (self)
  self.index = player:get_map()
  self.current_map = maps[self.index]
  self.encounters_allowed = map_encounters[self.index]
end

-- 
--  Draws any hud elements, such as the enemy hit points
--  and debug info
-- 
function overlay()
  if debug.hud then
    local map_index = player:get_map()
    current_map = maps[map_index]
    if (map_index ~= nil) and (map_index ~= 0) then

      gui.drawbox(0, 0, 255, 16, "black")

	  -- timer
      if timer == false then
        timer = true
        totalFrames = 1
      else
        totalFrames = totalFrames + 1
        gui.text(194, 8, timerstring["timer"], "white", "black")
      end

      gui.text(8, 8, 
        string.format("%s (%3d,%3d)", current_map, memory.readbyte(0x8e), 
          memory.readbyte(0x8f)), 
        "white", "black")
      if map_index == 1 then
        local zone = get_zone()
        local zonestr = string.format( "Zone %d", zone)
        gui.text(140, 8, zonestr, "white", "black")
      end

      -- encounter tracker
      gui.drawbox(0, 224, 255, 255, "black")
      if encounters.this_zone ~= nil then
        if (encounters.enc_zones[encounters.this_zone] ~= nil) then
          gui.text(8, 224,
          Set.tostring(encounters.enc_zones[encounters.this_zone]), 
          "white", "black")
        end
      end
      -- battle HUD
      if in_battle then
        enemy:hud()
      end
    else 
      timer = false
    end
  else
    enemy:show_hp()
  end
end

function get_zone()
  local zone = math.floor(player.map_x / 15) + math.floor(player.map_y / 15) * 8
  if zone % 2 == 1 then
    zone = rom.readbyte(zone/2 + 0xf532)
    zone = math.floor(zone % 16)
  else
    zone = rom.readbyte(zone/2 + 0xf532)
    zone = math.floor(zone / 16)
  end
  return zone
end

function update_timer()
	totalSeconds = totalFrames/nesClockSpeed
	seconds = totalSeconds % 60
	minutes = math.floor(totalSeconds / 60) % 60
	hours = math.floor(totalSeconds / 3600)
	return formatTimerString(hours, minutes, seconds)
end

function calc_enemy_dmg()
  local h_def = player:get_def()
  local e_str = enemy:get_str()
  if h_def >= e_str then
    lo = 0
    hi = math.floor((e_str + 4) / 6)
  else
    lo = math.floor((e_str - (h_def / 2)) / 4)
    hi = math.floor((e_str - (h_def / 2)) / 2)
  end 
  return lo.."-"..hi
end

function calc_hero_dmg()
  local h_atk = player:get_atk()
  local e_agi = enemy:get_agi()
  local lo = math.floor((h_atk - (e_agi / 2)) / 4)
  local hi = math.floor((h_atk - (e_agi / 2)) / 2)
  if lo < 0 then
    lo = 0
  end
  if hi < 1 then
    hi = 1
  end
  return lo.."-"..hi
end

function calc_run_chance()
  local h_agi = player:get_agi()
  local e_agi = enemy:get_agi()
  local e_agi_mod = e_agi * enemy:get_group_factor()
  local formatted = string.format(
    "%.1f%%", 100 * h_agi / (e_agi_mod + h_agi)
  )
  return formatted
end

function read_levels()
  for i=1,31 do
    levels[i] = rom.readbyte(0xf36c+(i*2)) * 256 + rom.readbyte(0xf36b+(i*2))
  end
end

function update()
  if (player:get_map() > 0) then
    -- update the player and enemy info every 1/4 second
    if (emu.framecount() % 15 == 0) then
      player:update()
      map:update()
      enemy:update()
      encounters:update()
      timerstring = update_timer()	
    end

    if features.repulsive then
      memory.writebyte(0xdb, 0xff)
    end
  end
end


-- for battle detection (enemies or you running away)
function running(address)
  if (player:get_map() > 0) then
    if address == 0xefc8 then
      battle_message(strings.enemyrun, player:get_tile()+1)
    else
      battle_message(strings.playerrun, player:get_tile()+1)
    end
    battle_mode(false, true)
  end
end

-- A thing draws near!
function encounter(address)
  if (player:get_map() > 0) then
    player.valid_tile = false
    battle_message(strings.encounter, memory.readbyte(0x3c)+1)
    pre_battle = true
  end
end

function cheats()
  if debug.cheats_enabled and debug.cheats then
    if (memory.readbyte(0x45) == 1) then
      debug.cheats()
      debug.cheats = false
    end
  end
end


-- main loop
function main()
  -- savestate.load(savestate.object(1))
  memory.registerexecute(0xefc8, running)
  memory.registerexecute(0xe8a4, running)
  memory.registerexecute(0xcf44, encounter)
  memory.registerwrite(0x45, cheats)
  read_levels()

  player = Player
  enemy = Enemy
  encounters = Encounters
  map = Map
  player.last_command = emu.framecount()
  enemy:update()
  player:update()
  map:update()
  update_timer()
  gui.register(overlay)
  emu.registerafter(update)

  while(true) do
    emu.frameadvance()
  end
end

main()
