from app.excel import ExcelHandler


class Chassis:
    def __init__(self, chassis_number):
        self.chassis_number = chassis_number
        self.notes = None
        self.products = []
        self.excel_handler = ExcelHandler('data/chassis_data.xlsx')

    def get_notes(self):
        if self.notes is None:
            self.notes = self.excel_handler.get_notes(self.chassis_number)
        return self.notes

    def set_notes(self, notes):
        self.notes = notes
        self.excel_handler.set_notes(self.chassis_number, notes)

    def get_products(self):
        if not self.products:
            products_df = self.excel_handler.get_products(self.chassis_number)
            self.products = products_df.to_dict('records')
        return self.products

    def remove_product(self, part_number):
        self.excel_handler.remove_product(self.chassis_number, part_number)

    def add_product(self, part_number, sku):
        self.excel_handler.add_product(self.chassis_number, part_number, sku)
        self.products.append({'part_number': part_number, 'sku': sku})
