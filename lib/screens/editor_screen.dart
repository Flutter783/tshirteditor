import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tshirteditor/screens/final_screen.dart';
import 'package:tshirteditor/screens/logo_screen.dart';
import 'package:tshirteditor/screens/shirt_screen.dart';
import 'package:tshirteditor/service/app_color.dart';
import 'dart:typed_data';
import '../widgets/sticker_editor.dart';
import '../widgets/sticker_model.dart';
import '../widgets/text_editor.dart';
import '../widgets/text_model.dart';
import 'home_screen.dart';

class EditorScreen extends StatefulWidget {
  final String shirtLink;
  const EditorScreen({super.key, required this.shirtLink});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  late String shirtDesign;
  List<StickerModel> stickerList = [];
  Color selectedColor = AppColors.appColor;
  bool isColorEnabled = false;
  List<TextModel> textList = [];
  List<Color> colorList = [
    const Color(0xFF006EA5),
    const Color(0xFFFF0000),
    const Color(0xFF00FFFF),
    const Color(0xFF0000FF),
    const Color(0xFF00008B),
    const Color(0xFFADD8E6),
    const Color(0xFF800080),
    const Color(0xFFFFFF00),
    const Color(0xFF00FF00),
    const Color(0xFFFF00FF),
    const Color(0xFFFFC0CB),
    const Color(0xFFFFFFFF),
    const Color(0xFFC0C0C0),
    const Color(0xFF808080),
    const Color(0xFF000000),
    const Color(0xFFFFA500),
    const Color(0xFFA52A2A),
    const Color(0xFF800000),
    const Color(0xFF008000),
    const Color(0xFF808000),
    const Color(0xFF7FFFD4),
  ];
  List<String> fontList = [];
  TextModel? selectedText;
  GlobalKey repaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    fontList = getFontList();
    shirtDesign = widget.shirtLink;
    tabController = TabController(length: 4, vsync: this);
  }

  List<String> getFontList() {
    List<String> fonts = [];
    fonts.add('Default');
    for (int i = 1; i <= 76; i++) {
      fonts.add('font$i');
    }
    return fonts;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPressedDiscard,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 20),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                      onPressed: () {
                        onBackPressedDiscard();
                      },
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Colors.black, size: 30)),
                ),
              ),
              Expanded(
                  child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                    return Container(
                      clipBehavior: Clip.hardEdge,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: selectedColor,
                          borderRadius: BorderRadius.circular(30)),
                      margin: const EdgeInsets.all(20),
                      child: RepaintBoundary(
                        key: repaintKey,
                        child: Container(
                          height: constraints.maxHeight,
                          width: constraints.maxWidth,
                          padding: const EdgeInsets.all(5),
                          color: selectedColor,
                          child: Stack(
                            fit: StackFit.expand,
                            clipBehavior: Clip.hardEdge,
                            children: [
                              CachedNetworkImage(
                                imageUrl: shirtDesign,
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
                              ...stickerList.map((stickerModel) {
                                return StickerEditor(
                                  stickerModel: stickerModel,
                                  onTap: () {
                                    setState(() {
                                      if (!stickerModel.isSelected) {
                                        for (var sticker in stickerList) {
                                          sticker.isSelected = false;
                                        }
                                      }
                                      stickerModel.isSelected =
                                      !stickerModel.isSelected;
                                    });
                                  },
                                  onDelete: () {
                                    setState(() {
                                      stickerList.remove(stickerModel);
                                    });
                                  },
                                  boundWidth: constraints.maxWidth,
                                  boundHeight: constraints.maxHeight,
                                );
                              }),
                              ...textList.map((textModel) {
                                return TextEditor(
                                  textModel: textModel,
                                  onTap: () {
                                    setState(() {
                                      if (!textModel.isSelected) {
                                        clearBorder();
                                        selectedText = textModel;
                                      } else {
                                        selectedText = null;
                                      }
                                      textModel.isSelected = !textModel.isSelected;
                                    });
                                  },
                                  onDelete: () {
                                    setState(() {
                                      selectedText = null;
                                      textList.remove(textModel);
                                    });
                                  },
                                  boundWidth: constraints.maxWidth,
                                  boundHeight: constraints.maxHeight,
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  )),
              Container(
                height: 75,
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    const Align(
                        alignment: Alignment.topLeft,
                        child: Text('BG Colors',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold))),
                    Container(
                        height: 50,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: const Border.fromBorderSide(
                                BorderSide(color: Colors.grey, width: 1))),
                        child: ListView.builder(
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedColor = colorList[index];
                                    });
                                  },
                                  child: Container(
                                    height: selectedColor == colorList[index]
                                        ? 45
                                        : 35,
                                    margin: const EdgeInsets.all(0),
                                    width: selectedColor == colorList[index]
                                        ? 45
                                        : 35,
                                    decoration: BoxDecoration(
                                        color: colorList[index],
                                        border: Border.fromBorderSide(
                                            BorderSide(
                                                color: selectedColor ==
                                                        colorList[index]
                                                    ? colorList[index]
                                                    : Colors.white)),
                                        shape: BoxShape.circle),
                                  ));
                            },
                            itemCount: colorList.length,
                            scrollDirection: Axis.horizontal)),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: showBottomNavigationBar(),
        ),
      ),
    );
  }

  Widget showBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.fromBorderSide(
              BorderSide(color: Colors.grey.shade300, width: 1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                clearBorder();
              });
              selectShirt();
            },
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: SvgPicture.asset('assets/images/ic_shirt2.svg'),
                  ),
                  const SizedBox(height: 3),
                  const Text('Shirts',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold))
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                clearBorder();
              });
              pickLogo();
            },
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: SvgPicture.asset('assets/images/ic_logo.svg'),
                  ),
                  const SizedBox(height: 3),
                  const Text('Logos',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold))
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                clearBorder();
              });
              addNewText();
            },
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: SvgPicture.asset('assets/images/ic_text.svg'),
                  ),
                  const SizedBox(height: 3),
                  const Text('Text',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold))
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (selectedText != null) {
                showBottomSheetForText();
              } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Select Text')));
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Image.asset('assets/images/ic_text_edit.png',
                        color: Colors.black),
                  ),
                  const SizedBox(height: 3),
                  const Text('Edit Text',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold))
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              showProgress();
              clearBorder();
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                Uint8List shirtBytes = await captureShirtDesign();
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            FinalScreen(shirtBytes: shirtBytes)));
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: SvgPicture.asset('assets/images/ic_save.svg'),
                  ),
                  const SizedBox(height: 3),
                  const Text('Finish',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void selectShirt() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const ShirtScreen(isEditorScreen: true)),
    );
    if (result != null) {
      setState(() {
        shirtDesign = result;
      });
    }
  }

  Future<bool> onBackPressedDiscard() async {
    bool shouldDiscard = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard editing'),
            content:
                const Text('Are you sure you want to leave the editor screen?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Discard',
                    style: TextStyle(color: Colors.black)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('Continue',
                    style: TextStyle(color: Colors.black)),
              ),
            ],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ) ??
        false;

    if (shouldDiscard) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      return true;
    }
    return false;
  }

  void pickLogo() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LogoScreen()),
    );
    if (result != null) {
      setState(() {
        StickerModel newSticker = StickerModel(
          stickerUri: result,
          top: 20,
          left: 20,
        );
        stickerList.add(newSticker);
      });
    }
  }

  void clearBorder() {
    selectedText = null;
    for (var text in textList) {
      text.isSelected = false;
    }
    for (var sticker in stickerList) {
      sticker.isSelected = false;
    }
  }

  void addNewText() async {
    setState(() {
      TextModel newTextData = TextModel(
        text: 'new text',
        textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: null,
            backgroundColor: Colors.transparent),
        isSelected: true,
        textAlign: TextAlign.center,
        top: 0,
        left: 0,
      );
      textList.add(newTextData);
      selectedText = newTextData;
    });
  }

  void showBottomSheetForText() {
    var textController = TextEditingController(text: selectedText!.text);
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setModal) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10)),
                              child: TextField(
                                maxLines: 3,
                                minLines: 1,
                                controller: textController,
                                style: TextStyle(
                                    color: selectedText!.textStyle.color,
                                    fontSize: 14,
                                    fontFamily:
                                        selectedText!.textStyle.fontFamily),
                                decoration: InputDecoration(
                                    hintText: 'Enter text here..',
                                    hintStyle: TextStyle(
                                        color: Colors.black.withOpacity(0.2),
                                        fontSize: 16),
                                    enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.transparent,
                                            width: 0)),
                                    focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.transparent,
                                            width: 0))),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (textController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Invalid')));
                              } else {
                                setState(() {
                                  selectedText?.text = textController.text;
                                });
                                setModal(() {});
                                Navigator.pop(context);
                              }
                            },
                            child: Container(
                              height: 30,
                              width: 30,
                              margin: const EdgeInsets.only(left: 5, right: 5),
                              padding: const EdgeInsets.all(3),
                              child:
                                  SvgPicture.asset('assets/images/ic_done.svg'),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      TabBar(
                        dividerColor: Colors.transparent,
                        indicatorColor: Colors.white,
                        controller: tabController,
                        tabs: const [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Fonts',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Style',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Color',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('BG',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ),
                        ],
                      ),
                      Container(
                        height: 170,
                        margin: const EdgeInsets.only(top: 10),
                        child: TabBarView(
                          controller: tabController,
                          children: <Widget>[
                            GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 5,
                                      crossAxisSpacing: 5,
                                      mainAxisExtent: 80),
                              itemCount: fontList.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedText?.textStyle =
                                            selectedText!.textStyle.copyWith(
                                                fontFamily: fontList[index]);
                                      });
                                      setModal(() {});
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.fromBorderSide(
                                              BorderSide(
                                                  color: fontList[index] ==
                                                          selectedText!
                                                              .textStyle
                                                              .fontFamily
                                                      ? Colors.white
                                                      : Colors.white
                                                          .withOpacity(0.15)))),
                                      child: Center(
                                        child: Text(
                                            fontList[index] != 'Default'
                                                ? 'Font'
                                                : 'Default',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontFamily:
                                                    fontList[index] != 'Default'
                                                        ? fontList[index]
                                                        : null)),
                                      ),
                                    ));
                              },
                            ),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(width: 5),
                                    const Text('3D',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                    Expanded(
                                      child: SizedBox(
                                        height: 30,
                                        child: Slider(
                                          activeColor: Colors.white,
                                          min: 0,
                                          max: 360,
                                          label: selectedText?.valueX
                                              .round()
                                              .toString(),
                                          value: selectedText!.valueX
                                              .clamp(0, 360),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedText?.valueX = value;
                                            });
                                            setModal(() {});
                                          },
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: SizedBox(
                                        height: 30,
                                        child: Slider(
                                          activeColor: Colors.white,
                                          min: 0,
                                          max: 360,
                                          label: selectedText?.valueY
                                              .round()
                                              .toString(),
                                          value: selectedText!.valueY
                                              .clamp(0, 360),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedText?.valueY = value;
                                            });
                                            setModal(() {});
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5)
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (selectedText
                                                  ?.textStyle.fontWeight ==
                                              FontWeight.bold) {
                                            selectedText?.textStyle =
                                                selectedText!.textStyle
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.normal);
                                          } else {
                                            selectedText?.textStyle =
                                                selectedText!.textStyle
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold);
                                          }
                                        });
                                        setModal(() {});
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(top: 30),
                                        decoration: BoxDecoration(
                                            color: selectedText?.textStyle
                                                        .fontWeight ==
                                                    FontWeight.bold
                                                ? Colors.white
                                                : Colors.grey,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: const Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Icon(Icons.format_bold,
                                              color: Colors.black, size: 24),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (selectedText
                                                  ?.textStyle.fontStyle ==
                                              FontStyle.italic) {
                                            selectedText?.textStyle =
                                                selectedText!.textStyle
                                                    .copyWith(
                                                        fontStyle:
                                                            FontStyle.normal);
                                          } else {
                                            selectedText?.textStyle =
                                                selectedText!.textStyle
                                                    .copyWith(
                                                        fontStyle:
                                                            FontStyle.italic);
                                          }
                                        });
                                        setModal(() {});
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(top: 24),
                                        decoration: BoxDecoration(
                                            color: selectedText
                                                        ?.textStyle.fontStyle ==
                                                    FontStyle.italic
                                                ? Colors.white
                                                : Colors.grey,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: const Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Icon(Icons.format_italic,
                                              color: Colors.black, size: 24),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (selectedText
                                                  ?.textStyle.decoration ==
                                              TextDecoration.underline) {
                                            selectedText?.textStyle =
                                                selectedText!.textStyle
                                                    .copyWith(
                                                        decoration:
                                                            TextDecoration
                                                                .none);
                                          } else {
                                            selectedText?.textStyle =
                                                selectedText!.textStyle
                                                    .copyWith(
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        decorationColor:
                                                            selectedText!
                                                                .textStyle
                                                                .color);
                                          }
                                        });
                                        setModal(() {});
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(top: 30),
                                        decoration: BoxDecoration(
                                            color: selectedText?.textStyle
                                                        .decoration ==
                                                    TextDecoration.underline
                                                ? Colors.white
                                                : Colors.grey,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: const Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Icon(Icons.format_underline,
                                              color: Colors.black, size: 24),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Column(
                              children: [
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Text('Opacity',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 14)),
                                    Expanded(
                                      child: SizedBox(
                                        height: 50,
                                        child: Slider(
                                          activeColor: Colors.white,
                                          min: 0.0,
                                          max: 1.0,
                                          value: selectedText!
                                                  .textStyle.color?.opacity ??
                                              1.0,
                                          label: selectedText!
                                              .textStyle.color?.opacity
                                              .toStringAsFixed(2),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedText?.textStyle =
                                                  selectedText!.textStyle
                                                      .copyWith(
                                                          color: selectedText!
                                                              .textStyle.color
                                                              ?.withOpacity(
                                                                  value));
                                            });
                                            setModal(() {});
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5)
                                  ],
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 7,
                                            mainAxisSpacing: 5,
                                            crossAxisSpacing: 5,
                                            childAspectRatio: 1),
                                    itemCount: colorList.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedText?.textStyle =
                                                  selectedText!.textStyle
                                                      .copyWith(
                                                          color:
                                                              colorList[index]);
                                            });
                                            setModal(() {});
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.all(0),
                                            decoration: BoxDecoration(
                                                color: colorList[index],
                                                border: Border.fromBorderSide(
                                                    BorderSide(
                                                        color: selectedText
                                                                    ?.textStyle
                                                                    .color ==
                                                                colorList[index]
                                                            ? Colors.white
                                                            : Colors
                                                                .grey.shade700,
                                                        width: 1)),
                                                shape: BoxShape.circle),
                                          ));
                                    },
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Text('Opacity',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 14)),
                                    Expanded(
                                      child: SizedBox(
                                        height: 50,
                                        child: Slider(
                                          activeColor: Colors.white,
                                          min: 0.0,
                                          max: 1.0,
                                          value: selectedText!.textStyle
                                                  .backgroundColor?.opacity ??
                                              1.0,
                                          label: selectedText!.textStyle
                                              .backgroundColor?.opacity
                                              .toStringAsFixed(2),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedText?.textStyle =
                                                  selectedText!
                                                      .textStyle
                                                      .copyWith(
                                                          backgroundColor:
                                                              selectedText!
                                                                  .textStyle
                                                                  .backgroundColor
                                                                  ?.withOpacity(
                                                                      value));
                                            });
                                            setModal(() {});
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5)
                                  ],
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 7,
                                            mainAxisSpacing: 5,
                                            crossAxisSpacing: 5,
                                            childAspectRatio: 1),
                                    itemCount: colorList.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedText?.textStyle =
                                                  selectedText!.textStyle
                                                      .copyWith(
                                                          backgroundColor:
                                                              colorList[index]);
                                            });
                                            setModal(() {});
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.all(0),
                                            decoration: BoxDecoration(
                                                color: colorList[index],
                                                border: Border.fromBorderSide(
                                                    BorderSide(
                                                        color: selectedText
                                                                    ?.textStyle
                                                                    .backgroundColor ==
                                                                colorList[index]
                                                            ? Colors.white
                                                            : Colors
                                                                .grey.shade700,
                                                        width: 1)),
                                                shape: BoxShape.circle),
                                          ));
                                    },
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  Future<Uint8List> captureShirtDesign() async {
    RenderRepaintBoundary boundary =
        repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  void showProgress() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.appColor),
                const SizedBox(height: 20),
                Text('Processing..',
                    style: TextStyle(color: AppColors.appColor, fontSize: 14)),
              ],
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
    );
  }
}
