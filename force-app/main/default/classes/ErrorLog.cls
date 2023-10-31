public without sharing class ErrorLog {
    @TestVisible
    private static final Integer max_JSON_length = Error_Log_Event__e.Bulk_Errors_JSON__c.getDescribe().getLength();
    
    public static Error_Log__c createLog(String sSystem, String sError, Exception oException, String relatedId) {
        Error_Log__c oErrorLog = new Error_Log__c();
        
        String s = oException.getStackTraceString();
        
        // remove all ErrorLog entries in stack trace
        while(s.substringBefore('\n').startsWithIgnoreCase('Class.ErrorLog.')) {
        	s = s.substringAfter('\n');
        }
        
        oErrorLog.Stack_Trace__c = s;
        
        if (s.startsWithIgnoreCase('Class.')) {
            String sClass = s.substringAfter('Class.');
            if (sClass.indexOf('.') >= 0) {
                oErrorLog.Class__c = s.substringAfter('Class.').substringBefore('.');
                oErrorLog.Method__c = s.substringBefore(':').substringAfterLast('.');
            } else {
                oErrorLog.Class__c = s.substringAfter('Class.').substringBefore(':');
            }
        } else {
            oErrorLog.Method__c = s.substringBefore(':');
        }

        try { oErrorLog.Line_Number__c = Integer.valueOf(s.substringAfter(': line ').substringBefore(',')); } catch (Exception e) { oErrorLog.Line_Number__c = -1; }
        
        oErrorLog.Error_Message__c = sError;
        oErrorLog.System__c = sSystem;
        oErrorLog.Related_Id__c = relatedId;
        
        return oErrorLog;
    }
    
    @TestVisible
    private static void sendEvent(List<Error_Log__c> lstErrors, Boolean test_bypass){
        if (Test.isRunningTest() && !test_bypass){
            insert lstErrors;
            return;
        }
        List<Error_Log_Event__e> eventList = new List<Error_Log_Event__e>();
        List<Error_Log__c> errors = lstErrors.clone();
        Error_Log__c prev_error;
        List<Error_Log__c> currEventErrors = new List<Error_Log__c>();
        while (!errors.isEmpty()){
            prev_error = errors.remove(errors.size()-1);
            currEventErrors.add(prev_error);
            String js = JSON.serialize(currEventErrors);
            if(js.length() > max_JSON_length - 1){
                prev_error = currEventErrors.remove(currEventErrors.size()-1);
                eventList.add(new Error_Log_Event__e(Bulk_Errors_JSON__c=JSON.serialize(currEventErrors)));
                currEventErrors = new List<Error_Log__c>();
                errors.add(prev_error);
            }else if (errors.isEmpty()){
                eventList.add(new Error_Log_Event__e(Bulk_Errors_JSON__c=js));
            }
        }
        
        if (!eventList.isEmpty()){
            EventBus.publish(eventList);
        }
    }
    
    private static void log(String sSystem, String sError, Exception oException, String relatedId) {
        sendEvent(new List<Error_Log__c> {createLog(sSystem, sError, oException, relatedId)}, false);
    }
    
    public static void log(String sSystem, String sError, String relatedId) {
        log(sSystem, sError, new DMLException(), relatedId);
    }
    
    public static void log(String sSystem, Exception e, String relatedId) {
        log(sSystem, e.getMessage(), e, relatedId);
    }
    
	public static void log(String sSystem, Database.SaveResult[] srList) { 
        List<Error_Log__c> lstErrors = new List<Error_Log__c>();
        
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                String sError = '';
                
                // Operation failed, so get all errors
                for(Database.Error err : sr.getErrors()) {
                    if (String.isNotBlank(sError)) sError += '\n';
                    
                    sError += err.getStatusCode() + ': ' + err.getMessage();
                }
                
                lstErrors.add(createLog(sSystem, sError, new DMLException(), sr.getId()));
            }
        }
        
        if (!lstErrors.isEmpty()) {
            sendEvent(lstErrors, false);
        }
    }

    public static void log(String sSystem, Database.UpsertResult[] srList) { 
        List<Error_Log__c> lstErrors = new List<Error_Log__c>();
        
        for (Database.UpsertResult sr : srList) {
            if (!sr.isSuccess()) {
                String sError;
                
                // Operation failed, so get all errors
                for(Database.Error err : sr.getErrors()) {
                    if (String.isNotBlank(sError)) sError += '\n';
                    
                    sError += err.getStatusCode() + ': ' + err.getMessage();
                }
                
                lstErrors.add(createLog(sSystem, sError, new DMLException(), sr.getId()));
            }
        }
        
        if (!lstErrors.isEmpty()) {
            sendEvent(lstErrors, false);
        }
    }

    public static void log(String sSystem, Database.UpsertResult[] srList, List<sObject> upsertRecList, String objectAPIName, List<String> fieldsAPINames ) { 
        List<Error_Log__c> lstErrors = new List<Error_Log__c>();
        
        Integer recIndex = 0;
        for (Database.UpsertResult sr : srList) {
            if (!sr.isSuccess()) {
                String fieldValues = '';
                sObject upsertRec = upsertRecList[recIndex];
                Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectAPIName).getDescribe().fields.getMap();
                for( String fieldName : fieldsAPINames ){
                    fieldValues += fieldMap.get(fieldName).getDescribe().getLabel()+':'+upsertRec.get(fieldName)+'\n';
                }
                
                String sError='';
                // Operation failed, so get all errors
                for(Database.Error err : sr.getErrors()) {
                    if (String.isNotBlank(sError)) sError += '\n';
                    
                    sError += err.getStatusCode() + ': ' + err.getMessage();
                }
                
                Error_Log__c errLog = createLog(sSystem, sError, new DMLException(), sr.getId());
                errLog.Field_Values__c = fieldValues;
                lstErrors.add(errLog);
            }
            recIndex++;
        }
        
        if (!lstErrors.isEmpty()) {
            sendEvent(lstErrors, false);
        }
    }

    public static void log(String sSystem, Database.DeleteResult[] srList) { 
        List<Error_Log__c> lstErrors = new List<Error_Log__c>();
        
        for (Database.DeleteResult sr : srList) {
            if (!sr.isSuccess()) {
                String sError;
                
                // Operation failed, so get all errors
                for(Database.Error err : sr.getErrors()) {
                    if (String.isNotBlank(sError)) sError += '\n';
                    
                    sError += err.getStatusCode() + ': ' + err.getMessage();
                }
                
                lstErrors.add(createLog(sSystem, sError, new DMLException(), sr.getId()));
            }
        }
        
        if (!lstErrors.isEmpty()) {
            sendEvent(lstErrors, false);
        }
    }
}