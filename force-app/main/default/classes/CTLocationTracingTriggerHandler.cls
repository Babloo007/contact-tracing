public with sharing class CTLocationTracingTriggerHandler {
    public static void beforeInsert(List<Location_Tracing__c> newRecords) {
        List<Location_Tracing__c> duplicates = CTLocationTracingController.checkDuplicates(newRecords);

        for(Location_Tracing__c trace : duplicates){
            trace.addError('Duplicate Location Tracing Record Found for Location : '+trace.Location__c+' & '+trace.Person__c);
        }
    }
}