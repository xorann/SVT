local L = AceLibrary("AceLocale-2.2"):new("SVT")

L:RegisterTranslations("deDE", 
	function()
		return {
			["Enable"] = "Aktivieren",
			["Enable timers."] = "Timer aktivieren",
			["Target only"] = "Nur Ziel",
			["Show timer only for the current target."] = "Zeige Timer nur für das aktuelle Ziel",

			shadowvuln_test = "^(.+) ist von Schattenverwundbarkeit betroffen.", --"^(.+) is afflicted by Shadow Vulnerability.",
			swpResist_test	= "^Euer Schattenwort: Schmerz wurde von (.+) widerstanden.", --"^Your Shadow Word: Pain was resisted by (.+).",
			mindblast_test = "^Euer Gedankenschlag trifft (.+) für", --"^Your Mind Blast (%a%a?)\its (.+) for",
			mindblastCrit_test = "^Euer Gedankenschlag trifft (.+) kritisch für", --"^Your Mind Blast (%a%a?)\its (.+) for",
			vulneResist_test = "^Eure Schattenverwundbarkeit wurde von (.+) widerstanden.", --"^Your Shadow Vulnerability was resisted by (.+).",
			mindflay_test = "Euer Gedankenschinden wurde von (.+) widerstanden.", --"^Your Mind Flay was resisted by (.+).",
			
			-- Bar
			["Bar"] = "Balken", -- module name
			["bar"] = "balken", -- console command
			
			 -- console options
			["Options for the bar plugin."] = "Optionen für die Timer Anzeigebalken.",
			["Show anchor"] = "Timer verschieben",
			["Show the bar anchor frame."] = "Fenster anzeigen um den Timer zu verschieben.",
			["Reset position"] = "Timerposition zurücksetzen",
			["Reset the anchor position, moving it to the original position."] = "Setzt die Position des Timers auf die Ausgangsposition zurück.",
			["Scale"] = "Skalierung",
			["Set the frame scale."] = "Timer Skalierung.",
			["Texture"] = "Textur",
			["Set the texture for the timerbars."] = "Textur des Timers definieren.",
					
			["Test"] = "Test",
			["Close"] = "Schliessen",
		}
	end
)