import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'player_model.g.dart';

@HiveType(typeId: 0)
class PlayerModel extends ChangeNotifier with HiveObjectMixin {
  @HiveField(1)
  int highScore = 0;

  int _age = 17;

  int _health = 5;
  int _currentExpenseMonth = 150000;
  int _currentDebtsExpenseMonth = 0;
  int _mentalhealth = 3;
  int _familyHayalga = 0;
  bool _isUniversity = false;
  int _networth = 0;
  String _family = 'none';

  int _stockbalance = 0;
  int _balance = 0;
  int _debt = 0;
  List<String> _assets = [];
  Map<int, List<int>> _allDebts = {};
  Education _education = Education.none;

  int _lives = 5;

  int _currentScore = 0;
  int _currentSalaryMonth = 0;
  double _investmentPercent = 0;
  int get age => _age;
  int get balance => _balance;
  int get health => _health;
  int get mentalhealth => _mentalhealth;
  int get networth => _networth;
  int get stockbalance => _stockbalance;
  int get currentExpenseMonth => _currentExpenseMonth;
  int get currentDebtsMonth => _currentDebtsExpenseMonth;
  int get currentSalaryMonth => _currentSalaryMonth;
  int get familyHayalga => _familyHayalga;
  int get debt => _debt;
  double get investmentPercent => _investmentPercent;

  String get family => _family;
  bool get isUniversity => _isUniversity;
  List<String> get assets => _assets;
  Education get education => _education;
  Map<int, List<int>> get allDebts => _allDebts;

  int get currentScore => _currentScore;

  int get lives => _lives;

  set investmenPercent(double value) {
    _investmentPercent = value;
  }

  set stockbalance(int value) {
    _stockbalance = value;
  }

  set debt(int value) {
    _debt = value;
  }

  set isUniversity(bool value) {
    _isUniversity = value;
  }

  set familyHayalga(int value) {
    _familyHayalga = value;
  }

  set age(int value) {
    _age = value;
  }

  set currentSalaryMonth(int value) {
    _currentSalaryMonth = value;
  }

  set currentExpenseMonth(int value) {
    _currentExpenseMonth = value;
  }

  set currentDebtsMonth(int value) {
    _currentDebtsExpenseMonth = value;
  }

  set health(int value) {
    _health = value;
  }

  set mentalhealth(int value) {
    _mentalhealth = value;
  }

  set networth(int value) {
    _networth = value;
  }

  set balance(int value) {
    _balance = value;
  }

  set currentScore(int value) {
    _currentScore = value;

    if (highScore < currentScore) {
      highScore = currentScore;
    }
    notifyListeners();
    save();
  }

  set education(Education value) {
    _education = value;
  }

  set lives(int value) {
    if (value <= 5 && value >= 0) {
      _lives = value;
      notifyListeners();
    }
  }

  set family(String value) {
    _family = value;
  }
}

enum Education {
  cs,
  business,
  finance,
  art,
  doctor,
  artist,
  reception,
  waiter,
  driver,
  barista,
  none,
}
