// import 'package:flutter/material.dart';
// import 'package:custom_multi_image_picker/asset.dart';
// import 'package:custom_multi_image_picker/custom_multi_image_picker.dart';

// class AssetView extends StatefulWidget {
//   final int _index;
//   final Asset _asset;

//   AssetView(this._index, this._asset);

//   @override
//   State<StatefulWidget> createState() => AssetState(this._index, this._asset);
// }

// class AssetState extends State<AssetView> {
//   int _index = 0;
//   Asset _asset;
//   AssetState(this._index, this._asset);

//   @override
//   void initState() {
//     print('_asset : ${_asset.filePath}');
//     super.initState();
//     _loadImage();
//   }

//   void _loadImage() async {
//     await this._asset.requestThumbnail(130, 130);
//     print('loadImage call');
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (null != this._asset.thumbData) {
//       print('if call');
//       print('${this._asset.thumbData}');
//       return Image.memory(
//         this._asset.thumbData.buffer.asUint8List(),
//         fit: BoxFit.cover,
//         gaplessPlayback: true,
//       );
//     } else {
//       print('else call');
//     }
//     return Text(
//       '${this._index}',
//       // style: Theme.of(context).textTheme.headline,
//     );
//   }
// }
