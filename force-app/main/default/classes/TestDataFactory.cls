public with sharing class TestDataFactory {

public static List<Vehicle__c> generateVehicleList(Integer vehicleCount){
    List<Vehicle__c> vehicleList = new List<Vehicle__c>();
    for (Integer i = 0; i < vehicleCount; i++) {
        Vehicle__c vehicle = new Vehicle__c();
        vehicle.Name = 'Test Vehicle ' + i;

        vehicleList.add(vehicle);
    }
    insert  vehicleList;
    return vehicleList;
}

public static List<Product2> generateTestEquipmentList(Integer equipmentCount){
    List<Product2> equipmentList = new List<Product2>();
    for(Integer i = 0; i < equipmentCount; i++){
        Product2 equipment = new Product2();
        equipment.Name='Test equipment ' + i;
        equipment.Replacement_Part__c = true;
        equipment.Maintenance_Cycle__c = (i + 1) * 5;

        equipmentList.add(equipment);
    }
    insert equipmentList;
    return equipmentList;
}

public static List<Case> generateTestRequests(String requestType, Integer requestsCount, List<Vehicle__c> vehicleList){        
    List<Case> casesList = new List<Case>();

    for(Integer i = 0; i < requestsCount; i++){
        Case newCase = new Case();
        newCase.Status = 'New';
        newCase.Origin = 'web';
        newCase.Type = requestType;
        newCase.Subject = 'Routine maintenance for vehicle ' + i;             
        newCase.Vehicle__c = vehicleList.get(i).Id;

        casesList.add(newCase);
    }
    insert casesList;
    return casesList;
}

public static Work_Part__c generateTestWorkPart(Id requestId, Id equipmentId){
    Work_Part__c workPart = new Work_Part__c();
    workPart.Maintenance_Request__c = requestId;
    workPart.Equipment__c = equipmentId;
    return  workPart;
} 


}
