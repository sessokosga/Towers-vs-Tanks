extends Node
const SECTION_ECONOMY = "Economy"
const SECTION_PLAYER = "Player"
const SECTION_LEVELS = "Levels"
const SECTION_UPGRADES = "Upgrades"
const SECTION_LEADERBOARD = "Leaderboard"
const SECTION_TOWERS = "Towers"
var config = ConfigFile.new()
var err = config.load("user://player.cfg")

func init():
	randomize()
	if err != OK:
		config.save("user://player.cfg")
		#save_balance(10)
		save_unlocked_towers(["tower249"])
		save_starting_towers(["tower249"])
		print("initialised player data")

# Economy
func save_balance(new_balance:int)->void:
	config.set_value(SECTION_ECONOMY,"balance",new_balance)
	config.save("user://player.cfg")

func retreive_balance()->int:
	return config.get_value(SECTION_ECONOMY,"balance",1)

# Leaderboard
func save_leaderboard(new_leaderboard):
	config.set_value(SECTION_LEADERBOARD,"users",new_leaderboard)
	config.save("user://player.cfg")

func retreive_leaderboard()->Array:
	return config.get_value(SECTION_LEADERBOARD,"users",[])

func save_xp(xp:int)->void:
	config.set_value(SECTION_LEADERBOARD,"xp",xp)
	config.save("user://player.cfg")

func retreive_xp()->int:
	return config.get_value(SECTION_LEADERBOARD,"xp",1)
	
# Levels
func save_unlocked_levels(level:int)->void:
	config.set_value(SECTION_LEVELS,"unlocked_level",level)
	config.save("user://player.cfg")

func retreive_unlocked_levels()->int:
	return config.get_value(SECTION_LEVELS,"unlocked_level",1)

# Player
func save_name(auth:String,default_name=false)->void:
	config.set_value(SECTION_PLAYER,"name",auth)
	if not default_name:
		config.set_value(SECTION_PLAYER,"has_set_a_name",true)
	config.save("user://player.cfg")

func retreive_name()->String:
	return config.get_value(SECTION_PLAYER,"name","unknowm123")

func has_set_a_name()->bool:
	return config.get_value(SECTION_PLAYER,"has_set_a_name",false)

# Upgrades
func save_upgrades(upgrade:Dictionary)->void:
	config.set_value(SECTION_UPGRADES,"upgrades",upgrade)
	config.save("user://player.cfg")
	
func retreive_upgrades()->Dictionary:
	return config.get_value(SECTION_UPGRADES,"upgrades",{})
	
# Towers
func save_starting_towers(list:Array)->void:
	config.set_value(SECTION_TOWERS,"starting_towers",list)
	config.save("user://player.cfg")

func retreive_starting_towers()->Array:
	return config.get_value(SECTION_TOWERS,"starting_towers",[])

func save_unlocked_towers(list:Array)->void:
	config.set_value(SECTION_TOWERS,"unlocked_towers",list)
	config.save("user://player.cfg")

func retreive_unlocked_towers()->Array:
	return config.get_value(SECTION_TOWERS,"unlocked_towers",[])
