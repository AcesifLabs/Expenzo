/// Drops a chained future's value or error, so a serial queue built with
/// `previous = result.then(ignoreOutcome, onError: ignoreOutcome)` keeps
/// running after a failed step.
Object? ignoreOutcome([Object? _]) => null;
