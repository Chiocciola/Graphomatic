using Toybox.WatchUi as Ui;

class Clock extends Ui.Drawable
{    
    var fontBig;
    var fontSmall;
    var fontAmPm;
    var fontSec;
        
    function initialize(params)
    {
        Drawable.initialize(params);   

        //fontBig = Ui.loadResource(Rez.Fonts.SF70);
        //fontBig = Graphics.FONT_SYSTEM_NUMBER_THAI_HOT;
        fontSec = Graphics.FONT_MEDIUM;
        fontAmPm = Graphics.FONT_TINY;          
    }

    function draw(dc)
    {
        if (Application.getApp().getProperty(Graphomatic.graph2Type) != 0
         && Application.getApp().getProperty(Graphomatic.graph3Type) != 0)
        {
            return;
        }
        
        var is24 = System.getDeviceSettings().is24Hour;        
        
        var showAmPm = !is24 && Application.getApp().getProperty(Graphomatic.showAmPm);
        var showSeconds = !$.sleepMode && Application.getApp().getProperty(Graphomatic.showSeconds);
        
        var small = (showAmPm || showSeconds);
        
        if (small)
        {
            if( fontSmall == null)
            {
                fontSmall = Ui.loadResource(Rez.Fonts.SF64);
                fontBig = null;
            }
        }
        else
        {
            if( fontBig == null)
            {
                fontSmall = null;
                fontBig = Ui.loadResource(Rez.Fonts.SF70);
            }
        
        }
        
        var font = small ? fontSmall : fontBig;
        var y    = small ?        16 :      11;
        
                
        // Get and show the current time
        var clockTime = System.getClockTime();
        
        var timeString;
        var amPm = "";
        var amPmWidth = 0;                        
        
        if (is24)
        {            
            timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
        }
        else
        {
            var hour = clockTime.hour % 12;
            if (hour == 0) { hour = 12; }
                            
            timeString = Lang.format("$1$:$2$", [hour, clockTime.min.format("%02d")]);
            
            if (showAmPm)
            {
                amPm = (clockTime.hour < 12) ? "AM" : "PM";
            }
        }   
        
        if (showAmPm || showSeconds)
        {            
            //amPmWidth = dc.getTextWidthInPixels(amPm, fontAmPm);
            amPmWidth = dc.getTextWidthInPixels("00", fontSec) + 2;
        }             
        
        var width = dc.getWidth();        
        var textWidth = dc.getTextWidthInPixels(timeString, font);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);            
        
        var x = (width - textWidth - amPmWidth) / 2;            
        dc.drawText(x, y, font, timeString, Graphics.TEXT_JUSTIFY_LEFT);
        
        // AM/PM and deconds
        var x1 = (width + textWidth - amPmWidth) / 2 + 1;
        
        if (showAmPm)
        {        
            dc.drawText(x1, 28, fontAmPm, amPm, Graphics.TEXT_JUSTIFY_LEFT);
        }
        
        if (showSeconds)
        {
            dc.drawText(x1, 46, fontSec, clockTime.sec.format("%02d"), Graphics.TEXT_JUSTIFY_LEFT);
        }               
    }
}