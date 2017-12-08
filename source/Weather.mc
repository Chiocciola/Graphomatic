using Toybox.Activity;
using Toybox.Application.Properties;
using Toybox.Application.Storage;
using Toybox.Background;
using Toybox.System;
using Toybox.Time;

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
        
    function charTypeIsActive(chartType) 
    {
        return Properties.getValue(Graphomatic.graph1Type) == chartType
            || Properties.getValue(Graphomatic.graph2Type) == chartType
            || Properties.getValue(Graphomatic.graph3Type) == chartType;    
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
        var status            = Storage.getValue(STATUS);
        var darkSkyApiKey     = Properties.getValue(Graphomatic.darkSkyApiKey);
        var darkSkyApiKeyPrev = Storage.getValue(APIKEY);

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
                    trigger = lastTime == null || Time.now().value() - lastTime.value() > ONE_HOUR.value();
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
            Storage.setValue(APIKEY, darkSkyApiKey);
            Storage.setValue(STATUS, ER_WAIT);
            triggerBgProc();
        }    
    }
    
    function onBackgroundData(data)
    {
        if (data == null)
        {
            return;
        }
                
        var connectionError = null;
        
        if (data instanceof Toybox.Lang.Number)
        {
            Storage.setValue(STATUS, data);
            
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
            if (Storage.getValue(STATUS) != ER_OK)
            {
                enableBgProc();
                Storage.setValue(STATUS, ER_OK);
            }

            if (data instanceof Toybox.Lang.String)
            {           
                connectionError = data;
            }        
            else
            {                           
                Storage.setValue(DATA1, data);            
                Storage.setValue(TIME, Time.now().value());
                
                System.println("Weather data are available");        
                //System.println(data);              
            }
        }
        
        Storage.setValue(Weather.ERROR, connectionError);
    }          
}