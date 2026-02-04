@isTest
public class TripTriggerTest {

    @isTest
    static void blocksInvalidTripDates() {
        Account a = TestDataFactory.createAccount();

        Trip__c t = new Trip__c(
            Status__c = 'A venir',
            Destination__c = 'Rome',
            Start_Date__c = Date.today().addDays(10),
            End_Date__c = Date.today().addDays(9),
            Number_of_Participants__c = 12,
            Total_Cost__c = 2000,
            Account__c = a.Id
        );

        Test.startTest();
        try {
            insert t;
            System.assert(false, 'L’insertion doit échouer si End <= Start.');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('date de fin'),
                'Le message d’erreur doit indiquer le problème de dates.'
            );
        }
        Test.stopTest();
    }
}
