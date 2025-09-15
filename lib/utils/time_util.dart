import 'package:intl/intl.dart';

// Hàm chuyển đổi từ chuỗi ngày giờ sang DateTime
DateTime parseDateTime(String dateTimeString) {
  try {
    return DateFormat("yyyy-MM-dd HH:mm").parse(dateTimeString);
  } catch (e) {
    print('Error parsing dateTime: $e');
    return DateTime
        .now(); // Trả về thời gian hiện tại nếu không thể phân tích chuỗi
  }
}

// Hàm chuyển đổi từ DateTime sang chuỗi ngày giờ
String formatDateTime(DateTime dateTime) {
  try {
    return DateFormat("yyyy-MM-dd HH:mm").format(dateTime);
  } catch (e) {
    print('Error formatting dateTime: $e');
    return ''; // Trả về chuỗi rỗng nếu không thể định dạng
  }
}

String reformatDateTime(String dateTimeString) {
  try {
    // Chuyển đổi chuỗi thành đối tượng DateTime
    DateTime parsedDateTime = DateTime.parse(dateTimeString);

    // Định dạng lại DateTime theo kiểu bạn muốn
    String formattedDateTime =
        DateFormat("dd-MM-yyyy HH:mm").format(parsedDateTime);
    return formattedDateTime;
  } catch (e) {
    print('Error formatting dateTime: $e');
    return ''; // Trả về chuỗi rỗng nếu có lỗi
  }
}
