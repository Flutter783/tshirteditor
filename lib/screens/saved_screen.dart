import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tshirteditor/screens/my_work_screen.dart';
import 'package:tshirteditor/service/app_color.dart';
import 'package:tshirteditor/sqf/favourite_shirt.dart';
import '../providers/download_provider.dart';
import '../services/ad_Server.dart';
import '../services/bannerAd.dart';
import '../sqf/sqf_database.dart';
import 'favourite_detail_screen.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  int currentIndex=0;
  List<FavouriteShirt> favouriteList=[];
  bool isFetching=true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DownloadProvider>(context, listen: false);
      provider.loadDownloadedFiles();
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
                  const Text('Saved Design',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: (){
                        setState(() {
                          currentIndex=0;
                        });
                        final provider = Provider.of<DownloadProvider>(context, listen: false);
                        provider.loadDownloadedFiles();
                      },
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: currentIndex == 0 ? AppColors.appColor : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.fromBorderSide(BorderSide(color: AppColors.appColor,width: 1))
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              margin: const EdgeInsets.only(right: 15),
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.fromBorderSide(BorderSide(color: currentIndex == 0 ? Colors.white : AppColors.appColor,width: 1)),
                                image: const DecorationImage(image: AssetImage('assets/images/img3.png'),fit: BoxFit.cover)
                              )
                            ),
                            Text('My Work',style: TextStyle(color: currentIndex==0 ? Colors.white : AppColors.appColor,fontSize: 14,fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: (){
                        setState(() {
                          currentIndex=1;
                          isFetching=true;
                        });
                        getFavouriteDesigns();
                      },
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: currentIndex == 1 ? AppColors.appColor : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.fromBorderSide(BorderSide(color: AppColors.appColor,width: 1))
                        ),
                        child: Row(
                          children: [
                            Container(
                                height: 40,
                                width: 40,
                                margin: const EdgeInsets.only(right: 15),
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.fromBorderSide(BorderSide(color: currentIndex == 1 ? Colors.white : AppColors.appColor,width: 1)),
                                    image: const DecorationImage(image: AssetImage('assets/images/img2.png'),fit: BoxFit.cover)
                                )
                            ),
                            Text('Favourite',style: TextStyle(color: currentIndex==1 ? Colors.white : AppColors.appColor,fontSize: 14,fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: currentIndex == 0 ? Consumer<DownloadProvider>(
                  builder: (context, provider, child) {
                    switch (provider.fetchStatus) {
                      case FetchDownloadStatus.fetching:
                        return const Center(
                            child: CircularProgressIndicator(color: Colors.black));
                      case FetchDownloadStatus.success:
                        return provider.downloadedFiles.isEmpty
                            ? const Center(child: Text('No downloads yet.'))
                            : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GridView.builder(
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 5,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: provider.downloadedFiles.length,
                            itemBuilder: (context, index) {
                              final file = provider.downloadedFiles[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => MyWorkScreen(shirtPath: provider.downloadedFiles[index].path, onDeleted: (){
                                    provider.loadDownloadedFiles();
                                  }),));
                                },
                                child: Card(
                                  color: Colors.white,
                                  elevation: 3,
                                  clipBehavior: Clip.hardEdge,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(10)),
                                  child: Image.file(file, fit: BoxFit.fill),
                                ),
                              );
                            },
                          ),
                        );

                      case FetchDownloadStatus.error:
                        return const Center(
                          child: Text('Permission denied'),
                        );
                      default:
                        return const Center(child: CircularProgressIndicator());
                    }
                  },
                ) : isFetching ? Center(child: SizedBox(height: 35,width: 35, child: CircularProgressIndicator(color: AppColors.appColor))) : favouriteList.isEmpty
                    ? const Center(
                    child: Text('No Favourite',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize:
                            16)))
                    : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      childAspectRatio: 1,
                    ),
                    itemCount: favouriteList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => FavouriteDetailScreen(designId: favouriteList[index].shirtId, designLink: favouriteList[index].shirtImage, onRemove: (){
                            getFavouriteDesigns();
                          })));
                        },
                        child: Card(
                          color: Colors.white,
                          elevation: 3,
                          clipBehavior: Clip.hardEdge,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(10)),
                          child: CachedNetworkImage(
                            imageUrl:favouriteList[index].shirtImage,
                            fit: BoxFit.cover,
                            progressIndicatorBuilder: (context,
                                url, downloadProgress) =>
                                Center(
                                  child: SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: CircularProgressIndicator(
                                        color: Colors.black,
                                        value: downloadProgress
                                            .progress),
                                  ),
                                ),
                            errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                          ),
                        ),
                      );
                    },
                  ),
            )),
            AdsServer().isInternetConnected
                ? BannerAdWidget(
                width: MediaQuery.of(context).size.width, maxHeight: 100)
                : Container(),
          ],
        ),
      ),
    );
  }
  void getFavouriteDesigns() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(DatabaseHelper.table);
    setState(() {
      isFetching=false;
      favouriteList = maps.map((map) => FavouriteShirt.fromMap(map)).toList();
    });
  }
}
