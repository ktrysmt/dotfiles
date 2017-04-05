-- reload
hs.hotkey.bind({"cmd", "alt"}, "R", function()
  hs.reload()
end)
hs.alert.show("config reloaded.")

local kana = false
local function handleEvent(e)
  local keyCode = e:getKeyCode()
  local keyUp = (e:getType() == hs.eventtap.event.types.keyUp)
  local result = false
  if keyCode == 104 then
    if kana then
      if keyUp then
        hs.eventtap.keyStroke({}, 102)
      end
      result = true
    end
    if keyUp then
      kana = not kana
    end
  end
  return result
end

eventtap = hs.eventtap.new({hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp}, handleEvent)
eventtap:start()

-- hotkey
local function keyCode(key, modifiers)
   modifiers = modifiers or {}
   return function()
      hs.eventtap.event.newKeyEvent(modifiers, string.lower(key), true):post()
      hs.timer.usleep(1000)
      hs.eventtap.event.newKeyEvent(modifiers, string.lower(key), false):post()      
   end
end

local function remapKey(modifiers, key, keyCode)
   hs.hotkey.bind(modifiers, key, keyCode, nil, keyCode)
end

local function disableAllHotkeys()
   for k, v in pairs(hs.hotkey.getHotkeys()) do
      v['_hk']:disable()
   end
end

local function enableAllHotkeys()
   for k, v in pairs(hs.hotkey.getHotkeys()) do
      v['_hk']:enable()
   end
end

local function handleGlobalAppEvent(name, event, app)
   if event == hs.application.watcher.activated then
      -- hs.alert.show(name)
      if name ~= "iTerm2" then
         enableAllHotkeys()
      else
         disableAllHotkeys()
      end
      --enableAllHotkeys()
   end
end

appsWatcher = hs.application.watcher.new(handleGlobalAppEvent)
appsWatcher:start()

-- escape
remapKey({'cmd'}, 30, keyCode('escape'))

-- カーソル移動
remapKey({'cmd'}, 'h', keyCode('p', {'ctrl'}))
remapKey({'cmd'}, 39, keyCode('n', {'ctrl'})) -- colon
-- remapKey({'cmd'}, 'j', keyCode('home'))
remapKey({'cmd'}, 'j', keyCode('a', {'ctrl'}))
remapKey({'cmd'}, 41, keyCode('e', {'ctrl'})) -- semicolon
remapKey({'cmd'}, 'k', keyCode('b', {'ctrl'}))
remapKey({'cmd'}, 'l', keyCode('f', {'ctrl'}))
remapKey({'cmd', 'shift'}, 'h', keyCode('up', {'shift'}))
remapKey({'cmd', 'shift'}, 39,  keyCode('down', {'shift'})) -- colon
remapKey({'cmd', 'shift'}, 'j', keyCode('home', {'shift'}))
remapKey({'cmd', 'shift'}, 41, keyCode('end', {'shift'})) -- semicolon
remapKey({'cmd', 'shift'}, 'k', keyCode('left', {'shift'}))
remapKey({'cmd', 'shift'}, 'l', keyCode('right', {'shift'}))
