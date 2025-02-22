/**
 * The DMLOperations class serves as a deep dive into Data Manipulation Language (DML) in Apex.
 * It covers fundamental DML operations such as insert, update, upsert, and delete.
 *
 * This class introduces developers to the concept of manipulating Salesforce records in Apex.
 * It discusses how to use DML operations to create, update, and delete records.
 * This class uses standard Salesforce objects like Account, Contact, and Opportunity for demonstration.
 *
 * Topics covered in this class include:
 * - Understanding how to use insert DML operation to create records in Salesforce.
 * - Understanding how to use update and upsert DML operations to update existing records in Salesforce.
 * - Understanding how to use delete DML operation to remove records from Salesforce.
 *
 * Users of this class can expect to gain a strong understanding of DML operations in Apex and
 * be prepared for more advanced topics in Salesforce development.
 *
 * The methods within this class serve as practical examples of different DML operations,
 * allowing developers to learn through practice and examples.
 *
 * @author Temitayo Oluwalade
 */


public with sharing class DMLOperations {

    /**
     * Question 1
     * Create a new Account object and inserts it into the database.
     * The Account will have a random name for uniqueness.
     * @return The Id of the newly created Account.
     */
  
    public static Id insertNewAccount() {
        // Create a new Account instance with a unique name
        Account newAccount = new Account(
            Name = 'Test Account ' + System.currentTimeMillis()
        );
        
        // Insert the Account into the database
        insert newAccount;
        
        // Return the Id of the newly created Account
        return newAccount.Id;
    }

    /**
     * Question 2
     * Create a new Account with the specified name and industry provided.
     * @param name The name of the account to be created.
     * @param industry The industry of the account to be created.
     */
  
    public static void createAccount(String name, String industry) {
        // Create and insert Account with specified fields
        Account newAccount = new Account(
            Name = name,
            Industry = industry
        );
        insert newAccount;
    }

    /**
     * Question 3
     * Create a new Contact and link it to the Account id provided then inserts it into the database.
     * @param accountId The Id of the Account to link the Contact to.
     * @return The Id of the newly created Contact.
     */
  
    public static Id insertNewContact(Id accountId) {
        // Create a new Contact instance
        Contact newContact = new Contact(
            LastName = 'Test Contact ' + System.currentTimeMillis(),
            AccountId = accountId // Link to the provided Account
        );
        
        // Insert the Contact into the database
        insert newContact;
        
        // Return the Id of the newly created Contact
        return newContact.Id;
    }

    /**
     * Question 4
     * Update the last name of a Contact in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param contactId The Id of the Contact to update.
     * @param newLastName The new last name for the Contact.
     */

    public static void updateContactLastName(Id contactId, String newLastName) {
        // Query for the Contact to update
        Contact contactToUpdate = [SELECT Id FROM Contact WHERE Id = :contactId];
        
        // Update the Contact's last name
        contactToUpdate.LastName = newLastName;
        
        // Update the Contact in the database
        update contactToUpdate;
    }

    /**
     * Question 5
     * Update the stage of an Opportunity in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param oppId The Id of the Opportunity to update.
     * @param newStage The new stage for the Opportunity.
     */
   
    public static void updateOpportunityStage(Id oppId, String newStage) {
        // Query for the Opportunity to update
        Opportunity oppToUpdate = [SELECT Id FROM Opportunity WHERE Id = :oppId];
        
        // Update the Opportunity's stage
        oppToUpdate.StageName = newStage;
        
        // Update the Opportunity in the database
        update oppToUpdate;
    }

    /**
     * Question 6
     * Update the Account's Name and Industry given an Account Id.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param accountId The Id of the account to be updated.
     * @param newName The new name for the account.
     * @param newIndustry The new industry for the account.
     */
    
    public static void updateAccountFields(Id accountId, String newName, String newIndustry) {
        // Query for the Account to update
        Account accountToUpdate = [SELECT Id FROM Account WHERE Id = :accountId];
        
        // Update the Account fields
        accountToUpdate.Name = newName;
        accountToUpdate.Industry = newIndustry;
        
        // Update the Account in the database
        update accountToUpdate;
    }

    /**
     * Question 7
     * Create or updates an Opportunities
     * The Opportunity's Stage is set to Qualification.
     * The Opportunity's Close Date is set to 3 months from today.
     * The Opportunity's Amount is set to 50000.
     * @param list of Opportunities to be changed then upserted.
     */

    public static void upsertOpportunityList(List<Opportunity> opportunities) {
        // Loop through each Opportunity in the list
        for(Opportunity opp : opportunities) {
            opp.StageName = 'Qualification';
            opp.CloseDate = Date.today().addMonths(3);
            opp.Amount = 50000;
        }
        
        // Upsert the opportunities List
        upsert opportunities;
    }

    /**
     * Question 8
     * Insert or update opportunities from list of names.
     * Associate the Opportunities with account that has the name accountName.
     * There should be an Opportunity for each name provided in the list.
     * HINT: The account may or may not exists in the database but is required for opportunity creation. Consider how upsert operation can help with this.
     * HINT: There should not be duplicate opportunites based on the name
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     */

    public static void upsertOpportunities(String accountName, List<String> oppNames) {
        // Query for existing account or create new one
        List<Account> existingAccounts = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
        Account acc;
        
        if(!existingAccounts.isEmpty()) {
            acc = existingAccounts[0];
        } else {
            acc = new Account(Name = accountName);
            insert acc;
        }
        
        // Query existing opportunities for this account
        Map<String, Opportunity> existingOpps = new Map<String, Opportunity>();
        for(Opportunity opp : [SELECT Id, Name FROM Opportunity WHERE AccountId = :acc.Id AND Name IN :oppNames]) {
            existingOpps.put(opp.Name, opp);
        }
        
        List<Opportunity> oppsToUpsert = new List<Opportunity>();
        
        // Create or update Opportunities
        for(String oppName : oppNames) {
            Opportunity opp;
            if(existingOpps.containsKey(oppName)) {
                opp = existingOpps.get(oppName);
            } else {
                opp = new Opportunity(
                    Name = oppName,
                    AccountId = acc.Id,
                    StageName = 'Prospecting',
                    CloseDate = Date.today().addMonths(1)
                );
            }
            oppsToUpsert.add(opp);
        }
        
        // Use upsert since we've properly handled existing records
        upsert oppsToUpsert;
    }

    /**
     * Question 9
	 * Upserts an Account with the specified name.
	 * If an Account with the given name already exists, update the description to "Updated Account".
	 * If no such Account exists, it creates a new one and sets the description to "New Account".
	 * @param accountName The name of the Account to be upserted.
	 * @return The Account that was upserted.
	 */

     public static Account upsertAccount(String accountName) {
        // Query for existing account
        List<Account> existingAccounts = [SELECT Id, Name, Description 
                                        FROM Account 
                                        WHERE Name = :accountName 
                                        LIMIT 1];
        
        Account acc;
        if(!existingAccounts.isEmpty()) {
            // Update existing account
            acc = existingAccounts[0];
            acc.Description = 'Updated Account';
            update acc;
        } else {
            // Create new account
            acc = new Account(
                Name = accountName,
                Description = 'New Account'
            );
            insert acc;
        }
        
        return acc;
    }

    /**
     * Question 10
	 * Manage the association between Contacts and Accounts
	 * Ensure that for each Contact in the provided list, there is a corresponding Account Name that matches the Contact's last name.
	 * If such an Account does not exist, the method creates it; if it does, the method ensures the Contact is associated with it. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
     * Example Contact.LastName = 'Doe' Link to Account.Name = 'Doe' 
     * Example Contact.LastName = 'Jane' Link to Account.Name = 'Jane'
	 * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */

     public static void upsertAccountsWithContacts(List<Contact> contactsToUpsert) {
        Map<String, Id> accountsByName = new Map<String, Id>();
        
        // First, ensure all needed accounts exist
        for(Contact cont : contactsToUpsert) {
            if(!accountsByName.containsKey(cont.LastName)) {
                Account acc = upsertAccount(cont.LastName);
                accountsByName.put(cont.LastName, acc.Id);
            }
        }
        
        // Now link contacts to their accounts
        for(Contact cont : contactsToUpsert) {
            cont.AccountId = accountsByName.get(cont.LastName);
        }
        
        // Upsert the contacts
        upsert contactsToUpsert;
    }

    /**
     * Question 11
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */
   
    public static void insertAndDeleteLeads(List<String> leadNames) {
        List<Lead> leadsToInsert = new List<Lead>();
        
        // Create Lead records
        for(String leadName : leadNames) {
            leadsToInsert.add(new Lead(
                LastName = leadName,
                Company = 'Test Company',
                Status = 'Open - Not Contacted'
            ));
        }
        
        // Insert the Leads
        insert leadsToInsert;
        
        // Delete the Leads
        delete leadsToInsert;
    }

    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
  
public static void createAndDeleteCases(String accountId, Integer numOfCases) {
    List<Case> casesToInsert = new List<Case>();
    
    // Create the specified number of Cases
    for(Integer i = 0; i < numOfCases; i++) {
        casesToInsert.add(new Case(
            Subject = 'Test Case ' + i,
            AccountId = accountId,
            Status = 'New',
            Origin = 'Web'
        ));
    }
    
    // Insert the Cases
    insert casesToInsert;
    
    // Delete the Cases
    delete casesToInsert;
  }
}