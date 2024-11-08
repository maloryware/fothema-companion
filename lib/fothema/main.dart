
import 'package:flutter/material.dart';
import 'package:fothema_companion/fothema/home.dart';

void main() {
  runApp(Home());
}
//
// class CoreWidget extends StatelessWidget {
//   const CoreWidget({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//         create: (context) => GeneratorScreenState(),
//           child: MaterialApp(
//             title: 'FOTHEMA Companion',
//             theme: ThemeData(
//             /**
//              *  This is the theme of your application.
//
//                 TRY THIS: Try running your application with \"flutter run\". You'll see
//                 the application has a purple toolbar. Then, without quitting the app,
//                 try changing the seedColor in the colorScheme below to Colors.green
//                 and then invoke \"hot reload\" (save your changes or press the \"hot
//                 reload\" button in a Flutter-supported IDE, or press \"r\" if you used
//                 the command line to start the app).
//
//                 Notice that the counter didn't reset back to zero; the application
//                 state is not lost during the reload. To reset the state, use hot
//                 restart instead.
//
//                 This works for code too, not just values: Most code changes can be
//                 tested with just a hot reload.
//                 colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//                 useMaterial3: true,
//              */
//               useMaterial3: true,
//               colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)
//             ),
//             home: HomeWidget()
//           )
//     );
//
//   }
// }
//
// enum ShouldNotify {
//   TRUE,
//   FALSE
// }
//
//
// class HomeWidget extends StatefulWidget {
//   @override
//   State<HomeWidget> createState() => _HomeWidgetState();
// }
//
// class _HomeWidgetState extends State<HomeWidget> {
//
//   var selectedIndex = 0;
//
//   @override
//   Widget build(BuildContext context) {
//
//     var widgets = <Widget>[
//       GeneratorPage(),
//       FavoritesPage() //todo: replace with favorites page
//     ];
//
//     if(selectedIndex >= widgets.length) throw UnimplementedError(\"No widget for index $selectedIndex\");
//
//     Widget selectedWidget = widgets[selectedIndex];
//
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return Scaffold(
//           body: Row(
//             children: [
//               SafeArea(
//                   child: NavigationRail(
//                     backgroundColor: Theme.of(context).colorScheme.secondary,
//                     extended: constraints.maxWidth >= 600,
//                     destinations: [
//                       NavigationRailDestination(
//                           icon: Icon(Icons.home),
//                           label: Text(\"Home\")),
//                       NavigationRailDestination(
//                           icon: Icon(Icons.favorite),
//                           label: Text(\"Favorites\"))
//                     ],
//                     selectedIndex: selectedIndex,
//                     onDestinationSelected: (value) {
//                       setState(() {
//                         selectedIndex = value;
//                       });
//                     },
//                   )
//               ),
//               Expanded(child: Container(
//                 color: Theme.of(context).colorScheme.onPrimary,
//                 child: selectedWidget
//               ))
//             ]
//           ));
//       }
//     );
//   }
// }
//
// class GeneratorScreenState extends ChangeNotifier {
//   WordPair current = WordPair.random();
//
//   var favorites = <WordPair>[];
//   void update(){
//     notifyListeners();
//   }
//   void getNext(){
//     current = WordPair.random();
//     notifyListeners();
//   }
//
//   void toggleFavorite(WordPair curr){
//     if(favorites.contains(curr)) favorites.remove(curr);
//     else favorites.add(curr);
//     notifyListeners();
//   }
//
//   bool getFavorite(WordPair curr){
//     return favorites.contains(curr);
//   }
//
// }
//
// class GeneratorPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     var appState = context.watch<GeneratorScreenState>();
//     var pair = appState.current;
//
//     IconData icon = appState.getFavorite(pair) ? Icons.thumb_up_alt : Icons.thumb_up_off_alt;
//     String label = appState.getFavorite(pair) ? \"Liked!\" : \"Like!\";
//     return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//
//             CentralCard(pair: pair),
//
//             SizedBox(height: 10),
//
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 ElevatedButton(
//                     onPressed: () {
//                       appState.getNext();
//                     },
//                     child: Text(\"Next\")
//                 ),
//
//                 ElevatedButton.icon(
//                     onPressed: () {
//                       appState.toggleFavorite(pair);
//                     },
//                     icon: Icon(icon),
//                     label: Text(label)
//                 ),
//               ],
//             )
//           ],
//         ),
//     );
//   }
// }
//
// class CentralCard extends StatelessWidget {
//   const CentralCard({
//     super.key,
//     required this.pair,
//   });
//
//   final WordPair pair;
//
//   @override
//   Widget build(BuildContext context) {
//
//     final theme = Theme.of(context);
//     final style = theme.textTheme.displayMedium!.copyWith(
//       color: theme.colorScheme.onPrimary
//     );
//
//
//     return Card(
//       color: theme.colorScheme.primary,
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Text(pair.asLowerCase, style: style, semanticsLabel: \"${pair.first} ${pair.second}\",),
//       ),
//     );
//   }
// }

