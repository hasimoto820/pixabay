import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
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
  // 初期値は空のListを与える
  List imageList = [];

  // 非同期の関数になったため返り値の型にFutureがつき、さらに async キーワードが追加されました。
  Future<void> fetchImages() async {
    // await で待つことで Future が外れ Response 型のデータを受け取ることができました。
    Response response = await Dio().get(
      'https://pixabay.com/api/?key=44357262-54a7d9b47553a12cf1b02a6dc&q=yellow+flowers&image_type=photo',
    );
    // 用意した imageList に hits の value を代入する
    imageList = response.data['hits'];
    setState(() {}); // 画面を更新したいので setState も呼んでおきます
  }

  // この関数の中の処理は初回に一度だけ実行されます。
  @override
  void initState() {
    super.initState();
    // 最初に一度だけ画像データを取得する。
    fetchImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          return Image.network(image['previewURL']);
        },
      ),
    );
  }
}
