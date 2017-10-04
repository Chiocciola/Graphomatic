using Toybox.WatchUi as Ui;

class StepsBar extends Ui.Drawable
{
    function initialize(params)
    {
        Drawable.initialize(params);        
    }

    function draw(dc)
    {
        var info = ActivityMonitor.getInfo();

        var steps = info.steps;
        //var steps = 6700;        
        var goal = info.stepGoal;
        
        var height = dc.getHeight();
        var width = dc.getWidth();        
         
        var y = height-2;
        
        if (steps < goal)
        {         
            var stepsX = (width - 1) * steps / goal;        
                      
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(stepsX + 1, y + 0, width, y + 0); 
            dc.drawLine(stepsX + 1, y + 1, width, y + 1);
            
            dc.setColor((steps < goal / 2) ? Graphics.COLOR_RED : Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);              
            dc.drawLine(0, y + 0, stepsX, y + 0); 
            dc.drawLine(0, y + 1, stepsX, y + 1);
            
            /*var c = (steps < goal / 2) ? 0xFF5555 : 0xFFFF00;
                        
            for (var i = 0; i <= goal; i += 1000)
            {
                dc.setColor(i <= steps ? c : Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                
                var x = (width - 1) * i / goal;
                dc.drawLine(x, y + 0, x, y + 2);            
            }   
            /**/  
            
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);    
            dc.drawLine(stepsX, y + 0, stepsX, y + 2);                                      
        } 
        else
        {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(0, y + 0, width, y + 0); 
            dc.drawLine(0, y + 1, width, y + 1);
        }                
    }   
}