class_name relation_manager extends Node
@export var playerName : String
@export var seaCultRep : int = 0
@export var decayMet : bool = false
@export var decayComplimented : bool = false
@export var decayRep : int = 0
@export var decayDeal : bool = false
@export var appleRep : int = 0
@export var knowsOfRitual : bool = false
@export var metPast : bool = false
@export var pastContract : bool = false
@export var metSurgeon : bool = false
@export var soldSoul : bool = false

func GetReputationType(s : String):
	match s:
		"Sea": 
			return GetSeaRep()
		"Apple": 
			return GetAppleRep()
		"Decay": 
			return GetDecayRep()
		"", _: 
			return -1
func GetPlayerName() : return playerName
func SetPlayerName(s : String) : playerName = s
func SetSeaRep(i : int) : seaCultRep = i
func GetSeaRep() : return seaCultRep
func SetDecayRep(i : int) : decayRep = i
func AdjustDecayRep(i : int) : decayRep += i
func GetDecayRep() : return decayRep
func SetAppleRep(i : int) : appleRep = i
func GetAppleRep() : return appleRep
