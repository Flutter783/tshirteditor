import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tshirteditor/constants/assets.dart';

class AppOpenAdManager {
  bool isFirstTime=true;
  AppOpenAd? _appOpenAd;
  bool _isAdAvailable = false;

  void loadAd() {
    if(isFirstTime){
      AppOpenAd.load(
        adUnitId: AdsAssets.appOpenAd,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _appOpenAd = ad;
            _isAdAvailable = true;
            debugPrint("App Open Ad Loaded");
            showAdIfAvailable();
          },
          onAdFailedToLoad: (error) {
            debugPrint("Failed to load App Open Ad: $error");
          },
        ),
      );
    }

  }


  void showAdIfAvailable() {
    if (_isAdAvailable && _appOpenAd != null) {
      _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          debugPrint("App Open Ad dismissed");
          _appOpenAd = null;
          _isAdAvailable = false;
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint("Failed to show App Open Ad: $error");
          _appOpenAd = null;
          _isAdAvailable = false;
          loadAd(); // Try loading a new ad
        },
      );

      _appOpenAd!.show();
      _appOpenAd = null;
      _isAdAvailable = false;
    } else {
      debugPrint("App Open Ad not ready to show.");
    }
  }
}
