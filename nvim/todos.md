# Futility Pruning
Intuition: If I'm down a queen and it's almost the depth limit, normal moves won't save me. Skip searching them.
Logic: Near leaf nodes, if static eval + margin < alpha, prune non-tactical moves. They can't improve the position enough.

# Reverse Futility Pruning
Intuition: If I'm already way ahead (up a queen) and it's near the depth limit, my opponent's quiet moves won't hurt me. Cut off the search.

Logic: If static eval - margin >= beta, return early (beta cutoff). Position is too good already.

# Razoring
Intuition: At very shallow depths, if the position looks terrible even after a quiescence search, just return early.
Logic: If static eval + large margin < alpha at depth 1-3, do qsearch. If still bad, return the qsearch score.

# ProbCut

Intuition: Do a shallow search with a wider window. If it shows a strong cutoff, the deep search will probably cut off too (probably).

Logic: At high depths, do a shallow search with adjusted bounds. If it produces a cutoff with high confidence, skip the deep search.

# MVV-LVA (Most Valuable Victim - Least Valuable Aggressor)

Intuition: Taking a queen with a pawn is better than taking a pawn with a queen. Try high-value captures first.
Logic: Order captures by: victim value (high to low), then attacker value (low to high).

# Killer Heuristic

Intuition: A move that caused a cutoff at one node might cause a cutoff at sibling nodes (similar positions). Remember those "killer" moves.
Logic: Store 2-3 non-capture moves per depth that caused beta cutoffs. Try them early at other nodes of the same depth.

# History Heuristic

Intuition: Some moves (like e4, Nf3) work well across many positions. Track which moves historically cause cutoffs.
Logic: Maintain a table counting how often each move (from-square, to-square) causes cutoffs. Order moves by this score.
