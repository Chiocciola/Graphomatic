class Chart
{
    const axesColor = Graphics.COLOR_WHITE;  

    var type;
    var width; 
    var height; 
    var chartHeight;    
           
    var xScaleOffset = 0;
     
    var lastSampledTime = new Time.Moment(0);
        
    var curr;
    
    var fixedMinY = null;
    var fixedMaxY = null;
    
    var zones = null;
    
    var minX = -1;
    var minY = -1;
    var minV =  1000000;
    var minC =  null;    
        
    var maxX = -1;
    var maxY = -1;
    var maxV = -1000000;
    var maxC = null;
    
    var buffer;
    
    function initialize (type, width, height)
    {
        self.type = type;
        self.width = width;
        self.height = height;
        
        xScaleOffset = (height <= 70) ? 0 : 5;
        
        chartHeight = height - 15 - xScaleOffset;
        
        var options = {:width => width, :height => chartHeight};
        buffer = new Graphics.BufferedBitmap(options);    
    }  
        
    function GetHrColor(hr, zones)
    {
        if (hr < zones[0]) { return 0; }
        if (hr < zones[1]) { return 1; }
        if (hr < zones[2]) { return 2; }
        if (hr < zones[3]) { return 3; }
        if (hr < zones[4]) { return 4; }
        if (hr < zones[5]) { return 5; }
        
        return 6;
    }
     
    function draw(dc, histIterator, posY, hours, unitsScale, style, colorIndex)
    {                   
        var drawTime = Time.now();
        
        //axesColor = colorIndex == null ? Graphics.COLOR_WHITE : colorA[colorIndex];
                      
        var iterMin = histIterator != null ? (histIterator.getMin() != null ? histIterator.getMin() : 0) : 0;        
        var iterMax = histIterator != null ? (histIterator.getMax() != null ? histIterator.getMax() : 1) : 1;
                                        
        var yScaleMin = fixedMinY != null ? fixedMinY : (iterMin * unitsScale).toLong().toDouble();
        var yScaleMax = fixedMaxY != null ? fixedMaxY : (iterMax * unitsScale).toLong().toDouble();
                      
        if ((yScaleMax - yScaleMin).abs() < 0.001)
        {
            yScaleMax = yScaleMin + 1;
        }
            
        var yScaleStep = 1.0;
        
        while ((yScaleMax - yScaleMin) / yScaleStep > chartHeight / 2)
        {
            yScaleStep *= 10;
        }
        
        yScaleMin = (yScaleMin / yScaleStep).toLong() * yScaleStep;
        yScaleMax = (yScaleMax / yScaleStep).toLong() * yScaleStep;
        
        if (iterMax * unitsScale > yScaleMax)
        {
            yScaleMax += yScaleStep;
        }
        
        if (iterMin * unitsScale < yScaleMin)
        {
            yScaleMin -= yScaleStep;
        }        
                
        if ((yScaleMax - yScaleMin).abs() < 0.001)
        {
            yScaleMax = yScaleMin + 1;
        }
        
        if ((yScaleMax - yScaleMin).abs() / yScaleStep > 10)
        {
            yScaleStep = yScaleStep * 5;
        }        
                        
        var dY = (chartHeight - 1) / (yScaleMax - yScaleMin);
                
        var dX = hours * 60.0 * 60.0 / width;                        

        // Current value
        curr = histIterator != null ? histIterator.next() : null;
       
        if (curr != null)
        {                               
            lastSampledTime = curr.when;            
        }
                
        // graph                
        minX = -1;
        minY = -1;
        minV =  1000000;
        
        maxX = -1;
        maxY = -1;
        maxV = -1000000;
        
        var prevX   = null;
        var prevMin = null;
        var prevMax = null;
        var prevColor = null;        
        
        var currX   = null; 
        var currMin = null;
        var currMax = null;
        var currColor = null;
        
        var sampleRate = null;
                        
        for (var sample = curr; sample != null; sample = histIterator.next())
        {
            var x = (width - (drawTime.value() - sample.when.value()) / dX).toLong(); 
            
            if (x < 0)
            {
                break;
            }
            
            if (sampleRate == null && currX != null)
            {
                sampleRate = lastSampledTime.subtract(sample.when);
            }
                                        
            if (x != currX)
            {
                while (prevX != currX && prevX != null)
                {
                    drawLine(dc, prevX, prevMin, prevMax, prevColor, style);  
                    prevX--; 
                }
                                            
                prevX     = currX;
                prevMin   = currMin;
                prevMax   = currMax;
                prevColor = currColor;
                                
                currX     = x;
                currMin   = null;
                currMax   = null;
                currColor = null;
            }
        
            if (sample.data == null)
            {
                continue;
            }                    
                    
            var y = (posY + chartHeight - 1) - (sample.data * unitsScale - yScaleMin) * dY;
            
            if (currMin == null || currMin > y)
            {
                currMin = y;
                
                if (prevMax != null && prevMax < currMin)
                {
                    prevMax = currMin;
                }
                
                currColor = (zones != null) ? GetHrColor(sample.data * unitsScale, zones) : colorIndex;              
            }
                                
            if (currMax == null || currMax < y)
            {
                currMax = y;
                
                if (prevMin != null && currMax < prevMin)
                {
                    currMax = prevMin;
                }               
            }            
                       
            if (minV > sample.data)
            {
                minV = sample.data;
                minX = x;
                minY = y;
                minC = currColor;
            }

            if (maxV < sample.data)
            {
                maxV = sample.data;
                maxX = x;
                maxY = y;
                maxC = currColor;
            }                                       
        }        

        // prev last  point        
        while (prevX != currX && prevX != null)
        {
            drawLine(dc, prevX, prevMin, prevMax, prevColor, style);
            prevX--;            
        }
        
        // last point
//        while (currX != null && currX >= 0)
//        {
            drawLine(dc, currX, currMin, currMax, currColor, style);
//            currX--;
//        }
        
        //
//        while (lastSampledTime.add(sampleRate).lessThan(drawTime))
//        {
//            lastSampledTime = lastSampledTime.add(sampleRate);
//        }
        
        var yBottom = posY + chartHeight - 1;        
        
        // Y-axis      
        dc.setColor(axesColor, Graphics.COLOR_TRANSPARENT);
         
        for (var i = (yScaleMin / yScaleStep).toLong() * yScaleStep + yScaleStep; i <= yScaleMax; i += yScaleStep)
        {
            var y = yBottom - ((i - yScaleMin) * dY);
        
            dc.drawLine(0, y, 4, y);    
            
            if (zones == null)
            {
                dc.drawLine(width - 1, y, width - 5, y);
            }                   
        }
        
        if (zones != null)
        {
            for (var i = 0; i < 6; i++)
            {
                var y = yBottom - ((zones[i] - yScaleMin) * dY);
                                                
                dc.setColor(Colors.Regular[i+1], Graphics.COLOR_BLACK);
                                
                //dc.drawLine(0, y1, 4, y1);
                dc.drawLine(width - 1, y, width - 5, y);                                     
            }
        }          

        // X-axis scale
        dc.setColor(axesColor, Graphics.COLOR_TRANSPARENT);            
        dc.drawLine(0, yBottom, width, yBottom);
         
        yBottom += xScaleOffset;
                               
        for (var i = 1; i < hours; i++)
        {
            var x = (width - 1) * i / hours;
        
            dc.drawLine(x, yBottom - 5, x, yBottom + 1);  
        }       
    }
    
    function drawLine(dc, x, y1, y2, colorIndex, style)
    {
        if (y2 == null)
        {
            return;
        }
        
        switch (style)
        {
            case 0:
                dc.setColor(colorIndex != null ? Colors.Fill[colorIndex] : Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);           
                dc.drawLine(x, y2, x, chartHeight);   

                dc.setColor(colorIndex != null ? Colors.Outline[colorIndex] : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);          
                dc.drawLine(x, y1, x, y2 + 1);
                break;
                
            case 1:
                dc.setColor(colorIndex != null ? Colors.Regular[colorIndex] : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);           
                dc.drawLine(x, y1, x, chartHeight);   
                break;

            case 2:
                dc.setColor(colorIndex != null ? Colors.Regular[colorIndex] : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);           
                dc.drawLine(x, y1, x, y2 + 1);   
                break;                 
        }         
    }
    
    function drawOverlay(dc, posY, unitsScale, unit)
    {
        // Max mark
        if (maxX >= 0)
        {
            dc.setColor((maxC != null) ? Colors.MinMax[maxC] : Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        
            dc.drawRectangle(maxX - 1, posY + maxY - 1, 3, 3);
            dc.drawRectangle(maxX - 2, posY + maxY - 2, 5, 5);
        }
        
        // Min mark
        if (minX >= 0)
        {
            dc.setColor((minC != null) ? Colors.MinMax[minC] : Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        
            dc.drawRectangle(minX - 1, posY + minY - 1, 3, 3);
            dc.drawRectangle(minX - 2, posY + minY - 2, 5, 5);
         }       

        var yText = posY + height - 15 - 1 - 2;
                    
        // Min/Max text   
        if (minX >= 0 && maxX >= 0)
        {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        
            var minMax =  (minV * unitsScale).toLong().toString() + " - " + (maxV * unitsScale).toLong().toString();
        
            dc.drawText(2, yText, Graphics.FONT_TINY, minMax, Graphics.TEXT_JUSTIFY_LEFT); 
        }               

        // Current value        
        var currStr = "n/a";
    
        if (type == Graphomatic.HR && Activity.getActivityInfo().currentHeartRate != null)
        {       
            currStr = (Activity.getActivityInfo().currentHeartRate * unitsScale).toLong().toString() + unit;
        }    
        else if (   curr != null            
            && curr.data != null)
        {
            currStr = (curr.data * unitsScale).toLong().toString() + unit;          
        }
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width - 3, yText, Graphics.FONT_TINY, currStr, Graphics.TEXT_JUSTIFY_RIGHT);  
    }        
}