# Eve Memory & Intelligence — Implementation Blueprint v1

The approved Eve Memory & Intelligence architecture is now implemented as the first persistent-memory layer.

## 1. Input layer
- Existing voice input -> speech-to-text.
- Existing text input.
- Current conversation remains short-term/working memory.

## 2. Memory Manager
`lib/services/memory_manager.dart`

Responsibilities:
- extraction from user turns
- classification
- importance/confidence scoring
- reinforcement and contradiction adjustment
- deterministic local semantic indexing
- retrieval and ranking
- lifecycle decay/archive
- remember / retrieve / reinforce / update / forget / summarize-ready boundary

### Auto-memory policy
Automatic extraction is deliberately conservative. Explicit `remember` requests are always high-confidence and pinned. Sensitive topics are not automatically retained.

## 3. Long-term memory types
- Semantic: stable facts
- Preference: likes, settings and communication choices
- Episodic: projects, plans and events
- Relationship: user/Eve context
- Skill: domain knowledge relevant to the user

## 4. Retrieval
The local index uses a 128-dimensional deterministic hashed vector and cosine similarity, combined with token overlap and lifecycle score.

This is intentionally an abstraction. A future hosted embedding provider can replace `_embed()` without changing the MemoryManager API or the UI.

## 5. Intelligence integration
Before each AI response:
1. current user turn is processed for memory
2. relevant memories are retrieved
3. only the top six are added to the system context
4. memories are explicitly marked as context, not instructions
5. the selected AI model reasons over conversation + relevant memory + Eve identity

This keeps memory model-agnostic.

## 6. User commands
Supported in English and Afrikaans:
- `Eve, remember that ...`
- `Eve, forget ...`
- `What do you remember about me?`
- `Eve, forget everything`
- `Eve, onthou ...`
- `Wat onthou jy van my?`
- `Eve, vergeet ...`
- `Eve, vergeet alles`

## 7. Storage and privacy
- Long-term memories are stored with `flutter_secure_storage`.
- Existing non-sensitive app preferences remain in SharedPreferences.
- Existing API-key storage is migrated to secure storage.
- No cloud memory sync is enabled by default.
- The memory UI provides delete-all control.

## 8. Memory lifecycle
Create -> Strengthen -> Retrieve -> Use -> Age -> Archive/Delete.

Pinned memories bypass automatic low-value decay.

## 9. User memory UI
`lib/screens/memory_screen.dart` now reads real MemoryProvider data instead of placeholder examples. It supports:
- filtering by memory type
- adding a memory
- pin/unpin
- reinforce
- forget
- delete all
- local-first privacy messaging

## 10. Future production upgrades
- Remote embedding provider behind an `EmbeddingProvider` interface
- LLM-based structured memory extraction with JSON schema validation
- contradiction resolution using a memory graph
- encrypted optional cloud backup
- memory export/import
- per-memory sensitivity/retention policies
- background summarization of old episodic memories
- provider-neutral AI gateway for Grok/OpenAI/Claude/Gemini/local models
