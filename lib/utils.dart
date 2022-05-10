import 'dart:math';

class RandomDate {
  final int _startYear;
  int? _endYear;

  RandomDate.withStartYear(this._startYear);
  RandomDate.withRange(this._startYear, this._endYear);

  DateTime random() {
    _endYear ??= DateTime.now().year;
    if (_endYear! < _startYear) {
      throw ArgumentError('Start year cannot be less then End year');
    }

    if (_startYear == _endYear) {
      if (_isLeapYear(_startYear)) {
        throw ArgumentError(
            'Start and End year cannot be same when leap years are excluded');
      } else {
        int? endYear = _endYear;
        if (endYear != null) {
          endYear++;
        }
        _endYear = endYear;
      }
    }
    Random _random = Random();
    int _randYear = _generateRandomYear();
    int _randMonthInt = _random.nextInt(12) + 1;
    int _randDay = _random.nextInt(_maxDays(_randYear, _randMonthInt));

    return DateTime(_randYear, _randMonthInt, _randDay);
  }

  int _generateRandomYear() {
    int _year = _startYear + Random().nextInt(_endYear! - _startYear);
    while (_isLeapYear(_year)) {
      _year = _startYear + Random().nextInt(_endYear! - _startYear);
    }
    return _year;
  }

  int _maxDays(int year, int month) {
    List<int> maxDaysMonthList = [4, 6, 9, 11];
    if (month == 2) {
      return _isLeapYear(year) ? 29 : 28;
    } else {
      return maxDaysMonthList.contains(month) ? 30 : 31;
    }
  }

  bool _isLeapYear(int year) =>
      (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));
}
