# bazi_flutter_core
# flutter版本的八字核心库
# 用于计算八字的基础功能
## 1.天干地支计算
## 2.大运起盘
## 3.流年计算
## 4.流月计算
## 5.流日计算
## 6.公农历转换

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

  
