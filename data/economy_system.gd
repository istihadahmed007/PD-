# ==============================================================================
# ECONOMY SYSTEM (BDT ৳) & COMMERCE CATALOG
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Manages currency formatting, player wallet, bank transactions, pricing,
#          fictional brands, vehicle garage services, clothing, and safehouses.
# ==============================================================================
class_name EconomySystem
extends RefCounted

const CURRENCY_SYMBOL := "৳"

# Item Categories
enum ItemCategory {
	FOOD_DRINK,
	UTILITY,
	EQUIPMENT,
	CLOTHING,
	VALUABLE
}

# Standard Items Catalog
const ITEMS := {
	"cha": {
		"id": "cha",
		"name": "Spiced Milk Tea (Cha)",
		"bangla_name": "দুধ চা",
		"category": ItemCategory.FOOD_DRINK,
		"price": 10,
		"effect_type": "stamina",
		"effect_val": 40.0,
		"desc": "Freshly brewed hot ginger and cardamom tea from Mama's Tong. Fully restores stamina.",
		"max_stack": 10
	},
	"singara": {
		"id": "singara",
		"name": "Hot Spiced Singara",
		"bangla_name": "গরম সিঙ্গারা",
		"category": ItemCategory.FOOD_DRINK,
		"price": 15,
		"effect_type": "health",
		"effect_val": 25.0,
		"desc": "Crispy fried pastry stuffed with spiced potato and peanut masala. Heals 25 HP.",
		"max_stack": 10
	},
	"samucha": {
		"id": "samucha",
		"name": "Crispy Samucha",
		"bangla_name": "মুচমুচে সমুচা",
		"category": ItemCategory.FOOD_DRINK,
		"price": 15,
		"effect_type": "health",
		"effect_val": 25.0,
		"desc": "Golden fried onion and minced chicken wrap. Heals 25 HP.",
		"max_stack": 10
	},
	"speed_drink": {
		"id": "speed_drink",
		"name": "Speed Carbonated Energy Drink",
		"bangla_name": "স্পিড এনার্জি ড্রিংক",
		"category": ItemCategory.FOOD_DRINK,
		"price": 35,
		"effect_type": "stamina_boost",
		"effect_val": 80.0,
		"desc": "Popular street energy drink. Instantly boosts stamina and doubles sprint duration for 30s.",
		"max_stack": 5
	},
	"kacchi_biryani": {
		"id": "kacchi_biryani",
		"name": "Old Dhaka Kacchi Biryani",
		"bangla_name": "পুরান ঢাকার কাচ্চি বিরিয়ানি",
		"category": ItemCategory.FOOD_DRINK,
		"price": 180,
		"effect_type": "full_restore",
		"effect_val": 100.0,
		"desc": "Fragrant basmati rice cooked with tender mutton and spiced potatoes. Restores 100% Health & Stamina.",
		"max_stack": 3
	},
	"medkit": {
		"id": "medkit",
		"name": "First Aid Medical Kit",
		"bangla_name": "প্রাথমিক চিকিৎসা কিট",
		"category": ItemCategory.UTILITY,
		"price": 450,
		"effect_type": "health",
		"effect_val": 75.0,
		"desc": "Sterile bandages, antiseptic lotion, and painkillers from Janata Medical Store. Restores 75 HP.",
		"max_stack": 5
	},
	"repair_kit": {
		"id": "repair_kit",
		"name": "Portable Vehicle Tool Kit",
		"bangla_name": "গাড়ির টুলবক্স",
		"category": ItemCategory.UTILITY,
		"price": 650,
		"effect_type": "repair_vehicle",
		"effect_val": 60.0,
		"desc": "Adjustable wrench, socket set, and tire patches. Repairs active vehicle by 60 HP in the field.",
		"max_stack": 3
	},
	"money_wad": {
		"id": "money_wad",
		"name": "Syndicate Cash Bundle",
		"bangla_name": "টাকার বান্ডিল",
		"category": ItemCategory.VALUABLE,
		"price": 1000,
		"effect_type": "cash",
		"effect_val": 1000.0,
		"desc": "Thick stack of 1000 Taka notes. Use to add ৳ 1,000 cash to your wallet.",
		"max_stack": 20
	}
}

# Clothing Outfits Catalog
const OUTFITS := {
	"dhaka_casual": {
		"id": "dhaka_casual",
		"name": "Dhaka Street Casual",
		"bangla_name": "ঢাকা ক্যাজুয়াল",
		"price": 0,
		"desc": "Dark navy graphic tee, stone-washed denim jeans, and comfortable white sneakers.",
		"colors": {
			"torso": Color(0.16, 0.22, 0.32, 1.0),
			"legs": Color(0.18, 0.2, 0.26, 1.0),
			"feet": Color(0.88, 0.88, 0.9, 1.0)
		}
	},
	"white_panjabi": {
		"id": "white_panjabi",
		"name": "Classic White Panjabi & Payjama",
		"bangla_name": "সাদা পাঞ্জাবি ও পায়জামা",
		"price": 850,
		"desc": "Traditional hand-stitched cotton panjabi with white payjama and leather sandals.",
		"colors": {
			"torso": Color(0.95, 0.95, 0.96, 1.0),
			"legs": Color(0.92, 0.92, 0.94, 1.0),
			"feet": Color(0.18, 0.14, 0.12, 1.0)
		}
	},
	"office_shirt": {
		"id": "office_shirt",
		"name": "Corporate Office Shirt & Slacks",
		"bangla_name": "অফিস শার্ট ও প্যান্ট",
		"price": 1400,
		"desc": "Tailored sky-blue buttoned dress shirt with charcoal formal slacks and dress shoes.",
		"colors": {
			"torso": Color(0.42, 0.62, 0.82, 1.0),
			"legs": Color(0.15, 0.16, 0.18, 1.0),
			"feet": Color(0.08, 0.08, 0.1, 1.0)
		}
	},
	"rickshaw_vest": {
		"id": "rickshaw_vest",
		"name": "Rickshaw Puller Vest & Lungi",
		"bangla_name": "রিকশাচালক ভেস্ট ও লুঙ্গি",
		"price": 350,
		"desc": "Working-class cotton vest, green-and-red checkered cotton lungi, and flip-flops.",
		"colors": {
			"torso": Color(0.85, 0.82, 0.78, 1.0),
			"legs": Color(0.12, 0.42, 0.22, 1.0),
			"feet": Color(0.35, 0.25, 0.18, 1.0)
		}
	},
	"tactical_black": {
		"id": "tactical_black",
		"name": "Tactical Night Windbreaker",
		"bangla_name": "কালো ট্যাকটিক্যাল জ্যাকেট",
		"price": 3200,
		"desc": "Reinforced matte black ripstop windbreaker with dark cargo pants and combat boots.",
		"colors": {
			"torso": Color(0.08, 0.08, 0.09, 1.0),
			"legs": Color(0.12, 0.12, 0.13, 1.0),
			"feet": Color(0.05, 0.05, 0.05, 1.0)
		}
	}
}

# Vehicle Garage Customization Services (Bhai Bhai Auto Workshop)
const GARAGE_SERVICES := {
	"repair": {
		"id": "repair",
		"name": "Full Body & Engine Repair",
		"bangla_name": "বডি ও ইঞ্জিন মেরামত",
		"cost": 500,
		"desc": "Restores vehicle health to 100%, extinguishes smoke/fire, and aligns wheels."
	},
	"paint": {
		"id": "paint",
		"name": "Custom Polyurethane Spray Paint",
		"bangla_name": "রং পরিবর্তন",
		"cost": 1200,
		"desc": "High-gloss automotive paint job in authentic colors.",
		"colors": {
			"dhaka_green": Color(0.08, 0.45, 0.22, 1.0),
			"crimson_red": Color(0.72, 0.12, 0.15, 1.0),
			"midnight_black": Color(0.08, 0.09, 0.1, 1.0),
			"pearl_white": Color(0.92, 0.93, 0.95, 1.0),
			"sky_blue": Color(0.15, 0.45, 0.78, 1.0),
			"amber_yellow": Color(0.88, 0.65, 0.12, 1.0)
		}
	},
	"engine_tune": {
		"id": "engine_tune",
		"name": "Stage 1 ECU & Turbo Tuning",
		"bangla_name": "ইঞ্জিন টিউনিং স্টেজ ১",
		"cost": 3500,
		"desc": "Custom intake and fuel injection tuning. +25% engine torque and +15% top speed."
	},
	"armor": {
		"id": "armor",
		"name": "Reinforced Steel Bullbar & Armor",
		"bangla_name": "স্টিল বাম্পার ও আর্মার",
		"cost": 4500,
		"desc": "Heavy-gauge steel front guard and door reinforcement. +50% max vehicle HP."
	},
	"air_horn": {
		"id": "air_horn",
		"name": "High-Decibel Dual Air Horn",
		"bangla_name": "হাইড্রলিক এয়ার হর্ন",
		"cost": 800,
		"desc": "Dhaka highway-grade pneumatic air horn that forces pedestrians and traffic aside."
	}
}

# Purchasable Real Estate Safehouses (Padma Housing Ltd.)
const PROPERTIES := {
	"safehouse_buriganga": {
		"id": "safehouse_buriganga",
		"name": "Buriganga Riverview Flat (2nd Floor)",
		"bangla_name": "বুড়িগঙ্গা রিভারভিউ ফ্ল্যাট",
		"price": 25000,
		"location": Vector3(32.0, 0.2, 45.0),
		"desc": "Spacious 2-bedroom residential flat overlooking the Sadarghat launch docks. Includes private bed, wardrobe, and item stash box."
	},
	"safehouse_old_dhaka": {
		"id": "safehouse_old_dhaka",
		"name": "Old Dhaka Tin-Roof Unit",
		"bangla_name": "পুরান ঢাকা টিনের বাড়ি",
		"price": 8500,
		"location": Vector3(-72.0, 0.2, 115.0),
		"desc": "Affordable starter home with private courtyard, resting cot, and storage trunk."
	}
}


static func format_bdt(amount: int) -> String:
	var s := str(abs(amount))
	var result := ""
	var count := 0
	
	# Format using South Asian numbering system (e.g. 1,00,000 or standard thousands)
	for i in range(s.length() - 1, -1, -1):
		result = s[i] + result
		count += 1
		if count == 3 and i > 0:
			result = "," + result
		elif count > 3 and (count - 3) % 2 == 0 and i > 0:
			result = "," + result
			
	var prefix := "- " if amount < 0 else ""
	return prefix + CURRENCY_SYMBOL + " " + result


static func get_item(item_id: String) -> Dictionary:
	return ITEMS.get(item_id.to_lower(), {})


static func get_item_price(item_id: String) -> int:
	var it = ITEMS.get(item_id.to_lower(), {})
	return it.get("price", 0)


static func get_outfit(outfit_id: String) -> Dictionary:
	return OUTFITS.get(outfit_id.to_lower(), {})


static func get_property(property_id: String) -> Dictionary:
	return PROPERTIES.get(property_id.to_lower(), {})
