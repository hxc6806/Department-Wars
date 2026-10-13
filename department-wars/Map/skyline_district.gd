extends RefCounted
## Map data only. Uses the existing encounters, rewards and healing.
const GRAPH = {
 "start": ["a", "b", "c"],
 "a": ["d"], "b": ["d", "e"], "c": ["e"],
 "d": ["f", "g"], "e": ["g"],
 "f": ["h"], "g": ["h"], "h": []
}
const NODES = {
 "start": [Vector2(490,520), "LIFT TERMINAL", "start", "Above the city.\nChoose one of three\nconnected routes."],
 "a": [Vector2(220,420), "ROOFTOP WALK", "battle", "Battle two enemies.\nReward: one card.\nLeads to the Skybridge."],
 "b": [Vector2(490,420), "SIGNAL TOWER", "elite", "Battle three enemies.\nReward: two cards.\nChoose either middle path."],
 "c": [Vector2(750,420), "SKY GARDEN", "rest", "Recover 25 health, up to\nyour maximum.\nLeads to the Archive."],
 "d": [Vector2(330,300), "SKYBRIDGE", "battle", "Battle two enemies.\nReward: one card.\nChoose the next crossing."],
 "e": [Vector2(650,300), "CIVIC ARCHIVE", "treasure", "Choose one existing card\nto add to your deck.\nLeads to the Upper Walk."],
 "f": [Vector2(220,180), "WEST TERRACE", "rest", "Recover 25 health, up to\nyour maximum.\nThe Observatory is next."],
 "g": [Vector2(650,180), "UPPER WALK", "battle", "Battle two enemies.\nReward: one card.\nThe Observatory is next."],
 "h": [Vector2(490,60), "OBSERVATORY", "battle", "Final route encounter.\nBattle two enemies and\nchoose one card to finish."]
}
