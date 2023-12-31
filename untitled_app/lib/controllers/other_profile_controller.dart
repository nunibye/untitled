import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/models/users.dart';
import '../models/current_user.dart';
import '../utilities/locator.dart';
import '../models/post_handler.dart';
import '../custom_widgets/controllers/pagination_controller.dart'
    show PaginationGetterReturn;
import '../models/feed_post_cache.dart' show Cache;

class OtherProfileController extends ChangeNotifier {
  final BuildContext context;
  final AppUser? passedUser;
  final String id;
  Cache loadedPostData = Cache(items: [], end: false);

  AppUser? loadedUser;
  late bool following;
  bool isFollowing = false;
  OtherProfileController({
    required this.context,
    required this.passedUser,
    this.loadedUser,
    required this.id,
  }) {
    _init();
  }
  void _init() async {
    if (passedUser != null) {
      loadedUser = passedUser!;
    } else {
      AppUser user = AppUser();
      await user.readUserData(id);
      loadedUser = user;
    }
    if (loadedUser!.uid == locator<CurrentUser>().getUID()) {
      context.go("/profile");
    }
    following = locator<CurrentUser>().checkIsFollowing(loadedUser!.uid);
    notifyListeners();
  }

  onFollowPressed() async {
    if ((loadedUser!.username != "") && (loadedUser!.uid != locator<CurrentUser>().uid)) {
      if (!isFollowing) {
        isFollowing = true;
        following = locator<CurrentUser>().checkIsFollowing(loadedUser!.uid);
        if (following) {
          following = false;
          loadedUser!.followers
              .remove(locator<CurrentUser>().getUID()); //subtract;
          notifyListeners();
          if (!(await locator<CurrentUser>().removeFollower(loadedUser!.uid))) {
            following = true;
            loadedUser!.followers
                .add(locator<CurrentUser>().getUID()); //subtract;
            notifyListeners();
          }
        } else {
          following = true;
          loadedUser!.followers
              .add(locator<CurrentUser>().getUID()); //subtract;
          notifyListeners();
          if (!(await locator<CurrentUser>().addFollower(loadedUser!.uid))) {
            following = false;
            loadedUser!.followers
                .remove(locator<CurrentUser>().getUID()); //subtract;
            notifyListeners();
          }
        }

        isFollowing = false;
      }
    }
  }

  dynamic getTimeFromPost(dynamic post) {
    return locator<PostsHandling>().getTimeFromPost(post);
  }

  Future<PaginationGetterReturn> getPosts(dynamic time) {
    return locator<PostsHandling>().getSubProfilePosts(time, loadedUser!);
  }

  onPageRefresh() {
    if (loadedUser != null) {
      loadedUser!.readUserData(null);
      notifyListeners();
    }
  }
}
