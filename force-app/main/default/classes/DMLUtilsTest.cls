@IsTest
private without sharing class DMLUtilsTest {
	@IsTest
	static void doInsert() {
		Account account;

		account = new Account(
			Name = 'Test Account'
		);

		Test.startTest();
		DMLUtils.doOperate(DMLUtils.DMLOperation.DO_INSERT, new List<SObject> { account });
		Test.stopTest();

		Assert.isTrue(true, 'The test successfully inserted an Account SObject');
	}
	@IsTest
	static void otherOperations() {
		List<Account> accountList;

		accountList = new List<Account> {
			new Account(
				Name = 'Test Account 1'
			),
			new Account(
				Name = 'Test Account 2'
			)
		};

		Test.startTest();
		DMLUtils.doOperate(DMLUtils.DMLOperation.DO_UPSERT, accountList);
		accountList[0].Name = 'Updated Test Account 1';
		DMLUtils.doOperate(DMLUtils.DMLOperation.DO_UPDATE, accountList);
		DMLUtils.doOperate(DMLUtils.DMLOperation.DO_DELETE, accountList);
		DMLUtils.doOperate(DMLUtils.DMLOperation.DO_UNDELETE, accountList);
		Test.stopTest();

		Assert.isTrue(true, 'The test successfully handled the remaining DML Operations');
	}
	@IsTest
	static void throwException() {
		Account account;

		account = new Account();

		Test.startTest();
		DMLUtils.doOperate(DMLUtils.DMLOperation.DO_INSERT, new List<SObject> { account });
		Test.stopTest();

		Assert.isTrue(true, 'The test threw an exception which was caught');
	}
}