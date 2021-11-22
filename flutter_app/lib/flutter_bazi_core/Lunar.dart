import 'Calendar.dart';
import 'Solar.dart';
import 'Time.dart';

/**
 * 农历/阴历
 * Class Solar
 * @package shiyin\calendar
 */
class Lunar extends Time {
  int year;
  int month;
  int day;

  bool isLeap = false;

  Lunar._();

  static Lunar _instance;
  static Calendar _calendar;
  static Solar _solar;

  static Lunar getInstance() {
    if (_instance == null) {
      _instance = Lunar._();
    }
    return _instance;
  }

  init() async {
    _calendar = Calendar.getInstance();
    _solar = Solar.getInstance();
  }

  getConfigure(int year, int month, int day, {bool isLeap = false}) {
    if (year < -1000 || year > 3000) {
      // 超出该范围，则误差较大
      return null;
    }
    if (month <= 0 || month > 12) {
      return null;
    }
    Map map = Map();
    map["year"] = year;
    map["month"] = month;
    map["day"] = day;
    return map;
    // static = static();
    // return configure(static, compact('year', 'month', 'day', 'isLeap'));
  }

  /**
   * 获取农历某个月有多少天
   * @return int
   */
  monthDays() {
    List monthArr = _calendar.GetZQAndSMandLunarMonthCode(year);
    List jdnm = monthArr.first;
    List mc = monthArr.last;

    int leap = 0;
    for (int j = 1; j <= 14; j++) {
      if (mc[j] - (mc[j]) ~/ 1 > 0) {
        leap = (mc[j] ~/ 1 + 0.5);
        break;
      }
    }
    int _month = month + 2;
    List nofd = [];
    for (int i = 0; i <= 14; i++) {
      nofd[i] = (jdnm[i + 1] + 0.5) ~/ 1 - (jdnm[i] + 0.5) ~/ 1;
    }

    int days = 0;
    if (isLeap) {
      if (leap >= 3) {
        if (leap == _month) {
          days = nofd[_month];
        }
      }
    } else {
      if (leap == 0) {
        days = nofd[_month - 1];
      } else {
        days = nofd[_month + (_month > leap ? 1 : 0) - 1];
      }
    }
    return days;
  }

  /**
   * 年的闰月,0为无闰月
   * @return int
   */
  leapMonth() {
    List monthArr = _calendar.GetZQAndSMandLunarMonthCode(year);
    List mc = monthArr.last;
    int leap = 0;
    for (int j = 1; j <= 14; j++) {
      if (mc[j] - (mc[j]) ~/ 1 > 0) {
        leap = (mc[j] + 0.5) ~/ 1;
        break;
      }
    }
    return leap - 2 > 0 ? leap - 2 : 0;
  }

  @override
  String string() {
    return "$year年${isLeap ? '闰' : ''}$month月$day日";
  }

// 转换为阳历
  @override
  Solar tran() {
    List data = _calendar.Lunar2Solar(year, month, day, isLeap: isLeap);
    if (data == null || data.length < 4) return null;
    return _solar.getConfigure(data[0], data[1], data[2]);
  }
}
