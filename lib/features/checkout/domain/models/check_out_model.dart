class CheckOutModel {
  String? orderType;
  String? freeDeliveryType;
  double? amount;
  double? deliveryCharge;
  double? placeOrderDiscount;
  double? itemDiscount; // New property added
  String? couponCode;
  String? orderNote;

  CheckOutModel({
    required this.orderType,
    required this.freeDeliveryType,
    required this.amount,
    required this.deliveryCharge,
    required this.placeOrderDiscount,
    required this.itemDiscount, // Include the new parameter here
    required this.couponCode,
    required this.orderNote,
  });

  CheckOutModel copyWith({
    String? orderNote,
    double? discount,
    double? deliveryCharge,
    double? itemDiscount, // Add itemDiscount parameter in copyWith
  }) {
    if (orderNote != null) {
      this.orderNote = orderNote;
    }
    if (discount != null) {
      placeOrderDiscount = discount;
    }
    if (deliveryCharge != null) {
      this.deliveryCharge = deliveryCharge;
    }
    if (itemDiscount != null) {
      this.itemDiscount = itemDiscount;
    }
    return this;
  }
}

// class CheckOutModel {
//   String? orderType;
//   String? freeDeliveryType;
//   double? amount;
//   double? deliveryCharge;
//   double? placeOrderDiscount;
//   String? couponCode;
//   String? orderNote;

//   CheckOutModel({
//     required this.orderType,
//     required this.freeDeliveryType,
//     required this.amount,
//     required this.deliveryCharge,
//     required this.placeOrderDiscount,
//     required this.couponCode,
//     required this.orderNote,
//   });

//   CheckOutModel copyWith(
//       {String? orderNote, double? discount, double? deliveryCharge}) {
//     if (orderNote != null) {
//       this.orderNote = orderNote;
//     }
//     if (discount != null) {
//       placeOrderDiscount = discount;
//     }
//     if (deliveryCharge != null) {
//       this.deliveryCharge = deliveryCharge;
//     }
//     return this;
//   }
// }
