-- Rime用户目录/lua/jp_kana_translator.lua
local c_k = require("convert_kana")
local kanji_map = require("jp_kanji_map")

local function translate(input, seg, env)
    -- 只在带有特定 tag 时触发（我们在 yaml 中定义前缀 ja 触发此 tag）
    if not seg:has_tag("jp_kana") then return end

    -- 去掉前缀 "ja"，提取后面的罗马音部分
    local romaji = string.sub(input, 3)
    if romaji == "" then return end

    -- 调用 Onion 的核心函数进行转换
    local hw = c_k.halfwidth_kata_t(romaji)
    
    -- 判断是否完全转换成功（如果含有英文小写字母说明拼写在日文中不存在）
    if not string.match(hw, "%l") then
        yield(Candidate("jp_hira", seg.start, seg._end, c_k.hira_t(hw), "〔平假名〕"))
        yield(Candidate("jp_kata", seg.start, seg._end, c_k.kata_t(hw), "〔片假名〕"))
        yield(Candidate("jp_hw", seg.start, seg._end, hw, "〔半角片假〕"))

        local kanji_candidates = kanji_map[romaji]
        if kanji_candidates then
            for _, text in ipairs(kanji_candidates) do
                yield(Candidate("jp_kanji", seg.start, seg._end, text, "〔日文汉字〕"))
            end
        end
    else
        yield(Candidate("jp_error", seg.start, seg._end, romaji, "〔无此假名〕"))
    end
end

return translate
