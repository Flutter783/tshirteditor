import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:tshirteditor/providers/design_provider.dart';
import 'package:tshirteditor/screens/design_detail_screen.dart';

import '../internet_checker.dart';
import '../service/app_color.dart';
import '../widgets/shimmer_widget.dart';

class DesignScreen extends StatefulWidget {
  const DesignScreen({super.key});

  @override
  State<DesignScreen> createState() => _DesignScreenState();
}

class _DesignScreenState extends State<DesignScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DesignProvider>(context, listen: false);
      if (provider.fetchStatus == FetchDesignStatus.init ||
          provider.fetchStatus == FetchDesignStatus.error) {
        provider.fetchDesignList();
      }
    });
  }

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
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Colors.black, size: 30)),
                  const Text('Shirt Ideas',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: Card(
                elevation: 3,
                clipBehavior: Clip.hardEdge,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 26),
                color: AppColors.appColor,
                child: Consumer<DesignProvider>(
                  builder: (context, provider, child) {
                    switch (provider.fetchStatus) {
                      case FetchDesignStatus.fetching:
                        return buildDesignShimmer();
                      case FetchDesignStatus.success:
                        return _buildDesignGrid(context);
                      case FetchDesignStatus.error:
                        return GestureDetector(
                          onTap: () async {
                            await provider.fetchDesignList();
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
                                        isInternetConnected
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesignGrid(BuildContext context) {
    return Consumer<DesignProvider>(
      builder: (context, designProvider, child) {
        return designProvider.designModel.isNotEmpty
            ? Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 22, horizontal: 8),
                child: RefreshIndicator(
                  onRefresh: () async {
                    await designProvider.fetchDesignList();
                  },
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1),
                    itemCount: designProvider.designModel.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          String designId =
                              designProvider.designModel[index].designId;
                          String designLink =
                              designProvider.designModel[index].designImage;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DesignDetailScreen(
                                      designLink: designLink,
                                      designId: designId)));
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                    color: AppColors.appColor,
                                    borderRadius: BorderRadius.circular(15)),
                                child: CachedNetworkImage(
                                  imageUrl: designProvider
                                      .designModel[index].designImage,
                                  fit: BoxFit.cover,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          Center(
                                    child: SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: CircularProgressIndicator(
                                          color: Colors.white,
                                          value: downloadProgress.progress),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                )),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                  width: 30,
                                  height: 30,
                                  padding: const EdgeInsets.all(7),
                                  margin: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle),
                                  clipBehavior: Clip.hardEdge,
                                  child: SvgPicture.asset(
                                      'assets/images/ic_expand.svg')),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(20),
                child: GestureDetector(
                  onTap: () async {
                    if (isInternetConnected) {
                      await designProvider.fetchDesignList();
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
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 14))),
                      ],
                    ),
                  ),
                ),
              );
      },
    );
  }
}
