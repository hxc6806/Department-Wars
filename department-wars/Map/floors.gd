extends RefCounted
## Floor list, node types and random node layouts. Every floor shares the same graph.
## Images are looked up by file name, so replacing a PNG with the same name swaps the art.
const GRAPH = {
 "start": ["a", "b"], "a": ["c", "d"], "b": ["d", "e"],
 "c": ["f"], "d": ["f", "g"], "e": ["g"],
 "f": ["h"], "g": ["h"], "h": ["boss"], "boss": []
}
const POSITIONS = {
 "start": Vector2(490,520), "a": Vector2(330,455), "b": Vector2(660,455),
 "c": Vector2(220,350), "d": Vector2(490,350), "e": Vector2(760,350),
 "f": Vector2(335,245), "g": Vector2(650,245), "h": Vector2(490,150),
 "boss": Vector2(490,52)
}
const FLOORS = [
 {"name": "BUSINESS DEPARTMENT", "background": "res://Assets/Maps/business_department.png"},
 {"name": "COMPUTER DEPARTMENT", "background": "res://Assets/Maps/computer_department.png"},
 {"name": "MEDICAL DEPARTMENT", "background": "res://Assets/Maps/medical_department.png"},
]
# Keys are the internal node types used by run_setup.gd; "name" is what the map shows.
const TYPES = {
 "start": {"name": "START", "symbol": "•", "image": "res://Assets/MapNodes/start.png", "text": "Your run begins here."},
 "battle": {"name": "ASSIGNMENTS", "symbol": "⚔", "image": "res://Assets/MapNodes/assignments.png", "text": "Battle two enemies.\nWin and choose a card."},
 "elite": {"name": "QUIZZES", "symbol": "!", "image": "res://Assets/MapNodes/quizzes.png", "text": "Battle three enemies.\nWin and choose two cards."},
 "treasure": {"name": "RESTAURANT", "symbol": "▣", "image": "res://Assets/MapNodes/restaurant.png", "text": "Choose one card to add\nto your deck."},
 "rest": {"name": "HOME", "symbol": "+", "image": "res://Assets/MapNodes/home.png", "text": "Recover 25 health, up to\nyour maximum health."},
 "boss": {"name": "EXAM", "symbol": "♛", "image": "res://Assets/MapNodes/exam.png", "text": "Exam coming soon."},
}
const MIDDLE = ["a", "b", "c", "d", "e", "f", "g", "h"]
const WEIGHTS = {"battle": 50, "elite": 20, "treasure": 15, "rest": 15}
# Each floor always gets at least one of these.
const GUARANTEED = ["elite", "treasure", "rest"]

## Random layout for one floor, in the map's DATA format: id -> [position, name, type, text].
static func generate(rng: RandomNumberGenerator) -> Dictionary:
 var kinds: Array = GUARANTEED.duplicate()
 while kinds.size() < MIDDLE.size():
  kinds.append(_roll(rng))
 for i in range(kinds.size() - 1, 0, -1):
  var j := rng.randi_range(0, i)
  var swap = kinds[i]
  kinds[i] = kinds[j]
  kinds[j] = swap
 return build(kinds)

## Layout from a fixed list of 8 types for nodes a-h (used by tests).
static func build(kinds: Array) -> Dictionary:
 var data := {"start": _node("start", "start")}
 for i in MIDDLE.size():
  data[MIDDLE[i]] = _node(MIDDLE[i], kinds[i])
 data["boss"] = _node("boss", "boss")
 return data

## Loads an image if it exists and has been imported; null otherwise so callers can fall back.
static func texture(path: String) -> Texture2D:
 return load(path) if ResourceLoader.exists(path) else null

static func _node(id: String, kind: String) -> Array:
 return [POSITIONS[id], TYPES[kind].name, kind, TYPES[kind].text]

static func _roll(rng: RandomNumberGenerator) -> String:
 var total := 0
 for kind in WEIGHTS: total += WEIGHTS[kind]
 var pick := rng.randi_range(1, total)
 for kind in WEIGHTS:
  pick -= WEIGHTS[kind]
  if pick <= 0: return kind
 return "battle"
