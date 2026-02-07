public with sharing class TripDailyScheduler implements Schedulable {

    public void execute(SchedulableContext sc) {
        // Lance les batchs 
        Database.executeBatch(new TripCancellationBatch(), 200);
        Database.executeBatch(new TripStatusBatch(), 200);
    }
}