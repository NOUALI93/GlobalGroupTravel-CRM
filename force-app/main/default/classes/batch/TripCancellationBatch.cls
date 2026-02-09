public with sharing class TripCancellationBatch implements Database.Batchable<SObject> {

    // start()
    public Database.QueryLocator start(Database.BatchableContext bc) {

        Date targetDate = Date.today().addDays(7);

        return Database.getQueryLocator([
            SELECT Id, Status__c, Number_of_Participants__c, Start_Date__c
            FROM Trip__c
            WHERE Start_Date__c = :targetDate
              AND Status__c != 'Annulé'
        ]);
    }

    // execute()
    public void execute(Database.BatchableContext bc, List<Trip__c> scope) {

        List<Trip__c> tripsToUpdate = new List<Trip__c>();

        for (Trip__c t : scope) {

            if (t.Number_of_Participants__c != null &&
                t.Number_of_Participants__c < 10) {

                t.Status__c = 'Annulé';
                tripsToUpdate.add(t);
            }
        }

        if (!tripsToUpdate.isEmpty()) {
            update tripsToUpdate;
        }
    }

    // finish()
    public void finish(Database.BatchableContext bc) {
        System.debug('TripCancellationBatch terminé');
    }
}