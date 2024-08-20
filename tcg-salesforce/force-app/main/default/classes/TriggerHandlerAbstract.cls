public abstract class TriggerHandlerAbstract {
    
    public abstract void runBeforeInsert();
    public abstract void runBeforeUpdate();
    public abstract void runAfterInsert();
    public abstract void runAfterUpdate();
    
    public void init() {
        runBeforeInsert();
        runBeforeUpdate();
        runAfterInsert();
        runAfterUpdate();
    }
}