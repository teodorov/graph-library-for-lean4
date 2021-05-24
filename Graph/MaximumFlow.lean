import Graph.Graph
import Std.Data.HashSet

namespace Graph

variable {α : Type} [BEq α] [Inhabited α] variable {β : Type}


structure VertexState where
  excess : Nat := 0
  height : Nat := 0
  nextVertex : Nat
  currentNeighbor : Nat := 0
  neighborList : Array Nat

instance : Inhabited VertexState := ⟨ { nextVertex := arbitrary, neighborList := Array.empty } ⟩ 

structure MaxFlowEdge where
  capacity : Nat
  flow : Nat := 0

private def InternalFlowNetwork := Graph VertexState MaxFlowEdge
-- variable (FlowNetwork := Graph α Nat) -- TODO how to do this?

-- def basicMinimumCut (g : Graph α β) :

instance [Inhabited γ] : Inhabited (Edge γ) := ⟨ 0, arbitrary ⟩

private def createAdjacencyListAndNeighborSets (vertex : Vertex α Nat) (id : Nat) (neighborSets : Array (Std.HashSet Nat)) : Option ((Array (Edge MaxFlowEdge)) × (Array (Std.HashSet Nat))) := do
  let mut neighborSets := neighborSets
  let mut currentNeighborSet := neighborSets[id]
  let mut adjacencyList : Array (Edge MaxFlowEdge) := Array.empty
  for i in [0:vertex.adjacencyList.size] do
    let edge := vertex.adjacencyList[i]
    if currentNeighborSet.contains edge.target then return none else -- There is either an antiparallel edge (see Cormen et al. Introduction to Algorithms) or the graph is not simple
    neighborSets := neighborSets.modify edge.target (λ neighborSet => neighborSet.insert id)
    currentNeighborSet := currentNeighborSet.insert edge.target
    adjacencyList := adjacencyList.push { edge with weight := { capacity := edge.weight, flow := 0 } }

  let resultNeighborSets := neighborSets.set! id currentNeighborSet
  some (adjacencyList, resultNeighborSets)
  

private def nullFlowNetwork (g : Graph α Nat) : Option InternalFlowNetwork := do
  let mut adjacencyLists : Array (Array (Edge MaxFlowEdge)) := Array.empty
  let mut neighborSets : Array (Std.HashSet Nat) := mkArray g.vertices.size Std.HashSet.empty
  let mut nextVertexPointers : Array Nat := Array.empty
  for i in [0:g.vertices.size] do
    match createAdjacencyListAndNeighborSets g.vertices[i] i neighborSets with
      | some (newAdjacencyList, newNeighborSets) =>
        adjacencyLists := adjacencyLists.push newAdjacencyList
        neighborSets := newNeighborSets
        nextVertexPointers := nextVertexPointers.push i
      | none => return none
  let mut vertices : Array (Vertex VertexState MaxFlowEdge) := Array.empty
  for i in [0:g.vertices.size] do
    let vertexState : VertexState := {
      nextVertex := nextVertexPointers[i]
      neighborList := neighborSets[i].toArray
    }
    vertices := vertices.push { userData := vertexState, adjacencyList := adjacencyLists[i] }

  some ⟨ vertices ⟩
  
-- private def initializePreflow (g)
  -- vertices := vertices.modify source (λ vertex => { vertex with userData := { vertex.userData with height := g.vertices.size } } )

-- def pushRelabelToFront (g : Graph α Nat) (source : Nat) (sink : Nat) : Option (Graph α Nat) :=
--   match nullFlowNetwork g with
--     | none => none
--     | some initialGraph =>
--       let preflowGraph : InternalFlowNetwork := _

--       _

end Graph