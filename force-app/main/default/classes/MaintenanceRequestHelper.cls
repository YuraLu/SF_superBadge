public with sharing class MaintenanceRequestHelper {

    public static void updateWorkOrders(List<Case> casesList) {

        List<Case> newCases = new List<Case>();
        Set<Id> casesIdSet = new Set<Id>();

        Map<String, Integer> nearestServiceDateMap = calculateNearestServiceDate(casesIdSet);
        
        for(Case caseItem : casesList){
            if(caseItem.status == 'closed')
                if(caseItem.type == 'Repair' || caseItem.type =='Routine Maintenance'){
                    
                    Case newCase = new Case();
                    newCase.Status = 'New';
                    newCase.Type = 'Routine Maintenance';
                    newCase.Subject = 'Future routine checkup for ' 
                                    + caseItem.Vehicle__r.Make__c + ' ' 
                                    + caseItem.Vehicle__r.Model__c + ' ' 
                                    + caseItem.Vehicle__r.VIN_Number__c;
                    newCase.Vehicle__c = caseItem.Vehicle__c;
                    newCase.Equipment__c = caseItem.Equipment__c;
                    newCase.Date_Reported__c = System.today();
            
                    if(nearestServiceDateMap.get(caseItem.Id) == Null){
                        newCase.Date_Due__c = System.today();
                    }else {
                        newCase.Date_Due__c = System.today().addDays(nearestServiceDateMap.get(caseItem.Id));
                    }

                    newCases.add(newCase);
                    casesIdSet.add(caseItem.Id);
                }
        }

        if (newCases.size() > 0) {
            insert newCases;
        }
    }
    
    private static Map<String, Integer> calculateNearestServiceDate(Set<Id> casesIdSet){
        Map<String, Integer> shortestCycleMap = new Map<String,Integer>();

        List<AggregateResult> workPartList = [SELECT Maintenance_Request__c caseId, min(Equipment__r.Maintenance_Cycle__c) cycle 
                                                FROM Work_Part__c WHERE Maintenance_Request__c IN :casesIdSet GROUP BY Maintenance_Request__c ];
        
        for(AggregateResult workPart : workPartList){
            if(workPart.get('cycle') != Null){
                Integer daysLeftTillNextMaintenance = Integer.valueOf(workPart.get('cycle'));
                shortestCycleMap.put((String)workPart.get('caseId'), daysLeftTillNextMaintenance);
            }
        }
        return shortestCycleMap;
    }
}