-- Yipper - Players
--
-- Maps a plain character name onto a GUID.
--
-- Roll results reach us as a system message carrying only a character name: no
-- realm, no GUID. Everything else in Yipper is keyed by GUID, so a roll can only
-- be attributed to a tracked player once that name has been resolved.
--
-- Three sources feed the lookup, in order of trustworthiness:
--
--   1. The group or raid roster. Authoritative, and the only source that knows
--      the realm of a cross-realm member.
--   2. The guild roster. Covers a guildmate who rolls while we share no group
--      with them - the usual shape of an RP event - whether or not they have
--      said anything.
--   3. Players seen in chat, or looked at. Every message Yipper stores carries
--      a GUID that resolves back to a name, as does whoever we hover or target,
--      so anyone recently in front of us is known even outside guild and group.
--
-- Character names are only unique within a realm. When a name maps onto more
-- than one GUID we return nothing rather than guess: a roll shown under the
-- wrong character is worse than a roll that is not shown.

local _, Yipper = ...

Yipper.Players = {
    -- [name] = { [guid] = epoch last seen }
    --
    -- Cross-realm characters are filed under both "Name" and "Name-Realm",
    -- because a roll can reach us spelled either way.
    seen = { }
}

-- Returns true when the unit is the character the name refers to.
--
-- A roll gives a bare name for a character on our own realm and the
-- "Name-Realm" form for a cross-realm one, so accept both spellings.
local function unitMatchesName(unit, name)
    local unitName, unitRealm = UnitFullName(unit)

    if unitName == nil then
        return false
    end

    if unitName == name then
        return true
    end

    return unitRealm ~= nil and unitRealm ~= "" and (unitName .. "-" .. unitRealm) == name
end

-- Files a single name -> GUID pair, refreshing the timestamp when it is already
-- known so that pruning keeps active speakers around.
local function record(store, name, guid)
    if name == nil or name == "" then
        return
    end

    local entries = store[name]

    if entries == nil then
        entries = { }
        store[name] = entries
    end

    entries[guid] = time()
end

-- Yipper.Players - Remember
--
-- Records the name behind a GUID Yipper has just seen in chat.
-- Safe to call with anything: non-players, secret values and GUIDs the client
-- cannot make sense of are ignored.
function Yipper.Players:Remember(guid)
    if guid == nil or Yipper.Utils:IsSecret(guid) then
        return
    end

    -- Only player GUIDs carry a character name worth caching.
    if type(guid) ~= "string" or not guid:match("^Player%-") then
        return
    end

    -- GetPlayerInfoByGUID errors on a GUID it cannot parse, and roll broadcasts
    -- hand us data that came off the wire.
    local ok, _, _, _, _, _, name, realm = pcall(GetPlayerInfoByGUID, guid)

    if not ok or name == nil or name == "" then
        return
    end

    record(self.seen, name, guid)

    if realm ~= nil and realm ~= "" then
        record(self.seen, name .. "-" .. realm, guid)
    end
end

-- Yipper.Players - ResolveFromRoster
--
-- Finds the GUID of a group or raid member by name.
-- Returns nil when nobody in the group carries the name, or when two members
-- share it and we cannot tell which of them acted.
function Yipper.Players:ResolveFromRoster(name)
    if not IsInGroup() then
        return nil
    end

    local inRaid = IsInRaid()
    local members = GetNumGroupMembers()
    local found

    -- raid1..raidN includes us, party1..partyN does not.
    local count = inRaid and members or math.max(members - 1, 0)

    if not inRaid and unitMatchesName("player", name) then
        found = UnitGUID("player")
    end

    for i = 1, count do
        local unit = inRaid and ("raid" .. i) or ("party" .. i)

        if unitMatchesName(unit, name) then
            local guid = UnitGUID(unit)

            if found ~= nil and found ~= guid then
                return nil
            end

            found = guid
        end
    end

    return found
end

-- Yipper.Players - ResolveFromGuild
--
-- Finds the GUID of a guild member by name, which needs neither a shared group
-- nor for them to have spoken.
--
-- Returns nil when nobody in the guild carries the name, or when two members
-- somehow do.
function Yipper.Players:ResolveFromGuild(name)
    if not IsInGuild() then
        return nil
    end

    local members = GetNumGuildMembers()

    -- The roster is empty until the client has been handed it. Ask for it so a
    -- later lookup can succeed; the game throttles the request for us.
    if members == 0 then
        if C_GuildInfo ~= nil and C_GuildInfo.GuildRoster ~= nil then
            pcall(C_GuildInfo.GuildRoster)
        end

        return nil
    end

    local found

    for i = 1, members do
        -- Same-realm members come back under a bare name and connected-realm
        -- ones as "Name-Realm", which is exactly how a roll spells them too.
        local memberName, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, guid = GetGuildRosterInfo(i)

        -- Guard the GUID rather than trusting its position in that list: a
        -- patch that adds a return value would otherwise feed us nonsense.
        if memberName == name and type(guid) == "string" and guid:match("^Player%-") then
            if found ~= nil and found ~= guid then
                return nil
            end

            found = guid
        end
    end

    return found
end

-- Yipper.Players - ResolveFromCache
--
-- Finds the GUID of anyone who has spoken within the cache window.
-- Stale entries are pruned on the way through, which also lets a name that once
-- collided become usable again once the other character has aged out.
function Yipper.Players:ResolveFromCache(name)
    local entries = self.seen[name]

    if entries == nil then
        return nil
    end

    local now = time()
    local remaining = 0
    local found

    for guid, lastSeen in pairs(entries) do
        if (now - lastSeen) > Yipper.Constants.PlayerCacheAgeInSeconds then
            entries[guid] = nil
        else
            remaining = remaining + 1
            found = guid
        end
    end

    if remaining == 0 then
        self.seen[name] = nil
        return nil
    end

    -- Two characters share this name. Nothing in the roll message says which of
    -- them rolled, so decline instead of attributing it to the wrong one.
    if remaining > 1 then
        return nil
    end

    return found
end

-- Yipper.Players - Resolve
--
-- Resolves a character name onto a GUID, preferring the roster over the cache.
function Yipper.Players:Resolve(name)
    if name == nil or name == "" then
        return nil
    end

    -- We always know ourselves, group or not. A cross-realm character who
    -- shares our name arrives spelled "Name-Realm" and will not match here,
    -- so this cannot steal someone else's roll.
    if unitMatchesName("player", name) then
        return UnitGUID("player")
    end

    local guid = self:ResolveFromRoster(name)

    if guid ~= nil then
        return guid
    end

    guid = self:ResolveFromGuild(name)

    if guid ~= nil then
        return guid
    end

    return self:ResolveFromCache(name)
end
