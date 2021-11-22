# bazi_flutter_core
# flutter版本的八字核心库
# 用于计算八字的基础功能
## 1.天干地支计算
## 2.大运起盘
```
  Chinese _chinese = Chinese.getInstance();
  _chinese.init();
  Map bzInfo = _chinese.Fate(true, 1990, 1, 1, hour: 1);
  _chinese.getFleetYear
  print(bzInfo);
  ```
## 3.流年计算
```
  Map<String, dynamic> luckyInfoList = _chinese.getFleetYear(1999, 0);
  print(luckyInfoList);
  ```
## 4.流月计算
```
  Map<String, dynamic> luckyInfoList = _chinese.getFleetMonth(1999);
  print(luckyInfoList);
  ```
## 5.流日计算
```
  Map<String, dynamic> luckyInfoList = _chinese.getFleetDay(1990, 2, 4, 6);
  print(luckyInfoList);
  ```
## 6.流时计算
```
  List<LuckyInfo> luckyInfoList = _chinese.getFleetHour(2);
  print(luckyInfoList);
  ```
## 7.公农历转换

# 农历转阳历
```
  Calendar _calendar = Calendar.getInstance();
  var l = _calendar.Solar2Lunar(2021, 11, 11); // [2021,10,7,false]
  print(l);
  ```
# 阳历转农历
```
  var s = _calendar.Lunar2Solar(2021, 10, 7); // [2021,11,11]
  print(s);
  ```

  
