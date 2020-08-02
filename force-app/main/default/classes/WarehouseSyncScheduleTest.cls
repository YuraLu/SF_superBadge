@isTest
global class WarehouseSyncScheduleTest {
    
    @isTest
    static void testSyncShedule(){
    Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
    String cronExpression = '0 0 13 * * ?';

    Test.startTest();
    String cronJobId = System.schedule('Inventory daily sync', cronExpression, new WarehouseSyncSchedule());  
    CronTrigger crTrigger = [SELECT id, cronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id= :cronJobId];
    Test.stopTest();
        
    Integer actualTimesTriggered = crTrigger.TimesTriggered;
    System.assertEquals(0, actualTimesTriggered);
    
    String actualFireTime = String.valueOf(crTrigger.NextFireTime);
    System.assertEquals('2020-08-03 13:00:00', actualFireTime);   
    }
}