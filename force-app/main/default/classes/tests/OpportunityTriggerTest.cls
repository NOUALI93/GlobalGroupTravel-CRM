@isTest
public class OpportunityTriggerTest {

    @isTest
    static void createsTripWhenOpportunityBecomesWon() {
        Account a = TestDataFactory.createAccount();
        Opportunity o = TestDataFactory.createOpportunity(a.Id);

        Test.startTest();
        o.StageName = 'Closed Won';
        update o;
        Test.stopTest();

        List<Trip__c> trips = [
            SELECT Id, Status__c, Account__c, Opportunity__c, Total_Cost__c
            FROM Trip__c
            WHERE Opportunity__c = :o.Id
        ];

        System.assertEquals(1, trips.size(), 'Un Trip doit être créé à la clôture gagnée.');
        System.assertEquals('A venir', trips[0].Status__c, 'Statut par défaut attendu.');
        System.assertEquals(a.Id, trips[0].Account__c, 'Trip doit être lié à l’Account.');
        System.assertEquals(o.Id, trips[0].Opportunity__c, 'Trip doit être lié à l’Opportunity.');
        System.assertEquals(5000, trips[0].Total_Cost__c, 'Total cost doit copier Amount.');
    }

    @isTest
    static void doesNotCreateDuplicateTripOnFurtherUpdates() {
        Account a = TestDataFactory.createAccount();
        Opportunity o = TestDataFactory.createOpportunity(a.Id);

        // 1) Passe en gagné -> crée Trip
        o.StageName = 'Closed Won';
        update o;

        // 2) Update encore -> ne doit pas créer un 2e Trip
        Test.startTest();
        o.Description = 'Update after won';
        update o;
        Test.stopTest();

        Integer tripCount = [
            SELECT count()
            FROM Trip__c
            WHERE Opportunity__c = :o.Id
        ];
        System.assertEquals(1, tripCount, 'Aucun doublon ne doit être créé.');
    }
}
