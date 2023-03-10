import tkinter as tk
from app.excel import ExcelHandler
from app.chassis import Chassis
from app.label import LabelPrinter


class MainWindow(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Chassis Parts Harvesting App")
        self.geometry("800x600")
        self.create_widgets()

        self.excel_handler = ExcelHandler('data/chassis_data.xlsx')

    def create_widgets(self):
        # Create a search box
        self.search_var = tk.StringVar()
        self.search_var.trace("w", self.search_callback)
        self.search_entry = tk.Entry(self, textvariable=self.search_var)
        self.search_entry.pack()

        # Create a listbox to display search results
        self.listbox = tk.Listbox(self)
        self.listbox.pack()

        # Create a table to display harvested parts
        self.table = tk.Frame(self)
        self.table.pack()

        # Create a button to print a label
        self.print_label_button = tk.Button(self, text="Print Label", command=self.print_label, state=tk.DISABLED)
        self.print_label_button.pack()

    def search_callback(self, *args):
        search_term = self.search_var.get()
        search_results = self.excel_handler.search_chassis(search_term)
        self.populate_listbox(search_results)

    def populate_listbox(self, results):
        # Populate the listbox with the search results
        self.listbox.delete(0, tk.END)
        for result in results:
            self.listbox.insert(tk.END, f"{result[0]} - {result[1]}")

    def capture_notes(self, chassis):
        # Capture the notes for the selected chassis and store them in a variable
        notes = self.excel_handler.get_notes(chassis)
        return notes

    def create_table(self, products):
        # Create a table to display the harvested products
        self.table.destroy()
        self.table = tk.Frame(self)
        self.table.pack()
        for i, product in enumerate(products):
            part_number = tk.Label(self.table, text=product['part_number'])
            part_number.grid(row=i, column=0)
            sku = tk.Label(self.table, text=product['sku'])
            sku.grid(row=i, column=1)
            checkbox = tk.Checkbutton(self.table)
            checkbox.grid(row=i, column=2)

    def print_label(self):
        # Generate a QR code with the SKU information and print the label
        selected_rows = self.table.children.values()
        selected_products = []
        for row in selected_rows:
            part_number, sku, checkbox = row.children.values()
            if checkbox.instate(['selected']):
                selected_products.append({'part_number': part_number.cget('text'), 'sku': sku.cget('text')})
        LabelPrinter().print_labels(selected_products)


if __name__ == '__main__':
    app = MainWindow()
    app.mainloop()
