public with sharing class MaintenanceRequestHelper {

    public static void updateWorkOrders(List<Case> casesList) {

        List<Case> newCases = new List<Case>();
  
        Set<Id> closedRequestIdSet = new Set<Id>();
        List<Case> validRequestList = new List<Case>();
        Map<Id, Decimal> nearestServiceDateMap = calculateNearestServiceDate(closedRequestIdSet);

        for(Case caseItem : casesList){
            if(caseItem.Status.equals('Closed') && (caseItem.Type.equals('Repair') || caseItem.Type.equals('Routine Maintenance'))) {
                    closedRequestIdSet.add(caseItem.Id);
                    validRequestList.add(caseItem);
                }
        }


        for (Case caseItem : validRequestList) {
            Case newCase = caseItem.clone(false,true,false,false);
            newCase.Status = 'New';
            newCase.Type = 'Routine Maintenance';
            newCase.Subject = 'Future routine checkup for ' 
                                    + caseItem.Vehicle__r.Make__c + ' ' 
                                    + caseItem.Vehicle__r.Model__c + ' ' 
                                    + caseItem.Vehicle__r.VIN_Number__c;
            newCase.Vehicle__c = caseItem.Vehicle__c;
            newCase.Date_Reported__c = System.today();
            newCase.Date_Due__c = System.today();

            if(nearestServiceDateMap.size() > 0){
                newCase.Date_Due__c = System.today().addDays(Integer.valueOf(nearestServiceDateMap.get(caseItem.Id)));
            }
            newCase.ParentId = caseItem.Id;

            System.debug('nearestServiceDateMap.size() = ' + nearestServiceDateMap.size() );

            newCases.add(newCase);
        }

        if (newCases.size() > 0) {
            insert newCases;
            resolveWorkParts(newCases);
        }
    }

    private static void resolveWorkParts(List<Case> requestList){
        Map<Id, Id> OldRequestToNewRequestMap = new Map<Id, Id>();
        for(Case request: requestList){
            OldRequestToNewRequestMap.put(request.ParentId, request.Id);
        }
        
        List<Work_Part__c> updatedWorkParts = new List<Work_Part__c>();
        List<Work_Part__c> previousRequestWorkParts = [SELECT Id, Maintenance_Request__c, Equipment__c, Quantity__c FROM Work_Part__c WHERE Maintenance_Request__c IN :OldRequestToNewRequestMap.keySet()];
        for(Work_Part__c item: previousRequestWorkParts){
            Work_Part__c workPart = new Work_Part__c();
            workPart.Maintenance_Request__c = OldRequestToNewRequestMap.get(item.Maintenance_Request__c);
            workPart.Equipment__c = item.Equipment__c;
            workPart.Quantity__c = item.Quantity__c;
            updatedWorkParts.add(workPart);
        }
        insert updatedWorkParts;
    }
    
    private static Map<Id, Decimal> calculateNearestServiceDate(Set<Id> closedRequestIdSet){
        Map<Id, Decimal> shortestCycleMap = new Map<Id, Decimal>();

        List<Work_Part__c> workPartList = 
            [SELECT Maintenance_Request__c, Equipment__r.Maintenance_Cycle__c FROM Work_Part__c WHERE Maintenance_Request__c IN :closedRequestIdSet];
        
        for(Work_Part__c workPart : workPartList){
            Id requestId = workPart.Maintenance_Request__c;
            Decimal cycle = workPart.Equipment__r.Maintenance_Cycle__c;
            if((!shortestCycleMap.containsKey(requestId)) || (shortestCycleMap.containsKey(requestId) && cycle < shortestCycleMap.get(requestId))){
                shortestCycleMap.put(requestId, cycle);
            }
        }
        return shortestCycleMap;
    }
}