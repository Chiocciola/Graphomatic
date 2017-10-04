/*
class SimulationIterator
{
    var curr = 0;
    var max = 148;
    
    var vals = new [149];
    
    var time;

    function initialize()
    {          
        while(curr < max)
        {        
            vals[curr] = 60 + 120 / (1 + 0.01*(curr - max/3)*(curr - max/3)) + Math.rand()/200000000;
    
            curr++;   
        }     
    }
    
    function getIterator(options)
    {
        time = Time.now();  
        curr = 0;
        
        return self;
    }

    function getMin()
    {
        return 60;
    }
    
    function getMax()
    {
        return 180;
    }
    
    function next()
    {
        if (curr >= max)
        {
            return null;
        }
    
        var sample = new SensorHistory.SensorSample();
        
        sample.data = vals[curr];
        sample.when = time.add(new Time.Duration(-4*60*60*curr/max));
    
        curr++;
    
        return sample;
    }
}
/**/