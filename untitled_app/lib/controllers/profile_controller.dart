import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/models/users.dart' show AppUser;
import '../models/current_user.dart';
import 'bottom_nav_bar_controller.dart';
import '../utilities/locator.dart';

class ProfileController extends ChangeNotifier {
  //int likes = locator<CurrentUser>().likes;
  //List<dynamic> followers = locator<CurrentUser>().followers;
  //List<dynamic> following = locator<CurrentUser>().following;
  //String username = locator<CurrentUser>().username;
  //String profileImage = locator<CurrentUser>().profilePicture;
  //String name = locator<CurrentUser>().name;

  //String profileBio = locator<CurrentUser>().bio;

  final BuildContext context;
  late AppUser user;

  ProfileController({
    required this.context,
  }) {
    initUser();
  }
  onPageRefresh() {
    loadUserData();
  }

//FIXME maybe move to a standard class format for more reusablity
  initUser() {
    user = AppUser(
      uid: locator<CurrentUser>().uid,
      name: locator<CurrentUser>().name,
      username: locator<CurrentUser>().username,
      profilePicture: locator<CurrentUser>().profilePicture,
      bio: locator<CurrentUser>().bio,
      likes: locator<CurrentUser>().likes,
      followers: locator<CurrentUser>().followers,
      following: locator<CurrentUser>().following,
    );
  }

//FIXME doesn't update
  editProfilePressed() async {
    locator<NavBarController>().disable();
    await context.push("/profile/edit_profile");

    locator<NavBarController>().enable();
    user.profilePicture = locator<CurrentUser>().profilePicture;
    user.bio = locator<CurrentUser>().bio;
    user.name = locator<CurrentUser>().name;
    user.username = locator<CurrentUser>().username;
    notifyListeners();
  }

  settingsButtonPressed() async {
    locator<NavBarController>().disable();
    await context.push('/profile/user_settings');
    locator<NavBarController>().enable();
  }

  String getUID() {
    return locator<CurrentUser>().getUID();
  }

  void loadUserData() async {
    await locator<CurrentUser>().readCurrentUserData();
    // likes = locator<CurrentUser>().likes;
    // followers = locator<CurrentUser>().followers;
    // following = locator<CurrentUser>().following;
    // username = locator<CurrentUser>().username;
    // profileImage = locator<CurrentUser>().profilePicture;
    // profileBio = locator<CurrentUser>().bio;
    initUser();
    //print(username);
    notifyListeners();
  }
}
