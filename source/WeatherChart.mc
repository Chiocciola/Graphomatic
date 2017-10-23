class WeatherChartModel
{
    var status;
    var communicationError;
    var location;
    
    var weatherError;
    var h;
    var i;
    var t;
    var startIndex;
}

class WeatherChart
{
    //const linePos = 0;
    //const timePos = 0;
    //const tempPos = 16;
    //const locaPos = 37;

    const locaPos = -5;
    var iconPos = 10;
    var linePos = 15;            
    var timePos = 18;
    var tempPos = 33;
    
    var type;
    var width; 
    var height; 
    
    var buffer;
    var bufferOffset = 0;
    
    var drawnDataTime;
    var drawnHourTime;
    var drawnError;
    var drawnStatus;
       
    var drawCounter = 0;
    
    var iconMode = true;

    function initialize (type, width, height)
    {
        self.type = type;
        self.width = width;
        self.height = height;
        
        iconMode = height >= 60;
        
        if (iconMode)        
        {
            linePos = iconPos;
        }
               
        var options = {:width => width, :height => height - linePos};
        buffer = new Graphics.BufferedBitmap(options); 
        
        bufferOffset = linePos;
              
        timePos -= linePos;
        tempPos -= linePos;
        linePos -= linePos;
        
        var extraHeight = height - 55;                     
        linePos += extraHeight;
        timePos += extraHeight;
        tempPos += extraHeight;           
    }  

    function isUpdateNeeded()
    {    
        var dataTime = Application.getApp().getProperty(Weather.TIME);
        var error = Application.getApp().getProperty(Weather.ERROR);
        var status = Application.getApp().getProperty(Weather.STATUS);
    
        var now = Time.now().value();
        var hourTime = now - now % 3600;
        
        return self.drawnDataTime == null
            || self.drawnHourTime == null
            || self.drawnDataTime != dataTime  
            || self.drawnHourTime != hourTime 
            || !equals (self.drawnStatus, status)
            || !equals (self.drawnError,  error);
    }
    
    function equals(a, b)
    {
        if (a == null) { return b == null; }
        if (b == null) { return false; }
        
        if (a instanceof Toybox.Lang.String)
        {
            return a.equals(b);
        }
        
        return a == b;
    }

    function draw(dc, pos)
    {
        drawnDataTime = Application.getApp().getProperty(Weather.TIME);
    
        var now = Time.now().value();
        drawnHourTime = now - now % 3600;            
    
        drawnStatus = Application.getApp().getProperty(Weather.STATUS);
        drawnError = Application.getApp().getProperty(Weather.ERROR);
            
        var model = getModel();
        
        drawWeather(dc, pos, model);
    }
    
    function drawOverlay(dc, pos)
    {    
        var model = getModel();

        if (model.status != null)
        {
            var x = dc.getWidth();
        
            switch (model.status)
            {
                case Weather.ER_WAIT:
                    dc.drawBitmap(x - 14, pos, Weather.WaitIcon);
                    break;
                    
                case Weather.ER_NO_CONNECTION:
                    dc.drawBitmap(x - 14, pos, Weather.BtRedIcon);
                    break;
                    
                case Weather.ER_NO_SYNC:
                    dc.drawBitmap(x - 14, pos, Weather.SyncIcon);
                    break;                    
                    
                case Weather.ER_NO_GPS:
                    dc.drawBitmap(x - 14, pos, Weather.GpsIcon);
                    break;
                    
                case Weather.ER_NO_DARKSKYKEY:
                    dc.drawBitmap(x - 14, pos, Weather.KeyIcon);
                    break;
            }
        } 

        drawCounter++;
        drawLocation(dc, pos, model);
    }    
    
    function getModel()
    {            
        var model = new WeatherChartModel();
        
        model.communicationError = Application.getApp().getProperty(Weather.ERROR);
        model.status             = Application.getApp().getProperty(Weather.STATUS);
            
        var data = Application.getApp().getProperty(Weather.DATA1);
        
        if (data == null)
        {        
            model.weatherError = "Updating";
            return model;
        }
        
        if (data["l"] == null || data["s"] == null || data["h"] == null || data["i"] == null || data["t"] == null)
        {
            model.weatherError = "Wrong format";
            return model;        
        }         
        
        model.location = data["l"];
        
        var darkSkyError = data["s"];
        if (darkSkyError.length() != 0)
        {
            model.weatherError = darkSkyError;
            return model;
        }                
                
        var start = 100;

        var h = data["h"];
        for (var j = 0; j < h.size(); j++)
        {
            if (h[j] == drawnHourTime)
            {
                start = j;
                break;
            }
        }
        
        if (start == 100)
        {
            model.weatherError =  "Weather data too old";
            return model;                    
        } 
        
        model.h = data["h"];
        model.i = data["i"];
        model.t = data["t"];
        model.startIndex = start;
        
        return model;
    } 
        
    function shift(s1, s2, i)
    {
        if (s1 == null) { return s2;}
        if (s2 == null) { return s1;}
        
        return (i % 2 == 0) ? s1 : s2;
    }

    function drawLocation(dc, pos, model)    
    {
        var s = shift(model.communicationError, model.location, drawCounter);
        if (s != null)              
        {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, pos + locaPos,      Graphics.FONT_TINY, s, Graphics.TEXT_JUSTIFY_CENTER);
        }    
    }
    
    function drawWeather(dc, pos, model)
    {
        if (model.weatherError != null)
        {   
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(width / 2, pos + timePos,      Graphics.FONT_TINY, model.weatherError, Graphics.TEXT_JUSTIFY_CENTER);                       
            return;                  
        } 
                
        for (var j = 0; j < 7; j = j + 2)
        {
            if (model.startIndex + j >= model.h.size())
            {
                break;
            }
            
            var t = model.t[model.startIndex + j] + "°";
            var hour = Time.Gregorian.info(new Time.Moment(model.h[model.startIndex + j]), Time.FORMAT_SHORT).hour;
            var h = "";
            
            if (System.getDeviceSettings().is24Hour)
            {
                h = hour.toString() + ":00";
            }
            else
            {                    
                var h12 = hour % 12;
                if (h12 == 0) { h12 = 12; }
                
                var amPm = (hour < 12) ? "AM" : "PM";
                h = h12.toString() + amPm;
            }

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText((j + 1) * 18.5, pos + tempPos, Graphics.FONT_MEDIUM, t, Graphics.TEXT_JUSTIFY_CENTER);
            
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
            dc.drawText((j + 1) * 18.5, pos + timePos, Graphics.FONT_TINY, h, Graphics.TEXT_JUSTIFY_CENTER);
        }        
            
        for (var j = 0; j <= 7; j = j + 1)
        {
            if (model.startIndex + j >= model.h.size())
            {
                break;
            }
        
            var icon = model.i[model.startIndex + j];
        
            if (iconMode)
            {                        
                var x = j * 18.5;
                dc.drawBitmap(x, pos + linePos, Weather.Icons[icon]);
                continue;
            }
                     
            var x1 = (j    ) * 18.5;
            var x2 = (j + 1) * 18.5;

            dc.setColor( Weather.Colors[icon], Graphics.COLOR_BLACK);
            dc.drawLine(x1, pos + linePos + 0, x2, pos + linePos + 0);
            dc.drawLine(x1, pos + linePos + 1, x2, pos + linePos + 1);
            dc.drawLine(x1, pos + linePos + 2, x2, pos + linePos + 2);
                        
            if (j % 2 == 0)
            {
                dc.drawLine(x1,     pos + linePos + 3, x1,     pos + linePos + 6);
            }
            else
            {
                dc.drawLine(x1,     pos + linePos + 3, x1,     pos + linePos + 4);
            }
        }        
    }    
}