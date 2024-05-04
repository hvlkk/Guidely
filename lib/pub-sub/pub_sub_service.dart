// Demo code for pub-sub service.
// The objective is to let hosts and participants who are interested
// in these events subscribe to the corresponding topics and receive real-time updates.
// The PubSubService class is a singleton that allows users to subscribe to topics, publish messages to topics, and unsubscribe from topics.

// Usage

// Create a new tour
// final tour = Tour('tour_1', 'Walking Tour', []);

// Create users
// final user1 = User('user_1', 'Alice');
// final user2 = User('user_2', 'Bob');

//  User1 registers for the tour
// tour.participants.add(user1);

// User2 registers for the tour
// tour.participants.add(user2);

// Subscribe users to tour announcement topic
// for (final participant in tour.participants) {
//   PubSubService().subscribe('tour_announcement_${tour.id}', do something with the user)
//   });
// }

// Organizer makes an announcement
// final organizer = TourOrganizer('organizer_1', 'Charlie');
// organizer.makeAnnouncement(tour, 'Meeting point for the tour has been changed.');

class PubSubService {
  static final PubSubService _instance = PubSubService._internal();

  factory PubSubService() {
    return _instance;
  }

  PubSubService._internal();

  final _listeners = <String, List<Function>>{};

  void subscribe(String topic, Function callback) {
    if (!_listeners.containsKey(topic)) {
      _listeners[topic] = [];
    }

    _listeners[topic]!.add(callback);
  }

  void publish(String topic, [dynamic data]) {
    if (!_listeners.containsKey(topic)) {
      return;
    }

    for (final listener in _listeners[topic]!) {
      listener(data);
    }
  }

  void unsubscribe(String topic, Function callback) {
    if (!_listeners.containsKey(topic)) {
      return;
    }

    _listeners[topic]!.remove(callback);
  }

  void unsubscribeAll(String topic) {
    if (!_listeners.containsKey(topic)) {
      return;
    }

    _listeners[topic]!.clear();
  }
}
