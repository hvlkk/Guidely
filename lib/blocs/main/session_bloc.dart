import 'package:guidely/models/entities/session.dart';
import 'package:guidely/services/business_layer/session_service.dart';
import 'package:guidely/services/business_layer/tour_service.dart';

class SessionBloc {
  endSession(String sessionId, String tourId) {
    _updateSessionState(sessionId, SessionStatus.completed);
    TourService.updateTourData(tourId, {'state': 'past'});
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
