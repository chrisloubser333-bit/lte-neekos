# Eve Intelligence v2 — AI Memory Extraction, Retrieval & Reinforcement

Eve Intelligence v2 is a hybrid memory intelligence layer. It combines a fast local semantic index with an AI memory analyst so the app can learn what is durable without sending the entire memory store to the model.

## Turn pipeline

```text
User turn
   │
   ├──────────────► Local semantic retrieval
   │                         │
   │                         ▼
   │                  Top relevant memories
   │                         │
   │                         ├──────────────► AI response
   │                         │
   │                         └──────────────► AI memory analyst
   │                                                │
   │                                                ▼
   │                                      structured decisions
   │                                                │
   │                                                ▼
   │                                         MemoryManager
   │                                      ┌───────┼────────┐
   │                                      ▼       ▼        ▼
   │                                   create   update  reinforce
   │                                      │       │        │
   │                                      └───────┼────────┘
   │                                              ▼
   │                                      persistent memory
```

## AI decisions

The extractor returns only:
- `create`
- `update`
- `reinforce`
- `forget`
- `ignore`

The MemoryManager remains authoritative for deduplication, persistence, confidence, lifecycle and decay.

## Retrieval

Retrieval is currently a fast local semantic candidate stage using hashed sparse embeddings, token overlap and lifecycle scoring. This avoids network latency on every turn while still giving the AI analyst the relevant memory candidates needed for reinforcement/update decisions.

This boundary is intentionally ready for a hosted embedding/vector provider in a later production pass.

## Reinforcement

The AI analyst can decide that an existing memory is confirmed by the latest user turn. The MemoryManager then increases reinforcement count and confidence instead of creating a duplicate.

Contradictory user statements can produce an `update` decision, replacing the older memory rather than accumulating conflicting facts.

## Concurrency

Response generation and memory analysis run concurrently. If the memory-analysis request fails, the conversation still succeeds.

## Safety

The extractor is instructed not to automatically retain health/medical, political, religious, sexual, criminal, financial-account, password, identity-number or similarly sensitive information. Explicit deterministic `remember` commands remain supported.

## Tests

`test/memory_intelligence_test.dart` covers:
- structured/fenced JSON parsing
- AI create decisions
- AI reinforcement decisions
- ignore decisions

Existing memory retrieval/forget tests remain in `test/memory_manager_test.dart`.
