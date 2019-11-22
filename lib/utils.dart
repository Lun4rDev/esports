import 'package:flutter/material.dart';

// Commonly used widgets and functions in the app
class Utils {
  // Sized square image fetched from the web
  static Widget image(String url, double size) => url != null 
    ? SizedBox(width: size, height: size, child: Image.network(url),) 
    : SizedBox(width: size, height: size);

  // Loading animation
  static Widget get loadingCircle => Container(
    width: double.maxFinite,
    height: 140,
    alignment: Alignment.center,
    child: CircularProgressIndicator(strokeWidth: 1,),);

  // Placeholder box when there is no data
  static Widget nothingBox(String label) => SizedBox( 
    width: double.maxFinite,
    height: 140, 
    child: Center(child: Text(label, style: TextStyle(color: Colors.grey)),),);
}