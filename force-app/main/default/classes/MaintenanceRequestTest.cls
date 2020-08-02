@isTest
public with sharing class MaintenanceRequestTest {

    @isTest
    private static void positiveOneRecordTest(){
        
        Vehicle__c vehicle = new Vehicle__c(Name = 'Test Vehicle');
        insert vehicle;
        System.debug('Single: vehicle = ' + vehicle);

        List<Product2> equipmentList = new List<Product2>();
        Product2 equipment = new Product2(Name = 'Test Equipment 1',Replacement_Part__c = true,Maintenance_Cycle__c = 15,Current_Inventory__c = 5, Warehouse_SKU__c = 'tryItNow');
        Product2 equipmentTwo = new Product2(Name = 'Test Equipment 2',Replacement_Part__c = true,Maintenance_Cycle__c = 10,Current_Inventory__c = 1,Warehouse_SKU__c = 'tryItNowHurryUp');

        equipmentList.add(equipment);
        equipmentList.add(equipmentTwo);
        insert equipmentList;
        System.debug('Single: equipment = ' + equipment);
        System.debug('Single: equipmentTwo = ' + equipmentTwo);

        Case request = new Case(
        Status = 'New',
        Origin = 'web',
        Type = 'Repair',
        Subject = 'Routine maintenance for vehicle ' + vehicle.Name,           
        Vehicle__c = vehicle.Id);

        insert request;
        System.debug('Single: request = ' + request);

        List<Work_Part__c> workPartList = new List<Work_Part__c>();
        workPartList.add(new Work_Part__c(Maintenance_Request__c = request.Id, Equipment__c = equipment.Id));
        workPartList.add(new Work_Part__c(Maintenance_Request__c = request.Id, Equipment__c = equipmentTwo.Id));
        insert workPartList;
        System.debug('Single: workPartList = ' + workPartList);

        Test.startTest();
        request.Status = 'Closed';
        update request;
        System.debug('Single: updatet status = ' + request.Status);
        Test.stopTest();

        Case initialRequest = [SELECT Id, Status, Date_Due__c, Date_Reported__c, Vehicle__c, Subject FROM Case WHERE Id=: request.Id];
        List<Work_Part__c> workPartsFromInitialRequest = [SELECT Id, Equipment__c, Equipment__r.Maintenance_Cycle__c FROM Work_Part__c WHERE Maintenance_Request__c = :initialRequest.Id];
        System.debug('Single: initialRequest = ' + initialRequest);
        System.debug('Single: initialRequest workPartList = ' + workPartsFromInitialRequest);


        Case updatedRequest = [SELECT Id, Status, Date_Due__c, Date_Reported__c, Vehicle__c, Type, (Select Id From Work_Parts__r), Subject FROM Case WHERE Subject like '%Future routine%'];
        List<Work_Part__c> workPartsFromUpdatedRequest = [SELECT Id, Equipment__c, Equipment__r.Maintenance_Cycle__c FROM Work_Part__c WHERE Maintenance_Request__c = :updatedRequest.Id];
        System.debug('Single: updatedRequest = ' + initialRequest);
        System.debug('Single: updatedRequest workPartList = ' + workPartsFromUpdatedRequest);


        System.assertEquals('Closed',initialRequest.Status);
        System.assertEquals(System.today(), updatedRequest.Date_Reported__c);
        System.assertEquals(initialRequest.Vehicle__c, updatedRequest.Vehicle__c);
        System.assertEquals('Routine Maintenance', updatedRequest.Type);

        Integer cycle = Integer.valueOf(equipment.Maintenance_Cycle__c);
        Integer secondEqipmentMaintenanceCycle = Integer.valueOf(equipmentTwo.Maintenance_Cycle__c);

        if(secondEqipmentMaintenanceCycle < cycle){
            cycle = secondEqipmentMaintenanceCycle;
        }
        Date expectedDueDate = System.today().addDays(cycle);

        System.debug('Single: cycle = ' + cycle);
        System.debug('Single: expectedDueDate = ' + expectedDueDate);

        System.assertEquals(expectedDueDate, updatedRequest.Date_Due__c);

        Id firstOldEquipmentId = workPartsFromInitialRequest[0].Equipment__c;
        Id secondOldEquipmentId = workPartsFromInitialRequest[1].Equipment__c;
        Id firstNewEquipmentId = workPartsFromUpdatedRequest[0].Equipment__c;
        Id secondNewEquipmentId = workPartsFromUpdatedRequest[1].Equipment__c;
        System.debug('Single: firstOldEquipmentId = ' + firstOldEquipmentId);
        System.debug('Single: secondOldEquipmentId = ' + secondOldEquipmentId);
        System.debug('Single: firstNewEquipmentId = ' + firstNewEquipmentId);
        System.debug('Single: secondNewEquipmentId = ' + secondNewEquipmentId);

        System.assertEquals(firstOldEquipmentId, firstNewEquipmentId);
        System.assertEquals(secondOldEquipmentId, secondNewEquipmentId);
    }


    @isTest
    private static void positiveBulkTest(){
        Integer recordsCount = 400;
        String requestType = 'Routine maintenance';
        List<Vehicle__c> vehicleList = TestDataFactory.generateVehicleList(recordsCount);
        List<Product2> equipmentList = TestDataFactory.generateTestEquipmentList(recordsCount);
        List<Case> requestList = TestDataFactory.generateTestRequests(requestType, recordsCount, vehicleList);
        List<Work_Part__c> workParts = new List<Work_Part__c>();

       // List<Case> generatedRequestList = prepareData();
        System.debug('Positive bulk qty=' + requestList.size());
        System.debug('Positive Status of 10 record=' + requestList[10].Status);

        for(Integer i = 0; i < recordsCount; i++){
            Case request = requestList.get(i);
            request.Status = 'Closed';
            workParts.add(TestDataFactory.generateTestWorkPart(request.Id, equipmentList.get(i).Id));
        }
        insert workParts;

        Test.startTest();
        update requestList;
        System.debug('Positive bulk after update qty=' + requestList.size());
        System.debug('Status of 10 record after update=' + requestList[10].Status);
        Test.stopTest();

        Integer expectedCasesCount = recordsCount;
        Integer actualCasesCount = [SELECT count() FROM Case WHERE Type='Routine Maintenance']; 
        System.debug('Positive cases qty=' + actualCasesCount);

        System.assertEquals(expectedCasesCount, actualCasesCount);
    }
    
    @isTest
    private static void negativeTest(){
        Integer recordsCount = 400;
        String requestType = 'Routine maintenance';
        List<Vehicle__c> vehicleList = TestDataFactory.generateVehicleList(recordsCount);
        List<Product2> equipmentList = TestDataFactory.generateTestEquipmentList(recordsCount);
        List<Case> requestList = TestDataFactory.generateTestRequests(requestType, recordsCount, vehicleList);
        List<Work_Part__c> workParts = new List<Work_Part__c>();

        //List<Case> generatedRequestList = prepareData();
        System.debug('Negative bulk qty=' + requestList.size());
        System.debug('Negative Status of 10 record=' + requestList[10].Status);

        for(Integer i = 0; i < recordsCount; i++){
            Case request = requestList.get(i);
            request.Status = 'Closed';
            request.Type = 'Electronic';
            workParts.add(TestDataFactory.generateTestWorkPart(request.Id, equipmentList.get(i).Id));
        }
        insert workParts;

        Test.startTest();
        update requestList;
        System.debug('Negative bulk after update qty=' + requestList.size());
        System.debug('Negative Status of 10 record after update=' + requestList[10].Status);
        Test.stopTest();

        Integer expectedCasesCount = 0;
        Integer actualCasesCount = [SELECT count() FROM Case WHERE Type='Routine Maintenance']; 
        System.debug('Negative cases qty=' + actualCasesCount);

        System.assertEquals(expectedCasesCount, actualCasesCount);
    }
}