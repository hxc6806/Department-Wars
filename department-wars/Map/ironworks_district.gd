extends RefCounted
# Map content only. Encounters use the team's existing combat system.
const GRAPH = {
 "start": ["a", "b"], "a": ["c", "d"], "b": ["d", "e"],
 "c": ["f"], "d": ["f", "g"], "e": ["g"],
 "f": ["h"], "g": ["h"], "h": ["boss"], "boss": []
}
const NODES = {
 "start": [Vector2(490,520), "RAIL TERMINAL", "start", "Welcome to the Ironworks.\nChoose your route."],
 "a": [Vector2(280,440), "LOADING BAY", "battle", "Battle two enemies.\nReward: one card."],
 "b": [Vector2(680,440), "SECURITY CHECKPOINT", "elite", "Battle three enemies.\nReward: two cards."],
 "c": [Vector2(210,340), "SCRAP DEPOT", "treasure", "Choose one card to add\nto your deck."],
 "d": [Vector2(490,340), "MAINTENANCE ROOM", "rest", "Recover 25 health.\nHealing cannot exceed\nyour maximum."],
 "e": [Vector2(750,340), "PRESSURE WORKS", "battle", "Battle two enemies.\nReward: one card."],
 "f": [Vector2(330,230), "ASSEMBLY LINE", "battle", "Battle two enemies.\nReward: one card."],
 "g": [Vector2(650,230), "FURNACE WATCH", "elite", "Battle three enemies.\nHigher risk; two card\nrewards."],
 "h": [Vector2(490,140), "FURNACE GATE", "battle", "Final route encounter.\nBattle two enemies and\nchoose one card."],
 "boss": [Vector2(490,50), "FURNACE CORE", "boss", "Boss encounter coming soon."],
}
