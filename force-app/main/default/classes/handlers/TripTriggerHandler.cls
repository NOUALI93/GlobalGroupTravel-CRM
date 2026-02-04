public with sharing class TripTriggerHandler {
    public static void beforeUpsert(List<Trip__c> trips) {
        TripService.validateTripDates(trips);
    }
}

