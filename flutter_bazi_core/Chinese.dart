import 'package:bazi_flutter_app/flutter_bazi_core/bazi_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Calendar.dart';
import 'dart:math';

class BzDyInfo {
  List<dynamic> tg; // 天干
  List<dynamic> dz; // 地支
  List<dynamic> dyTg; // 大运天干
  List<dynamic> dyDz; // 大运地支
  String startesc; // 起运描述
  List<dynamic> startTime; // 起运时间
  String bazi; // 八字
  String dyBazi; // 大运八字
  String sx; // 生肖
  int sxIndex; // 生肖的索引
  List<dynamic> dyStartTime; // 大运开始时间
  int newDyStartTime; // 老板要求用自己算法的起运时间
  String newDyStartTimeDes; // 起运藐视
  String frontName; // 上一个节气名字
  String frontTime; // 上一个节气时间
  String backName; // 下一个节气名字
  String backTime; // 下一个节气时间
  int lYear; // 农历的年
  int lMonth; // 农历的月
  int lDay; // 农历的日
  bool isLeap; // 是否是闰月
  String startYun;
  String preJieLinTime;
  int preJieLinIndex;
  String nextJieLinTime;
  int nextJieLinIndex;
  int sex; // 性别 // 男 1 女 -1
  int nianTianYinYang; // 年天干阴阳
  int currentYearOld;
  List<Map<String, dynamic>> dayun;
  List<dynamic> range; // 碧海伦算法计算自己的大运范围

  BzDyInfo({this.tg, this.dz, this.dyTg, this.dyDz, this.startesc, this.startTime, this.bazi, this.dyBazi, this.sx, this.newDyStartTime, this.newDyStartTimeDes, this.frontName, this.frontTime, this.backName, this.backTime, this.lYear, this.lMonth, this.lDay, this.sxIndex, this.isLeap, this.startYun, this.preJieLinTime, this.preJieLinIndex, this.nextJieLinTime, this.nextJieLinIndex, this.sex, this.nianTianYinYang, this.currentYearOld, this.dayun});
}

class LuckyInfo {
  String topDescribe;
  String bottomDescibe;
  int tg;
  int dz;
  String tip; // 流月,流日专用
  int startDay; // 计算流日开始时间
  int endDay; // 计算流日结束时间
  int hourG; // 流时专用

  LuckyInfo({this.topDescribe, this.bottomDescibe, this.tg, this.dz, this.tip, this.startDay, this.endDay, this.hourG});
}


/// * 天干地支
/// * Class Chinese
class Chinese {
  Chinese._();

  static Chinese _instance;

  static Chinese getInstance() {
    if (_instance == null) {
      _instance = Chinese._();
    }
    return _instance;
  }

  Calendar _calendar;

  init() async {
    _calendar = Calendar.getInstance();
  }

  // 中文数字
  List<String> number = ['日', '一', '二', '三', '四', '五', '六', '七', '八', '九', '十'];

// 农历月份常用称呼
  List<String> Month = [
    '正',
    '二',
    '三',
    '四',
    '五',
    '六',
    '七',
    '八',
    '九',
    '十',
    '冬',
    '腊'
  ];

// 农历日期常用称呼
  List<String> DayPreference = ['初', '十', '廿', '卅'];

// 十天干
  List<String> GAN = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];

// 十二地支
  List<String> ZHI = [
    '子',
    '丑',
    '寅',
    '卯',
    '辰',
    '巳',
    '午',
    '未',
    '申',
    '酉',
    '戌',
    '亥'
  ];

// 十二生肖
  List<String> Zodiac = [
    '鼠',
    '牛',
    '虎',
    '兔',
    '龙',
    '蛇',
    '马',
    '羊',
    '猴',
    '鸡',
    '狗',
    '猪'
  ];

// 星期
  List<String> WeekDay = ['日', '一', '二', '三', '四', '五', '六'];

  /// 廿四节气(从春分开始)
  List<String> SolarTerms = [
    '春分',
    '清明',
    '谷雨',
    '立夏',
    '小满',
    '芒种',
    '夏至',
    '小暑',
    '大暑',
    '立秋',
    '处暑',
    '白露',
    '秋分',
    '寒露',
    '霜降',
    '立冬',
    '小雪',
    '大雪',
    '冬至',
    '小寒',
    '大寒',
    '立春',
    '雨水',
    '惊蛰'
  ];

// 12节气
  List<String> SolarIterm = ['立春', '惊蛰', '清明', '立夏', '芒种', '小暑', '立秋', '白露', '寒露', '立冬', '大雪', '小寒'];

// 用于计算节气索引
  List<String> JqmcStrIndex = ['冬至', '小寒', '大寒', '立春', '雨水', '惊蛰', '春分', '清明', '谷雨', '立夏', '小满', '芒种', '夏至', '小暑', '大暑', '立秋', '处暑', '白露', '秋分', '寒露', '霜降', '立冬', '小雪', '大雪'];


  /// 某公历年立春点开始的24节气
  /// @param int year
  /// @return array jq[($k+21)%24]
  List solarTerms(int year) {
    List solarTermsTime = [];
    Map dj = _calendar.GetAdjustedJQ(
        year - 1, 21, 23); //求出含指定年立春开始之3个节气JD值,以前一年的年值代入
    for (int k = 0; k < dj.length; k++) {
      if (k < 21 || k > 23) {
        continue;
      }
      solarTermsTime = _calendar.Julian2Solar(dj[k]); //21立春;22雨水;23惊蛰
    }
    dj = _calendar.GetAdjustedJQ(year, 0, 20); //求出指定年节气之JD值,从春分开始
    for (int i = 0; i < dj.length; i++) {
      solarTermsTime = _calendar.Julian2Solar(dj[i]);
    }
    return solarTermsTime;
  }


  /// 四柱计算,分早子时晚子时,传公历
  /// @param int year
  /// @param int month
  /// @param int day
  /// @param int hour 时间(0-23)
  /// @param int minute 分钟数(0-59),在跨节的时辰上会需要,有的排盘忽略了跨节
  /// @param int second 秒数(0-59)
  /// @param bool $zero
  /// @return array(天干, 地支, 对应的儒略日历时间, 对应年的12节+前后N节, 对应时间所处节的索引)
  GanZhi(int year, int month, int day, int hour,
      {int minute = 0, int second = 0, bool zero = true}) {
    double jd = _calendar.Solar2Julian(year, month, day,
        hour: hour, minute: minute, second: max(1, second));
    if (jd == -1) {
      //多加一秒避免精度问题
      return [];
    }
    List tg = [];
    List dz = [];
    List jq = _calendar.GetPureJQSinceSpring(year); //取得自立春开始的节,该数组长度固定为16
    if (jd < jq[1]) {
      //jq[1]为立春,约在2月5日前后,
      year = year - 1; //若小于jq[1],则属于前一个节气年
      jq = _calendar.GetPureJQSinceSpring(year); //取得自立春开始的节
    }

    int ygz = ((year + 4712 + 24) % 60 + 60) % 60;
    tg.add(ygz % 10); //年干
    dz.add(ygz % 12); //年支

    int index = 0;
    for (int j = 0; j <= 15; j++) {
      //比較求算节气月,求出月干支
      if (jq[j] >= jd) {
        //已超過指定时刻,故應取前一个节气
        index = j - 1;
        break;
      }
    }

    int tmm = ((year + 4712) * 12 + (index - 1) + 60) % 60; //数组0为前一年的小寒所以这里再减一
    int mgz = (tmm + 50) % 60;
    tg.add(mgz % 10); //月干
    dz.add(mgz % 12); //月支
    double jdA = jd + 0.5; //计算日柱之干支,加0.5是将起始點从正午改为从0點开始.
    var dayJD = jdA.floor() + (((jdA - jdA.floor()) * 86400) + 3600) / 86400;  //将秒数化为日数,加回到jd的整数部份
    var dgz = (((dayJD + 49).floor() % 60 + 60) % 60).floor();
    tg.add(dgz % 10); //日干
    dz.add(dgz % 12); //日支var
    if (zero && (hour >= 23)) {
      //区分早晚子时,日柱前移一柱
      tg[2] = (tg[2] + 10 - 1) % 10;
      dz[2] = (dz[2] + 12 - 1) % 12;
    }

    var dh = dayJD * 12; //计算时柱之干支
    var hgz = (((dh + 48) % 60 + 60) % 60).floor();
    tg.add(hgz % 10); //时干
    dz.add(hgz % 12); //时支

    return [tg, dz, jd, jq, index];
  }


  /// 公历年排盘
  /// * @param bool isMale 是否为男性
  /// * @param int year
  /// * @param int month
  /// * @param int day
  /// * @param int hour 时间(0-23)
  /// * @param int minute 分钟数(0-59),在跨节的时辰上会需要,有的排盘忽略了跨节
  /// * @param int second 秒数(0-59)
  /// * @return array
  Fate(bool isMale, int year, int month, int day,
      {int hour = 0, int minute = 0, int second = 0}) {
    Map<String, dynamic> ret = Map();
    if (isMale == null || year == null || month == null || day == null) {
      ret["ret"] = 0;
      ret["data"] = null;
      ret["error"] = "参数错误";
      return ret;
    }

    List<String> JQs = [
      '小寒',
      '立春',
      '惊蛰',
      '清明',
      '立夏',
      '芒种',
      '小暑',
      '立秋',
      '白露',
      '寒露',
      '立冬',
      '大雪'
    ]; // 12节气，不包含另外12中气
    BzDyInfo bzInfo = BzDyInfo();
    List LuckyG = []; //大运干支
    List LuckyZ = [];
    List ganZhiList = _instance.GanZhi(year, month, day, hour,
        minute: minute, second: second);
    List tg = ganZhiList[0]; // 天干
    List dz = ganZhiList[1]; // 地支
    double jd = ganZhiList[2]; // 对应的儒略日历时间
    List jq = ganZhiList[3]; // 对应年的12节+前后N节
    int ix = ganZhiList[4]; // 对应时间所处节的索引

    int pn = tg[0] % 2; //起大运.阴阳年干:0阳年1阴年
    double span = 0;
    var srSpan = 0;

    if ((isMale && pn == 0) || (!isMale && pn == 1)) {
      srSpan = shirenSpan(jd, jq[ix + 1], true);
      //起大运时间,阳男阴女顺排
      span = jq[ix + 1] - jd; //往后数一个节,计算时间跨度
      for (int i = 1; i <= 12; i++) {
        //大运干支
        LuckyG.add((tg[1] + i) % 10);
        LuckyZ.add((dz[1] + i) % 12);
      }
    } else {
      srSpan = shirenSpan(jd, jq[ix], false);
      // 阴男阳女逆排,往前数一个节
      span = jd - jq[ix];
      for (int i = 1; i <= 12; i++) {
        //确保是正数
        LuckyG.add((tg[1] + 20 - i) % 10);
        LuckyZ.add((dz[1] + 24 - i) % 12);
      }
    }

    int days = (span * 4 * 30)
        .floor(); //折合成天数:三天折合一年,一天折合四个月,一个时辰折合十天,一个小时折合五天,反推得到一年按360天算,一个月按30天算
    int y = (days / 360).floor(); //三天折合一年
    int m = (days % 360 / 30).floor(); //一天折合四个月
    int d = (days % 360 % 30).floor(); //一个小时折合五天
    bzInfo.tg = tg;
    bzInfo.dz = dz;
    bzInfo.dyTg = LuckyG;
    bzInfo.dyDz = LuckyZ;
    bzInfo.startesc = "$y年$m月$d天起运";
    double start_jd_time = (jd + span * 120)
        .toDouble(); //三天折合一年,一天折合四个月,一个时辰折合十天,一个小时折合五天,反推得到一年按360天算
    bzInfo.startTime = _calendar.Julian2Solar(start_jd_time); //转换成公历形式,注意这里变成了数组

    bzInfo.sx = Zodiac[dz[0]]; //生肖
    bzInfo.sxIndex = dz[0];

    List dyStartTime = [];
    for (int i = 0; i < 12; i++) {
      String dyBazi = bzInfo.dyBazi ?? "";
      dyBazi += GAN[LuckyG[i]];
      dyBazi += ZHI[LuckyZ[i]];
      bzInfo.dyBazi = dyBazi;
      dyStartTime.add(_calendar.Julian2Solar(start_jd_time + i * 10 * 360));
    }
    bzInfo.dyStartTime = dyStartTime;

    // 计算前后节气时间
    bzInfo.frontName = JQs[ix % 12];
    List<int> preTime = julian2solar(jq[ix]);
    bzInfo.frontTime = datetime2string(preTime);
    bzInfo.backName = JQs[(ix + 1) % 12];
    List<int> nexTime = julian2solar(jq[ix + 1]);
    bzInfo.backTime = datetime2string(nexTime);
    bzInfo.preJieLinTime = datetime2stringCommon(preTime);
    bzInfo.nextJieLinTime = datetime2stringCommon(nexTime);
    bzInfo.preJieLinIndex = JqmcStrIndex.indexOf(bzInfo.frontName);
    bzInfo.nextJieLinIndex = JqmcStrIndex.indexOf(bzInfo.backName);
    bzInfo.sex = isMale ? 1 : -1; // 性别
    bzInfo.nianTianYinYang = pn == 0 ? 1 : -1; // 阴阳年干
    DateTime dateTime = DateTime.now();
    bzInfo.currentYearOld = dateTime.year - year;

    // 农历的时间
    List<int> solarDate = _calendar.Solar2Lunar(year, month, day);
    bzInfo.lYear = solarDate[0];
    int lMonth = 0;
    if (solarDate[1] == 11) {
      lMonth = 0;
    } else if(solarDate[1] == 12) {
      lMonth = 1;
    } else {
      lMonth = solarDate[1] + 1;
    }
    bzInfo.lMonth = lMonth;
    bzInfo.lDay = solarDate[2] - 1;
    bzInfo.isLeap = solarDate[3] == 1;

    // 计算实仁起运时间
    var startAge = (srSpan / 3).round().abs();
    var lunarDate = _calendar.Solar2Lunar(year, month, day);
    lunarDate[0] += startAge; // 出生日期农历年平移到起运年
    var shirenLuckyDay = offsetLunar2solar(lunarDate); // 农历时间偏移到公历时间
    bzInfo.startYun = "${shirenLuckyDay[0]}-${shirenLuckyDay[1]}-${shirenLuckyDay[2]}";
    bzInfo.newDyStartTime  = shirenLuckyDay[0];

    // 计算大运范围-根据生日进行切割
    List<dynamic> range = [];
    for (int i = 0; i < 10; i++) {
      lunarDate[0] += 10;
      var solar = offsetLunar2solar(lunarDate);
      range.add(solar);
    }
    bzInfo.range = range;


    List<Map<String, dynamic>> dy = [];
    int startDyTime = bzInfo.newDyStartTime;
    int startDyMonth = shirenLuckyDay[1];
    int startDyDay = shirenLuckyDay[2];
    int rangeYear = startDyTime;
    double currentJulian = getCurrentJulianTime(); // 获取当前儒略日时间
    int selectToday; // 圈今标记;
    for (int i = 0; i < bzInfo.dyTg.length; i++) {
      if (i >= 10) {
        break;
      }
      rangeYear = range[i][0];
      int rangeMonth = range[i][1];
      int rangeDay = range[i][2];
      List<dynamic> nextDy = getBeforeDay(rangeYear, rangeMonth, rangeDay); // 获取结束大运公历生日

      int nextDyYear = nextDy[0];
      int nextDyMonth = nextDy[1];
      int nextDyDay = nextDy[2];
      Map<String, dynamic> map = {};
      double startDyJulian = _calendar.Solar2Julian(startDyTime, startDyMonth, startDyDay); // 获取大运开始儒略日时间
      double endDyJulian = _calendar.Solar2Julian(nextDyYear, nextDyMonth, nextDyDay);  // 获取大运结束儒略日时间
      if (currentJulian >= startDyJulian && currentJulian <= endDyJulian) {
        map["mark"] = true; // 圈住今天
        selectToday = i;
      } else {
        map["mark"] = false;
      }
      List<dynamic> bhDy = range[i];
      int tg = bzInfo.dyTg[i];
      int dz = bzInfo.dyDz[i];
      map["year"] = startDyTime;
      map["old"] = startDyTime - year;
      map["ganZhi"] = "$tg:$dz";
      map["month"] = startDyMonth;
      map["day"] = startDyDay;
      map["nextDyYear"] = nextDyYear;
      map["nextDyMonth"] = nextDyMonth;
      map["nextDyDay"] = nextDyDay;
      map["birthday"] = [year, month, day];
      startDyTime = bhDy[0];
      startDyMonth = bhDy[1];
      startDyDay = bhDy[2];
      dy.add(map);
    }
    bzInfo.dayun = dy;

    Map<String, dynamic> data = {};
    data["mcIndex"] = bzInfo.lMonth;
    data["diIndex"] = bzInfo.lDay;
    data["Lyear2"] = bzInfo.lYear < 10 ? "0${bzInfo.lYear}" : bzInfo.lYear;
    data["isLun"] = bzInfo.isLeap;
    data["startYun"] = bzInfo.startYun;
    data["preJieLinTime"] = bzInfo.preJieLinTime;
    data["preJieLinIndex"] = bzInfo.preJieLinIndex;
    data["nextJieLinTime"] = bzInfo.nextJieLinTime;
    data["nextJieLinIndex"] = bzInfo.nextJieLinIndex;
    data["sex"] = bzInfo.sex;
    data["nianTianYinYang"] = bzInfo.nianTianYinYang;
    data["shenXiao"] = bzInfo.sxIndex;
    data["currentYearOld"] = bzInfo.currentYearOld;
    data["dayun"] = bzInfo.dayun;
    data["jd"] = jd;

    String sizhu = "";
    for (int i = 0; i < bzInfo.tg.length; i++) {
      int tg = bzInfo.tg[i];
      int dz = bzInfo.dz[i];
      sizhu += "$tg:";
      i == bzInfo.tg.length - 1 ? sizhu += "$dz" : sizhu += "$dz:";
    }
    data["sizhu"] = sizhu;
    data["selectToday"] = selectToday; // 圈今标记
    ret["data"] = data;
    ret["error"] = "";
    ret["ret"] = 1;
    return ret;
  }

  /**
   * 偏移农历到公历
   * @param lunarDate
   * @returns List
   */
  offsetLunar2solar(lunarDate) {
    var ld = [lunarDate[0], lunarDate[1], lunarDate[2], lunarDate[3]];
    var shirenLuckyDay = _calendar.Lunar2Solar(ld[0], ld[1], ld[2], isLeap: ld[3] == 1);
    if (shirenLuckyDay == null) { // 如果平移后的日期不存在
      if (ld[3] == 1) { // 平移的日期为闰月，转为非闰月重试
        ld[3] = 0;
        shirenLuckyDay = _calendar.Lunar2Solar(ld[0], ld[1], ld[2], isLeap: ld[3] == 1);
        if (shirenLuckyDay == null) { // 平移后的日期不存在(平移后，大月(30)变小月(29))
          ld[2] -= 1;
          shirenLuckyDay = _calendar.Lunar2Solar(ld[0], ld[1], ld[2], isLeap: ld[3] == 1);
        }
      } else { // 平移日期不存在，大小月问题
        ld[2] -= 1;
        shirenLuckyDay = _calendar.Lunar2Solar(ld[0], ld[1], ld[2], isLeap: ld[3] == 1);
      }
    }
    return shirenLuckyDay;
  }

  /**
   * 农历月份常用名称
   * @param int month
   * @return string
   */
  monthString(int month) {
    int k = month - 1;
    return Month[k];
  }

  /**
   * 农历日期数字返回汉字表示法
   * @param int day
   * @return string
   */

  dayString(int day) {
    String dayStr = "";
    switch (day) {
      case 10:
        dayStr = DayPreference[0] + number[10];
        break;
      case 20:
        dayStr = DayPreference[2] + number[10];
        break;
      case 30:
        dayStr = DayPreference[3] + number[10];
        break;
      default:
        int k = (day / 10).truncate();
        int m = day % 10;
        dayStr = DayPreference[k] + number[m];
    }
    return dayStr;
  }

  /**
   * 日期时间数组转为字符串
   * @param data
   * @returns {string}
   */
  datetime2string(List<int> data) {
    var second = 0;
    if (data.length == 6) {
      second = data[5];
    }
    return "${data[0]}年${data[1]}日${data[2]}日 ${data[3]}时${data[4]}分$second秒";
  }

  datetime2stringCommon(List<int> data) {
    var second = 0;
    if (data.length == 6) {
      second = data[5];
    } else if (data.length == 3) {
      return "${data[0]}-${data[1]}-${data[2]}";
    }
    return "${data[0]}-${data[1]}-${data[2]} ${data[3]}:${data[4]}:$second";
  }


  /// 流年(点击大运需要展开的数据)
  /// * @param startYear 需要计算的开始年份
  /// * @param old 需要计算的开始年龄
  /// * @param size 获取的条目数，如1990年开始往后十年(1990～1999),就是10
  /// * @param dyStartYear  大运开始年份,如果是大运的第一年就传值,不是就不用传
  /// * @param dyEndYear  大运结束年份,如果是大运的最后一年就传值,不是就不用传
  /// * @param bool isMark 是否被圈今
  /// * @param String startDyTime 大运开始时间
  /// * @param String endDyTime 大运结束时间
  /// * @returns {*[]}
  getFleetYear(int startYear, int old, {int size = 10, int dyStartYear, int dyEndYear, bool isMark, String startDyTime, String endDyTime}) {
    Map<String, dynamic> ret = {};
    if (startYear == null || old == null) {
      ret["ret"] = 0;
      ret["data"] = null;
      ret["error"] = "参数错误";
      return ret;
    }
    var yearGZ = ((startYear + 4712 + 24) % 60 + 60) % 60;
    List<LuckyInfo> columns = [];
    List<Map<String, dynamic>> data = [];
    var g = yearGZ % 10;
    var z = yearGZ % 12;
    var i = 0;
    while (i < size) {
      Map<String, dynamic> map = {};
      LuckyInfo luckyInfo = LuckyInfo();
      luckyInfo.tg = g;
      luckyInfo.dz = z;
      luckyInfo.topDescribe = "${startYear + i}年";
      luckyInfo.bottomDescibe = "${old + i}岁";
      if (i == 0 && dyStartYear != null) {
        map["dyStartYear"] = dyStartYear;
      } else if (i == size - 1 && dyEndYear != null) {
        map["dyEndYear"] = dyEndYear;
      }
      map["year"] = startYear + i;
      map["old"] = old + i;
      map["ganZhi"] = "$g:$z";
      if (isMark) { // 被圈今才需要做判断
        List currentSi = _calendar.yearJieQi(startYear + i); // 获取今天的节气
        List nextSi = _calendar.yearJieQi(startYear + i + 1); // 获取明年的节气
        Map currentSiMap = currentSi[0];
        Map nextSiMap = nextSi[0];
        int jieQStartY;
        int jieQStartM;
        int jieQStartD;
        int jieQEndY;
        int jieQEndM;
        int jieQEndD;
        if (i == 0) { // 大运开始时间
          List startDyTimeList = startDyTime.split("-");
          jieQStartY = startYear;
          jieQStartM = int.parse(startDyTimeList[1]);
          jieQStartD = int.parse(startDyTimeList[2]);
          jieQEndY = nextSiMap["year"];
          jieQEndM = nextSiMap["month"];
          jieQEndD = nextSiMap["day"];
        } else if (i == size - 1) { // 大运结束时间
          List endDyTimeList = startDyTime.split("-");
          jieQStartY = currentSiMap["year"];
          jieQStartM = currentSiMap["month"];
          jieQStartD = currentSiMap["day"];
          jieQEndY = startYear + i;
          jieQEndM = int.parse(endDyTimeList[1]);
          jieQEndD = int.parse(endDyTimeList[2]);
        } else { // 中间时间段
          jieQStartY = currentSiMap["year"];
          jieQStartM = currentSiMap["month"];
          jieQStartD = currentSiMap["day"];
          jieQEndY = nextSiMap["year"];
          jieQEndM = nextSiMap["month"];
          jieQEndD = nextSiMap["day"];
        }
        double startDyJulian = _calendar.Solar2Julian(jieQStartY, jieQStartM, jieQStartD); // 获取开始儒略历
        double endJulian = _calendar.Solar2Julian(jieQEndY, jieQEndM, jieQEndD); // 获取结束儒略历
        double currentJulian = getCurrentJulianTime(); // 获取当前儒略日时间
        if (currentJulian >= startDyJulian && currentJulian <= endJulian) {
          map["mark"] = true; // 圈住今天
          map["selectToday"] = i;
        } else {
          map["mark"] = false;
        }
      }
      data.add(map);
      columns.add(luckyInfo);
      g = nextG(g);
      z = nextZ(z);
      i++;
    }
    ret["ret"] = 1;
    ret["data"] = data;
    ret["error"] = null;
    return ret;
  }

  /**
   * 流月(点击流年时需要展开的数据)
   * @param year 年
   * @param startMonth 开始月份, 取生日当天
   * @param startMonth 结束月份, 取下一个大运生日前一天
   * @param birthday 公历生日
   * @param startYear 大运开始年
   * @param endYear 大运结束年
   * @param type 0: 中间 1: 头部 2: 尾部, 头尾需要进行截取
   * @param isMark: 是否需要圈今
   * @returns {{g: *, z: *, tip: string}[]}
   */
  getFleetMonth(int year, List birthday, {int startMonth, int endMonth, int startDyDay, int endDyDay, int dyStartYear, int dyEndYear, int type = 0, bool isMark}) {
    Map<String, dynamic> ret = {};
    if (year == null || birthday == null) {
      ret["ret"] = 0;
      ret["data"] = null;
      ret["error"] = "参数错误";
      return ret;
    }
    List si = _calendar.yearJieQi(year);
    // 将公历生日转为农历
    List lunarBirthday = _calendar.Solar2Lunar(birthday[0], birthday[1], birthday[2]);

    // 优化为年上起月法
    var g = year2month(((year + 4712 + 24) % 60 + 60) % 60 % 10);
    var z = 2;
    List<LuckyInfo> result = [];
    List<Map<String, dynamic>> data = [];
    int tempYear = year;
    for (int i = 0; i < si.length; i++) {
      Map<String, dynamic> resultMap = {};
      Map map = si[i];
      LuckyInfo resultInfo = LuckyInfo();
      resultInfo.tg = g;
      resultInfo.dz = z;
      resultInfo.tip = map["month"].toString() + '月' + SolarIterm[i];
      resultInfo.bottomDescibe = resultInfo.tip;
      resultInfo.startDay = map["day"];
      resultInfo.endDay = map["dd"];
      resultMap["ganZhi"] = "$g:$z";
      resultMap["jieLinIndex"] = 1;
      resultMap["solar"] = "$tempYear-${map["month"]}-${map["day"]}";
      resultMap["day"] = map["day"];
      resultMap["month"] = map["month"];
      resultMap["SolarIterm"] = SolarIterm[i];
      resultMap["year"] = tempYear;
      resultMap["jd"] = map["jd"];
      resultMap["nextjd"] = map["nextjd"] - 1;
      if (map["month"] == 12) {
        tempYear += 1;
      }
      data.add(resultMap);
      result.add(resultInfo);
      g = nextG(g);
      z = nextZ(z);
    }
    // 截取需要的月份
    if (type != 0) {
      data =  Chinese.monthRange(year, data, [dyStartYear, startMonth, startDyDay], [dyEndYear, endMonth, endDyDay]);
      if (type == 1) {
        Map first = data[0];
        double jd =  first["jd"];
        List jdSolar = _calendar.Julian2Solar(jd);
        first["month"] = jdSolar[1];
         data[0] = first;
      }
    }


    // 圈今
    double currentJulian = getCurrentJulianTime(); // 获取当前儒略日时间
    double siJulian;
    double nextSiJulian;
    for (int i = 0; i < data.length; i++) {
      Map mapItem = data[i];
      if (type == 1 && i == 0) { // 头部
        siJulian = _calendar.Solar2Julian(dyStartYear, startMonth, startDyDay);
        nextSiJulian = mapItem["nextjd"];
      } else if (type == 2 && i == data.length - 1) { // 尾部
        siJulian = mapItem["jd"];
        nextSiJulian = _calendar.Solar2Julian(dyEndYear, endMonth, endDyDay);
      } else {
        siJulian = mapItem["jd"];
        nextSiJulian = mapItem["nextjd"];
      }
      if (currentJulian >= siJulian && currentJulian < nextSiJulian) { // 圈今计算
        data[i]["mark"] = true; // 圈住今天
        data[i]["selectToday"] = i;
      } else {
        data[i]["mark"] = false;
      }
    }
    // 设置生日
    if (type == 1) { // 头部
      data[0]["isShowBirthDay"] = true;
    } else if (type == 2) { // 尾部
      data[data.length - 1]["isShowBirthDay"] = false;
    } else {
      List birthList  = offsetLunar2solar([year - 1, lunarBirthday[1], lunarBirthday[2], lunarBirthday[3]]); // 计算他去年生日
      List nextBirthList = offsetLunar2solar([year, lunarBirthday[1], lunarBirthday[2], lunarBirthday[3]]); // 计算他今年的公历生日
      List prevBirthList = offsetLunar2solar([year + 1, lunarBirthday[1], lunarBirthday[2], lunarBirthday[3]]); // 明年的公历生日
      double prevBirthJulian = _calendar.Solar2Julian(prevBirthList[0], prevBirthList[1], prevBirthList[2]);
      double birthJulian = _calendar.Solar2Julian(birthList[0], birthList[1], birthList[2]);
      double nextBirthJulian = _calendar.Solar2Julian(nextBirthList[0], nextBirthList[1], nextBirthList[2]);
      List nextSi = _calendar.yearJieQi(year+1); // 求出下一年的节气
      for (int i = 0; i < si.length; i++) {
        Map map = si[i];
        Map nextMap;
        if (i + 1 < si.length) {
          nextMap = si[i + 1];
        }
        if (nextMap == null) {
          nextMap = nextSi[0];
        }
        int mapYear = map["year"];
        int mapMonth = map["month"];
        int mapDay = map["day"];
        int nextMapYear = nextMap["year"];
        int nextMapMonth = nextMap["month"];
        int nextMapDay = nextMap["day"];
        double siJulian = _calendar.Solar2Julian(mapYear, mapMonth, mapDay);
        double nextSiJulian = _calendar.Solar2Julian(nextMapYear, nextMapMonth, nextMapDay);
        if (siJulian <= birthJulian && birthJulian < nextSiJulian) { // 今年的生日
          data[i]["isShowBirthDay"] = true;
          // break;
        }
        if (siJulian <= nextBirthJulian && nextBirthJulian < nextSiJulian) { // 明年的生日
          data[i]["isShowBirthDay"] = true;
          // break;
        }
        if (siJulian <= prevBirthJulian && prevBirthJulian <= nextSiJulian) { // 去年的生日
          data[i]["isShowBirthDay"] = true;
        }
      }
    }
    ret["ret"] = 1;
    ret["data"] = data;
    ret["error"] = null;
    return ret;
  }

  /**
   * 流日(点击流月需要展开的数据)
   * @param year 年
   * @param month 月份
   * @param startDay 月份对应的12节气的开始日期
   * @param distanceMonth 起止日期对应的月份
   * @param delimiterDay 下一个月份对应的12节气开始日期
   * @param type 0: 中间 1: 头部 2: 尾部, 头尾需要进行截取
   * @returns {*[]}
   */
  getFleetDay(int year, int month, int startDay, List birthday, double startJd, double endJd, {int startDyMonth, int endDyMonth, int startDyDay, int endDyDay, int offerStartDyYear, int type, String solarTerms}) {
    Map<String, dynamic> ret = {};
    if (year == null || month == null || startDay == null || birthday == null) {
      ret["ret"] = 0;
      ret["data"] = null;
      ret["error"] = "参数错误";
      return ret;
    }
    // startJd = startJd.floor() - 0.5;
    List startJdSolar = _calendar.Julian2Solar(startJd);
    startJd = _calendar.Solar2Julian(startJdSolar[0], startJdSolar[1], startJdSolar[2], hour: 0, minute: 0, second: 1);
    int tempYear = year;
    int tempMonth = month;

    var firstDay = _calendar.Julian2Solar(startJd);
    var gzd = _instance.GanZhi(firstDay[0], firstDay[1], firstDay[2], 0);
    var tg = gzd[0];
    var dz = gzd[1];
    var dayG = tg[2];
    var dayZ = dz[2];
    var hourG = tg[3];

    List<LuckyInfo> result = [];
    List<Map<String, dynamic>> data = [];

    buildColumns(result, data, tempYear, tempMonth, startJd, endJd, dayG, dayZ, hourG);

    // 获取他今天的日期
    DateTime currentTime = DateTime.now();
    // 将公历生日转为农历
    List lunarBirthday = _calendar.Solar2Lunar(birthday[0], birthday[1], birthday[2]);
    // lunarBirthday
    List lastYearSolarBirth = offsetLunar2solar([year - 1, lunarBirthday[1], lunarBirthday[2], lunarBirthday[3]]);  // 计算他去年的生日
    List solarBirth = offsetLunar2solar([year, lunarBirthday[1], lunarBirthday[2], lunarBirthday[3]]); // 计算他今年的公历生日
    List nextSolarBirth = offsetLunar2solar([year + 1, lunarBirthday[1], lunarBirthday[2], lunarBirthday[3]]); // 明年的公历生日
    if (offerStartDyYear == null) {
      offerStartDyYear = year;
    }
    int solarTempYear;
    // 计算24个节气,为了覆盖所有,需要覆盖上一年的所有节气,以及今年的所有节气
    Map jqMap = _calendar.GetAdjustedJQ(year - 1, 0, 23);
    Map jqNextMap = _calendar.GetAdjustedJQ(year, 0, 23);
    List jieqiList = [];
    List jieqiNextList = [];
    for (int i = 0; i < 23; i++) {
      var jqValue =  jqMap[i];
      List jdSolar = _calendar.Julian2Solar(jqValue);
      jieqiList.add(jdSolar);
    }
    for (int i = 0; i < 23; i++) {
      var jqNextValue = jqNextMap[i];
      List jdNextSolar = _calendar.Julian2Solar(jqNextValue);
      jieqiNextList.add(jdNextSolar);
    }
    for (int i = 0; i < data.length; i++) {
      Map<String, dynamic> item = data[i];
      String solar = item["solar"];
      List<String> solarList = solar.split('-');
      if (solarTempYear == null) {
        solarTempYear = int.parse(solarList[0]);
      }
      int tempMonth = int.parse(solarList[1]);
      int tempday = int.parse(solarList[2]);
      // 圈今处理
      if (tempMonth == currentTime.month &&  tempday == currentTime.day) {
        data[i]["mark"] = true; // 圈住今天
        data[i]["selectToday"] = i;
      } else {
        data[i]["mark"] = false; // 圈住今天
      }
      List lunar = _calendar.Solar2Lunar(solarTempYear, tempMonth, tempday); // 公历转农历
      if (lunar[2] == 1) { // 说明是初一
        item["isLunarFirstDay"] = true;
        data[i] = item;
      }
      if (lunar[3] == 1) { // 说明是闰月
        item["isLunar"] = true;
        data[i] = item;
      }
      // 为了覆盖所有,需要计算上一年的所有节气
      for (int k = 0; k < jieqiList.length; k++) {
        List jieqiSolar = jieqiList[k];
        if (solar == "${jieqiSolar[0]}-${jieqiSolar[1]}-${jieqiSolar[2]}") {
          item["solarIterm"] = this.SolarTerms[k];
          data[i] = item;
        }
      }
      // 计算今年的所有节气
      for (int k = 0; k < jieqiNextList.length; k++) {
        List jieqiSolar = jieqiNextList[k];
        if (solar == "${jieqiSolar[0]}-${jieqiSolar[1]}-${jieqiSolar[2]}") {
          item["solarIterm"] = this.SolarTerms[k];
          data[i] = item;
        }
      }
      if (tempMonth == 12) { // 对下一年的处理
        int days = solarMonthHasDays(solarTempYear, tempMonth);
        if (tempday == days) {
          solarTempYear += 1;
        }
      }
      int lunarMonth = lunar[1];
      int lunarDay = lunar[2];
      if (lunarMonth == 11) {
        lunarMonth = 0;
      } else if (lunarMonth == 12) {
        lunarMonth = 1;
      } else {
        lunarMonth += 1;
      }
      lunarDay -= 1;
      item["lunarMonth"] = lunarMonth;
      item["lunarDay"] = lunarDay;
      if (type == 1) { // 头部
        data[0]["isShowBirthDay"] = true;
      } else if (type == 2) { // 尾部
        data[0]["isShowBirthDay"] = false;
      } else {
        if (solar == "${lastYearSolarBirth[0]}-${lastYearSolarBirth[1]}-${lastYearSolarBirth[2]}" || solar == "${solarBirth[0]}-${solarBirth[1]}-${solarBirth[2]}" || solar == "${nextSolarBirth[0]}-${nextSolarBirth[1]}-${nextSolarBirth[2]}") {
          item["isShowBirthDay"] = true;
        }
      }
      data[i] = item;
    }


    ret["ret"] = 1;
    ret["data"] = data;
    ret["error"] = null;
    return ret;
    // return result;
  }

  /**
   * 起始的子时对应的时干
   * @param hourG
   * @returns {*[]}
   */
  getFleetHour(hourG) {
    Map<String, dynamic> ret = {};
    if (hourG == null) {
      ret["ret"] = 0;
      ret["data"] = null;
      ret["error"] = "参数错误";
      return ret;
    }
    var start = -1;
    var z = 0;
    List<LuckyInfo> result = [];
    List<Map<String, dynamic>> data = [];
    while (start < 12) {
      Map<String, dynamic> resultMap = {};
      LuckyInfo resultInfo = LuckyInfo();
      resultInfo.tg = hourG;
      resultInfo.dz = z;
      resultInfo.tip = "${2 * start + 1}-${(2 * (start + 1) + 1)}";
      resultMap["ganZhi"] = "$hourG:$z";
      resultMap["hours"] = resultInfo.tip;
      data.add(resultMap);
      result.add(resultInfo);
      hourG = nextG(hourG);
      z = nextZ(z);
      start += 1;
    }
    result[0].tip = '0-1';
    result[12].tip = '23-24';
    data[0]["hours"] = '0-1';
    data[12]["hours"] = '23-24';
    ret["ret"] = 1;
    ret["data"] = data;
    ret["error"] = null;
    return ret;
  }

  /**
   * 流年(点击大运需要展开的数据)
   * @param start 开始的年份数组
   * @param end 结束的年份数组
   * @returns {(*|number)[]} 第一个为开始年份，第二个参数为计算尺度
   */
  static yearRange(start, end) {
    var sy = start[0];
    var ey = end[0];
    var spr = spring(start[0]);
    if (solar2julian(start[0], start[1], start[2]) < spr) { // 当前开始时间在当年春分点之前，需要往前多显示一年
      var s = julian2solar(spr);
      if (!(s[0] == start[0] && s[1] == start[1] && s[2] == start[2])) { // 和立春不是同一天
        sy -= 1;
        if (sy == 0) { // 公元0年不存在，向前偏移到公元前1年
          sy = -1;
        }
      }
    }
    var endJd = solar2julian(end[0], end[1], end[2]);
    if (endJd < spring(end[0])) { // 结束时间在今年春分点之前，则今年无需显示
      ey -= 1;
    } else { // 如果在今年春分点以后，也有可能到下年
      if (spring(ey + 1) < endJd) { // 结束时间 在下一年的春分点之后，需要往后多显示一年
        ey += 1;
      }
    }
    return [sy, ey - sy + 1];
  }

  static monthRange(year, List months, start, end) {
    var startJD = solar2julian(start[0], start[1], start[2]);
    var endJD = solar2julian(end[0], end[1], end[2]) + 0.0000157;
    var interval = [months[0]["jd"], months[months.length - 1]["nextjd"]];
    List<Map<String, dynamic>> tempMonth = [];
    if (interval[0] < startJD && startJD < interval[1]) { // 开始时间在今年中

      for (int i = 0; i < months.length; i++) {
        var month = months[i];
        if (month["nextjd"] < startJD) {
          continue;
        }
        if (month["jd"] < startJD) {
          month["jd"] = startJD;
        }
        tempMonth.add(month);
      }
    }

    List<Map<String, dynamic>> tempJMonth = [];
    if (interval[0] < endJD && endJD < interval[1]) { // 结束时间在今年中
      for (int i = 0; i < months.length; i++) {
        var month = months[i];
        if (month["nextjd"] < endJD) {
          tempJMonth.add(month);
          continue;
        }
        if (month["jd"] < endJD) {
          month["nextjd"] = endJD;
          tempJMonth.add(month);
          continue;
        }
      }
    }
    if (tempJMonth.length != 0) {
      return tempJMonth;
    } else if (tempMonth.length != 0) {
      return tempMonth;
    } else {
      return months;
    }
  }

  /**
   * 获取某年立春
   * @param yer
   * @returns {*}
   * */
  static spring(int year) {
    return adjustedJQ(year - 1, 21, 21)[21];
  }

  /**
   * 实仁计算span
   * @param birthtimeJD 出生时间儒略日
   * @param nearbyJD 靠近的节气儒略日
   * @param forward 顺排还是逆排
   * @returns {number}
   */
  shirenSpan(birthtimeJD, nearbyJD, bool forward) {
     List birthSolar = _calendar.Julian2Solar(birthtimeJD);
     List nearBySolar = _calendar.Julian2Solar(nearbyJD);
     var diff;
     for (int i = 0; i < 3; i++) {
       if (birthSolar[i] != nearBySolar[i]) {
         diff = 1;
         break;
       }
       diff = 0;
     }
    // 儒略日格式化为整数(即从当天12时计算),从生日到节气的间隔+节气那天(出生这天和节气不是同一天的时候，才额外加)
    return (birthtimeJD.floor() - (forward ? nearbyJD.floor() : nearbyJD.ceil())).abs() + diff;
  }

  // 私有方法
  // 计算流日
  buildColumns(List<LuckyInfo> result, List<Map<String, dynamic>> data, int year, int month, double startJD, double endJD, int dayG, int dayZ, int hourG) {
    while (startJD < endJD) {
      LuckyInfo resultInfo = LuckyInfo();
      List solar = _calendar.Julian2Solar(startJD);

      Map<String, dynamic> resultMap = {};
      resultInfo.tip = "${solar[1]}月${solar[2]}日";
      resultInfo.bottomDescibe = resultInfo.tip;
      resultInfo.tg = dayG;
      resultInfo.dz = dayZ;
      resultInfo.hourG = hourG;
      resultMap["ganZhi"] = "$dayG:$dayZ";
      resultMap["solar"] = "${solar[0]}-${solar[1]}-${solar[2]}";
      resultMap["hourG"] = hourG;
      resultMap["tip"] = resultInfo.tip;
      resultMap["month"] = month;

      result.add(resultInfo);
      data.add(resultMap);
      dayG = nextG(dayG);
      dayZ = nextZ(dayZ);
      hourG = (hourG + 12) % 10;
      startJD += 1;
    }
  }


  /**
   * 找不到农历就往前退一天直到找到为止
   * @param year 农历年
   * @param month 农历月
   * param day 农历天
   * @returns {*[]}
   */
  List findNextSolarBirthday(int year, int month, int day) {
    // 获取下一年的公历生日
    List nextSolarBirthday = _calendar.Lunar2Solar(year, month, day);
    while (nextSolarBirthday == null) {
      // 获取生日前一天
      List lunarBirthBefore = getLunarBeforeDay(year, month, day);
      nextSolarBirthday = _calendar.Lunar2Solar(lunarBirthBefore[0], lunarBirthBefore[1], lunarBirthBefore[2]);
    }
    return nextSolarBirthday;
  }

  /**
   * 获取前一天
   * @param year
   * @param month
   * param day
   * @returns {*[]}
   */
  getBeforeDay(int year, int month, int day) {
    if (day == 1) {
      if (month == 1) { // 进年
        year -= 1;
        month = 12;
      } else { // 进月
        month -= 1;
      }
      // 获取这个月有几天
      int dm = solarMonthHasDays(year, month);
      day = dm;
      return [year, month, day];
    }
    // 正常前进一天
    day -= 1;
    return [year, month, day];
  }

  /**
   * 获取农历前一天
   * @param year
   * @param month
   * param day
   * @returns {*[]}
   */
  getLunarBeforeDay(int year, int month, int day, {bool isLeap = false}) {
    if (day == 1) {
      if (month == 1) { // 进年
        year -= 1;
        month = 12;
      } else { // 进月
        month -= 1;
      }
      // 获取这个月有几天
      int dm = lunarMonthHasDays(year, month, isLeap);
      day = dm;
      return [year, month, day];
    }
    // 正常前进一天
    day -= 1;
    return [year, month, day, 0];
  }

  // 农历转公历
  Map Lunar2Solar(int year, int month, int day, {bool isLeap = false, String time = "0:0:00"}) {
    Map<String, dynamic> ret = Map();
    if (isLeap == null || year == null || month == null || day == null) {
      ret["ret"] = 0;
      ret["data"] = null;
      ret["error"] = "参数错误";
      return ret;
    }
    List solar = offsetLunar2solar([year, month, day, isLeap ? 1 : 0]);
    int solarYear = solar[0];
    int solarMonth = solar[1];
    int solarDay = solar[2];
    // debugPrint("solar: $solar");
    Map result = Fate(true, solarYear, solarMonth, solarDay);
    Map<String, dynamic> fateData = result["data"];
    Map<String, dynamic> data = {};
    data["solar"] = "$solarYear-$solarMonth-$solarDay";
    data["mcIndex"] = fateData["mcIndex"];
    data["diIndex"] = fateData["diIndex"];
    data["Lyear2"] = fateData["Lyear2"];
    data["isLun"] = fateData["isLun"];
    data["beforeJqTime"] = fateData["preJieLinTime"];
    data["beforeJqIndex"] = fateData["preJieLinIndex"];
    data["afterJqTime"] = fateData["nextJieLinTime"];
    data["afterJqIndex"] = fateData["nextJieLinIndex"];
    data["time"] = time;
    data["siZhu"] = fateData["sizhu"];

    ret["ret"] = 1;
    ret["data"] = data;
    ret["error"] = "";
    return ret;
  }

  // 公历转农历
  Map Solar2Lunar(int year, int month, int day, {String time = "0:0:00"}) {
    Map<String, dynamic> ret = Map();
    if (year == null || month == null || day == null) {
      ret["ret"] = 0;
      ret["data"] = null;
      ret["error"] = "参数错误";
      return ret;
    }
    Map result = Fate(true, year, month, day);
    Map<String, dynamic> fateData = result["data"];
    Map<String, dynamic> data = {};
    data["solar"] = "$year-$month-$day";
    data["mcIndex"] = fateData["mcIndex"];
    data["diIndex"] = fateData["diIndex"];
    data["Lyear2"] = fateData["Lyear2"];
    data["isLun"] = fateData["isLun"];
    data["beforeJqTime"] = fateData["preJieLinTime"];
    data["beforeJqIndex"] = fateData["preJieLinIndex"];
    data["afterJqTime"] = fateData["nextJieLinTime"];
    data["afterJqIndex"] = fateData["nextJieLinIndex"];
    data["time"] = time;
    data["siZhu"] = fateData["sizhu"];

    ret["ret"] = 1;
    ret["data"] = data;
    ret["error"] = "";
    return ret;
  }

  // 获取某年农历的润月,如果没有润月的年则返回0
  Future<Map<String, dynamic>> getLunByYear({
    @required int year,
  }) async {
    Map<String, dynamic> ret = Map();
    Chinese _chinese = Chinese.getInstance();
    if (year == null) {
      ret["ret"] = 0;
      ret["data"] = null;
      ret["error"] = "参数错误";
      return ret;
    }
    Map<String, dynamic> data = {};
    List<int> months = [1 , 15, 28];
    for (int i = 1; i < 13; i++) {
      for (int k = 0; k < months.length; k++) {
        List lunar = _calendar.Solar2Lunar(year + 1, i, months[k]);
        if (lunar == null) {
          continue;
        }
        if (lunar.last == 1 && year == lunar[0]) {
          data["month"] = lunar[1];
        }
      }
    }


    for (int i = 1; i < 13; i++) {
      for (int k = 0; k < months.length; k++) {
        List lunar = _calendar.Solar2Lunar(year, i, months[k]);
        if (lunar == null) {
          continue;
        }
        if (lunar.last == 1 && year == lunar[0]) {
          data["month"] = lunar[1];
        }
      }
    }

    for (int i = 1; i < 13; i++) {
      for (int k = 0; k < months.length; k++) {
        List lunar = _calendar.Solar2Lunar(year - 1, i, months[k]);
        if (lunar == null) {
          continue;
        }
        if (lunar.last == 1 && year == lunar[0]) {
          data["month"] = lunar[1];
        }
      }
    }

    if (data["month"] == null) {
      data["month"] = 0;
    }
    ret["ret"] = 1;
    ret["data"] = data;
    ret["error"] = "";
    return ret;
  }

  // 获取农历月的天数
  getLunarMonthDayNum(int year, int month, bool isLeap) {
    Map<String, dynamic> ret = Map();
    if (year == null) {
      ret["ret"] = 0;
      ret["data"] = null;
      ret["error"] = "参数错误";
      return ret;
    }
    Map<String, dynamic> data = {};
    int days = lunarMonthHasDays(year, month, isLeap);
    data["num"] = days;
    ret["ret"] = 1;
    ret["data"] = data;
    ret["error"] = "";
    return ret;
  }

  /**
   * 根据八字干支查找对应的公历日期
   * @param yearColumn 年柱的60甲子年索引
   * @param monthColumn 月柱的60甲子年索引
   * @param dayColumn 日柱的60甲子年索引
   * @param hourColumn 时柱的60甲子年索引
   * @param zzs 早(true)/晚(false)子时，时柱为X子才会生效
   * @param startYear
   * @param mx
   */
  gz2datetime(String sizhu,
      {bool zzs = true, int startYear = 600, int mx = 27}) {
    Map<String, dynamic> ret = Map();
    if (sizhu == null) {
      ret["ret"] = 0;
      ret["data"] = null;
      ret["error"] = "参数错误";
      return ret;
    }
   List<dynamic> result = _calendar.gz2datetime(sizhu, zzs: zzs, startYear: startYear, mx: mx);
   List<Map<String, dynamic>> data = [];
    List<String> sizhuList = sizhu.split(":");
    int hz = int.parse(sizhuList[7]);
    String hour = "00";
    if (zzs == false && (hz == 0 || hz == 12)) {
      hour = "23";
    } else if (hz == 0) {
      hour = "00";
    } else if (hz == 1) {
      hour = "01";
    } else if (hz == 2) {
      hour = "03";
    } else if (hz == 3) {
      hour = "05";
    } else if (hz == 4) {
      hour = "07";
    } else if (hz == 5) {
      hour = "09";
    } else if (hz == 6) {
      hour = "11";
    } else if (hz == 7) {
      hour = "13";
    } else if (hz == 8) {
      hour = "15";
    } else if (hz == 9) {
      hour = "17";
    } else if (hz == 10) {
      hour = "19";
    } else if (hz == 11) {
      hour = "21";
    }


    for(int i = 0; i < result.length; i++) {
     var item = result[result.length - i - 1];
     int y = item[0];
     int m = item[1];
     int d = item[2];
     Map fateResult = Fate(true, y, m, d, hour: item[3], minute: item[4], second: item[5]);
     Map<String, dynamic> itemMap = {};
     Map<String, dynamic> fateData = fateResult["data"];
     itemMap["solar"] = "$y-$m-$d";
     itemMap["mcIndex"] = fateData["mcIndex"];
     itemMap["diIndex"] = fateData["diIndex"];
     itemMap["Lyear2"] = fateData["Lyear2"];
     itemMap["isLun"] = fateData["isLun"];
     itemMap["siZhu"] = fateData["sizhu"];
     itemMap["time"] = "$hour:00:00";
     itemMap["jd"] = fateData["jd"];
     data.add(itemMap);
   }
    ret["ret"] = 1;
    ret["data"] = data;
    ret["error"] = "";
    return ret;
  }

  // 获取当前儒略日时间
  double getCurrentJulianTime() {
    DateTime currentTime = DateTime.now(); // 获取当前时间
    return _calendar.Solar2Julian(currentTime.year, currentTime.month, currentTime.day); // 将当前时间转为儒略日
  }

  /**
   * 下一个天干索引
   * @example 环形排列天干，获取当前天干的下一个天干索引
   * @param i
   * @return int
   */
  nextG(i)
  {
    return next(i, 10);
  }

  /**
   * 上一个天干索引
   * @example 环形排列天干，获取当前天干的上一个天干索引
   * @param i
   * @return int
   */
  prevG(i)
  {
    return prev(i, 10);
  }

  /**
   * 下一个地支
   * @example 环形排列地支，获取当前地支的下一个地支索引
   * @param i
   * @return int
   */
  nextZ(int i)
  {
    return next(i, 12);
  }

  /**
   * 上一个地支
   * @example 环形排列地支，获取当前地支的上一个地支索引
   * @param i 当前地支的索引，如 丑->1
   * @return int
   */
  prevZ(int i)
  {
    return prev(i, 12);
  }


  /**
   * 年上起月法
   * @param yearGan 年干
   * @return int 月干(月支都从寅开始)
   */
  year2month(int yearGan)
  {
    return ((yearGan % 5 + 1) * 2) % 10;
  }

  /**
   * 日上起时法
   * @param dayGan 日干
   * @return int 时干(时支都从子开始)
   */
  day2hour(int dayGan)
  {
    return (dayGan % 5) * 2;
  }

  /**
   * 环形偏移下一个
   * @param current 当前
   * @param size 环形内数值个数
   * @return int
   */
  next(int current, int size)
  {
    return (current + 1) % size;
  }

  /**
   * 环形偏移上一个
   * @param current 当前
   * @param size 环形内数值个数
   * @return int
   */
  prev(int current, int size)
  {
    return (current + size - 1) % size;
  }
}
