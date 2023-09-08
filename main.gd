extends HBoxContainer

var players := []
var deck := []

var effect_stack := []

var phase = GamePhase.UNTAP
enum GamePhase {
	UNTAP,
	DRAW,
	DRAFT,
	MANA_TI,
	MANA_NTI,
	ATTACK_TI,
	BLOCK_TI,
	DAMAGE_TI,
	POST_COMBAT_TI,
	ATTACK_NTI,
	BLOCK_NTI,
	DAMAGE_NTI,
	POST_COMBAT_NTI,
	REGROUP,
	MAIN_TI,
	MAIN_NTI
	}

const NUM_PLAYERS := 2
var first_turn = true

const STARTING_DRAFT_PACK_SIZE = 16

onready var game_log = $GameLog

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	init()
	
# Do init stuff in this function for easier modding
func init():
	players = []
	
	# init players
	for _n in NUM_PLAYERS:
		players.push_back(Player.new(self))
	
	# init deck, this will probably be a resource file
	for n in 50:
		var card = Card.new()
		card.card_name = str(n)
		deck.push_back(card)
		
	deck.shuffle()
		
	for player in players:
		for _n in STARTING_DRAFT_PACK_SIZE:
			var top_card = deck.pop_front()
#			log_message(str("adding ", top_card.card_name))
			player.draft_pack.push_back(top_card)
	
	first_turn = true
	
	do_untap_phase()
	
func do_untap_phase():
	log_message("starting untap phase")
	
	phase = GamePhase.UNTAP
	for player in players:
		for battlefield_players in player.battlefields:
			for permanent in player.battlefields[battlefield_players]:
				permanent.tapped = false
				
	do_draw_phase()
	
func do_draw_phase():
	log_message("starting draw phase")
	
	phase = GamePhase.DRAW
	
	if not first_turn:
		for player in players:
			player.draw(2)
	else:
		log_message("skipping draw phase in the first turn")
		
	do_draft_phase()
	
func do_draft_phase():
	log_message("starting draft phase")
	
	phase = GamePhase.DRAFT
	
	for player in players:
		player.draft()
		
#	do_mana_ti_phase()

func do_mana_ti_phase():
	phase = GamePhase.MANA_TI
	
	players[0].do_mana_phase()
	
	do_mana_nti_phase()

func do_mana_nti_phase():
	phase = GamePhase.MANA_NTI
	
	players[1].do_mana_phase()
	
	do_attack_ti_phase()

func do_attack_ti_phase():
	phase = GamePhase.ATTACK_TI
	
	players[0].declare_ti_attackers()
	interaction_phase()
	
	do_block_ti_phase()

func do_block_ti_phase():
	phase = GamePhase.BLOCK_TI
	
	players[1].declare_ti_blockers()
	interaction_phase()
	
	do_damage_ti_phase()

func do_damage_ti_phase():
	phase = GamePhase.DAMAGE_TI
	
	# Damage calculations go here
	
	do_post_combat_ti()

func do_post_combat_ti():
	phase = GamePhase.POST_COMBAT_TI
	
	# Triggers should go here
	interaction_phase()
	
func do_attack_nti_phase():
	pass

func do_block_nti_phase():
	pass
	
func do_damage_nti_phase():
	pass

func do_post_combat_nti_phase():
	pass
	
func do_regroup():
	pass
	
func do_main_ti():
	pass
	
func do_main_nti():
	pass

func interaction_phase():
	var all_passed = false
	while (not effect_stack.empty()) or (not all_passed):
		if all_passed:
			var effect = effect_stack.pop_back()
			effect.execute()
		
		all_passed = true 
		for player in players:
			if player.take_action_or_pass():
				all_passed = false
				break

func log_message(message):
	var to_add = Label.new()
	to_add.text = message
	
	game_log.add_child(to_add)
