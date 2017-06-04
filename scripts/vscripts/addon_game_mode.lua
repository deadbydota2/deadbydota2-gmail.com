-- Generated from template

local MANIAC_TEAM = DOTA_TEAM_BADGUYS
local SURVIVORS_TEAM = DOTA_TEAM_GOODGUYS
local GENERATORS_TEAM = DOTA_TEAM_CUSTOM_1
local generator_building

scoreFirstTeam = 0
scoreSecondTeam = 0

if CAddonTemplateGameMode == nil then
	CAddonTemplateGameMode = class({})
end

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = CAddonTemplateGameMode()
	GameRules.AddonTemplate:InitGameMode()
end

function CAddonTemplateGameMode:InitGameMode()
	print( "Template addon is loaded." )
	-- GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	ListenToGameEvent('entity_killed', Dynamic_Wrap( CAddonTemplateGameMode, 'test' ) , self )
	ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(CAddonTemplateGameMode, 'OnPlayerPickHero'), self)
	ListenToGameEvent('entity_killed', Dynamic_Wrap( CAddonTemplateGameMode, 'onGewneratorKilled' ) , self )	
end

function CAddonTemplateGameMode:onGewneratorKilled(event)
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	print(killedUnit == generator_building)
	if killedUnit == generator_building then
		CAddonTemplateGameMode:generatePortal()
	end
end

function CAddonTemplateGameMode:generatePortal()
	local pos2 = Vector(1000, 128, 128)
	generator_building = CreateUnitByName("npc_dota_creature_gnoll_portal", pos2, true, nil, nil, GENERATORS_TEAM)
    generator_building:SetAbsOrigin(pos2)
	generator_building:RemoveModifierByName("modifier_invulnerable")
end

function CAddonTemplateGameMode:test(event)
	local killedUnit = EntIndexToHScript( event.entindex_killed )

	if killedUnit and killedUnit:IsRealHero() then
		if killedUnit:GetTeamNumber() == 3 then
			scoreFirstTeam = scoreFirstTeam + 1
			if scoreFirstTeam >= 1 then
				GameRules:MakeTeamLose(3)
				end
		end
		if killedUnit:GetTeamNumber() == 2 then
			scoreSecondTeam = scoreSecondTeam + 1
			if scoreSecondTeam >= 1 then
				GameRules:MakeTeamLose(2)
				end
		end
	end
end

function CAddonTemplateGameMode:OnPlayerPickHero(keys)
    CAddonTemplateGameMode:GenerateGenerator(128, 128, 128)
end

function CAddonTemplateGameMode:GenerateGenerator(x, y, z)
	local pos2 = Vector(x, y, z)
    -- Spawning
	generator_building = CreateUnitByName("npc_dota_creature_gnoll_generator", pos2, true, nil, nil, GENERATORS_TEAM)
    generator_building:SetAbsOrigin(pos2)
	generator_building:RemoveModifierByName("modifier_invulnerable")
end

-- Evaluate the state of the game
function CAddonTemplateGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end