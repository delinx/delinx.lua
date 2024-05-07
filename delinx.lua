---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- Uitl --------------------------------------------------------------------
function copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
  return res
end

-- Function to adjust saturation of a given color
-- Parameters:
--   colorString: Input color in the format "#RRGGBB" (hexadecimal)
--   saturationChange: Saturation change value from 0.0 to 2.0
-- Returns:
--   Adjusted color in the format "#RRGGBB" (hexadecimal)
function adjustSaturation(colorString, saturationChange)
  -- Validate input
  assert(type(colorString) == "string" and colorString:match("^#%x%x%x%x%x%x$"), "Invalid color format")
  assert(type(saturationChange) == "number" and saturationChange >= 0.0 and saturationChange <= 2.0,
    "Invalid saturation change value")

  -- Extract RGB components
  local r, g, b = tonumber(colorString:sub(2, 3), 16) / 255, tonumber(colorString:sub(4, 5), 16) / 255,
      tonumber(colorString:sub(6, 7), 16) / 255

  -- Convert RGB to HSL
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local l = (max + min) / 2
  local d = max - min

  local function hue2rgb(p, q, t)
    if t < 0 then t = t + 1 end
    if t > 1 then t = t - 1 end
    if t < 1 / 6 then return p + (q - p) * 6 * t end
    if t < 1 / 2 then return q end
    if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
    return p
  end

  local h, s, l = 0, 0, l
  if d ~= 0 then
    s = d / (1 - math.abs(2 * l - 1))
    h = (max == r) and (g - b) / d + ((g < b) and 6 or 0) or
        (max == g) and (b - r) / d + 2 or
        (max == b) and (r - g) / d + 4
    h = h / 6
  end

  -- Adjust saturation
  s = s * saturationChange

  -- Ensure saturation is within bounds
  s = math.max(0, math.min(1, s))

  -- Convert HSL back to RGB
  local q = (l < 0.5) and (l * (1 + s)) or (l + s - l * s)
  local p = 2 * l - q
  r, g, b = hue2rgb(p, q, h + 1 / 3), hue2rgb(p, q, h), hue2rgb(p, q, h - 1 / 3)

  -- Convert RGB to hexadecimal color string
  local function toHex(value)
    return string.format("%02X", math.floor(value * 255))
  end

  return "#" .. toHex(r) .. toHex(g) .. toHex(b)
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
--
-- Delinx theme inspired by J.Blow theme
--
-- Use `:Telescope highlight` to get a good list to search through
-- Use `:Inspect` to get info about colour group under the cursor


-- Defined colours
-- Use `norcalli/nvim-colorizer.lua` to preview HEX as colours
local c = {
  none = "NONE",
  default = "#fa3744",
  default_bg = "#00ff00",
  black = "#000000",       -- selection
  tiber = "#052525",       -- jblow bg
  tiberdark = "#031b1b",   -- jbloxextra float
  tan = "#c8b491",         -- jblow vars
  tanhalf = "#5a6354",     -- Tan half transparency
  white = "#ffffff",       -- jblow logic
  mystic = "#c3d2e1",      -- jblow it, cast etc
  green = "#50d246",       -- jblow comments
  turquoise = "#3cdcb4",   -- jblow string
  riptide = "#82e6d7",     -- jblow numbers
  pastelgreen = "#82e687", -- jblow types
  punch = "#eb3741",       -- jblowextra panic red
  swamp = "#2d4132",       -- linenr
}

THEME_SATURATION = 1.00
-- list of colours to adjust and not adjust saturation of
local ignoreColours = { "none", "white", "tiber", "tiberdark" }
for name, color in pairs(c) do
  for _, ignoredColour in ipairs(ignoreColours) do
    if name == ignoredColour then
      goto continue
      break
    end
  end

  --print(" " .. name .. " " .. color .. " " .. adjustSaturation(color, THEME_SATURATION))
  c[name] = adjustSaturation(color, THEME_SATURATION)
  ::continue::
end

-- -- Defaults
local style_default = {
  blend = 0,
  bold = false,
  standout = false,
  underline = false,
  undercurl = false,
  underdouble = false,
  underdotted = false,
  underdashed = false,
  strikethrough = false,
  italic = false,
  reverse = false,
  nocombine = false,
}

local s = {
  default = style_default,
  comment = copy(style_default),
  char_const = copy(style_default),
  todo = copy(style_default),
  underlined = copy(style_default),
  bold = copy(style_default),
  italic = copy(style_default),
}

s.comment.italic = true
s.char_const.italic = true
s.todo.italic = true
s.bold.bold = true
s.italic.italic = true


-- Defined custom groups
-- Layout: bg, fg, under, italic, bold
local custom_groups = {
  -- -- Change plain text colour
  ["plaintext"] = { c.tan, c.none, s.default },                -- Global Background
  -- -- Default nvim groups
  ["normal"] = { c.none, c.tiber, s.default },                 -- Global Background
  ["normalfloat"] = { c.none, c.tiberdark, s.default },        -- Global Background
  ["comment"] = { c.green, c.tiber, s.comment },               -- any comment
  ["constant"] = { c.mystic, c.none, s.default },              -- any constant
  ["string"] = { c.turquoise, c.tiber, s.default },            -- a string constant: "this is a string"
  ["character"] = { c.turquoise, c.tiber, s.char_const },      -- a character constant: 'c', '\n'
  ["number"] = { c.riptide, c.none, s.default },               -- a number constant: 234, 0xff
  ["boolean"] = { c.riptide, c.none, s.default },              -- a boolean constant: TRUE, false
  ["float"] = { c.riptide, c.none, s.default },                -- a floating point constant: 2.3e10
  ["identifier"] = { c.tan, c.none, s.default },               -- any variable name
  ["function"] = { c.tan, c.none, s.default },                 -- function name (also: methods for classes)
  ["statement"] = { c.default, c.default_bg, s.default },      -- any statement
  ["conditional"] = { c.white, c.none, s.default },            -- if, then, else, endif, switch, etc.
  ["repeat"] = { c.white, c.none, s.default },                 -- for, do, while, etc.
  ["label"] = { c.punch, c.none, s.default },                  -- case, default, etc.
  ["operator"] = { c.mystic, c.none, s.default },              -- "sizeof", "+", "*", etc.
  ["keyword"] = { c.mystic, c.none, s.default },               -- any other keyword
  ["exception"] = { c.punch, c.none, s.default },              -- try, catch, throw
  ["preproc"] = { c.punch, c.none, s.default },                -- generic Preprocessor
  ["include"] = { c.mystic, c.none, s.default },               -- preprocessor #include
  ["define"] = { c.mystic, c.none, s.default },                -- preprocessor #define
  ["macro"] = { c.punch, c.none, s.default },                  -- same as Define
  ["precondit"] = { c.punch, c.none, s.default },              -- preprocessor #if, #else, #endif, etc.
  ["type"] = { c.pastelgreen, c.none, s.default },             -- int, long, char, etc.
  ["storageclass"] = { c.mystic, c.none, s.default },          -- static, register, volatile, etc.
  ["structure"] = { c.tan, c.none, s.default },                -- struct, union, enum, etc.
  ["typedef"] = { c.pastelgreen, c.none, s.default },          -- a typedef
  ["special"] = { c.punch, c.none, s.default },                -- any special symbol
  ["specialchar"] = { c.punch, c.none, s.default },            -- special character in a constant
  ["tag"] = { c.default, c.default_bg, s.default },            -- you can use CTRL-] on this
  ["delimiter"] = { c.tan, c.none, s.default },                -- character that needs attention
  ["specialcomment"] = { c.default, c.default_bg, s.default }, -- special things inside a comment
  ["debug"] = { c.default, c.default_bg, s.default },          -- debugging statements
  ["underlined"] = { c.none, c.none, s.underlined },           -- text that stands out, HTML links
  ["visual"] = { c.black, c.mystic, s.underlined },            -- Selected text
  ["incsearch"] = { c.mystic, c.black, s.underlined },         -- Selected text
  ["search"] = { c.mystic, c.black, s.underlined },            -- Selected text
  ["cursearch"] = { c.black, c.mystic, s.underlined },         -- Selected text
  -- ["ignore"] = { c.default, c.default_bg, s.default},  -- left blank, hidden  hl-Ignore
  ["error"] = { c.default, c.default_bg, s.default },          -- any erroneous construct
  ["todo"] = { c.white, c.punch, s.todo },                     -- anything, mostly the keywords TODO FIXME and XXX
  -- -- Cursor
  ["cursorline"] = { c.none, c.none, s.default },
  ["cursorlinenr"] = { c.mystic, c.none, s.default },
  ["linenr"] = { c.swamp, c.none, s.default },
  -- -- PMenu
  ["pmenu"] = { c.tan, c.tiberdark, s.default },
  ["pmenusel"] = { c.none, c.swamp, s.default },
  ["pmenusbar"] = { c.none, c.tiberdark, s.default },
  ["pmenuthumb"] = { c.none, c.swamp, s.default },
  -- -- LSP Groups
  -- -- TS Groups
  ["@type.builtin"] = { c.riptide, c.none, s.default },                       -- built in types
  ["@type.qualifier.rust"] = { c.mystic, c.none, s.default },                 -- rust mut
  -- -- Rust Groups
  ["@lsp.typemod.keyword.unsafe.rust"] = { c.punch, c.none, s.default },      -- rust unfase
  ["@lsp.typemod.typealias.declaration.rust"] = { c.tan, c.none, s.default }, -- type alias lvalue
  ["@lsp.typemod.enummember.defaultlibrary.rust"] = { c.mystic, c.none, s.default },
  ["@lsp.typemod.enum.defaultlibrary.rust"] = { c.mystic, c.none, s.default },

  -- TODO: unsafe
  -- -- Custom
  -- -- unsorted
  ["nontext"] = { c.none, c.none, s.default },
  ["signcolumn"] = { c.swamp, c.none, s.default },
  -- -- -- git gutter
  ["gitsignsadd"] = { "#76C683", c.none, s.default },
  ["gitsignschange"] = { "#CBC874", c.none, s.default },
  ["gitsignsdelete"] = { "#DC666A", c.none, s.default },
  -- -- -- diagnostic
  ["diagnosticsignwarn"] = { "#D79717", c.none, s.default },
  ["diagnosticsignerror"] = { "#DC666A", c.none, s.default },
  ["diagnosticsigninfo"] = { "#76C683", c.none, s.default },
  ["diagnosticsignhint"] = { "#76C683", c.none, s.default },
  -- -- -- Scope Lines
  ["iblWhitespace"] = { c.none, c.none, s.default },
  ["iblIndent"] = { c.swamp, c.none, s.default },
  -- -- Zig Groups
  ["@exception.zig"] = { c.punch, c.none, s.default },
  ["@attribute.zig"] = { c.mystic, c.none, s.default },
  ["@type.qualifier.zig"] = { c.mystic, c.none, s.default },
  ["@boolean.zig"] = { c.riptide, c.none, s.default },
  ["@lsp.type.struct.zig"] = { c.pastelgreen, c.none, s.default },
  ["@lsp.type.enum.zig"] = { c.pastelgreen, c.none, s.default },
  ["@lsp.type.namespace.zig"] = { c.mystic, c.none, s.default },
  ["@lsp.type.enumMember.zig"] = { c.tan, c.none, s.default },
  ["@operator.zig"] = { c.white, c.none, s.default },

  -- -- -- Telescope
  ["telescopeselection"] = { c.black, c.white, s.default },
  ["telescopematching"] = { c.white, c.black, s.default },
  ["telescopenormal"] = { c.tan, c.tiber, s.default },
  ["telescopepromptnormal"] = { c.tan, c.tiber, s.default },
  ["telescoperesultsnormal"] = { c.tan, c.tiber, s.default },
  ["telescopepreviewnormal"] = { c.tan, c.tiber, s.default },
  ["TelescopeResultsLineNr"] = { c.punch, c.none, s.default },
  ["TelescopeResultsSpecialComment"] = { c.punch, c.none, s.default },
  ["TelescopeResultsComment"] = { c.punch, c.none, s.default },
  -- -- Markdown
  ["@spell.markdown"] = { c.tan, c.none, s.default },
  ["@text.title.1.markdown"] = { c.green, c.none, s.bold },
  ["@text.title.2.markdown"] = { c.green, c.none, s.bold },
  ["@text.title.3.markdown"] = { c.green, c.none, s.bold },
  ["@text.title.4.markdown"] = { c.green, c.none, s.bold },
  ["@text.title.5.markdown"] = { c.green, c.none, s.bold },
  ["@text.title.6.markdown"] = { c.green, c.none, s.bold },
  ["@text.title.1.marker.markdown"] = { c.pastelgreen, c.none, s.default },
  ["@text.title.2.marker.markdown"] = { c.pastelgreen, c.none, s.default },
  ["@text.title.3.marker.markdown"] = { c.pastelgreen, c.none, s.default },
  ["@text.title.4.marker.markdown"] = { c.pastelgreen, c.none, s.default },
  ["@text.title.5.marker.markdown"] = { c.pastelgreen, c.none, s.default },
  ["@text.title.6.marker.markdown"] = { c.pastelgreen, c.none, s.default },
  ["@punctuation.special.markdown"] = { c.green, c.none, s.default },
  ["@punctuation.bracket.markdown_inline"] = { c.green, c.none, s.default },
  ["@punctuation.reference.markdown_inline"] = { c.tan, c.none, s.default },
  ["@punctuation.delimiter.markdown_inline"] = { c.green, c.none, s.default },
  ["@text.uri.markdown_inline"] = { c.pastelgreen, c.none, s.default },
  ["@text.strong.markdown_inline"] = { c.tan, c.none, s.bold },
  ["@text.reference.markdown_inline"] = { c.green, c.none, s.default },
  ["@text.quote.markdown"] = { c.tan, c.none, s.italic },
  ["@text.literal.block.markdown"] = { c.mystic, c.none, s.italic },
  ["@text.literal.markdown_inline"] = { c.mystic, c.none, s.italic },
  ["@text.emphasis.markdown_inline"] = { c.tan, c.none, s.italic },
  ["@text.todo.unchecked.markdown"] = { c.mystic, c.none, s.bold },
  ["@text.todo.checked.markdown"] = { c.pastelgreen, c.none, s.bold },
  ["@tag.delimiter.html"] = { c.mystic, c.none, s.default },
  ["@tag.attribute.html"] = { c.tan, c.none, s.default },
  ["@tag.html"] = { c.mystic, c.none, s.default },
  ["@text.html"] = { c.tan, c.none, s.default },
  -- -- -- Verse support
  ["@verse"] = { c.tan, c.none, s.default },
  ["@verse.block_comment"] = { c.green, c.none, s.comment },
  ["@verse.comment"] = { c.green, c.none, s.comment },
  ["@verse.hex"] = { c.riptide, c.none, s.default },
  ["@verse.number"] = { c.riptide, c.none, s.default },
  ["@verse.string"] = { c.turquoise, c.none, s.default },
  ["@verse.keywords.logic"] = { c.white, c.none, s.default },
  ["@verse.keywords.special"] = { c.mystic, c.none, s.default },
  ["@verse.keywords.reserved"] = { c.mystic, c.none, s.default },
  ["@verse.keywords.effects"] = { c.mystic, c.none, s.default },
  ["@verse.keywords.types"] = { c.riptide, c.none, s.default },
  ["@verse.keywords.attention"] = { c.punch, c.none, s.default },
  -- -- -- Odin support
  ["@type.odin"] = { c.tan, c.none, s.default },
  ["@odin.numtypes"] = { c.riptide, c.none, s.default },
  -- -- -- CPP
  --["@storageclass.cpp"] = { c.pastelgreen, c.none, s.default },
  ["@lsp.type.macro.cpp"] = { c.mystic, c.none, s.default },
  ["@lsp.type.enum.cpp"] = { c.pastelgreen, c.none, s.default },
  ["@lsp.type.property.cpp"] = { c.tan, c.none, s.default },
  ["@lsp.type.class.cpp"] = { c.pastelgreen, c.none, s.default },
  ["@lsp.type.namespace.cpp"] = { c.tanhalf, c.none, s.italic },
  ["@type.qualifier.cpp"] = { c.mystic, c.none, s.default },
  ["@include.cpp"] = { c.punch, c.none, s.default },
  ["@define.cpp"] = { c.punch, c.none, s.default },
  ["@keyword.return.cpp"] = { c.punch, c.none, s.default },
}

function Custom_Syntax()
  -- -- -- Default plain text group
  --vim.cmd([[syntax region plaintext start=/^/ end=/$/]])
end

function Load_Verse()
  -- -- -- Verse support groups
  vim.cmd([[syntax clear]])
  vim.cmd([[syntax match @verse /./]])
  vim.cmd([[syntax match @verse.keywords.special "[.<>:,!@%^&*+=|\-\\?~]"]])
  vim.cmd([[syntax match @verse.number.octal "0o[0-7]\+"]])
  vim.cmd([[syntax match @verse.number.binary "0b[01]\+"]])
  vim.cmd([[syntax match @verse.number.decimal "\<[0-9]\+\(\.[0-9]\+\)\?\>"]])
  vim.cmd([[syntax match @verse.number.scientific "e[+-]\=[0-9]\+"]])
  vim.cmd([[syntax match @verse.hex "0x[0-9A-Fa-f]\+"]])
  vim.cmd([[syntax match @verse.comment "\v([^<]|^)#([^>]|$).*"]])
  vim.cmd([[syntax region @verse.block_comment start=/<#/ end=/#>/]])
  vim.cmd([[syntax region @verse.string start=/"/ end=/"/]])
  vim.cmd([[syntax keyword @verse.keywords.logic if else then return for while loop block case do]])
  vim.cmd([[syntax keyword @verse.keywords.attention return break continue]])
  vim.cmd(
    [[syntax keyword @verse.keywords.reserved where interface class module enum using set map array tuple var external editable]])
  vim.cmd(
    [[syntax keyword @verse.keywords.types int string logic true vector3 transform false message listenable translation rotation vector2 struct color agent type t comparable char float void creative_prop Print]])
  vim.cmd(
    [[syntax keyword @verse.keywords.effects transacts suspends override abstract native concrete final public unique persistent private computes epic_internal decides localizes varies module_scoped_var_weak_map_key]])
end

function Load_Odin()
  -- -- -- Verse support groups
  vim.cmd(
    [[syntax keyword @odin.numtypes int i8 i16 i32 i64 i128 uint u8 u16 u32 u64 u128 uintptr f16 f32 f64 quaternion64 quaternion128 quaternion256 rune string cstring rawptr typeid any]])
end

-- Utility
local function apply_hl_groups()
  for hl_group_name, group in pairs(custom_groups) do
    local st = group[3]
    vim.api.nvim_set_hl(0, hl_group_name, {
      fg = group[1],
      bg = group[2],
      bold = st.bold,
      blend = st.blend,
      standout = st.standout,
      underline = st.underline,
      undercurl = st.undercurl,
      underdouble = st.underdouble,
      underdotted = st.underdotted,
      underdashed = st.underdashed,
      strikethrough = st.strikethrough,
      italic = st.italic,
      reverse = st.reverse,
      nocombine = st.nocombine,
    })
  end
end

vim.cmd.hi("clear")
vim.cmd('syntax reset')
apply_hl_groups()

vim.cmd [[
    augroup CustomFileTypeStreamTODO
        autocmd!
        autocmd BufRead,BufNewFile *.verse lua Load_Verse()
    augroup END
]]

vim.cmd [[
    augroup CustomFileTypeOdinGroups
        autocmd!
        autocmd BufRead,BufNewFile *.odin lua Load_Odin()
    augroup END
]]

vim.cmd [[
    augroup CustomSyntaxGroups
        autocmd!
        autocmd BufRead,BufNewFile * lua Custom_Syntax()
    augroup END
]]
