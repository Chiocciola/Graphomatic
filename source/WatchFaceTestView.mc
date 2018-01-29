using Toybox.Application.Properties;
using Toybox.Time;

var sleepMode = true;
var fastDraw = false;
var timeDoubleClick;

class WatchFaceTestView extends Toybox.WatchUi.WatchFace
{
    const DBL_CLICK = new Time.Duration(5);

    function initialize()
    {
        WatchFace.initialize();                
    }

    // Load your resources here
    function onLayout(dc)
    {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow()
    {
        //$.fastDraw = true;
        Weather.checkBgProcStatus();
                
        var layout = 1;
      
		var app = Application.getApp();      
      
        var time = app.getProperty("timeDblClck");  
        if (time != null && Time.now().value() - time < DBL_CLICK.value())
        {
			layout = app.getProperty("Layout");
			layout = (layout == null || layout != 1) ? 1 : 2;
		}
		
		var chart1 = Properties.getValue(Graphomatic.graph1Type + layout.toString());
		var chart2 = Properties.getValue(Graphomatic.graph2Type + layout.toString());
		var chart3 = Properties.getValue(Graphomatic.graph3Type + layout.toString());
		

		app.setProperty(Graphomatic.graph1Type, chart1);
		app.setProperty(Graphomatic.graph2Type, chart2);
		app.setProperty(Graphomatic.graph3Type, chart3);

		app.setProperty("Layout", layout);        
		app.setProperty("timeDblClck", Time.now().value());	        
    }

    // Update the view
    function onUpdate(dc)
    {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);       
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
        $.fastDraw = true;
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep()
    {
        $.sleepMode = false;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep()
    {
        $.sleepMode = true;
    }
}
