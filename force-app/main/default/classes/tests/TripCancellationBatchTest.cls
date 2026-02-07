@isTest
public class TripCancellationBatchTest {

    @isTest
    static void cancelsTripsStartingIn7DaysWithLessThan10Participants() {
        // 1) Données de base
        Account a = TestDataFactory.createAccount();

        // 2) Trip qui DOIT être annulé (J+7, participants = 5)
        Trip__c t = new Trip__c(
            Status__c = 'A venir',
            Destination__c = 'Berlin',
            Start_Date__c = Date.today().addDays(7),
            End_Date__c = Date.today().addDays(10),
            Number_of_Participants__c = 5,
            Total_Cost__c = 1500,
            Account__c = a.Id
        );
        insert t;

        // 3) Exécution du batch
        Test.startTest();
        Database.executeBatch(new TripCancellationBatch(), 200);
        Test.stopTest();

        // 4) Vérification
        Trip__c refreshed = [SELECT Status__c FROM Trip__c WHERE Id = :t.Id];
        System.assertEquals('Annulé', refreshed.Status__c, 'Le Trip doit être annulé si < 10 participants à J-7.');
    }

    @isTest
    static void doesNotCancelTripsWhenParticipantsIsNullOrEnough() {
        Account a = TestDataFactory.createAccount();

        // Trip J+7 mais participants NULL => ne doit PAS être annulé
        Trip__c tNull = new Trip__c(
            Status__c = 'A venir',
            Destination__c = 'Madrid',
            Start_Date__c = Date.today().addDays(7),
            End_Date__c = Date.today().addDays(9),
            Number_of_Participants__c = null,
            Total_Cost__c = 900,
            Account__c = a.Id
        );

        // Trip J+7 mais participants >= 10 => ne doit PAS être annulé
        Trip__c tOk = new Trip__c(
            Status__c = 'A venir',
            Destination__c = 'Lisbon',
            Start_Date__c = Date.today().addDays(7),
            End_Date__c = Date.today().addDays(9),
            Number_of_Participants__c = 12,
            Total_Cost__c = 900,
            Account__c = a.Id
        );

        insert new List<Trip__c>{ tNull, tOk };

        Test.startTest();
        Database.executeBatch(new TripCancellationBatch(), 200);
        Test.stopTest();

        Map<Id, Trip__c> m = new Map<Id, Trip__c>([
            SELECT Status__c FROM Trip__c WHERE Id IN :new List<Id>{ tNull.Id, tOk.Id }
        ]);

        System.assertEquals('A venir', m.get(tNull.Id).Status__c, 'Participants null => ne pas annuler.');
        System.assertEquals('A venir', m.get(tOk.Id).Status__c, '>= 10 participants => ne pas annuler.');
    }
}