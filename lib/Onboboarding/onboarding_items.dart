import 'package:weather/Onboboarding/onboarding_info.dart';

class OnboardingItems{
  List<OnboardingInfo> items = [
    OnboardingInfo(
        title : "Cảnh báo thời tiết cực đoan",
        descriptions : "Nhận cảnh báo mua giông bất thường trước 1-3 giờ",
        image: "assets/thoitiet.png"),
    OnboardingInfo(
        title : "Giá cả thị trường",
        descriptions : "Cập nhật giá cả nông sản mới nhất và chính xác nhất",
        image: "assets/giaca.png"),
    OnboardingInfo(
        title : "Nhận diện sâu bệnh",
        descriptions : "Công nghệ AI giúp tự động phát hiện và đề xuất cách điều trị",
        image: "assets/nhandiensau.png"),
    OnboardingInfo(
        title : "Chuyên gia tư vấn",
        descriptions : "Dễ dàng tiếp cận chuyên gia cây trồng để nhận hỗ trợ kịp thơ",
        image: "assets/chuyengiatuvan.png"),
  ];
}