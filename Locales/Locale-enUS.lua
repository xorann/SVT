local L = AceLibrary("AceLocale-2.2"):new("SVT")

L:RegisterTranslations("enUS", 
	function()
		return {
			["Enable"] = true,
			["Enable timers."] = true,
			["Target only"] = true,
			["Show timer only for the current target."] = true,

			shadowvuln_test = "^(.+) is afflicted by Shadow Vulnerability.",
			swpResist_test	= "^Your Shadow Word: Pain was resisted by (.+).",
			mindblast_test = "^Your Mind Blast hits (.+) for",
			mindblastCrit_test = "^Your Mind Blast crits (.+) for",
			vulneResist_test = "^Your Shadow Vulnerability was resisted by (.+).",
			mindflay_test = "^Your Mind Flay was resisted by (.+).",
			
			-- Bar
			["Bar"] = true, -- module name
			["bar"] = true, -- console command
			
			 -- console options
			["Options for the bar plugin."] = true,
			["Show anchor"] = true,
			["Show the bar anchor frame."] = true,
			["Reset position"] = true,
			["Reset the anchor position, moving it to the original position."] = true,
			["Scale"] = true,
			["Set the frame scale."] = true,
			["Texture"] = true,
			["Set the texture for the timerbars."] = true,
					
			["Test"] = true,
			["Close"] = true,
			
			-- mind flay
			["Mind Flay"] = true,
			["Start Channeling Mind Flay if you are not already channeling."] = true,
			
			-- FuBar
			["|cffeda55fRight click|r to show the options menu."] = true,
		}
	end
)
