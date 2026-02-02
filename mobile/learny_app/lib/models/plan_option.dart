class PlanOption {
  const PlanOption({
    required this.id,
    required this.name,
    required this.priceLabel,
    required this.description,
    required this.isHighlighted,
  });

  final String id;
  final String name;
  final String priceLabel;
  final String description;
  final bool isHighlighted;
}
