using Toybox.WatchUi as Ui;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.System;

class StatusBar extends Ui.Drawable
{
    var BluetoothIcon;
    var AlarmClockIcon;
    var MoonIcon;
    var NotificationIcon;
    
    var font;                            
        
    function initialize(params)
    {
        Drawable.initialize(params);
        
        font = Graphics.FONT_TINY;             
        
        BluetoothIcon = Ui.loadResource(Rez.Drawables.BluetoothIcon);
        AlarmClockIcon = Ui.loadResource(Rez.Drawables.AlarmClockIcon);
        MoonIcon = Ui.loadResource(Rez.Drawables.MoonIcon);
        NotificationIcon = Ui.loadResource(Rez.Drawables.NotificationIcon);
    }

    function draw(dc)
    {
        var width = dc.getWidth(); 
                       
        var x = width - 1;
        var gap = 5;
        
        var stats = System.getSystemStats();
        var settings = System.getDeviceSettings();        
        
        // Battery
        var batteryText = stats.battery.toLong().toString() + "%";
        dc.drawText(x, -4, font, batteryText, Graphics.TEXT_JUSTIFY_RIGHT); 
        
        x -= dc.getTextWidthInPixels(batteryText, font);
        
        // notification count is not 0, only when connected to the phone
        if (settings.notificationCount > 0)
        {
            x = x - 9 - gap;
            dc.drawBitmap(x, 3, NotificationIcon);
        }         
        else if (settings.phoneConnected)
        {
            x = x - 7 - gap;     
            dc.drawBitmap(x, 0, BluetoothIcon);
        }
        
        if (settings.doNotDisturb)
        {
            x = x - 10 - gap;
            dc.drawBitmap(x, 1, MoonIcon);
        }
        
        if (settings.alarmCount > 0)
        {
            x = x - 9 - gap;
            dc.drawBitmap(x, 3, AlarmClockIcon);
        }

        // Date / time
        var info = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        
        if (   Application.getApp().getProperty(Graphomatic.graph2Type) == 0
            || Application.getApp().getProperty(Graphomatic.graph3Type) == 0)
        {
            dc.drawText(0, -4, font, info.day_of_week + " " + info.day + " " + info.month, Graphics.TEXT_JUSTIFY_LEFT);   
            //dc.drawText(0, -4, font,                          info.day + " " + info.month, Graphics.TEXT_JUSTIFY_LEFT);
            
            return;
        }
        
        var is24Hour = System.getDeviceSettings().is24Hour;
        
        var showSeconds = !$.sleepMode && Application.getApp().getProperty(Graphomatic.showSeconds);
        var showAmPm    = !is24Hour    && Application.getApp().getProperty(Graphomatic.showAmPm);                
        
        var timeFont   = (showSeconds || showAmPm) ? Graphics.FONT_TINY : Graphics.FONT_LARGE;
        var timeOffset = (showSeconds || showAmPm) ?                 -4 :                  -6;        
        
        var timeString = getTimeString(showSeconds, showAmPm);                 
        var timeWidth  = dc.getTextWidthInPixels(timeString, timeFont);
        
        // Centered time string doesnt overlap status icons            
        if ( (width + timeWidth) / 2 < x - gap)
        {  
            var timeX = (width - timeWidth) / 2;
        
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(timeX, timeOffset, timeFont, timeString, Graphics.TEXT_JUSTIFY_LEFT);

            var dateString = info.day_of_week + " " + info.day;                
            var dateWidth  = dc.getTextWidthInPixels(dateString, font);
            
            if (dateWidth > timeX)
            {
                dateString = info.day_of_week;                
                dateWidth  = dc.getTextWidthInPixels(dateString, font);                
            
                if (dateWidth > timeX)
                {
                    dateString = "";
                }
            }
            
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
            dc.drawText(0, -4, font, dateString, Graphics.TEXT_JUSTIFY_LEFT);               
        }
        else
        {
            var dateString = info.day_of_week;                            
            var dateWidth = dc.getTextWidthInPixels(dateString, font);

            dc.drawText((dateWidth + x - timeWidth) / 2, timeOffset, timeFont, timeString, Graphics.TEXT_JUSTIFY_LEFT);  

            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
            dc.drawText(0, -4, font, dateString, Graphics.TEXT_JUSTIFY_LEFT); 
        }
    }
    
    function getTimeString(showSeconds, showAmPm)
    {
        var clockTime = System.getClockTime();

        var is24Hour = System.getDeviceSettings().is24Hour;

        var hour = clockTime.hour;
        
        if (!is24Hour)
        {
            hour = hour % 12;
            if (hour == 0) {hour = 12;}        
        }
                        
        if (showSeconds)
        {
            return Lang.format("$1$:$2$:$3$", [hour, clockTime.min.format("%02d"), clockTime.sec.format("%02d")]);
        }

        if (showAmPm)
        {
            var amPm = (clockTime.hour < 12) ? "AM" : "PM";
        
            return Lang.format("$1$:$2$ $3$", [hour, clockTime.min.format("%02d"), amPm]);
        }        
        
        return Lang.format("$1$:$2$", [hour, clockTime.min.format("%02d")]);
    }    
}