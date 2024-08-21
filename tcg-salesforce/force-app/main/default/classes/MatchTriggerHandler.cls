public with sharing class MatchTriggerHandler extends TriggerHandlerAbstract {
    public MatchService service = new MatchService();

    public override void runBeforeUpdate() {
        if(!Trigger.isBefore || !Trigger.isUpdate) { return; }
    }

    public override void runBeforeInsert() {
        if(!Trigger.isBefore || !Trigger.isInsert) { return; }
    }

    public override void runAfterInsert() {
        if(!Trigger.isAfter || !Trigger.isInsert) { return; }
        service.generateMatchRows(Trigger.new, (Map<Id, Match__c>) Trigger.oldMap);
    }

    public override void runAfterUpdate() {
        if(!Trigger.isAfter || !Trigger.isUpdate) { return; }
        service.generateMatchRows(Trigger.new, (Map<Id, Match__c>) Trigger.oldMap);
    }
}