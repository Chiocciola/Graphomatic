var sleepMode = true;
var fastDraw = false;

class WatchFaceTestView extends Toybox.WatchUi.WatchFace
{
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
    function onShow() {
        //$.fastDraw = true;        
    }

    // Update the view
    function onUpdate(dc)
    {
    	Weather.checkBgProcStatus();
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
