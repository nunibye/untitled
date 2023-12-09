import 'package:flutter/material.dart';
import 'package:untitled_app/utilities/locator.dart';
import '../utilities/constants.dart' as c;
import '../models/users.dart';
import 'dart:async';
import '../models/search_model.dart';
import 'package:go_router/go_router.dart';
import '../models/group_handler.dart';
import '../models/current_user.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import '../custom_widgets/warning_dialog.dart';

class CreateGroupPageController extends ChangeNotifier {
  String icon = "";
  final nameController = TextEditingController();
  final nameFocus = FocusNode();
  final descriptionController = TextEditingController();
  final searchTextController = TextEditingController();
  final PageController pageController = PageController();
  final selectedPeopleScroll = ScrollController();
  List<AppUser> selectedPeople = [];
  List<AppUser> hits = [];
  bool isLoading = false;
  bool showEmojiKeyboard = false;
  Timer? _debounce;
  int? selectedToDelete;
  BuildContext context;
  bool canSwipe = false;

  CreateGroupPageController({required this.context});
  void goForward() {
    if (nameController.text.length < c.minGroupName) {
      nameFocus.requestFocus();
      //FIXME show pop up
    } else {
      hideKeyboard();
      pageController.nextPage(
          duration: const Duration(milliseconds: c.signUpAnimationDuration),
          curve: Curves.decelerate);
    }
  }

  void _pop() {
    context.pop();
  }

  void updateCanSwipe() {
    if (nameController.text.length < c.minGroupName) {
      if (canSwipe) {
        canSwipe = false;
        notifyListeners();
      }
    } else {
      if (!canSwipe) {
        canSwipe = true;
        notifyListeners();
      }
    }
  }

  void _popTwice() {
    _pop();
    _pop();
  }

  Future<bool> exitPressed() async {
    if (selectedPeople.isEmpty &&
        icon == "" &&
        nameController.text == "" &&
        descriptionController.text == "") {
      _pop();
    } else {
      showMyDialog(
          AppLocalizations.of(context)!.exitEditProfileTitle,
          AppLocalizations.of(context)!.exitEditProfileBody,
          [
            AppLocalizations.of(context)!.exit,
            AppLocalizations.of(context)!.stay
          ],
          [_popTwice, _pop],
          context);
    }
    return false;
  }

  void goBack() {
    hideKeyboard();
    pageController.previousPage(
        duration: const Duration(milliseconds: c.signUpAnimationDuration),
        curve: Curves.decelerate);
  }

  void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void onSearchTextChanged(String s) async {
    if (s == '') {
      hits = [];

      isLoading = false;
      notifyListeners();
    } else {
      isLoading = true;
      notifyListeners();
    }
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce =
        Timer(const Duration(milliseconds: c.searchPageDebounce), () async {
      if (s != '') {
        hits = await SearchModel().hitsQuery(s);
        hits.removeWhere(
            (element) => element.uid == locator<CurrentUser>().getUID());
        isLoading = false;
        notifyListeners();
      }
    });
  }

  bool isUserSelected(AppUser user) {
    for (AppUser slectedUser in selectedPeople) {
      if (user.uid == slectedUser.uid) {
        return true;
      }
    }
    return false;
  }

  void addRemovePersonToList(AppUser user, bool add) {
    if (add) {
      selectedPeople.add(user);
      Timer(const Duration(milliseconds: 50), () {
        selectedPeopleScroll.animateTo(
          selectedPeopleScroll.position.maxScrollExtent,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 200),
        );
      });
    } else {
      selectedPeople.removeWhere((element) => element.uid == user.uid);
    }

    notifyListeners();
  }

  void setSelectedToDelete(int index) {
    if (index == selectedToDelete) {
      selectedPeople
          .removeWhere((element) => element.uid == selectedPeople[index].uid);
      selectedToDelete = null;
    } else {
      selectedToDelete = index;
    }
    notifyListeners();
  }

  void createGroup() {
    context.pop();
    final newGroup = Group(
        icon: icon,
        description: descriptionController.text,
        name: nameController.text,
        lastActivity: DateTime.now().toUtc().toIso8601String(),
        owner: locator<CurrentUser>().getUID(),
        invitees: selectedPeople.map((e) => e.uid).toList(),
        members: []);
    GroupHandler().createGroup(newGroup);
  }

  void pickEmoji() async {
    final returnedString =
        ((await context.pushNamed("pick_emoji")) ?? "").toString();
    if (returnedString != "") icon = returnedString;
    notifyListeners();
  }

  void clearIcon() {
    icon = "";
    notifyListeners();
  }
}
