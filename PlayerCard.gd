class_name PlayerCard
extends Resource


@export var id: String = ""
@export var player_name: String = ""
@export var long_name: String = ""

@export var rating: int = 75
@export var potential: int = 0

@export var position: String = "FWD"
@export var positions: String = ""

@export var club: String = ""
@export var club_position: String = ""

@export var league_name: String = ""
@export var league_level: float = 0.0

@export var nation: String = ""
@export var rarity: String = "BRONZE"

@export var photo: Texture2D

@export var age: int = 0
@export var date_of_birth: String = ""
@export var height_cm: int = 0
@export var weight_kg: int = 0

@export var contract_until: String = ""

@export var market_value_eur: int = 0
@export var value_eur: int = 0
@export var wage_eur: int = 0

@export var preferred_foot: String = "RIGHT"
@export var weak_foot: int = 0
@export var skill_moves: int = 0
@export var international_reputation: int = 0

@export var work_rate: String = ""
@export var body_type: String = ""

@export var pace: int = 0
@export var shooting: int = 0
@export var passing: int = 0
@export var dribbling: int = 0
@export var defending: int = 0
@export var physical: int = 0

@export var transfermarkt_match_score: float = 0.0
@export var transfermarkt_position: String = ""
@export var transfermarkt_foot: String = ""
@export var transfermarkt_league: String = ""

@export var sofascore_rating: float = 0.0
@export var sofascore_appearances: int = 0
@export var sofascore_minutes: int = 0
@export var sofascore_league: String = ""


static func from_dictionary(data: Dictionary) -> PlayerCard:
	var card: PlayerCard = PlayerCard.new()

	card.id = str(
		data.get(
			"id",
			data.get("player_id", "")
		)
	)

	card.player_name = str(
		data.get(
			"name",
			data.get(
				"player_name",
				data.get(
					"short_name",
					"Игрок"
				)
			)
		)
	)

	card.long_name = str(
		data.get(
			"long_name",
			card.player_name
		)
	)

	card.rating = int(
		data.get(
			"rating",
			data.get(
				"overall",
				75
			)
		)
	)

	card.potential = int(
		data.get(
			"potential",
			0
		)
	)

	card.positions = str(
		data.get(
			"positions",
			data.get(
				"player_positions",
				data.get(
					"pos",
					data.get(
						"position",
						"FWD"
					)
				)
			)
		)
	)

	card.position = _convert_position(
		card.positions
	)

	card.club = str(
		data.get(
			"club",
			data.get(
				"club_name",
				""
			)
		)
	)

	card.club_position = str(
		data.get(
			"club_position",
			""
		)
	)

	card.league_name = str(
		data.get(
			"league",
			data.get(
				"league_name",
				""
			)
		)
	)

	card.league_level = float(
		data.get(
			"league_level",
			0.0
		)
	)

	card.nation = str(
		data.get(
			"nation",
			data.get(
				"nationality_name",
				""
			)
		)
	)

	card.rarity = str(
		data.get(
			"rarity",
			"BRONZE"
		)
	).to_upper()

	card.age = int(
		data.get(
			"age",
			0
		)
	)

	card.date_of_birth = str(
		data.get(
			"dob",
			data.get(
				"date_of_birth",
				""
			)
		)
	)

	card.height_cm = int(
		data.get(
			"height_cm",
			0
		)
	)

	card.weight_kg = int(
		data.get(
			"weight_kg",
			0
		)
	)

	card.contract_until = str(
		data.get(
			"contract_until",
			""
		)
	)

	card.market_value_eur = int(
		data.get(
			"market_value_eur",
			0
		)
	)

	card.value_eur = int(
		data.get(
			"value_eur",
			0
		)
	)

	card.wage_eur = int(
		data.get(
			"wage_eur",
			0
		)
	)

	card.preferred_foot = str(
		data.get(
			"preferred_foot",
			"RIGHT"
		)
	)

	card.weak_foot = int(
		data.get(
			"weak_foot",
			0
		)
	)

	card.skill_moves = int(
		data.get(
			"skill_moves",
			0
		)
	)

	card.international_reputation = int(
		data.get(
			"international_reputation",
			0
		)
	)

	card.work_rate = str(
		data.get(
			"work_rate",
			""
		)
	)

	card.body_type = str(
		data.get(
			"body_type",
			""
		)
	)

	card.pace = int(
		data.get(
			"pace",
			0
		)
	)

	card.shooting = int(
		data.get(
			"shooting",
			0
		)
	)

	card.passing = int(
		data.get(
			"passing",
			0
		)
	)

	card.dribbling = int(
		data.get(
			"dribbling",
			0
		)
	)

	card.defending = int(
		data.get(
			"defending",
			0
		)
	)

	card.physical = int(
		data.get(
			"physical",
			data.get(
				"physic",
				0
			)
		)
	)

	card.transfermarkt_match_score = float(
		data.get(
			"tm_match_score",
			0.0
		)
	)

	card.transfermarkt_position = str(
		data.get(
			"position_tm",
			""
		)
	)

	card.transfermarkt_foot = str(
		data.get(
			"foot_tm",
			""
		)
	)

	card.transfermarkt_league = str(
		data.get(
			"tm_league",
			""
		)
	)

	card.sofascore_rating = float(
		data.get(
			"sofascore_rating",
			0.0
		)
	)

	card.sofascore_appearances = int(
		data.get(
			"sofascore_appearances",
			0
		)
	)

	card.sofascore_minutes = int(
		data.get(
			"sofascore_minutes",
			0
		)
	)

	card.sofascore_league = str(
		data.get(
			"ss_league",
			""
		)
	)

	return card


static func _convert_position(value: String) -> String:
	var pos: String = value.to_upper()

	if "GK" in pos:
		return "GK"

	if (
		"ST" in pos
		or "CF" in pos
		or "LW" in pos
		or "RW" in pos
		or "FWD" in pos
	):
		return "FWD"

	if (
		"CAM" in pos
		or "CM" in pos
		or "CDM" in pos
		or "LM" in pos
		or "RM" in pos
		or "MID" in pos
	):
		return "MID"

	if (
		"CB" in pos
		or "LB" in pos
		or "RB" in pos
		or "LWB" in pos
		or "RWB" in pos
		or "DEF" in pos
	):
		return "DEF"

	return "MID"


func has_position(target_position: String) -> bool:
	var target: String = target_position.to_upper().strip_edges()

	if position.to_upper() == target:
		return true

	var all_positions: String = positions.to_upper().replace(",", " ")

	var position_list: PackedStringArray = all_positions.split(
		" ",
		false
	)

	for item: String in position_list:
		if item.strip_edges() == target:
			return true

	return false


func duplicate_card() -> PlayerCard:
	var copy: PlayerCard = PlayerCard.new()

	copy.id = id
	copy.player_name = player_name
	copy.long_name = long_name

	copy.rating = rating
	copy.potential = potential

	copy.position = position
	copy.positions = positions

	copy.club = club
	copy.club_position = club_position

	copy.league_name = league_name
	copy.league_level = league_level

	copy.nation = nation
	copy.rarity = rarity
	copy.photo = photo

	copy.age = age
	copy.date_of_birth = date_of_birth
	copy.height_cm = height_cm
	copy.weight_kg = weight_kg

	copy.contract_until = contract_until

	copy.market_value_eur = market_value_eur
	copy.value_eur = value_eur
	copy.wage_eur = wage_eur

	copy.preferred_foot = preferred_foot
	copy.weak_foot = weak_foot
	copy.skill_moves = skill_moves
	copy.international_reputation = international_reputation

	copy.work_rate = work_rate
	copy.body_type = body_type

	copy.pace = pace
	copy.shooting = shooting
	copy.passing = passing
	copy.dribbling = dribbling
	copy.defending = defending
	copy.physical = physical

	copy.transfermarkt_match_score = transfermarkt_match_score
	copy.transfermarkt_position = transfermarkt_position
	copy.transfermarkt_foot = transfermarkt_foot
	copy.transfermarkt_league = transfermarkt_league

	copy.sofascore_rating = sofascore_rating
	copy.sofascore_appearances = sofascore_appearances
	copy.sofascore_minutes = sofascore_minutes
	copy.sofascore_league = sofascore_league

	return copy
