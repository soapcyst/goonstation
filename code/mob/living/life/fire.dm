
/datum/lifeprocess/fire
	process(var/datum/gas_mixture/environment)
		var/duration = owner.getStatusDuration("burning")
		if (duration)
			if (duration > 200)
				for (var/atom/A as anything in owner.contents)
					if (A.event_handler_flags & HANDLE_STICKER)
						if (A:active)
							owner.visible_message("<span class='alert'><b>[A]</b> is burnt to a crisp and destroyed!</span>")
							qdel(A)

			if (isturf(owner.loc))
				var/turf/location = owner.loc
				location.hotspot_expose(T0C + 300, 400)

			for (var/atom/A in owner.contents)
				A.material_trigger_on_temp(T0C + 900)

			for (var/atom/equipped_stuff in owner.equipped())
				equipped_stuff.material_trigger_on_temp(T0C + 900)
