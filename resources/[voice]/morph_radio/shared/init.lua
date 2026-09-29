Shared = {}

---@class Shared
---@field Ready boolean
---@field UseCommand boolean
---@field Debug boolean
---@field Overlay 'default'|'always'|'never'

---@type Shared
Shared = {
    Ready = true,
    UseCommand = false,
    Debug = false,
    Overlay = 'never' -- default, always, never
}

if not LoadResourceFile(GetCurrentResourceName(), 'build/index.html') then
    Shared.Ready = false
    warn('UI has not been built, refer to the readme or download a release build.\n	^3https://github.com/Qbox-project/morph_radio/releases/')
end

if not lib.checkDependency('morph_ui', '3.14.0') then
    Shared.Ready = false
    warn('Missing Update of morph_ui, please update your morph_ui to 3.14.0')
end

lib.locale()