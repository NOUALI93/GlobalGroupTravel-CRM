@isTest
public class TestDataFactory {
    public static Account createAccount() {
        Account a = new Account(Name = 'Test Account');
        insert a;
        return a;
    }

    public static Opportunity createOpportunity(Id accountId) {
        Opportunity o = new Opportunity(
            Name = 'Test Opp',
            AccountId = accountId,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            Amount = 5000,
            Destination__c = 'Paris',
            Start_Date__c = Date.today().addDays(20),
            End_Date__c = Date.today().addDays(25),
            Number_of_Participants__c = 12
        );
        insert o;
        return o;
    }
}
