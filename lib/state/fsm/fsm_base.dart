/// Base FSM (Finite State Machine) Framework
///
/// This provides a type-safe, predictable state management system where:
/// - States and transitions are explicit
/// - Invalid transitions are prevented at compile time
/// - Global actions (reset, logout) work from any state
/// - Easy to visualize and discuss with stakeholders

/// Base class for all FSM states
abstract class FsmState {
  const FsmState();

  /// Human-readable name for debugging/logging
  String get name;

  /// Whether this is a terminal state (no further transitions possible)
  bool get isTerminal => false;

  /// Whether this is an error state
  bool get isError => false;

  /// Whether this is a loading/transitioning state
  bool get isTransitioning => false;
}

/// Base class for FSM events/actions
abstract class FsmEvent {
  const FsmEvent();

  String get name;
}

/// Global events that can be triggered from any state
abstract class GlobalFsmEvent extends FsmEvent {
  const GlobalFsmEvent();
}

/// Reset event - returns FSM to initial state
class ResetEvent extends GlobalFsmEvent {
  const ResetEvent();

  @override
  String get name => 'RESET';
}

/// Transition result
sealed class TransitionResult<S extends FsmState> {
  const TransitionResult();
}

/// Successful transition to new state
class TransitionSuccess<S extends FsmState> extends TransitionResult<S> {
  final S newState;
  final List<FsmEffect>? effects;

  const TransitionSuccess(this.newState, {this.effects});
}

/// Transition denied (guard failed)
class TransitionDenied<S extends FsmState> extends TransitionResult<S> {
  final String reason;

  const TransitionDenied(this.reason);
}

/// Transition not applicable (event not handled in current state)
class TransitionNotApplicable<S extends FsmState> extends TransitionResult<S> {
  const TransitionNotApplicable();
}

/// Side effects that should be executed after a transition
abstract class FsmEffect {
  const FsmEffect();

  String get name;
}

/// Effect to fetch data
class FetchEffect extends FsmEffect {
  final String resource;

  const FetchEffect(this.resource);

  @override
  String get name => 'FETCH:$resource';
}

/// Effect to navigate to a route
class NavigateEffect extends FsmEffect {
  final String route;

  const NavigateEffect(this.route);

  @override
  String get name => 'NAVIGATE:$route';
}

/// Effect to clear/reset data
class ClearEffect extends FsmEffect {
  final String target;

  const ClearEffect(this.target);

  @override
  String get name => 'CLEAR:$target';
}

/// Effect to show notification/alert
class NotifyEffect extends FsmEffect {
  final String message;
  final NotifyType type;

  const NotifyEffect(this.message, {this.type = NotifyType.info});

  @override
  String get name => 'NOTIFY:${type.name}';
}

enum NotifyType { info, success, warning, error }

/// Guard function type - returns null if allowed, or reason string if denied
typedef TransitionGuard<S extends FsmState, E extends FsmEvent> = String? Function(S currentState, E event);

/// Base FSM definition
abstract class FsmDefinition<S extends FsmState, E extends FsmEvent> {
  /// Initial state
  S get initialState;

  /// Handle an event and return the transition result
  TransitionResult<S> handle(S currentState, E event);

  /// Handle global events (reset, logout, etc.)
  TransitionResult<S> handleGlobal(S currentState, GlobalFsmEvent event) {
    if (event is ResetEvent) {
      return TransitionSuccess(
        initialState,
        effects: [const ClearEffect('all')],
      );
    }
    return const TransitionNotApplicable();
  }

  /// Process an event (handles both regular and global events)
  TransitionResult<S> process(S currentState, FsmEvent event) {
    if (event is GlobalFsmEvent) {
      return handleGlobal(currentState, event);
    }
    return handle(currentState, event as E);
  }
}

/// Mixin for FSM state that includes context data
mixin FsmStateData<T> on FsmState {
  T? get data;
}

/// Mixin for FSM state that includes error information
mixin FsmStateError on FsmState {
  String? get errorMessage;
  dynamic get errorData;

  @override
  bool get isError => errorMessage != null;
}
