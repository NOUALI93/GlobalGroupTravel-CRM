@isTest
public class TripStatusBatchTest {

    @isTest
    static void updatesStatusBasedOnDatesAndKeepsCancelled() {
        Account a = TestDataFactory.createAccount();
        Date today = Date.today();

        // 1) Doit devenir "A venir"
        Trip__c tFuture = new Trip__c(
            Status__c = 'En cours', // volontairement faux
            Destination__c = 'Paris',
            Start_Date__c = today.addDays(5),
            End_Date__c = today.addDays(10),
            Number_of_Participants__c = 20,
            Total_Cost__c = 1000,
            Account__c = a.Id
        );

        // 2) Doit devenir "En cours"
        Trip__c tCurrent = new Trip__c(
            Status__c = 'A venir', // volontairement faux
            Destination__c = 'Rome',
            Start_Date__c = today.addDays(-1),
            End_Date__c = today.addDays(2),
            Number_of_Participants__c = 20,
            Total_Cost__c = 1000,
            Account__c = a.Id
        );

        // 3) Doit devenir "Terminé"
        Trip__c tPast = new Trip__c(
            Status__c = 'En cours', // volontairement faux
            Destination__c = 'Tokyo',
            Start_Date__c = today.addDays(-10),
            End_Date__c = today.addDays(-2),
            Number_of_Participants__c = 20,
            Total_Cost__c = 1000,
            Account__c = a.Id
        );

        // 4) Annulé => ne doit pas changer
        Trip__c tCancelled = new Trip__c(
            Status__c = 'Annulé',
            Destination__c = 'Berlin',
            Start_Date__c = today.addDays(-10),
            End_Date__c = today.addDays(10),
            Number_of_Participants__c = 5,
            Total_Cost__c = 1000,
            Account__c = a.Id
        );

        insert new List<Trip__c>{ tFuture, tCurrent, tPast, tCancelled };

        Test.startTest();
        Database.executeBatch(new TripStatusBatch(), 200);
        Test.stopTest();

        Map<Id, Trip__c> refreshed = new Map<Id, Trip__c>([
            SELECT Id, Status__c
            FROM Trip__c
            WHERE Id IN :new List<Id>{ tFuture.Id, tCurrent.Id, tPast.Id, tCancelled.Id }
        ]);

        System.assertEquals('A venir',  refreshed.get(tFuture.Id).Status__c, 'Future => A venir');
        System.assertEquals('En cours', refreshed.get(tCurrent.Id).Status__c, 'Current => En cours');
        System.assertEquals('Terminé',  refreshed.get(tPast.Id).Status__c, 'Past => Terminé');
        System.assertEquals('Annulé',   refreshed.get(tCancelled.Id).Status__c, 'Annulé ne change jamais');
    }
}