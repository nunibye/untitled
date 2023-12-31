import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/models/users.dart';
import 'package:untitled_app/views/download_page.dart';
import 'package:untitled_app/views/edit_group_page.dart';
import 'package:untitled_app/views/login.dart';
//import 'package:untitled_app/views/root_page.dart';
import 'package:untitled_app/views/sign_up.dart';
import 'package:untitled_app/views/user_settings.dart';
import '../views/compose_page.dart';
import '../views/feed_page.dart';
import '../views/search_page.dart';
import '../views/profile_page.dart';
import '../views/edit_profile.dart';
import 'router_notifier.dart';
import '../views/navigation_bar.dart';
import '../models/post_handler.dart';
import '../views/other_profile.dart';
import '../views/view_post_page.dart';
import '../views/profile_picture_detail.dart';
import '../views/welcome.dart';
import '../views/followers.dart';
import '../views/following.dart';
import '../views/recent_activity.dart';
import '../views/groups_page.dart';
import '../views/create_group_page.dart';
import '../models/group_handler.dart';
import '../custom_widgets/emoji_picker.dart';
import '../views/sub_group_page.dart';
import '../models/group_handler.dart' show Group;
import '../views/auth_action_interface.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorFeedKey = GlobalKey<NavigatorState>(debugLabel: 'Feed');
final _shellNavigatorSearchKey =
    GlobalKey<NavigatorState>(debugLabel: 'Search');
final _shellNavigatorComposeKey =
    GlobalKey<NavigatorState>(debugLabel: 'Compose');
final _shellNavigatorProfileKey =
    GlobalKey<NavigatorState>(debugLabel: 'Profile');
final _shellNavigatorGroupsKey =
    GlobalKey<NavigatorState>(debugLabel: 'Groups');
final routerNotifier = RouterNotifier();
final goRouter = GoRouter(
  refreshListenable: routerNotifier,
  redirect: routerNotifier.redirect,
  initialLocation: '/', 
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: true,
  routes: [
    // GoRoute(
    //   path: '/',
    //   builder: (context, state) {
    //     return const RootPage();
    //   },
    // ),

    GoRoute(
      path: '/profile_picture_detail',
      name: 'profile_picture_detail',
      builder: (context, state) {
        String url = state.extra as String;
        return ProfilePictureDetail(imageURL: url);
      },
    ),
    GoRoute(
      path: '/sub_profile/:id',
      // name: 'sub_profile',
      builder: (context, state) {
        AppUser? user = state.extra as AppUser?;
        String id = state.pathParameters["id"]!;
        return OtherProfile(user: user, id: id);
      },
      // routes: [
      //   GoRoute(
      //     path: 'post/:id',
      //     name: 'post_screen',
      //     builder: (context, state) {
      //       Post? post = state.extra as Post?;
      //       String id = state.pathParameters["id"]!;
      //       return ViewPostPage(post: post, id: id);
      //     },
      //   ),
      // ],
    ),

    GoRoute(
        path: '/',
        builder: (context, state) {
          return const WelcomePage();
        },
        routes: [
          GoRoute(
            path: 'signup',
            builder: (context, state) {
              return const SignUp();
            },
          ),
          GoRoute(
            path: 'auth',
            builder: (context, state) {
              final url = state.uri.queryParameters;
              
              return AuthActionInterface(urlData: url);
            },
          ),
          GoRoute(
            path: 'login',
            builder: (context, state) {
              return const LoginPage();
            },
          ),
          GoRoute(
            path: 'download',
            builder: (context, state) {
              return const DownloadPage();
            },
          ),
        ]),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorFeedKey,
          routes: [
            GoRoute(
              path: '/feed',
              name: 'feed',
              pageBuilder: (context, state) {
                bool? reload = state.extra as bool?;
                return NoTransitionPage(
                  child: reload == null
                      ? const FeedPage()
                      : FeedPage(
                          rebuild: reload,
                        ),
                );
              },
              routes: [
                GoRoute(
                  path: 'recent',
                  //name: 'recent',
                  //name: 'post_screen',
                  builder: (context, state) {
                    return const RecentActivity();
                  },
                ),
                GoRoute(
                  path: 'post/:id',
                  //name: 'post_screen',
                  builder: (context, state) {
                    Post? post = state.extra as Post?;
                    String id = state.pathParameters["id"]!;
                    return ViewPostPage(post: post, id: id);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorGroupsKey,
          routes: [
            GoRoute(
              path: '/groups',
              name: 'groups',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: GroupsPage(),
              ),
              routes: [
                GoRoute(
                    path: 'sub_group/:id',
                    name: 'sub_group',
                    builder: (context, state) {
                      Group? group = state.extra as Group?;
                      String id = state.pathParameters["id"]!;
                      return SubGroupPage(group: group, id: id);
                    },
                    routes: [
                      GoRoute(
                          path: 'edit_group',
                          name: 'edit_group',
                          pageBuilder: (context, state) {
                            Group? group = state.extra as Group;
                            return NoTransitionPage(
                              child: EditGroupPage(group: group),
                            );
                          }),
                    ]),
                GoRoute(
                  path: 'create_group',
                  name: 'create_group',
                  builder: (context, state) => const CreateGroupPage(),
                  routes: [
                    GoRoute(
                      path: 'pick_emoji',
                      name: 'pick_emoji',
                      pageBuilder: (context, state) {
                        return NoTransitionPage(
                          child: EmojiSelector(
                              onPressed: state.extra! as void Function(String)),
                        );
                      },
                      //builder: (context, state) => EmojiSelector(onPressed: state.extra! as void Function(String)),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorComposeKey,
          routes: [
            GoRoute(
              path: '/compose',
              name: 'compose',
              pageBuilder: (context, state) {
                final Group? group = state.extra as Group?;
                //if (args != null) print(args[0]);
                return NoTransitionPage(
                  child: ComposePage(group: group),
                );
              },
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorSearchKey,
          routes: [
            GoRoute(
              path: '/search',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SearchPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorProfileKey,
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProfilePage(),
              ),
              routes: [
                // GoRoute(
                //   path: 'post/:id',
                //   //name: 'post_screen',
                //   builder: (context, state) {
                //     Post? post = state.extra as Post?;
                //     String id = state.pathParameters["id"]!;
                //     return ViewPostPage(post: post, id: id);
                //   },
                // ),
                GoRoute(
                  path: 'edit_profile',
                  name: 'edit_profile',
                  builder: (context, state) => const EditProfile(),
                ),
                GoRoute(
                  path: 'user_settings',
                  name: 'user_settings',
                  builder: (context, state) => const UserSettings(),
                ),
                GoRoute(
                    path: 'followers',
                    name: 'followers',
                    builder: (context, state) {
                      AppUser user = state.extra as AppUser;
                      return Followers(user: user);
                    }),
                GoRoute(
                    path: 'following',
                    name: 'following',
                    builder: (context, state) {
                      AppUser user = state.extra as AppUser;
                      return Following(user: user);
                    }),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
