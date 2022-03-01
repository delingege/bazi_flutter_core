/**
 * Class Time
 * @package shiyin\calendar
 */
abstract class Time
{

  /**
   * 把公历转成农历|把农历转成阴历
   * @return Time|null
   */
   Time tran();

  /**
   * 输出格式化的字符串
   * @return string
   */
   String string();

   configure(object, properties) {
     // for (int i = 0; i < properties.length; i++) {
     //   Map map = properties[i];
     //
     // }
    // foreach ($properties as $name => $value) {
    //   $object->$name = $value;
    // }
    // return $object;
  }

}