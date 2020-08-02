@isTest
global class WarehouseCalloutServiceMock implements HttpCalloutMock{

    global HttpResponse respond(HttpRequest request){
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        String jsonBody = '[{"_id": "55d66213726b614000aaf741","replacement": true,"quantity": 54,"name": "Test Equipment 1","maintenanceperiod": 65,"lifespan": 20,"cost": 700,"sku": "100093"}, {"_id": "55d66946636b611100aaf742","replacement": false,"quantity": 987,"name": "Test Equipment 4", "maintenanceperiod": 15,"lifespan": 0,"cost": 2500, "sku": "100074" }]';
        response.setBody(jsonBody);
        response.setStatusCode(200);
        return response;
    }
}