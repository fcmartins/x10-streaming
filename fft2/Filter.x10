abstract class Filter[I,O](clock:Clock, inputCount:Int) implements StreamNode {
    private var isAlive:Boolean = true;
    private var reader:Reader[I];
    private var output:DoubleBuffer[O];
    
    public def this() {O haszero} {
        this(1);
    }
    
    public def this(inputCount:Int) {O haszero} {
        this(inputCount, Clock.make());
    }
    
    public def this(inputCount:Int, clock:Clock) {O haszero} {
        this(new DoubleBuffer[O](clock), inputCount);
    }
    
    public def this(out:DoubleBuffer[O], inSize:Int) {
        property(out.clock, inSize);
        this.output = out;
    }
    
    public def pop():I {
        return reader.pop();
    }
    
    public def peek(idx:Int):I {
        return reader.peek(idx);
    }
    
    public def push(value:O) {
        output.writer() = value;
    }
    
    public def eof():void {
        isAlive = false;
    }
    
    public def isAlive():Boolean {
        return isAlive;
    }
    
    public def add[T](sink:Filter[O,T]):Filter[O,T] {
        sink.launch(output.reader, this);
        return sink;
    }
    
    public def setReader(reader:Reader[I]) {
        this.reader = reader;
    }
    
    public def setOutput(out:DoubleBuffer[O]) {
        this.output = out;
    }
    
    protected def createReader(reader:DoubleBuffer.Reader[I]) {
        return new ClockedReader[I](reader, inputCount);
    }
    
    public def launch(bufReader:DoubleBuffer.Reader[I], parent:StreamNode) {
        reader = createReader(bufReader);
        async clocked(bufReader.clock) {
            launch(parent);
        }
    }
    
    def launch(parent:StreamNode) {
        while(parent.isAlive()) {
            work();
        }
        eof();
    }
    
    def launch() {
        while(isAlive) {
            work();
        }
    }
}

