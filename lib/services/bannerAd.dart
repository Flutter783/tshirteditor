import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tshirteditor/constants/assets.dart';
import '../service/app_color.dart';


class BannerAdWidget extends StatefulWidget {
  final double width;
  final int maxHeight;

  BannerAdWidget({required this.width, required this.maxHeight});

  @override
  _BannerAdWidgetState createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _inlineAdaptiveAd;
  bool isBannerAdLoaded = false;
  AdSize? _adSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBannerAd();
  }

  Future<void> _loadBannerAd() async {

    await _inlineAdaptiveAd?.dispose();
    setState(() {
      _inlineAdaptiveAd = null;
      isBannerAdLoaded = false;
    });

    AdSize size = AdSize.getInlineAdaptiveBannerAdSize(
      widget.width.truncate(),
      widget.maxHeight,
    );

    _inlineAdaptiveAd = BannerAd(
      adUnitId: AdsAssets.bannerAd,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) async {
          final BannerAd bannerAd = (ad as BannerAd);
          final AdSize? size = await bannerAd.getPlatformAdSize();
          if (size == null) {
            return;
          }

          setState(() {
            _inlineAdaptiveAd = bannerAd;
            isBannerAdLoaded = true;
            _adSize = size;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        },
      ),
    );
    await _inlineAdaptiveAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    return isBannerAdLoaded && _inlineAdaptiveAd != null && _adSize != null
        ? SizedBox(
      width: widget.width,
      height: _adSize!.height.toDouble(),
      child: AdWidget(ad: _inlineAdaptiveAd!),
    )
        : Container(
      width: widget.width,
      height: widget.maxHeight.toDouble(),
      margin: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Ad Loading..',
            style: TextStyle(
              color: AppColors.appColor,
              fontSize: MediaQuery.of(context).size.width * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.width * 0.03),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.1),
            child: LinearProgressIndicator(
              backgroundColor: Colors.grey[300],
              color: AppColors.appColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _inlineAdaptiveAd?.dispose();
    super.dispose();
  }
}
