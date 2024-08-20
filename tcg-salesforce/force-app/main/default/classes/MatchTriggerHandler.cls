public with sharing class MatchTriggerHandler extends TriggerHandlerAbstract {
    public override void runBeforeUpdate() {
        if(!Trigger.isBefore || !Trigger.isUpdate) { return; }
        //TODO: Call MatchService
    }

    public override void runBeforeInsert() {
        if(!Trigger.isBefore || !Trigger.isInsert) { return; }
        //TODO: Call MatchService
    }

    public override void runAfterInsert() {
        if(!Trigger.isAfter || !Trigger.isInsert) { return; }
        //TODO: Call MatchService
    }

    public override void runAfterUpdate() {
        if(!Trigger.isAfter || !Trigger.isUpdate) { return; }
        //TODO: Call MatchService
    }
}