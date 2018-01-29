class ChartDescription2
{
    var hours = 4;
    var iterator;
    var color;
    var units;
    var unitScale;
    var zones;
    
    function initialize(iterator, units, unitScale, zones)
    {
        self.iterator = iterator;
        self.units = units;
        self.unitScale = unitScale;
        self.zones = zones;
    }
}

class ChartPanel extends Toybox.WatchUi.Drawable
{        
    var charts = new[3];    
    var chartDescrs = new[4];
    
    var chartType = new [3];
    var chartPos = new [3];
    
    var chartCount = 1;
            
    var fpsCalc = 0;
    var fpsDraw = 0;
          
    //var simulation = new SimulationIterator();         
          
    function initialize(params)
    {
        Drawable.initialize(params);
        
        var profile = UserProfile.getProfile();                 
        var zones = profile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_GENERIC);
        
        chartDescrs[Graphomatic.HR] =            new ChartDescription2(new Lang.Method( SensorHistory, :getHeartRateHistory), " bpm", 1.0,  zones);
        //chartDescrs[Graphomatic.HR ] =         new ChartDescription2(new Lang.Method( simulation,    :getIterator),         " bpm", 1.0,  zones);
        
        if (System.getDeviceSettings().elevationUnits == System.UNIT_METRIC) {                
            chartDescrs[Graphomatic.ELEVATION] = new ChartDescription2(new Lang.Method( SensorHistory, :getElevationHistory), " m",   1.0,  null);
        }
        else {
            chartDescrs[Graphomatic.ELEVATION] = new ChartDescription2(new Lang.Method( SensorHistory, :getElevationHistory), " ft",  3.28084,  null);
        }
        
        chartDescrs[Graphomatic.PRESSURE] =      new ChartDescription2(new Lang.Method( SensorHistory, :getPressureHistory),  " hPa", 0.01, null);
        //chartDescrs[Graphomatic.PRESSURE] =    new ChartDescription2(new Lang.Method( SensorHistory, :getPressureHistory),  " mmHg", 0.0075006, null);  

        //chartDescrs[Graphomatic.WEATHER] =       new ChartDescription2(null,                                         " C",   1.0, null);          
    }

    function draw(dc)
    {
        layout(dc);
    
        var lowPriorityIndex = 0;
        
        var highPriorityCount = (chartType[0] == Graphomatic.HR ? 1 : 0) 
                              + (chartType[1] == Graphomatic.HR ? 1 : 0)
                              + (chartType[2] == Graphomatic.HR ? 1 : 0);        
                    
        for (var i = 0; i <= 2; i++)        
        {
            var chart = charts[i];
        
            if (chart == null)
            {
                continue;
            }
            
            var highPriorityChart = chart.type == Graphomatic.HR;
            
            // Slow CPU and limited execution time, only two graphs can be drawn simultaniously.
            var fullDraw =  highPriorityChart  || fpsDraw % (chartCount - highPriorityCount) == lowPriorityIndex;
            
            // at onShow and onHide will draw as fast as possible
            fullDraw = fullDraw & !$.fastDraw;
            
            if (!highPriorityChart) { lowPriorityIndex++; }                                        
            
            if (chart.type == Graphomatic.WEATHER)
            {   
                drawWeatherChart(dc, chart, chartPos[i], fullDraw);
            }
            else
            {                                
                var d = chartDescrs[chart.type];   
                        
                drawChart(dc, chart, chartPos[i], d.iterator, d.unitScale, d.units, d.hours, fullDraw, d.color);
            }
        }       
                
        $.fastDraw = false;                   
                
        // debug info    
        fpsDraw++;
                
        if (Application.getApp().getProperty("ShowDebugInfo"))
        {
            var height = dc.getHeight();
                    
            dc.drawLine(0, height - 4, (fpsCalc % 40), height - 4); 
            dc.drawLine(0, height - 3, (fpsDraw % 40), height - 3);
        }
    }
    
    function layout(dc)
    {
    		var app = Application.getApp();
    
        chartDescrs[1].hours = app.getProperty("DurationDefault");
        chartDescrs[2].hours = 0;
        chartDescrs[3].hours = app.getProperty("DurationPressure");
        
        chartDescrs[2].color = app.getProperty("ColorElevation");
        chartDescrs[3].color = app.getProperty("ColorPressure");        

        for (var i=1; i <= 3; i++)
        {
            if (chartDescrs[i].color == -1) { chartDescrs[i].color = null; }
            if (chartDescrs[i].hours >= 10) { chartDescrs[i].hours /= 60.0; }
            if (chartDescrs[i].hours ==  0) { chartDescrs[i].hours = chartDescrs[1].hours; }                                    
        }

        chartType[0] = app.getProperty(Graphomatic.graph1Type);            
        chartType[1] = app.getProperty(Graphomatic.graph2Type);        
        chartType[2] = app.getProperty(Graphomatic.graph3Type);
        
        if (chartType[1] == Graphomatic.NONE)
        {
            chartType[1] = chartType[2];
            chartType[2] = Graphomatic.NONE;
        }
        
        // Layout
        chartCount = (chartType[0] != Graphomatic.NONE ? 1 : 0) 
                   + (chartType[1] != Graphomatic.NONE ? 1 : 0)
                   + (chartType[2] != Graphomatic.NONE ? 1 : 0);
                                 
        chartPos[0] = chartCount < 3 ?  84 :  22;
        chartPos[1] = chartCount < 3 ? 146 :  84;
        chartPos[2] =                        146;

        var chartHeight = new [3];
        
        chartHeight[0] = 55;
        chartHeight[1] = 55;
        chartHeight[2] = 55;
        
        // special cases
        if (chartType[0] == Graphomatic.HR && chartCount == 1)
        {
            chartHeight[0] = 117;
        }
        
        if (chartType[0] == Graphomatic.WEATHER && chartCount <= 2)
        {
            chartPos[0] = 79;
            chartHeight[0] = 60;
        }
                                                                          
        for (var i = 0; i <= 2; i++)
        {
            if (    charts[i] != null 
                && (charts[i].type != chartType[i] || charts[i].height != chartHeight[i]))
            {
                charts[i] = null;
            }
        }

        var width = dc.getWidth();
        
        for (var i = 0; i <= 2; i++)
        {        
            if (charts[i] == null && chartType[i] != Graphomatic.NONE)
            {
                if (chartType[i] == Graphomatic.WEATHER)
                {
                    charts[i] = new WeatherChart(chartType[i], width, chartHeight[i]);
                }
                else
                {
                    charts[i] = new Chart(chartType[i], width, chartHeight[i]);
                }
                
                if (chartType[i] == Graphomatic.HR)
                {
                    charts[i].fixedMinY = 30;
                    charts[i].fixedMaxY = chartCount == 1 ? 200 : null;
                    charts[i].zones = chartDescrs[Graphomatic.HR].zones;
                }
            }  
        }          
    }

    function drawWeatherChart(dc, chart, y, fullDraw)
    {    
        if (fullDraw && chart.isUpdateNeeded())
        {      
            fpsCalc++;
                          
            var dcBuf = chart.buffer.getDc();           
            dcBuf.clear();
                            
            chart.draw(dcBuf, 0);
        }
                        
        if (chart.buffer != null)
        {
            dc.drawBitmap(0, y + chart.bufferOffset, chart.buffer);
            chart.drawOverlay(dc, y);
        }
        
        //dc.drawRectangle(0, y, chart.width, chart.height);        
    }
        
    function drawChart(dc, chart, y, historyProvider, unitScale, unit, hours, fullDraw, color)
    {
        // seconds per pixel
        var dX = hours * 60 * 60 / chart.width;
                
        if (fullDraw && (Time.now().value() - chart.lastSampledTime.value() > dX))
        {
            fpsCalc++;
        
            var dcBuf = chart.buffer.getDc();           
            dcBuf.clear();
            
            var options = {:period => new Time.Duration(60*60*hours)};                        
            var histIterator = historyProvider.invoke(options);
            
            var style = Application.getApp().getProperty("GraphStyle");                
            
            chart.draw(dcBuf, histIterator, 0, hours, unitScale, style, color);
        }
        else
        {
            var options = {:period => 1};
        
            chart.curr = historyProvider.invoke(options).next();
        }      
                                
        if (chart.buffer != null)
        {
            dc.drawBitmap(0, y, chart.buffer);
            chart.drawOverlay(dc, y, unitScale, unit);
        }
        
        //dc.drawRectangle(0, y, chart.width, chart.height);
    }
}