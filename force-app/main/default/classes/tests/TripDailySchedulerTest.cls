@isTest
public class TripDailySchedulerTest {

    @isTest
    static void scheduleExecutesWithoutError() {

        Test.startTest();

        // On planifie le scheduler dans le contexte test
        String cronExp = '0 0 0 1 1 ? 2099'; // date future fictive
        System.schedule('Test Trip Daily Scheduler', cronExp, new TripDailyScheduler());

        Test.stopTest();
    }
}