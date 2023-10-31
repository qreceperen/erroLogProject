public with sharing class DMLUtils {
	// Properties
	public Enum DMLOperation {
		DO_DELETE,
		DO_INSERT,
		DO_UNDELETE,
		DO_UPDATE,
		DO_UPSERT
	}
	// Execution Methods
	public static void doOperate(DMLOperation operation, List<SObject> operationList) {
		// Logic
		try {
			if(operation == DMLOperation.DO_DELETE) {
				delete operationList;
			}
			if(operation == DMLOperation.DO_INSERT) {
				insert operationList;
			}
			if(operation == DMLOperation.DO_UNDELETE) {
				undelete operationList;
			}
			if(operation == DMLOperation.DO_UPDATE) {
				update operationList;
			}
			if(operation ==     DMLOperation.DO_UPSERT) {
				upsert operationList;
			}
		} catch(Exception e) {
			String sSystem;
			sSystem = 'DML ' + operation + ' Error'; // We can replace with more descriptive name

			ErrorLog.log(sSystem, e, null);
			throw e;
		}
	}
}