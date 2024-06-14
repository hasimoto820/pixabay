import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PixabayPage(),
    );
  }
}

class PixabayPage extends StatefulWidget {
  const PixabayPage({super.key});

  @override
  State<PixabayPage> createState() => _PixabayPageState();
}

class _PixabayPageState extends State<PixabayPage> {
  List imageList = [];

  Future<void> fetchImages(String text) async {
    Response response = await Dio().get(
      'https://pixabay.com/api/?key=44357262-54a7d9b47553a12cf1b02a6dc&q=$text&image_type=photo&per_page=100',
    );
    print(response.data);

    // 用意した imageList に hits の value を代入する
    imageList = response.data['hits'];
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchImages('みかん');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
          ),
          onFieldSubmitted: (text) {
            print('@@@@@@@@@ 100 @@@@@@@@@');
            print(text);
            fetchImages(text);
          },
        ),
        backgroundColor: Colors.blue,
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 横に並べる個数をここで決めます。今回は 3 にします。
        ),
        // itemCount には要素数を与えます。
        // List の要素数は .length で取得できます。今回は20になります。
        itemCount: imageList.length,
        // index には 0 ~ itemCount - 1 の数が順番に入ってきます。
        // 今回、要素数は 20 なので 0 ~ 19 が順番に入ります。
        itemBuilder: (context, index) {
          // 要素を順番に取り出します。
          // index には 0 ~ 19 の値が順番に入ること、
          // List から番号を指定して要素を取り出す書き方を思い出しながら眺めてください。
          Map<String, dynamic> image = imageList[index];
          // プレビュー用の画像データがあるURLは previewURL の value に入っています。
          // URLをつかった画像表示は Image.network(表示したいURL) で実装できます。
          return InkWell(
            onTap: () async {
              print(image['likes']);

              // カレントディレクトリ
              Directory dir = await getTemporaryDirectory();

              print(dir);

              Response response = await Dio().get(
                // previewURL は荒いためより高解像度の webformatURL から画像をダウンロードします。
                image['webformatURL'],
                options: Options(
                  // 画像をダウンロードするときは ResponseType.bytes を指定します。
                  responseType: ResponseType.bytes,
                ),
              );

              // フォルダの中に image.png という名前でファイルを作り、そこに画像データを書き込みます。
              File imageFile = await File('${dir.path}/image.png')
                  .writeAsBytes(response.data);

              await Share.shareXFiles([XFile(imageFile.path)],
                  text: 'Great picture');
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Image.network(
                    image['previewURL'],
                    fit: BoxFit.cover,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    color: Colors.white,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.thumb_up_alt_outlined,
                          size: 14,
                        ),
                        Text('${image['likes']}'),
                        Text(image['likes'].toString()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
