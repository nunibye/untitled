import 'package:flutter/material.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/models/users.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/current_user.dart';
import '../utilities/locator.dart';
import 'profile_picture_loading.dart';
import 'package:provider/provider.dart';
import 'controllers/searched_user_controller.dart';
import '../custom_widgets/profile_avatar.dart';
import '../utilities/constants.dart' as c;

Widget searchPageBuilder(dynamic user) {
  return UserCard(user: user);
}

class UserCard extends StatelessWidget {
  final bool? initialBool;
  final AppUser user;
  final bool groupSearch;
  final bool tagSearch;
  final Function(String)? onCardTap;
  final void Function(AppUser, bool)? adder;
  const UserCard(
      {super.key,
      required this.user,
      this.groupSearch = false,
      this.tagSearch = false,
      this.onCardTap,
      this.adder,
      this.initialBool});

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;
    return ChangeNotifierProvider.value(
        value: SearchedUserController(
            user: user,
            context: context,
            groupSearch: groupSearch,
            adder: adder,
            initialBool: initialBool),
        builder: (context, child) {
          return InkWell(
            onTap: () {
              if (groupSearch) {
                Provider.of<SearchedUserController>(context, listen: false)
                    .onAddPressed();
              } else if (tagSearch) {
                onCardTap!(user.username);
              } else {
                Provider.of<SearchedUserController>(context, listen: false)
                    .onCardPressed();
              }
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: height * 0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ProfileAvatar(
                          url: user.profilePicture, size: width * 0.115),
                      Padding(
                        padding: EdgeInsets.all(width * 0.02),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (user.name != "")
                              Text(user.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            Text("@${user.username}")
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (user.uid == locator<CurrentUser>().getUID())
                    Container()
                  else if (groupSearch)
                    Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Provider.of<SearchedUserController>(context,
                                    listen: true)
                                .added
                            ? const Icon(Icons.check_circle)
                            : const Icon(Icons.circle_outlined))
                  else if (tagSearch)
                    Container()
                  else
                    SizedBox(
                      width: 120, //FIXME make dynamic
                      height: 35,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          side: BorderSide.none,
                          backgroundColor: Provider.of<SearchedUserController>(
                                      context,
                                      listen: true)
                                  .following
                              ? Theme.of(context).colorScheme.surface
                              : Theme.of(context).colorScheme.primaryContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () => Provider.of<SearchedUserController>(
                                context,
                                listen: false)
                            .onFollowPressed(),
                        child: Text(
                          Provider.of<SearchedUserController>(context,
                                      listen: true)
                                  .following
                              ? AppLocalizations.of(context)!.following
                              : AppLocalizations.of(context)!.follow,
                          style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 1,
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        });
  }
}
