public with sharing class CTLocationController {
    
    public static List<Location__c> getRecentStatusChanges(){
        return [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c 
            FROM Location__c 
            ORDER BY Status_Update_Date__c DESC 
            LIMIT 100];
    }

    public static List<Location__c> searchLocations(String searchTerm){
        searchTerm = searchTerm+'%';
        return [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c 
            FROM Location__c  
            WHERE Name LIKE :searchTerm 
            OR Address__c LIKE :searchTerm 
            OR Pincode__c LIKE :searchTerm 
            ORDER BY Status_Update_Date__c DESC NULLS LAST];
    }

    public static Location__c getLocationById(String locationId){
        List<Location__c> locations =  [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c 
                                    FROM Location__c 
                                    WHERE Id = :locationId];

        if(locations != null && locations.size() > 0)
            return locations[0];
        return null;
    }

    public static Map<String, Integer> getHealthStatusCount(){

        Map<String, Integer> healthCountMap = new Map<String, Integer>();

        for(AggregateResult result : [SELECT Status__c, COUNT(Id) total 
                                        FROM Location__c 
                                        GROUP BY Status__c]){
            String healthStatus = String.valueOf(result.get('Status__c'));
            Integer countVal = Integer.valueOf(result.get('total'));
            healthCountMap.put(healthStatus, countVal);
        }

        return healthCountMap;
    }

    public static void updateRedScore(Set<Id> locationIds){

        List<Location__c> locationsToUpdate = new List<Location__c>();

        AggregateResult[] redPeoplePerLocation = [
            SELECT Location__c, COUNT(Id) total
            FROM Location_Tracing__c
            WHERE Person__r.Health_Status__c = 'Red'
            AND Visit_Date__c = LAST_N_DAYS :10
            AND Location__c IN :locationIds
            GROUP BY Location__c
        ];

        for(AggregateResult ar : redPeoplePerLocation){
            String locationId = String.valueOf(ar.get('Location__c'));
            Integer redScore = Integer.valueOf(ar.get('total'));
            String status = getstatus(redScore);
            locationsToUpdate.add(new Location__c(Id=locationId, Red_Score__c=redScore, Status__c=status));
        }

        if(locationsToUpdate != null && locationsToUpdate.size() > 0)
            update locationsToUpdate;
    }

    public static String getstatus(Integer redScore){
        if(redScore == 0)
            return 'Green';
        else if(redScore <= 5)
            return 'Yellow';
        else if(redScore <= 10)
            return 'Orange';
        else
            return 'Red';
    }
}