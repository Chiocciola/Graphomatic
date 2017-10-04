using Toybox.Activity;
using Toybox.Application;
using Toybox.Background;
using Toybox.System;
using Toybox.Time;
using Toybox.WatchUi as Ui;

module Weather
{
    const TIME  = "wTime";
    const ERROR = "wError";
    const DATA1 = "wData";
    const STATUS = "wStatus";
    const APIKEY = "wApiKey";   
    
    const ER_WAIT = -1;
    const ER_OK = 0;
    const ER_NO_CONNECTION = 1;
    const ER_NO_GPS = 2;
    const ER_NO_DARKSKYKEY = 3;
    const ER_NO_SYNC = 4;
    
    const FIVE_MINUTES = new Time.Duration(5 * 60);
    const ONE_HOUR = new Time.Duration(60 * 60);
    
    const GpsIcon   = Ui.loadResource(Rez.Drawables.GpsIcon);
    const BtRedIcon = Ui.loadResource(Rez.Drawables.BtRedIcon);
    const KeyIcon   = Ui.loadResource(Rez.Drawables.KeyIcon);
    const SyncIcon  = Ui.loadResource(Rez.Drawables.SyncIcon);
    const WaitIcon  = Ui.loadResource(Rez.Drawables.WaitIcon);
    
    const Colors = {
        0 => Toybox.Graphics.COLOR_BLACK,
        1 => Toybox.Graphics.COLOR_YELLOW,  // "clear-day"
        2 => Toybox.Graphics.COLOR_WHITE,   // "clear-night"
        3 => Toybox.Graphics.COLOR_LT_GRAY, // "wind"
        4 => Toybox.Graphics.COLOR_DK_GRAY, // "fog"
        5 => Toybox.Graphics.COLOR_DK_GRAY, // "partly-cloudy-day"
        6 => Toybox.Graphics.COLOR_DK_GRAY, // "partly-cloudy-night"       
        7 => Toybox.Graphics.COLOR_DK_GRAY, // "cloudy"        
        8 => Toybox.Graphics.COLOR_BLUE,    // "rain"
        9 => Toybox.Graphics.COLOR_BLUE,    // "sleet"        
       10 => Toybox.Graphics.COLOR_BLUE     // "snow"        
    };
    
    function charTypeIsActive(chartType) 
    {
        var app = Toybox.Application.getApp();
        
        return app.getProperty(Graphomatic.graph1Type) == chartType
            || app.getProperty(Graphomatic.graph2Type) == chartType
            || app.getProperty(Graphomatic.graph3Type) == chartType;    
    }
         
    function enableBgProc()
    {
        if (charTypeIsActive(Graphomatic.WEATHER))
        {
            System.println("BG Process is enabled");
            Background.registerForTemporalEvent(ONE_HOUR);
        }
    }
    
    function triggerBgProc()
    {
        System.println("BG Process is triggered");
        
        if (charTypeIsActive(Graphomatic.WEATHER))
        {
            var lastTime = Background.getLastTemporalEventTime();        
            var nextTime =  (lastTime != null) ? lastTime.add(FIVE_MINUTES) : Time.now();
        
            Background.registerForTemporalEvent(nextTime);
        }
    }
    
    function checkBgProcStatus()
    {                    
        var app =  Application.getApp();
    
        var status            = app.getProperty(STATUS);
        var darkSkyApiKey     = app.getProperty(Graphomatic.darkSkyApiKey);
        var darkSkyApiKeyPrev = app.getProperty(APIKEY);

        var trigger = false;
        
        if (status == null)
        {         
            trigger = true;
        }
        else
        {
            switch (status)
            {
                case ER_WAIT:
                    var lastTime1 = Background.getLastTemporalEventTime();
                    trigger = lastTime1 == null || Time.now().subtract(lastTime1).value() > FIVE_MINUTES.value();
                    break;

                case ER_OK:
                    var lastTime = Background.getLastTemporalEventTime();
                    trigger = lastTime == null || Time.now().subtract(lastTime).value() > ONE_HOUR.value();
                    break;
            
                case ER_NO_CONNECTION:
                    trigger = System.getDeviceSettings().phoneConnected;
                    break;
                    
                case ER_NO_GPS:
                    trigger = Activity.getActivityInfo().currentLocation != null;
                    break;
                    
                case ER_NO_DARKSKYKEY:                
                    trigger = darkSkyApiKey != null && darkSkyApiKey.length() != 0;                 
                    break;
                    
                case ER_NO_SYNC:
                    trigger = true;
                    break;                    
            }
        }
        if (darkSkyApiKey != null && darkSkyApiKeyPrev != null && !darkSkyApiKey.equals(darkSkyApiKeyPrev))
        {
            trigger = true;
        }
        
        if (trigger)
        {
            app.setProperty(APIKEY, darkSkyApiKey);
            app.setProperty(STATUS, ER_WAIT);
            triggerBgProc();
        }    
    }
    
    function onBackgroundData(data)
    {
        if (data == null)
        {
            return;
        }
    
        var app = Application.getApp();            
        var connectionError = null;
        
        if (data instanceof Toybox.Lang.Number)
        {
            app.setProperty(STATUS, data);
            
            Background.deleteTemporalEvent();
            System.println("BG Process is suspended");
            /*
            switch (data)
            {
                case ER_NO_CONNECTION:
                    connectionError = null;
                    break;
                    
                case ER_NO_GPS:
                    connectionError = "No GPS";
                    break;
                    
                case ER_NO_DARKSKYKEY:
                    connectionError = "DarkSky key is not set";                 
                    break;
            } /**/           
        }      
        else 
        {
            if (app.getProperty(STATUS) != ER_OK)
            {
                enableBgProc();
                app.setProperty(STATUS, ER_OK);
            }

            if (data instanceof Toybox.Lang.String)
            {           
                connectionError = data;
            }        
            else
            {                           
                app.setProperty(DATA1, data);            
                app.setProperty(TIME, Time.now().value());
                
                System.println("Weather data are available");        
                //System.println(data);              
            }
        }
        
        app.setProperty(Weather.ERROR, connectionError);
    }          
}