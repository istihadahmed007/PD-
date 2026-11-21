# ==============================================================================
# STORY MISSIONS REPOSITORY (MISSION SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Defines the first three complete playable story missions featuring
#          original contemporary Bangladesh crime-action narratives, authentic
#          dialogues in Bengali & English, objectives, checkpoints, and rewards.
# ==============================================================================
class_name StoryMissions
extends RefCounted


static func get_mission_1() -> MissionResource:
	var m = MissionResource.new()
	m.mission_id = "m01_shadows_and_sparkplugs"
	m.title = "Shadows & Spark Plugs (ছায়া ও চালক)"
	m.mission_type = MissionResource.MissionType.DELIVERY
	m.description = "Deliver tuned Japanese carburetor parts across the canal bridge to Gaffar Bhai's shop before debt collectors arrive at Kabir Ustad's workshop."
	m.giver_name = "Kabir Ustad (কবির ওস্তাদ)"
	m.giver_location = Vector3(-48.0, 0.2, 96.0)
	m.giver_portrait_path = "res://assets/textures/characters/portrait_kabir.png"
	m.reward_bdt = 1500
	m.reward_xp = 350
	
	m.steps = [
		{
			"type": "TALK",
			"description": "Speak with Kabir Ustad inside Bhai Bhai Auto Workshop",
			"target_position": Vector3(-48.0, 0.2, 96.0),
			"target_radius": 3.5,
			"dialogue_before": "d_intro",
			"checkpoint": Vector3(-48.0, 0.2, 96.0)
		},
		{
			"type": "DRIVE",
			"description": "Mount the tuned Green CNG Auto-Rickshaw parked at the apron",
			"target_position": Vector3(-44.0, 0.45, 92.0),
			"target_radius": 3.0,
			"checkpoint": Vector3(-46.0, 0.2, 94.0)
		},
		{
			"type": "DELIVER",
			"description": "Transport the fragile carburetor parts across the Canal Bridge to Commercial Bazaar",
			"target_position": Vector3(-45.0, 0.2, -42.2),
			"target_radius": 5.5,
			"time_limit": 160.0,
			"fragile_cargo": true,
			"checkpoint": Vector3(0.0, 0.2, 50.0) # Bridge midpoint checkpoint
		},
		{
			"type": "TALK",
			"description": "Deliver the parts to Gaffar Bhai at Bismillah General Store and collect payment",
			"target_position": Vector3(-45.0, 0.2, -42.2),
			"target_radius": 4.0,
			"dialogue_before": "d_bazaar",
			"checkpoint": Vector3(-45.0, 0.2, -42.2)
		},
		{
			"type": "GOTO",
			"description": "Return to Bhai Bhai Auto Workshop and deliver the payment to Kabir Ustad",
			"target_position": Vector3(-48.0, 0.2, 96.0),
			"target_radius": 4.0,
			"dialogue_after": "d_complete",
			"checkpoint": Vector3(-48.0, 0.2, 96.0)
		}
	]
	
	m.dialogues = {
		"d_intro": [
			{
				"speaker": "KABIR USTAD (কবির ওস্তাদ)",
				"bengali": "জয়, ভালো সময় আসিস নাই রে বাপ। চেয়ারম্যানের গুন্ডারা সকালে এসে শাসিয়ে গেল... বলে ওদের নৌকায় গোপন চেম্বার বানিয়ে দিতে হবে। আমি না করেছি, কিন্তু আজই ব্যাংকের কিস্তি না দিলে গ্যারেজ সিল করে দেবে!",
				"english": "Joy, you couldn't have picked a worse day. The Chairman's thugs came by this morning... demanded we build hidden contraband chambers into their river launches. I refused, but if we don't pay the bank installment today, they'll seal the workshop!",
				"portrait": "res://assets/textures/characters/portrait_kabir.png"
			},
			{
				"speaker": "JOY (জয়নাল আবেদিন)",
				"bengali": "ওস্তাদ, আপনি মাথা গরম করবেন না। আব্বা সবসময় বলত, অসৎ টাকার চেয়ে আধপেটা থাকা ভালো। আমি আছি, কি করতে হবে বলেন?",
				"english": "Ustad, don't lose your temper. Father always said going hungry is better than dirty money. I'm here. Tell me what needs to be done.",
				"portrait": "res://assets/textures/characters/portrait_joy.png"
			},
			{
				"speaker": "KABIR USTAD (কবির ওস্তাদ)",
				"bengali": "বাজারের জাফর ভাইয়ের কাছে এই জাপানি কার্বুরেটরটা দিয়ে আয়। সবুজ সিএনজিটা নে। খবরদার, ট্রাফিকে ধাক্কাধাক্কি করিস না, কার্বুরেটরের পিনগুলো নষ্ট হলে সর্বনাশ হয়ে যাবে!",
				"english": "Take this tuned Japanese carburetor to Gaffar Bhai in the bazaar. Take the green CNG. Watch the traffic—don't crash, if the needle valves bend we're finished!",
				"portrait": "res://assets/textures/characters/portrait_kabir.png"
			}
		],
		"d_bazaar": [
			{
				"speaker": "GAFFAR BHAI (জাফর ভাই)",
				"bengali": "আরে জয়! সময়মতো এসেছিস ভাই। কার্বুরেটরটা একেবারে খাঁটি জিনিস! এই নে তোর ওস্তাদের পাওনা পনেরো শত টাকা। সাবধানে যা, মোড়ে নাকি ট্রাফিক পুলিশ কড়া চেকিং চালাচ্ছে!",
				"english": "Joy! You made it in time, brother. This carburetor is mint Japanese steel! Here's your Ustad's fifteen hundred Taka payment. Watch out heading back, traffic police are inspecting vehicles at the bridge!",
				"portrait": "res://assets/textures/characters/portrait_joy.png"
			}
		],
		"d_complete": [
			{
				"speaker": "KABIR USTAD (কবির ওস্তাদ)",
				"bengali": "আলহামদুলিল্লাহ! তুই গ্যারেজটা বাঁচালি রে জয়। এই নে, তোর মেহনতের পাঁচশো টাকা রাখ। তোর আব্বা থাকলে আজ তোকে দেখে গর্ব করত।",
				"english": "Alhamdulillah! You saved our workshop today, Joy. Keep this five hundred Taka for your sweat. If your father were alive today, he'd be proud of you.",
				"portrait": "res://assets/textures/characters/portrait_kabir.png"
			}
		]
	}
	
	return m


static func get_mission_2() -> MissionResource:
	var m = MissionResource.new()
	m.mission_id = "m02_eyes_of_buriganga"
	m.title = "Eyes of the Buriganga (বুড়িগঙ্গার চোখ)"
	m.mission_type = MissionResource.MissionType.INVESTIGATION
	m.description = "Infiltrate Chairman Afsarul's sand dredging depot with investigative journalist Nila Chowdhury to recover the smuggling manifest that caused Captain Farid's death."
	m.giver_name = "Nila Chowdhury (নীলা চৌধুরী)"
	m.giver_location = Vector3(-38.0, 0.2, 26.0) # Stepped Ghat
	m.giver_portrait_path = "res://assets/textures/characters/portrait_nila.png"
	m.prerequisite_mission_id = "m01_shadows_and_sparkplugs"
	m.reward_bdt = 3000
	m.reward_xp = 600
	
	m.steps = [
		{
			"type": "TALK",
			"description": "Meet investigative journalist Nila Chowdhury at the Riverside Stepped Ghat",
			"target_position": Vector3(-38.0, 0.2, 26.0),
			"target_radius": 3.5,
			"dialogue_before": "d_intro",
			"checkpoint": Vector3(-38.0, 0.2, 26.0)
		},
		{
			"type": "GOTO",
			"description": "Scout the river dredging industrial depot on the southern canal bank",
			"target_position": Vector3(-65.0, 0.2, 24.0),
			"target_radius": 5.0,
			"checkpoint": Vector3(-55.0, 0.2, 24.0)
		},
		{
			"type": "INVESTIGATE",
			"description": "Infiltrate the depot and search the parked Syndicate Pickup for the dredging manifest",
			"target_position": Vector3(-65.0, 0.2, 24.0),
			"target_radius": 3.0,
			"dialogue_after": "d_ledger",
			"checkpoint": Vector3(-65.0, 0.2, 24.0)
		},
		{
			"type": "DEFEND",
			"description": "Depot alarm sounded! Break line of sight from syndicate lookouts and evade police alert",
			"target_position": Vector3(-95.0, 0.2, -60.0),
			"target_radius": 8.0,
			"checkpoint": Vector3(-75.0, 0.2, -20.0)
		},
		{
			"type": "DELIVER",
			"description": "Deliver the recovered manifest safely to Nila's safehouse contact at the Residential Goli",
			"target_position": Vector3(-95.0, 0.2, -105.0),
			"target_radius": 4.5,
			"dialogue_after": "d_safehouse",
			"checkpoint": Vector3(-95.0, 0.2, -105.0)
		}
	]
	
	m.dialogues = {
		"d_intro": [
			{
				"speaker": "NILA CHOWDHURY (নীলা চৌধুরী)",
				"bengali": "জয়, তোমার বাবার মৃত্যু কোনো দুর্ঘটনা ছিল না। এই দেখো বন্দর কর্তৃপক্ষের গোপন লগ... সেদিন রাতে 'বালু-০৯' নামের যে ড্রেজারটা তোমার বাবার লঞ্চে ধাক্কা মেরেছিল, সেটার মালিক চেয়ারম্যান আফসারুল হক।",
				"english": "Joy, your father's death was no accident. Look at this port authority log... that night, the dredger 'Balu-09' that rammed your father's launch was owned by Chairman Afsarul Huq.",
				"portrait": "res://assets/textures/characters/portrait_nila.png"
			},
			{
				"speaker": "JOY (জয়নাল আবেদিন)",
				"bengali": "কী বললেন?! আমার আব্বা সারাজীবন সততার সাথে নদী পারাপার করল, আর এই পশুগুলো স্রেফ বালুর টাকার জন্য আব্বাকে মেরে ফেলল?!",
				"english": "What did you say?! My father piloted that river honestly his whole life, and these animals killed him just for sand dredging profits?!",
				"portrait": "res://assets/textures/characters/portrait_joy.png"
			},
			{
				"speaker": "NILA CHOWDHURY (নীলা চৌধুরী)",
				"bengali": "রাগলে চলবে না জয়, প্রমাণ লাগবে। ড্রেজিং ডিপোতে ওদের পিকআপ ট্রাকে আজকের কেমিক্যাল আর বালু পাচারের লগবই আছে। ওটা উদ্ধার করতে পারলে আমি পত্রিকায় চেয়ারম্যানের মুখোশ খুলে দেব!",
				"english": "Anger won't bring justice, Joy. We need hard evidence. Their pickup truck at the dredging depot has tonight's chemical and sand smuggling manifest. If we get that ledger, I will expose the Chairman on the front page!",
				"portrait": "res://assets/textures/characters/portrait_nila.png"
			}
		],
		"d_ledger": [
			{
				"speaker": "JOY (জয়নাল আবেদিন)",
				"bengali": "লগবইটা পেয়েছি! কিন্তু ওরা আমাদের দেখে ফেলেছে—গার্ডরা সাইরেন বাজিয়ে পুলিশ ডাকছে! আমাকে এখনই সরে পড়তে হবে!",
				"english": "I got the ledger! But lookouts spotted me—guards are sounding the alarm and calling the police! I need to break away now!",
				"portrait": "res://assets/textures/characters/portrait_joy.png"
			}
		],
		"d_safehouse": [
			{
				"speaker": "NILA CHOWDHURY (নীলা চৌধুরী)",
				"bengali": "সাবাশ জয়! এই প্রমাণপত্রগুলো চেয়ারম্যানের দুর্নীতির অকাট্য দলিল। পুরো শহর এখন ওর কুকীর্তি জানবে। তুমি নিজের জীবন বাজি রেখেছ, এই নাও তোমার সম্মানী।",
				"english": "Brilliant, Joy! These documents are undeniable proof of the Chairman's syndicate. The whole city will know what he did. You risked your life—take this reward.",
				"portrait": "res://assets/textures/characters/portrait_nila.png"
			}
		]
	}
	
	return m


static func get_mission_3() -> MissionResource:
	var m = MissionResource.new()
	m.mission_id = "m03_smoke_over_padma"
	m.title = "Smoke Over Padma (পদ্মার ধোঁয়া)"
	m.mission_type = MissionResource.MissionType.CHASE
	m.description = "SI Mahfuz tips off Joy that Chairman Afsarul's arson squad is speeding to burn down Rahmat Chacha's rickshaw depot. Intercept the convoy, disable the getaway truck, and extract Chacha to Thana custody."
	m.giver_name = "SI Mahfuzur Rahman (এসআই মাহফুজ)"
	m.giver_location = Vector3(45.0, 0.2, -31.0) # Lalbagh Thana Porch
	m.giver_portrait_path = "res://assets/textures/characters/portrait_mahfuz.png"
	m.prerequisite_mission_id = "m02_eyes_of_buriganga"
	m.reward_bdt = 5000
	m.reward_xp = 1000
	
	m.steps = [
		{
			"type": "TALK",
			"description": "Answer SI Mahfuz's emergency call outside Lalbagh Police Thana",
			"target_position": Vector3(45.0, 0.2, -31.0),
			"target_radius": 3.5,
			"dialogue_before": "d_intro",
			"checkpoint": Vector3(45.0, 0.2, -31.0)
		},
		{
			"type": "DRIVE",
			"description": "Commandeer the tuned Private Sedan parked along the avenue",
			"target_position": Vector3(3.8, 0.45, -28.0),
			"target_radius": 3.5,
			"checkpoint": Vector3(3.8, 0.2, -28.0)
		},
		{
			"type": "CHASE",
			"description": "High-Speed Intercept: Pursue Ghashi Tariq's arson convoy speeding toward the canal bridge",
			"target_position": Vector3(0.0, 0.45, 15.0),
			"target_radius": 7.0,
			"time_limit": 120.0,
			"dialogue_before": "d_chase_start",
			"checkpoint": Vector3(0.0, 0.2, -10.0)
		},
		{
			"type": "CHASE",
			"description": "Execute PIT maneuver or ram syndicate truck to disable it before the market entrance",
			"target_position": Vector3(0.0, 0.45, 65.0),
			"target_radius": 6.5,
			"dialogue_after": "d_ram_done",
			"checkpoint": Vector3(0.0, 0.2, 50.0)
		},
		{
			"type": "DEFEND",
			"description": "Dismount and defend Rahmat Chacha from the surviving syndicate thugs",
			"target_position": Vector3(0.0, 0.2, 70.0),
			"target_radius": 5.0,
			"dialogue_after": "d_rescue",
			"checkpoint": Vector3(0.0, 0.2, 70.0)
		},
		{
			"type": "DELIVER",
			"description": "Escort Rahmat Chacha to Lalbagh Police Station reception desk under protective custody",
			"target_position": Vector3(75.0, 0.2, -96.0),
			"target_radius": 4.5,
			"dialogue_after": "d_complete",
			"checkpoint": Vector3(75.0, 0.2, -96.0)
		}
	]
	
	m.dialogues = {
		"d_intro": [
			{
				"speaker": "SI MAHFUZ (এসআই মাহফুজ)",
				"bengali": "জয়, কান খুলে শোন। ঘাসি তারিক ওর গুন্ডাদের নিয়ে বাজারের দিকে রওনা হয়েছে। রহমত চাচার রিকশার গ্যারেজে আগুন লাগাবে ওরা, যাতে চেয়ারম্যান সস্তায় জমিটা দখল করতে পারে! আমি অফিশিয়ালি হাত বাঁধা, কিন্তু তুই যদি ওদের রাস্তায় আটকাতে পারিস...",
				"english": "Joy, listen carefully. Ghashi Tariq and his goons just mobilized toward the bazaar. They're going to torch Rahmat Chacha's rickshaw garage so the Chairman can grab the land cheap! My hands are officially tied by superiors, but if you stop them on the avenue...",
				"portrait": "res://assets/textures/characters/portrait_mahfuz.png"
			},
			{
				"speaker": "JOY (জয়নাল আবেদিন)",
				"bengali": "রহমত চাচা আমার আব্বার জানের দোস্ত! ওদের গায়ে হাত দেওয়ার আগে আমার লাশের উপর দিয়ে যেতে হবে!",
				"english": "Rahmat Chacha was my father's dearest friend! They will have to step over my dead body before touching him!",
				"portrait": "res://assets/textures/characters/portrait_joy.png"
			}
		],
		"d_chase_start": [
			{
				"speaker": "GHASHI TARIQ (ঘাসি তারিক)",
				"bengali": "আরে এই তো লঞ্চচালকের ছোকরা! তোর বাপের মতো তোকেও বুড়িগঙ্গার তলায় পুঁতে ফেলব!",
				"english": "Look who it is—the dead launch captain's brat! I'll bury you at the bottom of the Buriganga just like your old man!",
				"portrait": "res://assets/textures/characters/portrait_tariq.png"
			},
			{
				"speaker": "JOY (জয়নাল আবেদিন)",
				"bengali": "তারিক! আজ তোর গুন্ডাগিরির শেষ দিন!",
				"english": "Tariq! Today is the end of your extortion reign!",
				"portrait": "res://assets/textures/characters/portrait_joy.png"
			}
		],
		"d_ram_done": [
			{
				"speaker": "GHASHI TARIQ (ঘাসি তারিক)",
				"bengali": "গাড়ি নষ্ট হয়ে গেছে! নাম শালা, ছোকরাটাকে শেষ কর!",
				"english": "The truck is totaled! Dismount, finish off this kid!",
				"portrait": "res://assets/textures/characters/portrait_tariq.png"
			}
		],
		"d_rescue": [
			{
				"speaker": "RAHMAT CHACHA (রহমত চাচা)",
				"bengali": "জয় রে বাপ! তুই না আসলে ওরা আমাকে মেরেই ফেলত রে বাপ... তোর আব্বার রক্ত তোর শরীরে বইছে!",
				"english": "Joy, my son! If you hadn't arrived, they would have murdered me... your father's brave blood flows in your veins!",
				"portrait": "res://assets/textures/characters/portrait_rahmat.png"
			},
			{
				"speaker": "JOY (জয়নাল আবেদিন)",
				"bengali": "চাচা, একদম চিন্তা করবেন না। আপনাকে সোজা থানায় এসআই মাহফুজের জিম্মায় পৌঁছে দেব। ওখানে কোনো গুন্ডা আপনার চুলও স্পর্শ করতে পারবে না।",
				"english": "Chacha, don't worry. I am taking you straight to SI Mahfuz at the Thana under state protection. No syndicate thug can touch a hair on your head there.",
				"portrait": "res://assets/textures/characters/portrait_joy.png"
			}
		],
		"d_complete": [
			{
				"speaker": "SI MAHFUZ (এসআই মাহফুজ)",
				"bengali": "রহমত চাচাকে আমরা ম্যাজিস্ট্রেট কোর্টের সেফ কাস্টডিতে নিচ্ছি। তারিক আর ওর ড্রেজার গ্যাংয়ের বিরুদ্ধে অফিশিয়াল ওয়ারেন্ট জারি হলো! তুই আজ পুরো এলাকার মানসম্মান বাঁচিয়েছিস, জয়।",
				"english": "We are placing Rahmat Chacha under magistrate court protective custody. An official non-bailable arrest warrant has been issued against Tariq and the dredger gang! You saved our entire neighborhood today, Joy.",
				"portrait": "res://assets/textures/characters/portrait_mahfuz.png"
			}
		]
	}
	
	return m
