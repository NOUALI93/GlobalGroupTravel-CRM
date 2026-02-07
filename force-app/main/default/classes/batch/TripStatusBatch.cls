public with sharing class TripStatusBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Status__c, Start_Date__c, End_Date__c
            FROM Trip__c
            WHERE Start_Date__c != null
              AND End_Date__c != null
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Trip__c> scope) {
        Date today = Date.today();
        List<Trip__c> toUpdate = new List<Trip__c>();

        for (Trip__c t : scope) {

            // Ne pas toucher aux voyages annulés
            if (t.Status__c == 'Annulé') {
                continue;
            }

            String newStatus;

            if (today < t.Start_Date__c) {
                newStatus = 'A venir';
            } else if (today >= t.Start_Date__c && today <= t.End_Date__c) {
                newStatus = 'En cours';
            } else if (today > t.End_Date__c) {
                newStatus = 'Terminé';
            }

            if (newStatus != null && newStatus != t.Status__c) {
                t.Status__c = newStatus;
                toUpdate.add(t);
            }
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('TripStatusBatch terminé');
    }
}