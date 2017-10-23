(:background)
class WeatherService extends Toybox.System.ServiceDelegate
{
    function initialize()
    {
        ServiceDelegate.initialize();
    }

    function onTemporalEvent()
    {
        var app =  Application.getApp();
        
        /*
        var lastTime = app.getProperty("wTime"); 
        if (lastTime != null && (Time.now().value() - lastTime) < 360)
        {
            Background.exit(null);
        }/**/
        
        if (!System.getDeviceSettings().phoneConnected)
        {
            //Background.exit(Weather.ER_NO_CONNECTION);
            Background.exit(1);
        }
                
        var location = Activity.getActivityInfo().currentLocation;
        if (location == null)
        {
            //Background.exit(Weather.ER_NO_GPS);            
            Background.exit(2);
        }
        
        var latlng = location.toDegrees()[0].toString() + "," + location.toDegrees()[1].toString();
        
        //System.println("Current Location: " + latlng );
        
        //var darkSkyApiKey = app.getProperty(Graphomatic.darkSkyApiKey);
        var darkSkyApiKey = "1cbbfb780a7ada23c39be9ae9871754a";        

        if (darkSkyApiKey == null || darkSkyApiKey.length() == 0)
        {          
            //Background.exit(Weather.ER_NO_DARKSKYKEY);
            Background.exit(3);
        }
                
        Communications.makeWebRequest(
            "https://graphomatic.scalingo.io/data2",
            {
                "latlng" => latlng, 
                "darkskyapikey" => darkSkyApiKey
            },
            {},
            method(:responseCallback)
        );
        
        //System.println("Weather data are requested");        
    } 
    
    function responseCallback(responseCode, data)
    {
        if (responseCode == -2)
        {
            //Background.exit(Weather.ER_NO_SYNC);
            Background.exit(4);
        }
        
        if (responseCode != 200)
        {         
            Background.exit("Web error " + responseCode.toString());
        }

        //System.println("Weather data are received");            
        Background.exit(data);
    }     
}