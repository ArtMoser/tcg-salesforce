trigger MatchTrigger on Match__c (before insert, before update, after insert, after update) {
    new MatchTriggerHandler().init();
}