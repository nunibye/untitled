import 'package:cloud_firestore/cloud_firestore.dart';
import '../custom_widgets/controllers/pagination_controller.dart'
    show PaginationGetterReturn;
import 'package:firebase_auth/firebase_auth.dart';
import '../utilities/constants.dart' as c;

class Group {
  final String id;
  final String name;
  final String description;
  final String lastActivity;
  final String createdOn;
  final String icon;
  final List<String> members;
  final List<String> invitees;

  Group({
    this.id = "",
    required this.createdOn,
    required this.name,
    required this.lastActivity,
    required this.icon,
    required this.invitees,
    required this.members,
    required this.description,
  });
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map["name"] = name;
    map["lastActivity"] = lastActivity;
    map["invitees"] = invitees;
    map["members"] = members;
    map["description"] = description;
    map["icon"] = icon;
    map["createdOn"] = createdOn;
    return map;
  }

  static Group fromJson(Map<String, dynamic> json, String id) {
    return Group(
        createdOn: json["createdOn"],
        name: json["name"],
        lastActivity: json["lastActivity"],
        icon: json["icon"],
        invitees: json["invitees"].cast<String>(),
        members: json["members"].cast<String>(),
        description: json["description"],
        id: id);
  }
}

class GroupHandler {
  void createGroup(Group group) async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('groups').add(group.toMap());
  }

  Future<PaginationGetterReturn> getGroups(dynamic time) async {
    final user = FirebaseAuth.instance.currentUser!.uid;
    final query = FirebaseFirestore.instance
        .collection('groups')
        .where("members", arrayContains: user)
        .orderBy('lastActivity', descending: true);
    //.where("author", isEqualTo: user)

    late QuerySnapshot<Map<String, dynamic>> snapshot;
    if (time == null) {
      //initial data
      snapshot = await query.limit(c.postsOnRefresh).get();
    } else {
      snapshot = await query.startAfter([time]).limit(c.postsOnRefresh).get();
    }
    final postList = snapshot.docs.map<Group>((doc) {
      var data = doc.data();

      return Group.fromJson(data, doc.id);
    }).toList();
    return PaginationGetterReturn(
        end: (postList.length < c.postsOnRefresh), payload: postList);
  }
}
