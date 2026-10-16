extends RefCounted

const GRAPH = {
 "start": ["a", "b"], "a": ["c", "d"], "b": ["d", "e"],
 "c": ["f"], "d": ["f", "g"], "e": ["g"],
 "f": ["h"], "g": ["h"], "h": ["boss"], "boss": []
}
## Empty until the first node ("start") is completed; the run begins before any node.
var current := ""
var completed: Array[String] = []
var pending := ""
var graph: Dictionary = GRAPH.duplicate(true)

func configure(connections: Dictionary) -> void:
 graph = connections.duplicate(true)
 current = ""
 completed.clear()
 pending = ""

func available() -> Array:
 if not pending.is_empty(): return []
 if current.is_empty(): return ["start"]
 return graph[current].duplicate()

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
