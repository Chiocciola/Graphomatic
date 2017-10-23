class WatchFaceTestApp extends Toybox.Application.AppBase
{
    function initialize()
    {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }
    
    function onBackgroundData(data)
    {                
        Weather.onBackgroundData(data);
    }

    function getInitialView()
    {            
        /*if (getProperty("Reset") != 2)
        {
            var darkSkyApiKey = getProperty(Graphomatic.darkSkyApiKey);
            
            clearProperties();
            setProperty("Reset", 2);
            setProperty(Graphomatic.darkSkyApiKey, darkSkyApiKey);
        }
        */
    
        //Background.registerForTemporalEvent(Weather.FIVE_MINUTES);
    
        return [new WatchFaceTestView()];
    }
    
    function getServiceDelegate()
    {
        return [new WeatherService()];
    }
}