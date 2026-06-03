const db = require('../../firebase');

// Hàm tạo đơn đặt phòng mới và lưu lịch sử thanh toán
module.exports.create_new_booking = async (req, res) => {
  try {
    const body = req.body;
    const checkin = body.checkin;
    const checkout = body.checkout;
    const customerEmail = body.customerEmail;
    const customerName = body.customerName;
    const customerCountry = body.customerCountry;
    const customerPhone = body.customerPhone;
    const room = body.room;
    const quantity = body.quantity;
    const time = Date.now();
    const total = body.total;

    const BookingObject = {
      checkin: checkin,
      checkout: checkout,
      room: room,
      quantity: quantity,
      total: total,
      bookedAt: time,
      customerEmail: customerEmail,
      customerCountry: customerCountry,
      customerName: customerName,
      customerPhone: customerPhone,
      status: "Đã thanh toán"
    };
    const myBookingCollection = db.collection('Bookings');
    const countBooking = (await myBookingCollection.get().size) + 1;
    const bookingID = "Booking_" + toString(countBooking);

    const PaymentObject = {
      total: total,
      createdAt: time,
      method: "chuyển khoản ZaloPay",
      status: "Thành công",
      bookingID: bookingID,
    };

    const myPaymentCollection = db.collection('Payment');
    const countPayment = (await myPaymentCollection.get()).size + 1;

    await myBookingCollection.doc(bookingID).set(BookingObject);
    await myPaymentCollection.doc("Payment_" + toString(countPayment)).set(PaymentObject);

    return res.status(200).send();
  } catch (error) {
    console.log("Đã có lỗi khi thực thi hàm");
    return res.status(500).json(error.message).send();
  }
};
