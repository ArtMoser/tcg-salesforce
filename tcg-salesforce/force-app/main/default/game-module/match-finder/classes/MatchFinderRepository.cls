public with sharing class MatchFinderRepository {
    public List<Match__c> getMatchesByStatus(String status) {
        return [
            SELECT 
                Id, 
                Status__c, 
                PlayerOne__r.Name, 
                PlayerTwo__r.Name 
            FROM 
                Match__c 
            WHERE 
                Status__c =: status// 'Waiting'
        ];
    }
}