public with sharing class CTPersonController {
    
    public static String getToken(String mobileNo){
        Blob blobVal = Blob.valueOf(mobileNo);
        Blob hash = Crypto.generateDigest('MD5', blobVal);

        // Get the string value of blob hash
        return EncodingUtil.base64Encode(hash);
    }

    public static List<Person__c> getRecentHealthChanges(){
        return [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c 
        FROM Person__c 
        ORDER BY Status_Update_Date__c DESC 
        NULLS LAST LIMIT 100];
    }

    public static List<Person__c> searchPeople(String searchTerm){
        searchTerm = searchTerm+'%';
        return [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c 
            FROM Person__c 
            WHERE Name LIKE :searchTerm 
            OR Mobile__c LIKE :searchTerm 
            OR Token__c LIKE :searchTerm 
            ORDER BY Status_Update_Date__c DESC NULLS LAST];
    }

    public static Person__c getPersonById(String personId){
        List<Person__c> persons =  [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c 
                                        FROM Person__c 
                                        WHERE Id = :personId];

        if(persons != null && persons.size() > 0)
            return persons[0];
        return null;
    }

    public static Map<String, Integer> getHealthStatusCount(){

        Map<String, Integer> healthCountMap = new Map<String, Integer>();

        for(AggregateResult result : [SELECT Health_Status__c, COUNT(Id) total 
                                        FROM Person__c 
                                        GROUP BY Health_Status__c]){
            String healthStatus = String.valueOf(result.get('Health_Status__c'));
            Integer countVal = Integer.valueOf(result.get('total'));
            healthCountMap.put(healthStatus, countVal);
        }

        return healthCountMap;
    }

    public static Set<id> getCohabitants(Set<Id> personIds, Set<Id> alreadyProcessed){

        List<String> healthStatuses = new List<String>{'Green', 'Yellow'};
        List<People_Tracing__c> peopleTraces = [
            SELECT Id, Person_1__c, Person_2__c
            FROM People_Tracing__c
            WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds)
            AND Contact_type__c = 'Cohabitant'
            AND (Person_1__r.Health_Status__c IN :healthStatuses OR Person_2__r.Health_Status__c IN :healthStatuses)
        ];

        Set<Id> cohabitants = new Set<Id>();
        for(People_Tracing__c trace : peopleTraces){
            if(!alreadyProcessed.contains(trace.Person_1__c)){
                cohabitants.add(trace.Person_1__c);
                alreadyProcessed.add(trace.Person_1__c);
            }
            if(!personIds.contains(trace.Person_2__c)){
                cohabitants.add(trace.Person_2__c);
                alreadyProcessed.add(trace.Person_2__c);
            }
        }

        return cohabitants;
    }

    public static Set<id> getNeighbours(Set<Id> personIds, Set<Id> alreadyProcessed){

        List<People_Tracing__c> peopleTraces = [
            SELECT Id, Person_1__c, Person_2__c
            FROM People_Tracing__c
            WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds)
            AND Contact_type__c = 'Neighbour'
            AND (Person_1__r.Health_Status__c = 'Green' OR Person_2__r.Health_Status__c = 'Green')
        ];

        Set<Id> neighbours = new Set<Id>();
        for(People_Tracing__c trace : peopleTraces){
            if(!alreadyProcessed.contains(trace.Person_1__c)){
                neighbours.add(trace.Person_1__c);
                alreadyProcessed.add(trace.Person_1__c);
            }
            if(!alreadyProcessed.contains(trace.Person_2__c)){
                neighbours.add(trace.Person_2__c);
                alreadyProcessed.add(trace.Person_2__c);
            }
        }

        return neighbours;
    }

    public static Set<id> getPrimaryContacts(Set<Id> personIds, Set<Id> alreadyProcessed){

        List<String> healthStatuses = new List<String>{'Green', 'Yellow'};
        List<People_Tracing__c> peopleTraces = [
            SELECT Id, Person_1__c, Person_2__c
            FROM People_Tracing__c
            WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds)
            AND Contact_type__c = 'Other'
            AND Contact_Date__c = LAST_N_DAYS:10
            AND (Person_1__r.Health_Status__c IN :healthStatuses OR Person_2__r.Health_Status__c IN :healthStatuses)
        ];

        Set<Id> primaryContacts = new Set<Id>();
        for(People_Tracing__c trace : peopleTraces){
            if(!alreadyProcessed.contains(trace.Person_1__c)){
                primaryContacts.add(trace.Person_1__c);
                alreadyProcessed.add(trace.Person_1__c);
            }
            if(!alreadyProcessed.contains(trace.Person_2__c)){
                primaryContacts.add(trace.Person_2__c);
                alreadyProcessed.add(trace.Person_2__c);
            }
        }

        return primaryContacts;
    }

    public static Set<id> getSecondaryContacts(Set<Id> primaryContactIds, Set<Id> alreadyProcessed){

        List<People_Tracing__c> peopleTraces = [
            SELECT Id, Person_1__c, Person_2__c
            FROM People_Tracing__c
            WHERE (Person_1__c IN :primaryContactIds OR Person_2__c IN :primaryContactIds)
            AND Contact_type__c = 'Other'
            AND Contact_Date__c = LAST_N_DAYS:10
            AND (Person_1__r.Health_Status__c = 'Green' OR Person_2__r.Health_Status__c = 'Green')
        ];

        Set<Id> secondaryContacts = new Set<Id>();
        for(People_Tracing__c trace : peopleTraces){
            if(!alreadyProcessed.contains(trace.Person_1__c)){
                secondaryContacts.add(trace.Person_1__c);
                alreadyProcessed.add(trace.Person_1__c);
            }
            if(!alreadyProcessed.contains(trace.Person_2__c)){
                secondaryContacts.add(trace.Person_2__c);
                alreadyProcessed.add(trace.Person_2__c);
            }
        }

        return secondaryContacts;
    }
}