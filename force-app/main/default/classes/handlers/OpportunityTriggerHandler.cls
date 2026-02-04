public with sharing class OpportunityTriggerHandler {
    public static void afterUpdate(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        TripService.createTripsFromClosedWon(newList, oldMap);
    }
}
