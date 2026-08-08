enum ScanMode {
  freeExplore,
  experiment,
}

class ScanLaunchArgs {
  final ScanMode mode;
  final String? expectedReactionCode;

  const ScanLaunchArgs({
    this.mode = ScanMode.freeExplore,
    this.expectedReactionCode,
  });

  bool get isExperiment => mode == ScanMode.experiment;
}
