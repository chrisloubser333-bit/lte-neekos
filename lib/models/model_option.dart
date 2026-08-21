class ModelOption {
  final String id;
  final String name;
  final String description;

  const ModelOption({
    required this.id,
    required this.name,
    required this.description,
  });

  static const defaults = [
    ModelOption(
      id: 'grok-4.5',
      name: 'Grok 4.6',
      description: 'Best overall reasoning and conversation',
    ),
    ModelOption(
      id: 'grok-4.1-fast',
      name: 'Grok Fast',
      description: 'Lower latency for quick conversations',
    ),
  ];
}
