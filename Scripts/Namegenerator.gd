extends Node

const NAMES = ["Knut", "Björn", "Olaf", "Ragnar", "Sven", "Hakon", "Leif", "Gunnar", "Torben",
"Einar", "Sigurd", "Magnus", "Thore", "Asgrim", "Vidar", "Haldor", "Bjarne", "Snorri", "Ulf",
"Njord", "Stig", "Harald", "Erik", "Jari", "Thorvald", "Hemming", "Viggo", "Arvid", "Dag", "Halvar",
"Rolf", "Tjark", "Sampo", "Eike", "Odd", "Sune", "Roald", "Xaver", "Hemming", "Bo", "Njal", "Odin",
"Trygve", "Gisli", "Runar", "Torgeir", "Haukur", "Ketil", "Steinar", "Alvar", "Frode", "Gorm",
"Jostein", "Torstein", "Yrjö", "Hemming", "Mats", "Per", "Tor", "Asmund", "Isak", "Frej", "Johan",
"Lars", "Nils", "Tomas", "Valter", "Wilhelm", "Ake", "Hannes", "Elof", "Vilhelm", "Eskild", "Gustav",
"Ingmar", "Rune", "Sigvard", "Torbjörn", "Viktor", "Alf", "Bengt", "Diederik", "Eerik", "Göran",
"Henrik", "Ivar", "Joakim", "Klas", "Ludvig", "Mikkel", "Nikolaj", "Orvar", "Pelle", "Quirin",
"Ragnarök", "Sverker", "Ture", "Uffe", "Vladimir", "Waldemar", "Eskil", "Yngve", "Zebulon"
]
const LAST_NAMES = ["Nordsturm", "Frostklinge", "Eisgrim", "Schneebart", "Kälteklaue", "Winterzorn",
"Gletscherfaust", "Frostbeißer", "Nordfrost", "Eisenschlag", "Blizzard", "Sturmschatten", "Nordbrand",
"Eisensang", "Frostwind", "Schneehammer", "Kristallklaue", "Eiszorn", "Sturmwächter", "Klingenfrost",
 "Winterkralle", "Schneesturm", "Frostschatten", "Dunkelsturm", "Eishauch", "Kältewolf", "Nordmann",
"Eisnebel", "Kältenacht", "Zackensturm", "Sturmhart", "Frostbart", "Winterherz", "Schneefall",
"Eisbrand", "Klingensturm", "Frostbiss", "Eisdorn", "Eiskristall", "Nordhammer", "Schwarzfrost",
"Blutsturm", "Frostfeder", "Winterklaue", "Gluthauch", "Sturmspalter", "Tundraklinge", "Eiszapfen",
"Klingenherz", "Frostspeer", "Gletschersturm", "Kristallschatten", "Schneeklinge", "Wintergrimm",
"Nordstärke", "Schneebann", "Dunkelfrost", "Eisenschatten", "Eisfeuer", "Kältestern", "Winterwacht",
"Frostherz", "Gletschersang", "Nordglut", "Schneebrand", "Eisklaue", "Sturmfels", "Frostsporn",
"Tundrawind", "Winterfeder", "Eisschatten", "Nordzorn", "Blizzardherz", "Schneehauer", "Eisnebel",
"Winterbann", "Sturmherz", "Kältenschmied", "Nordfeder", "Eisfalke", "Schwarzschnee", "Dunkelklang",
"Frostklang", "Sturmjäger", "Schneefänger", "Winterreiter", "Eisspeer", "Kristallfrost", "Nordwolf",
"Eisklinge", "Tundrawächter", "Kältebringer", "Gletschertod", "Schneewind", "Eiskristall",
"Blizzardstimme", "Nordblick", "Eisschlag", "Winterhauer"
]

func generate_full_name_seed(seed: int) -> String:
	seed(seed)
	return NAMES[randi_range(0, 95)] + " " + LAST_NAMES[randi_range(0, 95)]

func generate_full_name() -> String:
	return NAMES[randi_range(0, 95)] + " " + LAST_NAMES[randi_range(0, 95)]
