import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class FirebaseDynamicLinkService {
  static Future<String> createDynamicLink(
      String groupId, String groupName) async {
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse(
          "https://www.example.com/groupDetails?groupIdN=${groupId}_${groupName}"),
      uriPrefix: "https://transpay.page.link/",
      androidParameters:
          const AndroidParameters(packageName: "com.example.trans_pay"),
      iosParameters: const IOSParameters(bundleId: "com.example.app.ios"),
    );
    final dynamicLink =
        await FirebaseDynamicLinks.instance.buildLink(dynamicLinkParams);
    return dynamicLink.toString();
  }
}
