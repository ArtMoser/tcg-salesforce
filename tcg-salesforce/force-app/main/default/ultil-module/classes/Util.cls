public with sharing class Util {
    public Boolean isChangedAndIsNotNull(SObject record, SObject oldRecord, String fieldName) {
        Object recordValue = record.get(fieldName);
        Object oldRecordValue = oldRecord.get(fieldName);

        return recordValue != oldRecordValue && recordValue != null && oldRecordValue == null;
    }

    public Boolean isChangedToOtherValue(SObject record, SObject oldRecord, String fieldName) {
        Object recordValue = record.get(fieldName);
        Object oldRecordValue = oldRecord.get(fieldName);

        return recordValue != oldRecordValue && recordValue != null && oldRecordValue != null;
    }

    public Integer getRandomPlayerByNumber() {
        Double randomValue = Math.random();

        Integer randomNumber = Math.round(randomValue * 2);

        if (randomNumber == 0) {
            randomNumber = 1;
        }

        return randomNumber;
    }
}