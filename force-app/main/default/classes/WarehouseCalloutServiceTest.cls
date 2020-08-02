@IsTest
private class WarehouseCalloutServiceTest{

    @isTest
    static void testWarehouseCalloutService(){
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        Test.startTest();
        WarehouseCalloutService.runWarehouseEquipmentSync();
        Test.stopTest();
        System.assertEquals(2, [SELECT count() FROM Product2]);
    }
}