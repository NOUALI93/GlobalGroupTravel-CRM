public with sharing class TripService {

    // GGT-02: Quand une Opportunity devient 'closed won', créer un Trip lié.
    public static void createTripsFromClosedWon(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {

        // Filtrer : uniquement les opps qui viennent de passer IsWon = true
        Set<Id> oppIdsToCheck = new Set<Id>();
        List<Opportunity> wonOpps = new List<Opportunity>();

        for (Opportunity o : newList) {
            Opportunity oldO = oldMap.get(o.Id);

            Boolean justBecameWon = (o.IsWon == true) && (oldO.IsWon == false);
            if (justBecameWon) {
                wonOpps.add(o);
                oppIdsToCheck.add(o.Id);
            }
        }

        if (wonOpps.isEmpty()) return;

        // Anti-duplicate : si un Trip existe déjà pour l’Opportunity, ne pas recréer
        Map<Id, Trip__c> existingByOpp = new Map<Id, Trip__c>();
        for (Trip__c t : [
            SELECT Id, Opportunity__c
            FROM Trip__c
            WHERE Opportunity__c IN :oppIdsToCheck
        ]) {
            existingByOpp.put(t.Opportunity__c, t);
        }

        // Créer les Trips
        List<Trip__c> toInsert = new List<Trip__c>();

        for (Opportunity o : wonOpps) {
            // message pour l’utilisateur lors du prob des dates
            if (o.Start_Date__c != null && o.End_Date__c != null) {
                if (o.End_Date__c <= o.Start_Date__c) {
                    o.addError('La date de fin du voyage doit être postérieure à la date de début.');
                    continue;
                }
            }

            if (existingByOpp.containsKey(o.Id)) continue;

            Trip__c t = new Trip__c();
            t.Status__c = 'A venir';
            t.Destination__c = o.Destination__c;
            t.Start_Date__c = o.Start_Date__c;
            t.End_Date__c = o.End_Date__c;
            t.Number_of_Participants__c = o.Number_of_Participants__c;
            t.Total_Cost__c = o.Amount;
            t.Account__c = o.AccountId;
            t.Opportunity__c = o.Id;

            toInsert.add(t);
        }

        if (toInsert.isEmpty()) return;

        if (!Schema.sObjectType.Trip__c.isCreateable()) return;

        insert toInsert;
    }

    // GGT-03: validation dates Trip
    public static void validateTripDates(List<Trip__c> trips) {
        for (Trip__c t : trips) {
            if (t.Start_Date__c != null && t.End_Date__c != null) {
                if (t.End_Date__c <= t.Start_Date__c) {
                    t.addError('La date de fin doit être postérieure à la date de début.');
                }
            }
        }
    }
}
