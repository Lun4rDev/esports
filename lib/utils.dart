import 'package:esports/localizations.dart';
import 'package:flutter/material.dart';

// i18n String getter
  String str(BuildContext context, String key) => EsportsLocalizations.of(context).get(key);

  // Sized square image fetched from the web
  Widget image(String url, double size) => url != null 
    ? SizedBox(width: size, height: size, child: Image.network(url),) 
    : SizedBox(width: size, height: size);

  // Loading animation
  Widget get loadingCircle => Container(
    width: double.maxFinite,
    height: 140,
    alignment: Alignment.center,
    child: CircularProgressIndicator(strokeWidth: 1,),);

  // Placeholder widget when there is no data to be shown
  Widget nothingBox(String label) => SizedBox( 
    width: double.maxFinite,
    height: 140, 
    child: Center(
      child: Text(
        label, 
        style: TextStyle(
          fontSize: 20,
          color: Colors.grey)),),);
// Commonly used widgets and functions in the app
class Utils {

  
}