/datum/action/bar/icon/abominationDevour
	duration = 50
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "abom_devour"
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "devour_over"
	bar_icon_state = "bar-changeling"
	border_icon_state = "border-changeling"
	color_active = "#d73715"
	color_success = "#3fb54f"
	color_failure = "#8d1422"
	var/mob/living/target
	var/datum/targetable/changeling/devour/devour

	New(Target, Devour)
		target = Target
		devour = Devour
		..()

	onUpdate()
		..()

		if(bounds_dist(owner, target) > 0 || target == null || owner == null || !devour)
			interrupt(INTERRUPT_ALWAYS)
			return

		var/mob/ownerMob = owner
		var/obj/item/grab/G = ownerMob.equipped()

		if (!istype(G) || G.affecting != target || G.state < 1)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(bounds_dist(owner, target) > 0 || target == null || owner == null || !devour)
			interrupt(INTERRUPT_ALWAYS)
			return

		var/mob/ownerMob = owner
		ownerMob.show_message("<span class='notice'>We must hold still for a moment...</span>", 1)

	onEnd()
		..()

		var/mob/ownerMob = owner
		if(owner && ownerMob && target && bounds_dist(owner, target) == 0 && devour)
			var/datum/abilityHolder/changeling/C = devour.holder
			if (istype(C))
				C.addDna(target)
			boutput(ownerMob, "<span class='notice'>We devour [target]!</span>")
			ownerMob.visible_message(text("<span class='alert'><B>[ownerMob] hungrily devours [target]!</B></span>"))
			playsound(ownerMob.loc, 'sound/voice/burp_alien.ogg', 50, 1)
			logTheThing("combat", ownerMob, target, "devours [constructTarget(target,"combat")] as a changeling in horror form [log_loc(owner)].")

			target.ghostize()
			qdel(target)

	onInterrupt()
		..()
		boutput(owner, "<span class='alert'>Our feasting on [target] has been interrupted!</span>")

/datum/targetable/changeling/devour
	name = "Devour"
	desc = "Almost instantly devour a human for DNA."
	icon_state = "devour"
	abomination_only = 1
	cooldown = 0
	targeted = 0
	target_anything = 0
	restricted_area_check = 2

	cast(atom/target)
		if (..())
			return 1
		var/mob/living/C = holder.owner

		var/obj/item/grab/G = src.grab_check(null, 1, 1)
		if (!G || !istype(G))
			return 1
		var/mob/living/carbon/human/T = G.affecting

		if (!istype(T))
			boutput(C, "<span class='alert'>This creature is not compatible with our biology.</span>")
			return 1
		if (isnpcmonkey(T))
			boutput(C, "<span class='alert'>Our hunger will not be satisfied by this lesser being.</span>")
			return 1
		if (T.bioHolder.HasEffect("husk"))
			boutput(usr, "<span class='alert'>This creature has already been drained...</span>")
			return 1

		actions.start(new/datum/action/bar/icon/abominationDevour(T, src), C)
		return 0

/datum/action/bar/private/icon/changelingAbsorb
	duration = 250
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "change_absorb"
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "devour_over"
	bar_icon_state = "bar-changeling"
	border_icon_state = "border-changeling"
	color_active = "#d73715"
	color_success = "#3fb54f"
	color_failure = "#8d1422"
	var/mob/living/target
	var/datum/targetable/changeling/absorb/devour
	var/last_complete = 0

	New(Target, Devour)
		target = Target
		devour = Devour
		..()

	onUpdate()
		..()

		if(bounds_dist(owner, target) > 0 || target == null || owner == null || !devour || !devour.cooldowncheck())
			interrupt(INTERRUPT_ALWAYS)
			return

		var/mob/ownerMob = owner
		var/obj/item/grab/G = ownerMob.equipped()

		if (!istype(G) || G.affecting != target || G.state != 3)
			interrupt(INTERRUPT_ALWAYS)
			return

		var/done = TIME - started
		var/complete = clamp((done / duration), 0, 1)
		if (complete >= 0.2 && last_complete < 0.2)
			boutput(ownerMob, "<span class='notice'>We extend a proboscis.</span>")
			ownerMob.visible_message(text("<span class='alert'><B>[ownerMob] extends a proboscis!</B></span>"))

		if (complete > 0.6 && last_complete <= 0.6)
			boutput(ownerMob, "<span class='notice'>We stab [target] with the proboscis.</span>")
			ownerMob.visible_message(text("<span class='alert'><B>[ownerMob] stabs [target] with the proboscis!</B></span>"))
			boutput(target, "<span class='alert'><B>You feel a sharp stabbing pain!</B></span>")
			random_brute_damage(target, 40)

		last_complete = complete

	onStart()
		..()
		if(bounds_dist(owner, target) > 0 || target == null || owner == null || !devour || !devour.cooldowncheck())
			interrupt(INTERRUPT_ALWAYS)
			return

		var/mob/ownerMob = owner

		if (isliving(target))
			target:was_harmed(owner, special = "ling")

		var/datum/abilityHolder/changeling/C = devour.holder
		if (istype(C))
			var/datum/bioHolder/originalBHolder = new/datum/bioHolder(target)
			originalBHolder.CopyOther(target.bioHolder)
			C.absorbed_dna[target.real_name] = originalBHolder
			ownerMob.show_message("<span class='notice'>We can now transform into [target.real_name], we must hold still...</span>", 1)

	onEnd()
		..()

		var/mob/ownerMob = owner
		if(owner && ownerMob && target && bounds_dist(owner, target) == 0 && devour)
			var/datum/abilityHolder/changeling/C = devour.holder
			if (istype(C))
				C.addDna(target)
			boutput(ownerMob, "<span class='notice'>We have absorbed [target]!</span>")
			ownerMob.visible_message(text("<span class='alert'><B>[ownerMob] sucks the fluids out of [target]!</B></span>"))
			logTheThing("combat", ownerMob, target, "absorbs [constructTarget(target,"combat")] as a changeling [log_loc(owner)].")

			target.dna_to_absorb = 0
			target.death(FALSE)
			target.real_name = "Unknown"
			target.bioHolder.AddEffect("husk")
			target.bioHolder.mobAppearance.flavor_text = "A desiccated husk."

	onInterrupt()
		..()
		boutput(owner, "<span class='alert'>Our absorbtion of [target] has been interrupted!</span>")

/datum/targetable/changeling/absorb
	name = "Absorb DNA"
	desc = "Suck the DNA out of a target."
	icon_state = "absorb"
	human_only = 1
	cooldown = 0
	targeted = 0
	target_anything = 0
	restricted_area_check = 2

	cast(atom/target)
		if (..())
			return 1
		var/mob/living/C = holder.owner

		var/obj/item/grab/G = src.grab_check(null, 3, 1)
		if (!G || !istype(G))
			return 1
		var/mob/living/carbon/human/T = G.affecting

		if (!istype(T))
			boutput(C, "<span class='alert'>This creature is not compatible with our biology.</span>")
			return 1
		if (isnpcmonkey(T))
			boutput(C, "<span class='alert'>Our hunger will not be satisfied by this lesser being.</span>")
			return 1
		if (T.bioHolder.HasEffect("husk"))
			boutput(usr, "<span class='alert'>This creature has already been drained...</span>")
			return 1

		actions.start(new/datum/action/bar/private/icon/changelingAbsorb(T, src), C)
		return 0
