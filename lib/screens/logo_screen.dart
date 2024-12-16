import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tshirteditor/providers/logo_provider.dart';
import 'package:tshirteditor/service/app_color.dart';
import '../services/ad_Server.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';


class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key});

  @override
  State<LogoScreen> createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<LogoProvider>(context, listen: false);
      if (provider.fetchStatus == FetchLogoStatus.init ||
          provider.fetchStatus == FetchLogoStatus.error) {
        provider.fetchLogo();
      }
    });
  }
  final AdsServer adsServer = AdsServer();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 10),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        adsServer.showInterstitialIfAvailable(true, onActionDone: (){
                          Navigator.pop(context);
                        });
                      },
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Colors.black, size: 30)),
                  const Text('Select Logo',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: Consumer<LogoProvider>(
                builder: (context, provider, child) {
                  switch (provider.fetchStatus) {
                    case FetchLogoStatus.fetching:
                      return Center(child: SizedBox(height: 30,width: 30,child: CircularProgressIndicator(color: AppColors.appColor)));
                    case FetchLogoStatus.success:
                      return _buildDesignGrid(context);
                    case FetchLogoStatus.error:
                      return GestureDetector(
                        onTap: () async {
                          await provider.fetchLogo();
                        },
                        child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Align(
                                  alignment: Alignment.center,
                                  child: Text('Tap to refresh',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold))),
                              const SizedBox(height: 20),
                              Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                      AdsServer().isInternetConnected
                                          ? 'Server not response'
                                          : 'No internet connection',
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 12))),
                            ],
                          ),
                        ),
                      );
                    default:
                      return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesignGrid(BuildContext context) {
    return Consumer<LogoProvider>(
      builder: (context, provider, child) {
        if (provider.logoModel.isNotEmpty) {
          return Padding(
          padding: const EdgeInsets.all(10),
          child: RefreshIndicator(
            onRefresh: () async {
              await provider.fetchLogo();
            },
            child: MasonryGridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              itemCount: provider.logoModel.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    adsServer.showInterstitialIfAvailable(true, onActionDone: (){
                      Navigator.pop(
                          context,
                          provider
                              .logoModel[index].logoImage);
                    });
                  },
                  child: Card(
                    margin: const EdgeInsets.all(0),
                    elevation: 3,
                    color: Colors.white,
                    clipBehavior: Clip.hardEdge,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CachedNetworkImage(
                        cacheManager: CustomCacheManager.instance,
                        imageUrl:
                        provider.logoModel[index].logoImage,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: double.infinity,
                            height: 100,
                            color: Colors.white,
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
        } else {
          return GestureDetector(
          onTap: () async {
            if (AdsServer().isInternetConnected) {
              await provider.fetchLogo();
            }
          },
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.white,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                    alignment: Alignment.center,
                    child: Text('Tap for refresh',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold))),
                SizedBox(height: 20),
                Align(
                    alignment: Alignment.center,
                    child: Text('No any design',
                        style:
                        TextStyle(color: Colors.grey, fontSize: 14))),
              ],
            ),
          ),
        );
        }
      },
    );
  }
}
class CustomCacheManager {
  static const key = 'customCache';

  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 15), // Adjust based on your needs
      maxNrOfCacheObjects: 100, // Adjust max number of files in cache
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
}

