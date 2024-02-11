import 'package:customizable_counter/customizable_counter.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:is_first_run/is_first_run.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 192, 145, 214)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  // ↓ Add the code below.
  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

}

// ...

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
      switch (selectedIndex) {
        case 0:
          page = DrinkLog();
          break;
        case 1:
          page = ProfilePage();
          break;
        case 2:
          page = ProfilePage();
          break;
        case 3:
          page = DrinkLog();
          break;
        default:
          throw UnimplementedError('no widget for $selectedIndex');
}

    return SafeArea(child: 
      Builder(
        builder: (context) {
         return LayoutBuilder(builder: (context, constraints) {
            return Scaffold(
              body: Row(
                children: [
                  SafeArea(
                    child: NavigationRail(
                      extended: constraints.maxWidth >= 600,
                      destinations: [
                        NavigationRailDestination(
                          icon: Icon(Icons.home),
                          label: Text('Home'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.person),
                          label: Text('Profile'),
                        ),
                    
                      ],
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (value) {
                        print('selected: $value');
                        setState(() {
                          selectedIndex = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: page,
                    ),
                  ),
                ],
              ),
            );
          }
        );
      }
    )
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;

    if (favorites.isEmpty) {
      return SafeArea(child: 
      Center(
        child: Text('You have no favorites yet'),
      )
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );

  }
}

// ProfilePage implements the Profile screen.
// There should be a dropdown menu to select your gender.
// The dropdown should have three options: male, female, and other.
// There should be a text field to enter your weight.
// There should be a button to save.
// When the button is pressed, the app
// should save the information and navigate back to the home screen.
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String selectedGender = 'Male'; // Default value
  TextEditingController weightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: 
    Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
        )
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<String>(
              value: selectedGender,
              items: ['Male', 'Female', 'Other']
                  .map((gender) => DropdownMenuItem(
                        child: Text(gender),
                        value: gender,
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedGender = value!;
                });
              },
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weight (lbs)',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Save information and navigate back to the home screen.
                saveProfileInfo(selectedGender, weightController.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saving profile...')),
                );
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    )
    );
  }
}

Future<void> saveProfileInfo(String selectedGender, String weightController) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save the profile information to SharedPreferences.
    prefs.setString('gender', selectedGender);
    prefs.setInt('weight', int.parse(weightController));

    // Print the saved information to the console.
    print(prefs.getString('gender'));
    print(prefs.getInt('weight'));
  }


Future<SharedPreferences> saveStuff() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int weightInLBS = prefs.getInt('weight') ?? 0;
  int weightInKG = (weightInLBS / 2.20462).round();
  String? gender = prefs.getString('gender');
  double liquor = prefs.getDouble('liquor') ?? 0;
  double beer = prefs.getDouble('beer') ?? 0;
  double wine = prefs.getDouble('wine') ?? 0;
  double alcoholConsumed = (liquor * 14) + (beer * 14) + (wine * 14);
  
  return prefs;

}

double calculateBAC() {
  
  SharedPreferences prefs = saveStuff() as SharedPreferences;

  int weight = prefs.getInt('weight') ?? 0;
  int weightInKG = (weight / 2.20462).round();
  String? gender = prefs.getString('gender');
  double liquor = prefs.getDouble('liquor') ?? 0;
  double beer = prefs.getDouble('beer') ?? 0;
  double wine = prefs.getDouble('wine') ?? 0;
  double alcoholConsumed = (liquor * 14) + (beer * 14) + (wine * 14);
  double constant = 0;

    // Calculate BAC based on weight and gender.
  // ...
  switch (gender) {
    case 'Male':
      constant = .71;
    case 'Female':
      constant = .58;
    case 'Other':
      constant = .65;
    default:
      throw UnimplementedError('no BAC calculation for $gender');
  }

  double denominator = weightInKG * constant;
  double bac = alcoholConsumed / denominator;
  bac = bac - (.015 * 1); // Subtract 0.015% per hour
  bac = bac * .1;
  return bac;
}

class DrinkLog extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return SafeArea(child: 
    Scaffold(
      appBar: AppBar(
        title: Text('Drink Log'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
        )
      ),
      body: Center( 
        child: Column(
          children: [
          SizedBox(height: 15),
          LiquorButton(),
          SizedBox(height: 15),
          BeerButton(),
          SizedBox(height: 15),
          WineButton(),
          SizedBox(height: 50),
          ElevatedButton(
            onPressed: () {
              double bac = calculateBAC();
              print(bac);
              String sBac = bac.toString();
              String message = 'Your BAC is: $sBac';
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Calculating BAC...')),
                );
                Text(message);
            },
            child: Text('Calculate BAC'),
          ),
        ]
      ),
      ),
    )
    );
  
}
}

class LiquorButton extends StatelessWidget {
  const LiquorButton({
    super.key,
    
  });

  

  @override
  Widget build(BuildContext context) {
    return CustomizableCounter(
    borderColor: Color.fromARGB(255, 0, 0, 0),
    borderWidth: 5,
    borderRadius: 100,
    backgroundColor: Theme.of(context).colorScheme.primary,
    buttonText: "Shots of Liquor",
    textColor: Color.fromARGB(255, 255, 255, 255),
    textSize: 20,
    count: 0,
    step: 1,
    minCount: 0,
    maxCount: 50,
    incrementIcon: const Icon(
    Icons.add,
    color: Colors.white,
          ),
          decrementIcon: const Icon(
    Icons.remove,
    color: Colors.white,
          ),
          onCountChange: (count) async {
            print('Liquor: ' + count.toString());
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setDouble('liquor', count);
          },
          onIncrement: (count) {
    
          },
          onDecrement: (count) {
    
          },
    );
  }
}

class BeerButton extends StatelessWidget {
  const BeerButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomizableCounter(
    borderColor: Color.fromARGB(255, 0, 0, 0),
    borderWidth: 5,
    borderRadius: 100,
    backgroundColor: Theme.of(context).colorScheme.primary,
    buttonText: "Bottles of Beer",
    textColor: Color.fromARGB(255, 255, 255, 255),
    textSize: 20,
    count: 0,
    step: 1,
    minCount: 0,
    maxCount: 50,
    incrementIcon: const Icon(
    Icons.add,
    color: Colors.white,
          ),
          decrementIcon: const Icon(
    Icons.remove,
    color: Colors.white,
          ),
          onCountChange: (count) async {
            print('Beer: ' + count.toString());
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setDouble('beer', count);
          },
          onIncrement: (count) {
    
          },
          onDecrement: (count) {
    
          },
    );
  }
}

class WineButton extends StatelessWidget {
  const WineButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomizableCounter(
    borderColor: Color.fromARGB(255, 0, 0, 0),
    borderWidth: 5,
    borderRadius: 100,
    backgroundColor: Theme.of(context).colorScheme.primary,
    buttonText: "Glasses of Wine",
    textColor: Color.fromARGB(255, 255, 255, 255),
    textSize: 20,
    count: 0,
    step: 1,
    minCount: 0,
    maxCount: 50,
    incrementIcon: const Icon(
    Icons.add,
    color: Colors.white,
          ),
          decrementIcon: const Icon(
    Icons.remove,
    color: Colors.white,
          ),
          onCountChange: (count) async {
            print('Wine: ' + count.toString());
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setDouble('wine', count);
          },
          onIncrement: (count) {
    
          },
          onDecrement: (count) {
    
          },
    );
  }
}


////////////////////////////////////////////////////////////////////

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return SafeArea(child: 
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    )
    );
  }
}

// ...


class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);       // ← Add this.
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );


    return Card(
      color: theme.colorScheme.primary,    // ← And also this.
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(pair.asLowerCase, style: style),

      ),
    );
  }
}



