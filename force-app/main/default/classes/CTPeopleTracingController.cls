public with sharing class CTPeopleTracingController {
    
    public static List<People_Tracing__c> getTraces(String personId){
        return [
            SELECT Id, Contact_Date__c, Person_1__c, Person_1__r.Health_Status__c, Person_1__r.Token__c, Person_2__c, Person_2__r.Health_Status__c, Person_2__r.Token__c 
            FROM People_Tracing__c 
            WHERE Person_1__c = :personId 
            OR Person_2__c = :personId 
            ORDER BY Contact_Date__c DESC
        ];
    }

    public static List<People_Tracing__c> checkDuplicates(List<People_Tracing__c> newPeopleTraces){

        Set<Id> peopleSet = new Set<Id>();
        for(People_Tracing__c trace : newPeopleTraces){
            peopleSet.add(trace.Person_1__c);
            peopleSet.add(trace.Person_2__c);
        }

        Map<Id, Set<Id>> traceMap = new Map<Id, Set<id>>();
        List<People_Tracing__c> duplicates = new List<People_Tracing__c>();

        List<People_Tracing__c> existingRecords = [
                                                    SELECT Id, Person_1__c, Person_2__c
                                                    FROM People_Tracing__c
                                                    WHERE Person_1__c IN :peopleSet
                                                    OR Person_2__c IN :peopleSet
                                                  ];

        if(existingRecords != null && existingRecords.size() > 0){
            for(People_Tracing__c trace : existingRecords){
                if(!traceMap.containsKey(trace.Person_1__c))
                    traceMap.put(trace.Person_1__c, new Set<Id>());
                traceMap.get(trace.Person_1__c).add(trace.Person_2__c);

                if(!traceMap.containsKey(trace.Person_2__c))
                    traceMap.put(trace.Person_2__c, new Set<Id>());
                traceMap.get(trace.Person_2__c).add(trace.Person_1__c);
            }

            for(People_Tracing__c trace : newPeopleTraces){
                if(traceMap.containsKey(trace.Person_1__c) && traceMap.get(trace.Person_1__c).contains(trace.Person_2__c) || 
                    traceMap.containsKey(trace.Person_2__c) && traceMap.get(trace.Person_2__c).contains(trace.Person_1__c)
                )
                    duplicates.add(trace);
            }
        }
        return duplicates;
    }
}