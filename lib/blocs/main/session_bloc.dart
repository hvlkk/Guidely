import 'package:guidely/models/entities/session.dart';
import 'package:guidely/services/business_layer/session_service.dart';

class SessionBloc {
  endSession(String sessionId) {
    _updateSessionState(sessionId, SessionStatus.completed);
  }

  updateSession(String sessionId, SessionStatus status) {
    _updateSessionState(sessionId, status);
  }

  _updateSessionState(String sessionId, SessionStatus status) {
    SessionService().updateSession(
      sessionId,
      {
        "status": status.toString(),
      },
    );
  }
}
