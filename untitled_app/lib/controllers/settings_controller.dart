import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled_app/models/current_user.dart';
import 'package:untitled_app/utilities/locator.dart';
import '../utilities/themes/dark_theme_provider.dart';
import '../controllers/bottom_nav_bar_controller.dart';
import 'package:go_router/go_router.dart';
import '../custom_widgets/warning_dialog.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';

class SettingsController extends ChangeNotifier {
  final BuildContext context;

  SettingsController({
    required this.context,
  });

  bool getValue() {
    final themeChange = Provider.of<DarkThemeProvider>(context, listen: false);
    return themeChange.darkTheme;
  }

  changeValue(value) {
    final themeChange = Provider.of<DarkThemeProvider>(context, listen: false);
    themeChange.darkTheme = value;
  }

  void _pop() {
    context.pop();
  }

  void _delete() {
    _pop();
    locator<CurrentUser>().deleteAccount();
    locator<NavBarController>().enable();
  }

  signOut() {
    locator<CurrentUser>().signOut();
    locator<NavBarController>().enable();
  }

  deleteAccount() {
    showMyDialog(
        AppLocalizations.of(context)!.deleteAcountTitle,
        AppLocalizations.of(context)!.deleteAcountBody,
        [
          AppLocalizations.of(context)!.goBack,
          AppLocalizations.of(context)!.delete
        ],
        [
          _pop,
          _delete
        ],
        context);
  }
}
