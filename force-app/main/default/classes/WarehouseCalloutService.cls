public with sharing class WarehouseCalloutService {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    @future(callout=true)
    public static void runWarehouseEquipmentSync() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        List<Product2> equipmentList = new List<Product2>();

        if (response.getStatusCode() == 200) {
            List<Object> responseList = (List<Object>)JSON.deserializeUntyped(response.getBody());   
            
            for (Object item : responseList) {

                Map<String, Object> productMap = (Map<String, Object>)item;

                Product2 product = new Product2();
                product.ProductCode = (String)productMap.get('_id');
                product.Replacement_Part__c = true;
                product.Current_Inventory__c = (Integer)productMap.get('quantity');
                product.Name = (String)productMap.get('name');
                product.Maintenance_Cycle__c = (Integer)productMap.get('maintenanceperiod');
                product.Lifespan_Months__c = (Integer)productMap.get('lifespan');
                product.Cost__c = (Decimal)productMap.get('cost');
                product.Warehouse_SKU__c = (String)productMap.get('sku');

                equipmentList.add(product);
            }
        }

        if (equipmentList.size() > 0) {
            upsert(equipmentList);
        }
    }
}