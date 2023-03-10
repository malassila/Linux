import qrcode
from escpos.printer import Usb


class LabelPrinter:
    def __init__(self, vendor_id=0x0416, product_id=0x5011):
        self.printer = Usb(vendor_id, product_id)

    def print_labels(self, products):
        for product in products:
            sku = product['sku']
            part_number = product['part_number']
            qr_code = qrcode.QRCode(version=1, box_size=10, border=4)
            qr_code.add_data(sku)
            qr_code.make(fit=True)
            qr_img = qr_code.make_image(fill_color="black", back_color="white")
            self.printer.set("center")
            self.printer.text(f"\n\n\n{part_number}\n\n")
            self.printer.image(qr_img)
            self.printer.text("\n\n\n\n")
            self.printer.cut()
