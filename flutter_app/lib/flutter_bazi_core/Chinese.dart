import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/flutter_bazi_core/bazi_core.dart';

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

/**
 * 天干地支
 * Class Chinese
 *
 */
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

  /** 廿四节气(从春分开始) */
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

  /**
   * 某公历年立春点开始的24节气
   * @param int year
   * @return array jq[($k+21)%24]
   */
  solarTerms(int year) {
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

  /**
   * 四柱计算,分早子时晚子时,传公历
   * @param int year
   * @param int month
   * @param int day
   * @param int hour 时间(0-23)
   * @param int minute 分钟数(0-59),在跨节的时辰上会需要,有的排盘忽略了跨节
   * @param int second 秒数(0-59)
   * @param bool $zero
   * @return array(天干, 地支, 对应的儒略日历时间, 对应年的12节+前后N节, 对应时间所处节的索引)
   */
  GanZhi(int year, int month, int day, int hour,
      {int minute = 0, int second = 0, bool zero = true}) {
    // int hour = 0, int minute = 0, int second = 0
    double jd = _calendar.Solar2Julian(year, month, day,
        hour: hour, minute: minute, second: max(1, second));
    // debugPrint("GanZhi-jd: $jd");
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
    int theS = ((jdA - (jdA ~/ 1)) * 86400) ~/ 1 +
        3600; //将jd的小数部份化为秒,並加上起始點前移的一小时(3600秒),取其整数值
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

  /**
   * 公历年排盘
   * @param bool isMale 是否为男性
   * @param int year
   * @param int month
   * @param int day
   * @param int hour 时间(0-23)
   * @param int minute 分钟数(0-59),在跨节的时辰上会需要,有的排盘忽略了跨节
   * @param int second 秒数(0-59)
   * @return array
   */
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

    // list($tg, $dz, $jd, $jq, $ix) =

    List ganZhiList = _instance.GanZhi(year, month, day, hour,
        minute: minute, second: second);
    List tg = ganZhiList[0];
    List dz = ganZhiList[1];
    double jd = ganZhiList[2];
    List jq = ganZhiList[3];
    int ix = ganZhiList[4];

    int pn = tg[0] % 2; //起大运.阴阳年干:0阳年1阴年
    double span = 0;

    if ((isMale && pn == 0) || (!isMale && pn == 1)) {
      //起大运时间,阳男阴女顺排
      span = jq[ix + 1] - jd; //往后数一个节,计算时间跨度
      for (int i = 1; i <= 12; i++) {
        //大运干支
        LuckyG.add((tg[1] + i) % 10);
        LuckyZ.add((dz[1] + i) % 12);
      }
    } else {
      // 阴男阳女逆排,往前数一个节
      span = jd - jq[ix];
      for (int i = 1; i <= 12; i++) {
        //确保是正数
        LuckyG.add((tg[1] + 20 - i) % 10);
        LuckyZ.add((dz[1] + 24 - i) % 12);
      }
    }

    int days = (span * 4 * 30)
        .truncate(); //折合成天数:三天折合一年,一天折合四个月,一个时辰折合十天,一个小时折合五天,反推得到一年按360天算,一个月按30天算
    int y = (days / 360).truncate(); //三天折合一年
    int m = (days % 360 / 30).truncate(); //一天折合四个月
    int d = days % 360 % 30; //一个小时折合五天
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

    for (int i = 0; i <= 3; i++) {
      String bazi = bzInfo.bazi ?? "";
      bazi += GAN[tg[i]];
      bazi += ZHI[dz[i]];
      bzInfo.bazi = bazi;
    }
    List dyStartTime = [];
    for (int i = 0; i < 12; i++) {
      String dyBazi = bzInfo.dyBazi ?? "";
      dyBazi += GAN[LuckyG[i]];
      dyBazi += ZHI[LuckyZ[i]];
      bzInfo.dyBazi = dyBazi;
      dyStartTime.add(_calendar.Julian2Solar(start_jd_time + i * 10 * 360));
    }
    bzInfo.dyStartTime = dyStartTime;
    debugPrint("起大运: tg: $tg, dz: $dz");

    // 计算前后节气时间
    debugPrint("计算前后节气时间: jd: $jd, jq: $jq ix: $ix");
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
    bzInfo.sex = isMale ? 1 : -1;
    bzInfo.nianTianYinYang = pn == 0 ? 1 : -1;
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

    int newDyStartTime = year + (span / 3).round();
    bzInfo.newDyStartTime = newDyStartTime;
    debugPrint("newDyStartTime: $newDyStartTime");
    var luckyYear = pureJQSinceSpring(newDyStartTime);
    List<int> solarLuckyYear = julian2solar(luckyYear[1]);
    bzInfo.newDyStartTimeDes = datetime2string(solarLuckyYear);
    bzInfo.startYun = datetime2stringCommon(solarLuckyYear);

    List<Map<String, dynamic>> dy = [];
    int startDyTime = bzInfo.newDyStartTime;
    for (int i = 0; i < bzInfo.dyTg.length; i++) {
      if (i >= 10) {
        break;
      }
      int tg = bzInfo.dyTg[i];
      int dz = bzInfo.dyDz[i];
      Map<String, dynamic> map = {};
      map["year"] = startDyTime;
      map["old"] = startDyTime - year;
      map["ganZhi"] = "$tg:$dz";
      startDyTime += 10;
      dy.add(map);
    }
    bzInfo.dayun = dy;


    debugPrint("newDyStartTime: ${bzInfo.newDyStartTimeDes}");
    Map<String, dynamic> data = {};
    ret["ret"] = 1;
    data["mcIndex"] = bzInfo.lMonth;
    data["diIndex"] = bzInfo.lDay;
    data["Lyear2"] = bzInfo.lYear;
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
    String sizhu = "";
    for (int i = 0; i < bzInfo.tg.length; i++) {
      int tg = bzInfo.tg[i];
      int dz = bzInfo.dz[i];
      sizhu += "$tg:";
      i == bzInfo.tg.length - 1 ? sizhu += "$dz" : sizhu += "$dz:";
    }
    data["sizhu"] = sizhu;
    ret["data"] = data;
    ret["error"] = "";
    return ret;

    // return bzInfo;
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
    }
    return "${data[0]}-${data[1]}-${data[2]} ${data[3]}:${data[4]}:$second";
  }

  /**
   * 流年(点击大运需要展开的数据)
   * @param year 年
   * @param size 获取的条目书，如1990年开始往后十年(1990～1999),就是10
   * @returns {*[]}
   */
  getFleetYear(int startYear, int old, {int size = 10}) {
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
      map["year"] = startYear + i;
      map["old"] = old + i;
      map["ganZhi"] = "$g:$z";
      data.add(map);
      columns.add(luckyInfo);
      g = nextG(g);
      z = nextZ(z);
      i++;
    }
    ret["ret"] = 1;
    ret["data"] = data;
    ret["error"] = null;
    debugPrint("getFleetYear---ret: $ret");
    return ret;
    // return columns;
  }

  /**
   * 流月(点击流年时需要展开的数据)
   * @param year 年
   * @returns {{g: *, z: *, tip: string}[]}
   */
  getFleetMonth(int year) {
    Map<String, dynamic> ret = {};
    if (year == null) {
      ret["ret"] = 0;
      ret["data"] = null;
      ret["error"] = "参数错误";
      return ret;
    }
    List si = _calendar.yearJieQi(year);

    // 优化为年上起月法
    var g = year2month(((year + 4712 + 24) % 60 + 60) % 60 % 10);
    var z = 2;
    List<LuckyInfo> result = [];
    List<Map<String, dynamic>> data = [];
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
      resultMap["solar"] = "$year-${map["month"]}-${map["day"]}";
      resultMap["day"] = map["day"];
      resultMap["dd"] = map["dd"];
      resultMap["SolarIterm"] = SolarIterm[i];
      data.add(resultMap);
      result.add(resultInfo);
      g = nextG(g);
      z = nextZ(z);
    }
    ret["ret"] = 1;
    ret["data"] = data;
    ret["error"] = null;
    debugPrint("getFleetMonth---ret: $ret");
    return ret;
    // return result;
  }

  /**
   * 流日(点击流月需要展开的数据)
   * @param year 年
   * @param month 月份
   * @param startDay 月份对应的12节气的开始日期
   * @param delimiterDay 下一个月份对应的12节气开始日期
   * @returns {*[]}
   */
  getFleetDay(int year, int month, int startDay, int delimiterDay) {
    Map<String, dynamic> ret = {};
    if (year == null || month == null) {
      ret["ret"] = 0;
      ret["data"] = null;
      ret["error"] = "参数错误";
      return ret;
    }
    var dayN = solarMonthHasDays(year, month);

    var gzd = _instance.GanZhi(year, month, startDay, 0);
    var tg = gzd[0];
    var dz = gzd[1];
    var dayG = tg[2];
    var dayZ = dz[2];
    var hourG = tg[3];

    List<LuckyInfo> result = [];
    List<Map<String, dynamic>> data = [];
    var nextStartDay = startDay - dayN;
    while (startDay < dayN || nextStartDay < delimiterDay) {
      Map<String, dynamic> resultMap = {};
      var m, d;
      if (nextStartDay > 0) {
        m = (month + 1) % 13;
        d = nextStartDay;
      } else {
        d = startDay;
        m = month;
      }
      LuckyInfo resultInfo = LuckyInfo();
      resultInfo.tip = "$m月$d日";
      resultInfo.bottomDescibe = resultInfo.tip;
      resultInfo.tg = dayG;
      resultInfo.dz = dayZ;
      resultInfo.hourG = hourG;
      resultMap["ganZhi"] = "$dayG:$dayZ";
      resultMap["solar"] = "$year-$month-$startDay";
      resultMap["hourG"] = hourG;
      data.add(resultMap);
      result.add(resultInfo);
      dayG = _instance.nextG(dayG);
      dayZ = _instance.nextZ(dayZ);
      hourG = (hourG + 12) % 10;
      startDay++;
      nextStartDay++;
    }
    ret["ret"] = 1;
    ret["data"] = data;
    ret["error"] = null;
    debugPrint("getFleetMonth---ret: $ret");
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
    // debugPrint("getFleetHour---ret: $ret");
    return ret;
    // return result;
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
