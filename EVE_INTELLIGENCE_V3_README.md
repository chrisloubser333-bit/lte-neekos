# Eve Intelligence v3

## What changed
Eve now has a provider abstraction and a production semantic embedding layer.

### Model/provider abstraction
`AiProviderRegistry` routes the selected model to:
- xAI / Grok
- OpenAI / GPT
- Anthropic / Claude
- Google / Gemini

Eve's memory extraction uses the same provider gateway, so it is not tied to xAI.

### Production semantic embeddings
`EmbeddingService` uses OpenAI `text-embedding-3-small` when an OpenAI key is configured.
Existing local hash embeddings remain as an offline fallback.
Memories record their embedding provider/model. On first production retrieval, old local memories are lazily migrated in batches.

### Memory continuity
The memory pipeline is now:

User -> selected model -> relevant memories -> response
                       \\-> memory extraction -> MemoryManager -> persistent store

The model can change without changing Eve's long-term memory.

## Configuration
Open Settings and add provider keys for the providers you want to use. Keys are stored using secure storage. An OpenAI key also enables production-grade semantic embeddings.

## Production warning
The mobile app should not ship unrestricted provider API keys. Before public release, move provider calls and key management behind a backend/ephemeral-token service.

## Validation
Run:
```bash
flutter pub get
flutter analyze
flutter test
```
