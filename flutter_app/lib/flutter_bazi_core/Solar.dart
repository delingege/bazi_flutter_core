import 'Calendar.dart';
import 'Lunar.dart';
import 'Time.dart';

/**
 * 公历/阳历
 * Class Solar
 * @package shiyin\calendar
 */
class Solar extends Time {
  int year;
  int month;
  int day;

  Solar._();

  static Solar _instance;
  static Calendar _calendar;
  static Lunar _lunar;

  static Solar getInstance() {
    if (_instance == null) {
      _instance = Solar._();
    }
    return _instance;
  }

  init() async {
    _calendar = Calendar.getInstance();
    _lunar = Lunar.getInstance();
  }

  getConfigure(int year, int month, int day) {
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
  }

  /**
   * 周几
   * @return int
   */
  week() {
    double jd = _calendar.Solar2Julian(year, month, day, hour: 12);
    return ((((jd + 1).truncate() % 7)) + 7) % 7;
  }

  /**
   * 所在月有多少天
   * @return int
   */
  monthDays() {
    int ndf1 = -(year % 4 == 0 ? 1 : 0);
    bool ndf2 = ((year % 400 == 0 ? 1 : 0) - (year % 100 == 0 ? 1 : 0) == 0
            ? false
            : true) &&
        (year > 1582);
    int ndf = ndf1 + (ndf2 ? 1 : 0);
    return 30 +
        (((month - 7.5).abs() + 0.5) % 2) -
        (month == 2 ? 1 : 0) * (2 + ndf);
  }

  /**
   * 获取星座下标 ['水瓶座', '双鱼座', '白羊座', '金牛座', '双子座', '巨蟹座', '狮子座', '处女座', '天秤座', '天蝎座', '射手座', '摩羯座']
   * @return int|false
   */
  zodiac() {
    if (month < 1 || month > 12) {
      return false;
    }
    if (day < 1 || day > 31) {
      return false;
    }
    List dds = [20, 19, 21, 20, 21, 22, 23, 23, 23, 24, 22, 22];
    int kn = month - 1;
    if (day < dds[kn]) {
      kn = ((kn + 12) - 1) % 12;
    }
    return kn;
  }

  @override
  String string() {
    return "$year年$month月$day日";
  }

  // 是否为闰年
  @override
  Time tran() {
    List data = _calendar.Solar2Lunar(year, month, day);
    if (data == null || data.length < 4) return null;
    return _lunar.getConfigure(data[0], data[1], data[2], isLeap: data[3] == 1);
  }
}
