class CoachAction {
  final String id;
  final String title;
  final String description;
  const CoachAction(this.id, this.title, this.description);
}

class CoachService {
  final List<CoachAction> _actions = const [
    CoachAction('screen_60', 'Screen off 60 mins before bed', 'Reduce blue light and cognitive arousal'),
    CoachAction('shift_-15', 'Shift bedtime -15 min', 'Nudge towards earlier sleep'),
    CoachAction('no_caffeine_20', 'No caffeine after 20:00', 'Reduce stimulant effects'),
  ];

  Future<CoachAction> pickAction({double epsilon = 0.2}) async {
    // MVP: purely random with small bias for first item as default
    final now = DateTime.now().millisecondsSinceEpoch;
    final idx = (now % 100) < (epsilon * 100) ? (now % _actions.length) : 0;
    return _actions[idx];
  }

  Future<void> logSelection(CoachAction action) async {
    // TODO: store in action_event table (MVP stub)
    return;
  }

  Future<void> logReward(CoachAction action, double reward) async {
    // TODO: update reward after next-day review (MVP stub)
    return;
  }
}
