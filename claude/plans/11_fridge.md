As Flutter developer and solution architect extend current app with new mode called fridge. After this change there will be two modes: storeroom and fridge. Modes dependencies:
- storeroom view will have fields as now
- fridge view will have Category, Name, Barcode, Qunatity, Insertion Date, Expirity Date
- product from storeroom can be moved to fridge
- in storeroom each product will have button with which will be moved to fridge, during it user can set expirity date in fridge
- after moving product from storeroom to fridge it will be added to fridge and removed from storeroom
- product expirity date in fridge can be set by user or as current date plus default expirity time
- each Category has different expirity time, after adding Category default fridge expirity time will be added to config tab. The date can be edited from config tab
- Category or Name can be removed only if product not exist in storeroom or fridge
- during moving to fridge if storeroom expirity date is before current date plus expirity time, then storeroom expirity date will be set

Do not forgot update App description.
