class NarrativeElementDraft {
  const NarrativeElementDraft({
    required this.title,
    required this.description,
    required this.photoPaths,
    this.status = 'finding',
  });

  final String title;
  final String description;
  final List<String> photoPaths;
  final String status;
}
