extends RefCounted

const GRAPH = {
 "start": ["a", "b"], "a": ["c", "d"], "b": ["d", "e"],
 "c": ["f"], "d": ["f", "g"], "e": ["g"],
 "f": ["h"], "g": ["h"], "h": ["boss"], "boss": []
}
var current := "start"
var completed: Array[String] = []
var pending := ""
var graph: Dictionary = GRAPH.duplicate(true)

func configure(connections: Dictionary) -> void:
 graph = connections.duplicate(true)
 current = "start"
 completed.clear()
 pending = ""

func available() -> Array:
 return graph[current].duplicate() if pending.is_empty() else []

func enter(id: String) -> bool:
 if not available().has(id):
  return false
 pending = id
 return true

func finish() -> bool:
 if pending.is_empty():
  return false
 current = pending
 completed.append(current)
 pending = ""
 return true
