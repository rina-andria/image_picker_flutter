import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker_flutter/src/ImagePicker.dart';
import 'package:image_picker_flutter/src/image/AssetDataImage.dart';
import 'package:image_picker_flutter/src/model/AssetData.dart';
import 'package:image_picker_flutter/src/page/ui/ImagePickerAppBar.dart';
import 'package:image_picker_flutter/src/utils/Utils.dart';

class MulImagePickerPage extends StatefulWidget {
  final int limit;
  final List<AssetData> selectedData;
  final ImagePickerType type;
  final Widget title, back, menu;
  final Decoration decoration;
  final Color appBarColor;
  final Language language;
  final ImageProvider placeholder;

  const MulImagePickerPage({
    Key key,
    this.title,
    this.limit = 9,
    this.selectedData,
    this.type = ImagePickerType.imageAndVideo,
    this.back,
    this.menu,
    this.decoration,
    this.appBarColor = Colors.blue,
    this.language,
    this.placeholder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MulImagePickerPageState();
  }
}

class MulImagePickerPageState extends State<MulImagePickerPage> {
  final List<AssetData> _data = [];
  final List<AssetData> selectedData = [];
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    Utils.cancelAll();
    super.dispose();
  }

  @override
  void initState() {
    if (widget.selectedData != null) {
      selectedData.addAll(widget.selectedData);
    }
    Future.delayed(Duration()).whenComplete(() {
      _refreshKey.currentState.show();
    });
    super.initState();
  }

  Future<Null> _getData() async {
    final List<AssetData> data = await Utils.getImages(widget.type);
    if (mounted) {
      setState(() {
        _data
          ..clear()
          ..addAll(data);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: ImagePickerAppBar(
        context: context,
        title: widget.title,
        language: widget.language,
        back: widget.back ??
            Icon(
              Utils.back,
              color: Colors.white,
            ),
        onBackCallback: () {
          Navigator.of(context).pop();
        },
        menu: widget.menu ??
            Icon(
              Utils.save,
              color: Colors.white,
            ),
        onSaveCallback: () {
          Navigator.of(context).pop(selectedData);
        },
        decoration: widget.decoration,
        appBarColor: widget.appBarColor,
      ),
      body: RefreshIndicator(
        key: _refreshKey,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) => _createItem(_data[index]),
          itemCount: _data.length,
          padding: EdgeInsets.fromLTRB(
            8,
            8,
            8,
            8 + MediaQuery.of(context).padding.bottom,
          ),
        ),
        onRefresh: _getData,
      ),
    );
  }

  Widget _createItem(AssetData data) {
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: <Widget>[
        FadeInImage(
          placeholder: widget.placeholder ?? Utils.placeholder,
          image: AssetDataImage(data),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        RawMaterialButton(
          fillColor:
              selectedData.contains(data) ? Colors.white54 : Colors.transparent,
          constraints: BoxConstraints.expand(),
          highlightElevation: 0,
          elevation: 0,
          disabledElevation: 0,
          shape: CircleBorder(
            side: BorderSide(
              color: selectedData.contains(data)
                  ? widget.appBarColor ?? Colors.blue
                  : Colors.transparent,
              width: 4,
            ),
          ),
          onPressed: () {
            if (selectedData.contains(data)) {
              setState(() {
                selectedData.removeWhere((a) {
                  return a == data;
                });
              });
            } else {
              if (selectedData.length < widget.limit) {
                setState(() {
                  selectedData
                    ..removeWhere((a) {
                      return a == data;
                    })
                    ..add(data);
                });
              } else {
                _scaffoldKey.currentState.showSnackBar(
                  SnackBar(
                    content: Text(
                      widget.language.showToast.replaceAll(
                        "###",
                        "${widget.limit}",
                      ),
                    ),
                  ),
                );
              }
            }
          },
          child: Text(
            showNumberText(data),
            style: TextStyle(
              fontSize: 48,
              color: widget.appBarColor ?? Colors.blue,
            ),
          ),
        ),
        iconVideo(data),
      ],
    );
  }

  Widget iconVideo(AssetData data) {
    if (data.isImage) {
      return Container(
        width: 0,
        height: 0,
      );
    }
    return Icon(
      Utils.video,
      color: widget.appBarColor ?? Colors.blue,
    );
  }

  showNumberText(AssetData data) {
    int num = selectedData.indexOf(data) + 1;
    if (num == 0) {
      return "";
    } else {
      return "$num";
    }
  }
}