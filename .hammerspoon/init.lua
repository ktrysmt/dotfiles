--[[
    References:
    * http://www.hammerspoon.org/docs/hs.hotkey.html#new
    * http://www.hammerspoon.org/docs/hs.eventtap.html#new
    * http://rochefort.hatenablog.com/entry/2017/03/06/070000
]]

--[[
    Reloading
]]
hs.hotkey.bind({"cmd", "alt"}, "R", function()
  hs.reload()
end)
hs.alert.show("config reloaded.")

--[[
    Switch kana and eisu
]]
local kana = false
local function switchEisuKanaByOne(e)
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
eventtap = hs.eventtap.new({hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp}, switchEisuKanaByOne)
eventtap:start()

--[[
    Mapping functions
]]
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

--[[
    Remaps
]]
remapKey({'cmd'}, 30, keyCode('escape'))
remapKey({'cmd'}, 'h', keyCode('up'))
remapKey({'cmd'}, 39, keyCode('down')) -- colon
remapKey({'cmd'}, 'j', keyCode('a', {'ctrl'}))
remapKey({'cmd'}, 41, keyCode('e', {'ctrl'})) -- semicolon
remapKey({'cmd'}, 'k', keyCode('left'))
remapKey({'cmd'}, 'l', keyCode('right'))
remapKey({'cmd', 'shift'}, 'h', keyCode('up', {'shift'}))
remapKey({'cmd', 'shift'}, 39,  keyCode('down', {'shift'})) -- colon
remapKey({'cmd', 'shift'}, 'j', keyCode('A', {'shift','ctrl'}))
remapKey({'cmd', 'shift'}, 41, keyCode('E', {'shift','ctrl'})) -- semicolon
remapKey({'cmd', 'shift'}, 'k', keyCode('left', {'shift'}))
remapKey({'cmd', 'shift'}, 'l', keyCode('right', {'shift'}))

--[[
    Main
]]
local function handleGlobalEvent(name, event, app)
    if event == hs.application.watcher.activated then
        local bundleId = string.lower(app.frontmostApplication():bundleID())
        -- hs.alert.show(bundleId)
        if (bundleId:match("iterm2")) then
            disableAllHotkeys()
            -- hs.execute("'/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli' --select-profile 'Naked profile'")
        -- elseif (bundleId:match("com.apple.terminal")) then
        --     disableAllHotkeys()
        --     hs.execute("'/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli' --select-profile 'Naked profile'")
        elseif (bundleId:match("com.google.chrome")) then
            remapKey({'option'}, 'D', keyCode('C', {'ctrl'})) -- chrome.v69対策 1 (macOS側は[場所を開く… > ctrl+C]にする)
            enableAllHotkeys()
            -- hs.execute("'/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli' --select-profile 'Default profile'")
        else
            enableAllHotkeys()
            -- hs.execute("'/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli' --select-profile 'Default profile'")
        end
    end
end
watcher = hs.application.watcher.new(handleGlobalEvent)
watcher:start()
hs.execute("'/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli' --select-profile 'Default profile'")
