import 'dart:math';

import 'package:flutter/cupertino.dart';

class BzInfo {
  List tg; // 天干
  List dz; // 地支
  var jd; // 对应的儒略日
  List jq; // 日期前后节气的儒略日
  int jqi; // 对应的节气索引
  BzInfo({this.tg, this.dz, this.jd, this.jq, this.jqi});
}

class BzPlate {
  List tg; // 天干
  List dz; // 地支
  String luckyDesc; // 起运日期描述
  List luckyTg; // 大运天干
  List luckyDz; // 大运地支
  List luckyDatetime; // 每个大运对应的起运具体时间
  String frontName;
  String frontTime;
  String backName;
  String backTime;

  BzPlate(
      {this.tg,
      this.dz,
      this.luckyTg,
      this.luckyDz,
      this.luckyDesc,
      this.luckyDatetime,
      this.frontName,
      this.frontTime,
      this.backName,
      this.backTime});
}

const synMonth = 29.530588853;

// 因子
const ptsA = [
  485,
  203,
  199,
  182,
  156,
  136,
  77,
  74,
  70,
  58,
  52,
  50,
  45,
  44,
  29,
  18,
  17,
  16,
  14,
  12,
  12,
  12,
  9,
  8
];
const ptsB = [
  324.96,
  337.23,
  342.08,
  27.85,
  73.14,
  171.52,
  222.54,
  296.72,
  243.58,
  119.81,
  297.17,
  21.02,
  247.54,
  325.15,
  60.93,
  155.12,
  288.79,
  198.04,
  199.76,
  95.39,
  287.11,
  320.81,
  227.73,
  15.45
];
const ptsC = [
  1934.136,
  32964.467,
  20.186,
  445267.112,
  45036.886,
  22518.443,
  65928.934,
  3034.906,
  9037.513,
  33718.147,
  150.678,
  2281.226,
  29929.562,
  31555.956,
  4443.417,
  67555.328,
  4562.452,
  62894.029,
  31436.921,
  14577.848,
  31931.756,
  34777.259,
  1222.114,
  16859.074
];

// 检查1582年
check1582(int year, int month, int day) {
  return year == 1582 && month == 10 && day >= 5 && day < 15;
}

timeIsOk(int hour, int minute, int second) {
  return 0 <= hour &&
      hour <= 24 &&
      0 <= minute &&
      minute <= 60 &&
      0 <= second &&
      second <= 60;
}

dateIsOk(int year, int month, int day) {
  if (year < -1000 ||
      year > 3000 ||
      month < 1 ||
      month > 12 ||
      check1582(year, month, day)) {
    return false;
  }
  int ndf1 = -(year % 4 == 0 ? 1 : 0);
  bool ndf2 =
      ((((year % 400 == 0) ? 1 : 0) - ((year % 100 == 0) ? 1 : 0)) == 1) &&
          (year > 1582);
  int ndf = ndf1 + (ndf2 ? 1 : 0);
  double dom =
      30 + (((month - 7.5).abs() + 0.5) % 2) - (month == 2 ? 1 : 0) * (2 + ndf);
  return 0 < day && day <= dom;
}

/**
 * 将公历时间转换为儒略日历时间
 * @return boolean|number
 * @param year
 * @param month
 * @param day
 * @param hour
 * @param minute
 * @param second
 */
solar2julian(year, month, day, {hour = 0, minute = 0, second = 0}) {
  if (!(dateIsOk(year, month, day) && timeIsOk(hour, minute, second))) {
    return null;
  }

  int yp = year + ((month - 3) / 10).floor();
  var yearJD;
  var init;
  if ((year > 1582) ||
      (year == 1582 && month > 10) ||
      (year == 1582 && month == 10 && day >= 15)) {
    //这一年有十天是不存在的
    init = 1721119.5;
    yearJD = (yp * 365.25).floor() - (yp / 100).floor() + (yp / 400).floor();
  } else if ((year < 1582) ||
      (year == 1582 && month < 10) ||
      (year == 1582 && month == 10 && day <= 4)) {
    init = 1721117.5;
    yearJD = (yp * 365.25).floor();
  } else {
    return null;
  }
  int mp = (month + 9).floor() % 12;
  int monthJD = mp * 30 + ((mp + 1) * 34 / 57).floor();
  int dayJD = day - 1;
  var hourJd = (hour + (minute + (second / 60)) / 60) / 24;
  return yearJD + monthJD + dayJD + hourJd + init;
}

/**
 * 将儒略日历时间转换为公历(格里高利历)时间
 * @param jd
 * @return array(年,月,日,时,分,秒)
 */
julian2solar(double jd) {
  var init, y4h;
  if (jd >= 2299160.5) {
    y4h = 146097;
    init = 1721119.5;
  } else {
    y4h = 146100;
    init = 1721117.5;
  }
  int jdr = (jd - init).floor();
  double yh = y4h / 4;
  int cen = ((jdr + 0.75) / yh).floor();
  int d = (jdr + 0.75 - cen * yh).floor();
  double ywl = 1461 / 4;
  int jy = ((d + 0.75) / ywl).floor();
  d = (d + 0.75 - ywl * jy + 1).floor();
  const ml = 153 / 5;
  int mp = ((d - 0.5) / ml).floor();
  d = ((d - 0.5) - 30.6 * mp + 1).floor();
  int y = (100 * cen) + jy;
  int m = (mp + 2) % 12 + 1;
  if (m < 3) {
    y = y + 1;
  }
  int sd = ((jd + 0.5 - (jd + 0.5).floor()) * 24 * 60 * 60 + 0.00005).floor();
  var mt = (sd / 60).floor();
  int ss = sd % 60;
  int hh = (mt / 60).floor();
  mt = mt % 60;
  int yy = y.floor();
  int mm = m.floor();
  int dd = d.floor();

  return [yy, mm, dd, hh, mt, ss];
}

/**
 * 对于指定日期时刻所属的朔望月,求出其均值新月点的月序数
 * @param jd
 * @return (number|number)[]
 */
meanNewMoon(var jd) {
  int kn = ((jd - 2451550.09765) / synMonth).floor();
  double jdt = 2451550.09765 + kn * synMonth;
  double t = (jdt - 2451545) / 36525;
  double theJD = jdt +
      0.0001337 * t * t -
      0.00000015 * t * t * t +
      0.00000000073 * t * t * t * t;
  return [kn, theJD];
}

/**
 * 获取指定年的春分开始的24节气,另外多取2个确保覆盖完一个公历年
 * 大致原理是:先用此方法得到理论值,再用摄动值(Perturbation)和固定参数DeltaT做调整
 * @return *[]
 * @param year
 */
meanJQJD(int year) {
  var i;
  var jd = VE(year);
  if (jd == 0) {
    return [];
  } //该年的春分點
  var ty = VE(year + 1) - jd; //该年的回歸年長

  const num = 26;

  const ath = 2 * pi / 24;
  var tx = (jd - 2451545) / 365250;
  var e = 0.0167086342 -
      0.0004203654 * tx -
      0.0000126734 * tx * tx +
      0.0000001444 * tx * tx * tx -
      0.0000000002 * tx * tx * tx * tx +
      0.0000000003 * tx * tx * tx * tx * tx;
  var tt = year / 1000;
  var vp = 111.25586939 -
      17.0119934518333 * tt -
      0.044091890166673 * tt * tt -
      4.37356166661345E-04 * tt * tt * tt +
      8.16716666602386E-06 * tt * tt * tt * tt;
  var rvp = vp * 2 * pi / 360;
  var peri = [];
  for (i = 0; i < num; i++) {
    int flag = 0;
    var th = ath * i + rvp;
    if (pi < th && th <= 3 * pi) {
      th = 2 * pi - th;
      flag = 1;
    } else if (3 * pi < th) {
      th = 4 * pi - th;
      flag = 2;
    }
    var f1 = 2 * atan((sqrt((1 - e) / (1 + e)) * tan(th / 2)));
    var f2 = (e * sqrt(1 - e * e) * sin(th)) / (1 + e * cos(th));
    var f = (f1 - f2) * ty / 2 / pi;
    if (flag == 1) {
      f = ty - f;
    } else if (flag == 2) {
      f = 2 * ty - f;
    }
    peri.add(f);
  }
  var JDs = [];
  for (i = 0; i < num; i++) {
    JDs.add(jd + peri[i] - peri[0]);
  }

  return JDs;
}

/**
 * 求出實際新月點
 * 以2000年初的第一個均值新月點為0點求出的均值新月點和其朔望月之序數 k 代入此副程式來求算實際新月點
 * @param k
 * @return number
 */
trueNewMoon(int k) {
  var jdt = 2451550.09765 + k * synMonth;
  var t = (jdt - 2451545) / 36525;
  var t2 = t * t;
  var t3 = t2 * t;
  var t4 = t3 * t;
  var pt = jdt + 0.0001337 * t2 - 0.00000015 * t3 + 0.00000000073 * t4;
  var m = 2.5534 + 29.10535669 * k - 0.0000218 * t2 - 0.00000011 * t3;
  var mprime = 201.5643 +
      385.81693528 * k +
      0.0107438 * t2 +
      0.00001239 * t3 -
      0.000000058 * t4;
  var f = 160.7108 +
      390.67050274 * k -
      0.0016341 * t2 -
      0.00000227 * t3 +
      0.000000011 * t4;
  var omega = 124.7746 - 1.5637558 * k + 0.0020691 * t2 + 0.00000215 * t3;
  var es = 1 - 0.002516 * t - 0.0000074 * t2;
  var pi180 = pi / 180;
  var apt1 = -0.4072 * sin(pi180 * mprime);
  apt1 += 0.17241 * es * sin(pi180 * m);
  apt1 += 0.01608 * sin(pi180 * 2 * mprime);
  apt1 += 0.01039 * sin(pi180 * 2 * f);
  apt1 += 0.00739 * es * sin(pi180 * (mprime - m));
  apt1 -= 0.00514 * es * sin(pi180 * (mprime + m));
  apt1 += 0.00208 * es * es * sin(pi180 * (2 * m));
  apt1 -= 0.00111 * sin(pi180 * (mprime - 2 * f));
  apt1 -= 0.00057 * sin(pi180 * (mprime + 2 * f));
  apt1 += 0.00056 * es * sin(pi180 * (2 * mprime + m));
  apt1 -= 0.00042 * sin(pi180 * 3 * mprime);
  apt1 += 0.00042 * es * sin(pi180 * (m + 2 * f));
  apt1 += 0.00038 * es * sin(pi180 * (m - 2 * f));
  apt1 -= 0.00024 * es * sin(pi180 * (2 * mprime - m));
  apt1 -= 0.00017 * sin(pi180 * omega);
  apt1 -= 0.00007 * sin(pi180 * (mprime + 2 * m));
  apt1 += 0.00004 * sin(pi180 * (2 * mprime - 2 * f));
  apt1 += 0.00004 * sin(pi180 * (3 * m));
  apt1 += 0.00003 * sin(pi180 * (mprime + m - 2 * f));
  apt1 += 0.00003 * sin(pi180 * (2 * mprime + 2 * f));
  apt1 -= 0.00003 * sin(pi180 * (mprime + m + 2 * f));
  apt1 += 0.00003 * sin(pi180 * (mprime - m + 2 * f));
  apt1 -= 0.00002 * sin(pi180 * (mprime - m - 2 * f));
  apt1 -= 0.00002 * sin(pi180 * (3 * mprime + m));
  apt1 += 0.00002 * sin(pi180 * (4 * mprime));

  var apt2 = 0.000325 * sin(pi180 * (299.77 + 0.107408 * k - 0.009173 * t2));
  apt2 += 0.000165 * sin(pi180 * (251.88 + 0.016321 * k));
  apt2 += 0.000164 * sin(pi180 * (251.83 + 26.651886 * k));
  apt2 += 0.000126 * sin(pi180 * (349.42 + 36.412478 * k));
  apt2 += 0.00011 * sin(pi180 * (84.66 + 18.206239 * k));
  apt2 += 0.000062 * sin(pi180 * (141.74 + 53.303771 * k));
  apt2 += 0.00006 * sin(pi180 * (207.14 + 2.453732 * k));
  apt2 += 0.000056 * sin(pi180 * (154.84 + 7.30686 * k));
  apt2 += 0.000047 * sin(pi180 * (34.52 + 27.261239 * k));
  apt2 += 0.000042 * sin(pi180 * (207.19 + 0.121824 * k));
  apt2 += 0.00004 * sin(pi180 * (291.34 + 1.844379 * k));
  apt2 += 0.000037 * sin(pi180 * (161.72 + 24.198154 * k));
  apt2 += 0.000035 * sin(pi180 * (239.56 + 25.513099 * k));
  apt2 += 0.000023 * sin(pi180 * (331.55 + 3.592518 * k));
  return pt + apt1 + apt2;
}

/**
 * 求∆t
 * @return number
 * @param yy
 * @param mm
 */
DeltaT(yy, mm) {
  var u, t, dt;
  var y = yy + (mm - 0.5) / 12;

  if (y <= -500) {
    u = (y - 1820) / 100;
    dt = (-20 + 32 * u * u);
  } else {
    if (y < 500) {
      u = y / 100;
      dt = (10583.6 -
          1014.41 * u +
          33.78311 * u * u -
          5.952053 * u * u * u -
          0.1798452 * u * u * u * u +
          0.022174192 * u * u * u * u * u +
          0.0090316521 * u * u * u * u * u * u);
    } else {
      if (y < 1600) {
        u = (y - 1000) / 100;
        dt = (1574.2 -
            556.01 * u +
            71.23472 * u * u +
            0.319781 * u * u * u -
            0.8503463 * u * u * u * u -
            0.005050998 * u * u * u * u * u +
            0.0083572073 * u * u * u * u * u * u);
      } else {
        if (y < 1700) {
          t = y - 1600;
          dt = (120 - 0.9808 * t - 0.01532 * t * t + t * t * t / 7129);
        } else {
          if (y < 1800) {
            t = y - 1700;
            dt = (8.83 +
                0.1603 * t -
                0.0059285 * t * t +
                0.00013336 * t * t * t -
                t * t * t * t / 1174000);
          } else {
            if (y < 1860) {
              t = y - 1800;
              dt = (13.72 -
                  0.332447 * t +
                  0.0068612 * t * t +
                  0.0041116 * t * t * t -
                  0.00037436 * t * t * t * t +
                  0.0000121272 * t * t * t * t * t -
                  0.0000001699 * t * t * t * t * t * t +
                  0.000000000875 * t * t * t * t * t * t * t);
            } else {
              if (y < 1900) {
                t = y - 1860;
                dt = (7.62 +
                    0.5737 * t -
                    0.251754 * t * t +
                    0.01680668 * t * t * t -
                    0.0004473624 * t * t * t * t +
                    t * t * t * t * t / 233174);
              } else {
                if (y < 1920) {
                  t = y - 1900;
                  dt = (-2.79 +
                      1.494119 * t -
                      0.0598939 * t * t +
                      0.0061966 * t * t * t -
                      0.000197 * t * t * t * t);
                } else {
                  if (y < 1941) {
                    t = y - 1920;
                    dt = (21.2 +
                        0.84493 * t -
                        0.0761 * t * t +
                        0.0020936 * t * t * t);
                  } else {
                    if (y < 1961) {
                      t = y - 1950;
                      dt = (29.07 + 0.407 * t - t * t / 233 + t * t * t / 2547);
                    } else {
                      if (y < 1986) {
                        t = y - 1975;
                        dt =
                            (45.45 + 1.067 * t - t * t / 260 - t * t * t / 718);
                      } else {
                        if (y < 2005) {
                          t = y - 2000;
                          dt = (63.86 +
                              0.3345 * t -
                              0.060374 * t * t +
                              0.0017275 * t * t * t +
                              0.000651814 * t * t * t * t +
                              0.00002373599 * t * t * t * t * t);
                        } else {
                          if (y < 2050) {
                            t = y - 2000;
                            dt = (62.92 + 0.32217 * t + 0.005589 * t * t);
                          } else {
                            if (y < 2150) {
                              u = (y - 1820) / 100;
                              dt = (-20 + 32 * u * u - 0.5628 * (2150 - y));
                            } else {
                              u = (y - 1820) / 100;
                              dt = (-20 + 32 * u * u);
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  if (y < 1955 || y >= 2005) {
    dt = dt - (0.000012932 * (y - 1955) * (y - 1955));
  }
  return dt / 60;
}

/**
 * 计算指定年(公历)的春分点(vernal equinox),但因地球在绕日运行时会因受到其他星球之影响而产生摄动(perturbation),必须将此现象产生的偏移量加入.
 * @return boolean|number 返回儒略日历格林威治时间
 * @param year
 */
VE(year) {
  var m;
  if (year < -8000 && 8001 < year) {
    return false;
  }
  if (1000 <= year && year <= 8001) {
    m = (year - 2000) / 1000;
    return 2451623.80984 +
        365242.37404 * m +
        0.05169 * m * m -
        0.00411 * m * m * m -
        0.00057 * m * m * m * m;
  } else {
    m = year / 1000;
    return 1721139.29189 +
        365242.1374 * m +
        0.06134 * m * m +
        0.00111 * m * m * m -
        0.00071 * m * m * m * m;
  }
}

/**
 * 地球在繞日运行时會因受到其他星球之影響而產生攝動(perturbation)
 * @return number 返回某时刻(儒略日历)的攝動偏移量
 * @param jd
 */
perturbation(jd) {
  var t = (jd - 2451545) / 36525;
  double s = 0;
  for (int k = 0; k <= 23; k++) {
    s = s + ptsA[k] * cos(ptsB[k] * 2 * pi / 360 + ptsC[k] * 2 * pi / 360 * t);
  }
  var w = 35999.373 * t - 2.47;
  var l =
      1 + 0.0334 * cos(w * 2 * pi / 360) + 0.0007 * cos(2 * w * 2 * pi / 360);
  return 0.00001 * s / l;
}

/**
 * 求算以含冬至中气为阴历11月开始的连续16个朔望月
 * @param year 年份
 * @param wJD 冬至的儒略日历时间
 * @return array
 */
SMSinceWinterSolstice(int year, double wJD) {
  var j, k;
  var tjd = {};

  var jd = solar2julian(year - 1, 11, 1);
  if (jd == null) {
    return {};
  }
  var nm = meanNewMoon(jd);
  var kn = nm[0];
  for (int i = 0; i <= 19; i++) {
    k = kn + i;
    tjd[i] = trueNewMoon(k) + 1 / 3;
    tjd[i] = tjd[i] - DeltaT(year, i - 1) / 1440;
  }
  for (j = 0; j <= 18; j++) {
    if ((tjd[j] + 0.5).floor() > (wJD + 0.5).floor()) {
      break;
    }
  }

  var JDs = {};
  for (k = 0; k <= 15; k++) {
    JDs[k] = tjd[j - 1 + k];
  }
  return JDs;
}

/**
 * 求出以某年立春點開始的節(注意:为了方便计算起运数,此处第0位为上一年的小寒)
 * @param yy
 * @return array jq[(2*k+21)%24]
 */
pureJQSinceSpring(int yy) {
  var jdpjq = [];

  var dj = adjustedJQ(yy - 1, 19, 23); //求出含指定年立春開始之3個節氣JD值,以前一年的年值代入

  // dj.forEach((k, value) {
  //   if (k < 19 || k > 23 || k % 2 == 0) {
  //
  //   } else {
  //     jdpjq.add(value); //19小寒;20大寒;21立春;22雨水;23惊蛰
  //   }
  // };

  dj.forEach((k, value) {
    if (k < 19 || k > 23 || k % 2 == 0) {
    } else {
      jdpjq.add(value); //19小寒;20大寒;21立春;22雨水;23惊蛰
    }
  });

  dj = adjustedJQ(yy, 0, 25); //求出指定年節氣之JD值,從春分開始,到大寒,多取两个确保覆盖一个公历年,也方便计算起运数
  dj.forEach((k, value) {
    if (k % 2 == 0) {
    } else {
      jdpjq.add(value);
    }
  });

  return jdpjq;
}

/**
 * 获取指定年的春分开始作perturbation調整後的24节气,可以多取2个
 * @param year
 * @param start 0-25
 * @param end 0-25
 * @return array
 */
adjustedJQ(int year, int start, int end) {
  if (start < 0 || 25 < start || end < 0 || 25 < end) {
    return {};
  }
  var jq = {};

  List Jd4JQ = meanJQJD(year);
  // for (int k = 0; k < Jd4JQ.length; k++) {
  //   if (k < start || k > end) {
  //     continue;
  //   }
  //   var ptb = perturbation(Jd4JQ[k]);
  //   var dt = DeltaT(year, ((k + 1) / 2).floor() + 3);
  //   jq[k] = Jd4JQ[k] + ptb - dt / 60 / 24;
  //   jq[k] = jq[k] + 1 / 3;
  // }
  for (var k = 0; k < Jd4JQ.length; k++) {
    var jd = Jd4JQ[k];
    if (k < start) {
      continue;
    }
    if (k > end) {
      continue;
    }
    var ptb = perturbation(jd); // 取得受perturbation影响所需微调
    var dt = DeltaT(
        year, ((k + 1) / 2).floor() + 3); // 修正dynamical time to Universal time
    jq[k] = jd + ptb - dt / 60 / 24; // 加上摄动调整值ptb,减去对应的Delta T值(分钟转换为日)
    jq[k] = jq[k] + 1 / 3; // 因中国(北京、重庆、上海)时间比格林威治时间先行8小时，即1/3日
  }
  return jq;
}

/**
 * 求出自冬至點為起點的連續15個中氣
 * @param year
 * @return array jq[(2*k+18)%24]
 */
ZQSinceWinterSolstice(int year) {
  // var JD4ZQ = [];
  //
  // var dj = adjustedJQ(year - 1, 18, 23);
  // JD4ZQ.add(dj[18]); //冬至
  // JD4ZQ.add(dj[20]); //大寒
  // JD4ZQ.add(dj[22]); //雨水
  //
  // dj = adjustedJQ(year, 0, 23);
  // for (var k in dj) {
  //   if (k % 2 != 0) {
  //     continue;
  //   }
  //   JD4ZQ.add(dj[k]);
  // }
  //
  // return JD4ZQ;
  var jdzq = {};

  var dj = adjustedJQ(year - 1, 18, 23); // 求出指定年冬至开始之节气JD值,以前一年的值代入

  jdzq[0] = dj[18]; //冬至
  jdzq[1] = dj[20]; //大寒
  jdzq[2] = dj[22]; //雨水

  dj = adjustedJQ(year, 0, 23); // 求出指定年节气之JD值
  var q = jdzq.length;
  for (var k = 0; k < dj.length; k++) {
    if (k % 2 != 0) {
      continue;
    }
    jdzq[q] = dj[k];
    q++;
  }
  return jdzq;
}

/**
 * 以比較日期法求算冬月及其餘各月名稱代碼,包含閏月,冬月為0,臘月為1,正月為2,餘類推.閏月多加0.5
 * @param year
 */
ZQAndSMandLunarMonthCode(int year) {
  var i;
  var mc = {};

  var jd4zq = ZQSinceWinterSolstice(year);
  // debugPrint("jd4zq: $jd4zq");
  var jd4sm = SMSinceWinterSolstice(year, jd4zq[0]);
  var yz = 0;
  if ((jd4zq[12] + 0.5).floor() >= (jd4sm[13] + 0.5).floor()) {
    for (i = 1; i <= 14; i++) {
      if (((jd4sm[i] + 0.5).floor() > (jd4zq[i - 1 - yz] + 0.5).floor() &&
          (jd4sm[i + 1] + 0.5).floor() <= (jd4zq[i - yz] + 0.5).floor())) {
        mc[i] = i - 0.5;
        yz = 1;
      } else {
        mc[i] = i - yz;
      }
    }
  } else {
    for (i = 0; i <= 12; i++) {
      mc[i] = i;
    }
    for (i = 13; i <= 14; i++) {
      if (((jd4sm[i] + 0.5).floor() > (jd4zq[i - 1 - yz] + 0.5).floor() &&
          (jd4sm[i + 1] + 0.5).floor() <= (jd4zq[i - yz] + 0.5).floor())) {
        mc[i] = i - 0.5;
        yz = 1;
      } else {
        mc[i] = i - yz;
      }
    }
  }
  return [jd4zq, jd4sm, mc];
}

// 公历转农历
solar2lunar(int year, int month, int day) {
  if (!dateIsOk(year, month, day)) return null;

  var mData = ZQAndSMandLunarMonthCode(year);
  // debugPrint("mData: $mData");
  var jd4sm = mData[1];
  var mc = mData[2];

  var jd = solar2julian(year, month, day, hour: 12); //求出指定年月日之JD值
  var mi = 0;
  var prev = 0;
  if (jd.floor() < (jd4sm[0] + 0.5).floor()) {
    prev = 1;
    mData = ZQAndSMandLunarMonthCode(year - 1);
    jd4sm = mData[1];
    mc = mData[2];
  }
  for (int i = 0; i <= 14; i++) {
    if (jd.floor() >= (jd4sm[i] + 0.5).floor() &&
        jd.floor() < (jd4sm[i + 1] + 0.5).floor()) {
      mi = i;
      break;
    }
  }

  if (mc[mi] < 2 || prev == 1) {
    year = year - 1;
  }
  month = ((mc[mi] + 10).floor() % 12) + 1;
  day = jd.floor() - (jd4sm[mi] + 0.5).floor() + 1;

  int isLeap = (mc[mi] - (mc[mi]).floor()).floor() * 2 + 1 != 1 ? 1 : 0;
  // return {"year": year, "month": month, "day": day, "isLeap": isLeap};
  return [year, month, day, isLeap];
}

lunar2solar(int year, int month, int day, {isLeap = false}) {
  if (year < -1000 ||
      3000 < year ||
      month < 1 ||
      12 < month ||
      day < 1 ||
      30 < day) {
    return false;
  }

  var lm = ZQAndSMandLunarMonthCode(year);
  var jd4sm = lm[1];
  var mc = lm[2];

  var leap = 0;
  for (int j = 1; j <= 14; j++) {
    if (mc[j] - (mc[j]).floor() > 0) {
      leap = (mc[j] + 0.5).floor();
      break;
    }
  }

  month = month + 2;

  const nofd = [];
  for (int i = 0; i <= 14; i++) {
    nofd.add((jd4sm[i + 1] + 0.5).floor() - (jd4sm[i] + 0.5).floor());
  }

  var jd;
  if (isLeap) {
    if (leap >= 3 && leap == month && day <= nofd[month]) {
      jd = jd4sm[month] + day - 1;
    }
  } else {
    var rate = leap == 0 ? 0 : 1;
    if (day <= nofd[month - 1 + rate * (month > leap ? 1 : 0)]) {
      jd = jd4sm[month - 1 + rate * (month > leap ? 1 : 0)] + day - 1;
    }
  }
  return jd == null ? false : julian2solar(jd).slice(0, 3);
}

// 获取公历某个月有多少天
solarMonthHasDays(int year, int month) {
  if (year < -1000 || year > 3000 || month < 1 || month > 12) {
    return 0;
  }
  var ndf1 = -(year % 4 == 0 ? 1 : 0);
  var ndf2 = (((year % 400 == 0 ? 1 : 0) - (year % 100 == 0 ? 1 : 0)) == 1) && (year > 1582);
  var ndf = ndf1 + (ndf2 ? 1 : 0);
  double result = 30 + (((month - 7.5).abs() + 0.5) % 2) - (month == 2 ? 1 : 0) * (2 + ndf);
  return result.toInt();
}

lunarMonthHasDays(int year, int month, bool isLeap) {
  if (year < -1000 || year > 3000 || month < 1 || month > 12) {
    return 0;
  }
  var lm = ZQAndSMandLunarMonthCode(year);
  var jdnm = lm[1];
  var mc = lm[2];

  var leap = 0;
  for (int j = 1; j <= 14; j++) {
    if (mc[j] - (mc[j]).floor() > 0) {
      leap = (mc[j] + 0.5).floor();
      break;
    }
  }
  month = month + 2;
  List nofd = [];
  for (int i = 0; i <= 14; i++) {
    nofd.add((jdnm[i + 1] + 0.5).floor() -
        (jdnm[i] + 0.5).floor()); //每月天數,加0.5是因JD以正午起算
  }

  if (isLeap) {
    if (leap >= 3 && leap == month) {
      return nofd[month];
    } else {
      return 0;
    }
  } else {
    return nofd[month - 1 + ((leap != 0 && month > leap) ? 1 : 0)];
  }
}

/**
 * 获取干支信息
 * @param year
 * @param month
 * @param day
 * @param hour
 * @param minute
 * @param second
 * @param zwz 区分早晚子时
 * @returns {{}|{jqi: number, g: *[], jq: *[], z: *[], jd: *[]}}
 */
gzi(int year, int month, int day, int hour,
    {int minute = 0, int second = 0, bool zwz = false}) {
// const info = {
// g: [], // 天干
// z: [], // 地址
// jd: [], // 对应的儒略日
// jq: [], // 日期前后节气的儒略日
// jqi: 0, // 对应的节气索引
// }
  BzInfo info = BzInfo();

  info.jd = solar2julian(year, month, day,
      hour: hour, minute: minute, second: max<int>(1, second));
  if (info.jd == null) return {};

  var jq = pureJQSinceSpring(year);
  if (info.jd < jq[1]) {
    year = year - 1;
    jq = pureJQSinceSpring(year);
  }

  var yearGZ = ((year + 4712 + 24) % 60 + 60) % 60;
  info.tg[0] = yearGZ % 10; //年干
  info.dz[0] = yearGZ % 12; //年支

  for (int j = 0; j <= 15; j++) {
    if (jq[j] >= info.jd) {
      info.jqi = j - 1;
      break;
    }
  }

  info.jq = [jq[info.jqi], jq[info.jqi + 1]];

  var monthGZ = (((year + 4712) * 12 + (info.jqi - 1) + 60) % 60 + 50) % 60;
  info.tg[1] = monthGZ % 10; //月干
  info.dz[1] = monthGZ % 12; //月支

  var jda = info.jd + 0.5;
  var dayJD = jda.floor() + (((jda - jda.floor()) * 86400) + 3600) / 86400;
  var dgz = ((dayJD + 49).floor() % 60 + 60) % 60;
  info.tg[2] = dgz % 10; //日干
  info.dz[2] = dgz % 12; //日支
  if (zwz && (hour >= 23)) {
    //区分早晚子时,日柱前移一柱
    info.tg[2] = (info.tg[2] + 10 - 1) % 10;
    info.dz[2] = (info.dz[2] + 12 - 1) % 12;
  }

  var dh = dayJD * 12;
  var hgz = ((dh + 48).floor() % 60 + 60) % 60;
  info.tg[3] = hgz % 10; //时干
  info.dz[3] = hgz % 12; //时支

  return info;
}

/**
 * 根据公历年月日排盘
 * @param male true男false女
 * @param year
 * @param month
 * @param day
 * @param hour
 * @param minute
 * @param second
 * @returns {{lucky: {datetime: *[], g: *[], z: *[], desc: string}, basic: {g: *[], z: *[]}}}
 */
plate(bool male, int year, int month, int day, int hour,
    {int minute = 0, int second = 0}) {
  var i, span;
  BzPlate plate = BzPlate();

  BzInfo info = gzi(year, month, day, hour, minute: minute, second: second);
  plate.tg = info.tg;
  plate.dz = info.dz;
  var jd = info.jd;

  const JQs = [
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
  plate.frontName = JQs[info.jqi % 12];
  plate.frontTime = datetime2string(julian2solar(info.jq[0]));
  plate.backName = JQs[(info.jqi + 1) % 12];
  plate.frontTime = datetime2string(julian2solar(info.jq[1]));

  var pn = plate.tg[0] % 2;
  if ((male && pn == 0) || (!male && pn == 1)) {
    //起大运时间,阳男阴女顺排
    span = info.jq[1] - jd; //往后数一个节,计算时间跨度
    for (i = 1; i <= 12; i++) {
      //大运干支
      plate.luckyTg.add((plate.tg[1] + i) % 10);
      plate.luckyDz.add((plate.dz[1] + i) % 12);
    }
  } else {
    // 阴男阳女逆排,往前数一个节
    span = jd - info.jq[0];
    for (i = 1; i <= 12; i++) {
      //确保是正数
      plate.luckyTg.add((plate.tg[1] + 20 - i) % 10);
      plate.luckyDz.add((plate.dz[1] + 24 - i) % 12);
    }
  }

  var days = (span * 4 * 30).floor();
  var y = (days / 360).floor();
  var m = (days % 360 / 30).floor();
  var d = (days % 360 % 30).floor();
  plate.luckyDesc = y + "年" + m + "月" + d + "天起运";

  var startJDTime = jd + span * 120;

  for (i = 0; i < 12; i++) {
    plate.luckyDatetime
        .add(datetime2string(julian2solar(startJDTime + i * 10 * 360)));
  }
  return plate;
}

datetime2string(dynamic data) {
  return data.slice(0, 3).map((v) => {v.padStart(2, '0')}).join('-') +
      ' ' +
      data.slice(3, 6).map((v) => {v.padStart(2, '0')}).join(':');
}
