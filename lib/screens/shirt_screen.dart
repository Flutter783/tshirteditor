import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tshirteditor/providers/shirt_provider.dart';
import 'package:tshirteditor/screens/editor_screen.dart';
import 'package:tshirteditor/service/app_color.dart';
import '../internet_checker.dart';
import '../widgets/shimmer_widget.dart';

class ShirtScreen extends StatefulWidget {
  final bool isEditorScreen;
  const ShirtScreen({super.key, required this.isEditorScreen});

  @override
  State<ShirtScreen> createState() => _ShirtScreenState();
}

class _ShirtScreenState extends State<ShirtScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ShirtProvider>(context, listen: false);
      if (provider.fetchStatus == FetchShirtStatus.init ||
          provider.fetchStatus == FetchShirtStatus.error) {
        provider.fetchShirts();
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
              child: Consumer<ShirtProvider>(
                builder: (context, provider, child) {
                  switch (provider.fetchStatus) {
                    case FetchShirtStatus.fetching:
                      return buildShirtShimmer();
                    case FetchShirtStatus.success:
                      return _buildDesignGrid(context);
                    case FetchShirtStatus.error:
                      return GestureDetector(
                        onTap: () async {
                          await provider.fetchShirts();
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
          ],
        ),
      ),
    );
  }

  Widget _buildDesignGrid(BuildContext context) {
    return Consumer<ShirtProvider>(
      builder: (context, designProvider, child) {
        return designProvider.shirtModel.isNotEmpty
            ? Padding(
          padding:
          const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: RefreshIndicator(
            onRefresh: () async {
              await designProvider.fetchShirts();
            },
            child: ListView.builder(itemBuilder: (context, index) {
              return Card(
                elevation: 3,
                color: AppColors.appColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)
                ),
                child: Column(
                  children: [
                    Container(
                      height: 300,
                      width: double.infinity,
                      margin: const EdgeInsets.only(left: 10,right: 10,top: 20),
                      child: CachedNetworkImage(
                        imageUrl: designProvider
                            .shirtModel[index].shirtImage,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => Center(
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
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: (){
                          String shirtLink=designProvider.shirtModel[index].shirtImage;
                          if(widget.isEditorScreen){
                            Navigator.pop(context, shirtLink);
                          }else{
                            Navigator.push(context, MaterialPageRoute(builder: (context) => EditorScreen(shirtLink: shirtLink)));
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30)
                          ),
                          child: Text('Edit Design',style: TextStyle(color: AppColors.appColor,fontSize: 14,fontWeight: FontWeight.bold)),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },itemCount: designProvider.shirtModel.length),
          ),
        )
            : GestureDetector(
          onTap: () async {
            if (isInternetConnected) {
              await designProvider.fetchShirts();
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
      },
    );
  }
}
