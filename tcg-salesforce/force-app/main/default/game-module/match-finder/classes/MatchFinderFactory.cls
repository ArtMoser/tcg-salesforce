public with sharing class MatchFinderFactory {
    public class MatchFinderData {
        @AuraEnabled
        public List<Match__c> matches { get;set; }
        @AuraEnabled
        public Match__c match { get;set; }
    }
}