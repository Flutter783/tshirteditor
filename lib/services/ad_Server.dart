import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:tshirteditor/constants/assets.dart';



class AdsServer {
  static final AdsServer _instance = AdsServer._internal();
  factory AdsServer() {
    return _instance;
  }
  AdsServer._internal();
  InterstitialAd? interstitialAd;
  int clickCounter = 0;
  int maxClicksBeforeAd = 3;
  bool isInternetConnected=false;
  bool requestToLoadInterstitial=false;

  Future<void> checkInternet() async {
    isInternetConnected = await InternetConnectionChecker().hasConnection;
    if(!requestToLoadInterstitial && isInternetConnected){
      loadInterstitialAd();
      requestToLoadInterstitial=true;
    }
    Timer(const Duration(seconds: 1), checkInternet);

  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdsAssets.interstitialAd,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          interstitialAd = null;
          requestToLoadInterstitial=false;
        },
      ),
    );
  }
  void showInterstitialIfAvailable(bool clickCount, {Function? onActionDone}) {
    if(!clickCount){
      clickCounter=0;
    }
    if (interstitialAd != null) {
      if (clickCounter == 0) {
        interstitialAd!.show();
        interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (InterstitialAd ad) {
            ad.dispose();
            clickCounter++;
            interstitialAd = null;
            requestToLoadInterstitial=false;
            onActionDone?.call();
          },
          onAdFailedToShowFullScreenContent:
              (InterstitialAd ad, AdError error) {
            ad.dispose();
            interstitialAd = null;
            requestToLoadInterstitial=false;

          },
        );
      } else if (clickCounter >= maxClicksBeforeAd) {
        clickCounter = 0;
        onActionDone?.call();
      } else {
        clickCounter++;
        onActionDone?.call();
      }
    } else {
      onActionDone?.call();
    }
  }

}