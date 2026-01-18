-- https://github.com/praydog/REFramework/issues/457#issuecomment-1186114769
-- Thanks KrisCris <3 (https://github.com/KrisCris)

local re = re
local imgui = imgui

local FONT_NAME = "NotoSansJP-Regular.otf"
local FONT_SIZE = 18

local CHINESE_GLYPH_RANGES = {
    0x0020, 0x00FF, -- Basic Latin + Latin Supplement
    0x2000, 0x206F, -- General Punctuation
    0x3000, 0x30FF, -- CJK Symbols and Punctuations, Hiragana, Katakana
    0x31F0, 0x31FF, -- Katakana Phonetic Extensions
    0xFF00, 0xFFEF, -- Half-width characters
    0x4e00, 0x9FAF, -- CJK Ideograms
    0,
}

local font = imgui.load_font(FONT_NAME, FONT_SIZE, CHINESE_GLYPH_RANGES)

re.on_frame(function()
    imgui.push_font(font)
    imgui.pop_font()
end)
