public with sharing class ContactTriggerHandler {
    public static void afterInsertHandler(List<Contact> newContacts) {
        Set<Id> accountIds = new Set<Id>();
        for(Contact cont : newContacts){
            if(String.isNotBlank(cont.AccountId))
                accountIds.add(cont.AccountId);
        }
        AccountContactService.updateActiveContacts(accountIds);
    }

    public static void afterUpdateHandler(List<Contact> newContacts, Map<Id, Contact> oldContactsMap) {
        Set<Id> accountIds = new Set<Id>();
            for(Contact cont : newContacts){
                if(String.isNotBlank(cont.AccountId) && oldContactsMap.get(cont.Id).Active__c != cont.Active__c)
                    accountIds.add(cont.AccountId);
                else if(oldContactsMap.get(cont.Id).AccountId != cont.AccountId){
                    accountIds.add(oldContactsMap.get(cont.Id).AccountId);
                    accountIds.add(cont.AccountId);
                }
            }
            AccountContactService.updateActiveContacts(accountIds);
    }

    public static void afterDeleteHandler(List<Contact> oldContacts) {
        Set<Id> accountIds = new Set<Id>();
        for(Contact cont : oldContacts){
            if(String.isNotBlank(cont.AccountId))
                accountIds.add(cont.AccountId);
        }
        AccountContactService.updateActiveContacts(accountIds);
    }

    public static void afterUndeleteHandler(List<Contact> newContacts) {
        Set<Id> accountIds = new Set<Id>();
        for(Contact cont : newContacts){
            if(String.isNotBlank(cont.AccountId))
                accountIds.add(cont.AccountId);
        }
        AccountContactService.updateActiveContacts(accountIds);
    }
}