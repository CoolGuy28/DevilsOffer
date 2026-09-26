class_name Interactable_Grave extends Interactable_Loot

func BreakGrave(p : Player, a : int):
	p.GetRelations().AdjustDecayRep(-a)
	if p.GetRelations().decayDeal == true:
		await p.EndDialogue()
		await get_tree().create_timer(2.0).timeout
		DialogueManager.show_dialogue_balloon(Global.GetGlobalDialogue(), "BrokenDeal", [self, { "player" = p }])
