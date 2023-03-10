import pandas as pd


class ExcelHandler:
    def __init__(self, file_path):
        self.file_path = file_path

    def search_chassis(self, search_term):
        df = pd.read_excel(self.file_path, sheet_name="Sheet1")
        df = df[df['Chassis'].str.contains(search_term, case=False)]
        return df[['Chassis', 'Model']].values.tolist()

    def get_notes(self, chassis):
        df = pd.read_excel(self.file_path, sheet_name="Sheet1")
        notes = df.loc[df['Chassis'] == chassis, 'Notes'].iloc[0]
        return notes

    def set_notes(self, chassis, notes):
        df = pd.read_excel(self.file_path, sheet_name="Sheet1")
        df.loc[df['Chassis'] == chassis, 'Notes'] = notes
        df.to_excel(self.file_path, index=False)

    def get_products(self, chassis):
        df = pd.read_excel(self.file_path, sheet_name="Sheet1")
        products_df = df.loc[df['Chassis'] == chassis, ['Part Number', 'SKU']]
        return products_df

    def remove_product(self, chassis, part_number):
        df = pd.read_excel(self.file_path, sheet_name="Sheet1")
        df = df.drop(df[(df['Chassis'] == chassis) & (df['Part Number'] == part_number)].index)
        df.to_excel(self.file_path, index=False)

    def add_product(self, chassis, part_number, sku):
        df = pd.read_excel(self.file_path, sheet_name="Sheet1")
        new_row = {'Chassis': chassis, 'Part Number': part_number, 'SKU': sku, 'Notes': ''}
        df = df.append(new_row, ignore_index=True)
        df.to_excel(self.file_path, index=False)
