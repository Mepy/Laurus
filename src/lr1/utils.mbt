///|
typealias Int as Index

///|
typealias Int as Token

///|
typealias Int as Sort

///|
typealias Int as Symbol

///|
typealias Array[Symbol] as Sentence

///|
struct Graph {
  adj_lists : Array[Array[Index]]
} derive(Show)

///|
struct SCC {
  component : Array[Index]
} derive(Show)

///|
struct Tarjan {
  graph : Graph
  mut index : Index
  stack : Array[Index]
  on_stack : Array[Bool]
  indices : Array[Index]
  lowlinks : Array[Index]
  sccs : Array[SCC]
} derive(Show)

///|
fn Tarjan::strongly_connect(self : Self, v : Index) -> Unit {
  self.indices[v] = self.index
  self.lowlinks[v] = self.index
  self.index += 1
  self.stack.push(v)
  self.on_stack[v] = true
  for w in self.graph.adj_lists[v] { // v -> w, w is a successor of v
    if self.indices[w] == -1 { // w has not been visited
      self.strongly_connect(w)
      self.lowlinks[v] = @cmp.minimum(self.lowlinks[v], self.lowlinks[w])
    } else if self.on_stack[w] { // w has been visited and in the current scc
      self.lowlinks[v] = @cmp.minimum(self.lowlinks[v], self.lowlinks[w])
    }
  }

  // If v is a root node, pop the stack and create an SCC
  if self.lowlinks[v] == self.indices[v] {
    let scc : Array[Index] = Array::new()
    let mut w : Index = -1
    while w != v {
      w = self.stack.pop().unwrap()
      self.on_stack[w] = false
      scc.push(w)
    }
    self.sccs.push(SCC::{ component: scc })
  }
}

///|
fn Tarjan::analyze(graph : Graph) -> Array[SCC] {
  let node_count = graph.adj_lists.length()
  let tarjan = Tarjan::{
    graph,
    index: 0,
    stack: Array::new(),
    indices: Array::make(node_count, -1),
    lowlinks: Array::make(node_count, -1),
    on_stack: Array::make(node_count, false),
    sccs: Array::new(),
  }
  for v in 0..<node_count {
    if tarjan.indices[v] == -1 {
      tarjan.strongly_connect(v)
    }
  }
  tarjan.sccs
}

///|
struct SuperGraph {
  sccs : Array[SCC]
  scc_adj_lists : Array[Array[Index]] // adjacency lists for SCC indices
  scc_map : Array[Index] // maps node index to SCC index
} derive(Show)

///|
fn SuperGraph::new(graph : Graph) -> SuperGraph {
  let sccs = Tarjan::analyze(graph)
  let node_count = graph.adj_lists.length()
  let scc_count = sccs.length()

  // Create mapping from node to SCC index
  let scc_map : Array[Index] = Array::make(node_count, -1)
  for i in 0..<scc_count {
    let scc = sccs[i]
    for node in scc.component {
      scc_map[node] = i
    }
  }

  // Build supergraph adjacency lists
  let edge_sets : Array[Set[Index]] = Array::makei(scc_count, _ => Set::new())

  // Add edges between different SCCs
  for from_node in 0..<node_count {
    let from_scc = scc_map[from_node]
    let to_set = edge_sets[from_scc]
    for to_node in graph.adj_lists[from_node] {
      let to_scc = scc_map[to_node]
      if from_scc != to_scc {
        to_set.add(to_scc)
      }
    }
  }
  let scc_adj_lists : Array[Array[Index]] = edge_sets.map(edge_set => edge_set.to_array())
  SuperGraph::{ sccs, scc_adj_lists, scc_map }
}

///|
fn SuperGraph::topology_sort(self : Self) -> Array[Index] {
  let node_count = self.scc_adj_lists.length()
  let in_degree : Array[Index] = Array::make(node_count, 0)

  // Calculate in-degrees
  for from in 0..<node_count {
    for to in self.scc_adj_lists[from] {
      in_degree[to] += 1
    }
  }

  // Initialize queue with nodes having in-degree 0
  let queue : Array[Index] = Array::new()
  for i in 0..<node_count {
    if in_degree[i] == 0 {
      queue.push(i)
    }
  }
  let result : Array[Index] = Array::new()

  // Process nodes in topological order
  while queue.length() > 0 {
    let current = queue.pop().unwrap()
    result.push(current)

    // Reduce in-degree of neighbors
    for neighbor in self.scc_adj_lists[current] {
      in_degree[neighbor] -= 1
      if in_degree[neighbor] == 0 {
        queue.push(neighbor)
      }
    }
  }
  result
}
