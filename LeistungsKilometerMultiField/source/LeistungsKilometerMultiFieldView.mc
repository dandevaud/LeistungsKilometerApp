using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.FitContributor as Fit;
using Toybox.Math;

class LeistungsKilometerMultiFieldView extends Ui.DataField {

    hidden var lkm;
    hidden var lkmh;
    hidden var avlkmh;
    hidden var steepness;
    hidden var _mTimerState;
    
    hidden var _avLkmh;
	hidden var _totLkm;
	hidden var _lkmh;
	hidden var _steepness;
	hidden var fieldNum = 4;
	hidden var switchtimer =0;
	
	hidden var _lkmDC;
	hidden var _lkmDisp;
	hidden var _lkmhDC;
	hidden var _lkmhDisp;
	hidden var _avlkmhDisp;
	hidden var _avlkmhDC;
	hidden var _gradDC;
	hidden var _gradDisp;

	
	hidden var app;
	
	hidden var carouselSec;
	
	hidden var zScoreTrigger;
	hidden var displayArray = [];
	hidden var lkmMeanArray = [];
	hidden var meanArraySize;
        
	
	
	function onSettingsChanged(){
		initializeProperties();
		initializeFields();
		initializeArray();
	}


	function initializeFields(){
		if(_avLkmh==null&&_avlkmhDC){
			_avLkmh = self.createField(Ui.loadResource(Rez.Strings.Test)+Ui.loadResource(Rez.Strings.avLong)+" "+Ui.loadResource(Rez.Strings.lkmLong)+" "+Ui.loadResource(Rez.Strings.hLong), 1, Fit.DATA_TYPE_FLOAT, { :mesgType => Fit.MESG_TYPE_SESSION, :units => Ui.loadResource(Rez.Strings.lkmShort)+Ui.loadResource(Rez.Strings.hShort) });
		}
		if(_lkmh==null&&_lkmhDC){
			_lkmh = self.createField(Ui.loadResource(Rez.Strings.Test)+Ui.loadResource(Rez.Strings.lkmLong)+" "+Ui.loadResource(Rez.Strings.hLong),2, Fit.DATA_TYPE_FLOAT, { :mesgType => Fit.MESG_TYPE_RECORD, :units => Ui.loadResource(Rez.Strings.lkmShort)+Ui.loadResource(Rez.Strings.hShort) });
		}
		if(_totLkm==null&&_lkmDC){
			_totLkm = self.createField(Ui.loadResource(Rez.Strings.Test)+Ui.loadResource(Rez.Strings.lkmLong)+" Total",3, Fit.DATA_TYPE_FLOAT, { :mesgType => Fit.MESG_TYPE_SESSION, :units => Ui.loadResource(Rez.Strings.lkmShort) });
		}
		if(_steepness==null&&_gradDC){
			_steepness = self.createField(Ui.loadResource(Rez.Strings.Test)+Ui.loadResource(Rez.Strings.gradient), 4, Fit.DATA_TYPE_FLOAT, { :mesgType => Fit.MESG_TYPE_RECORD, :units => Ui.loadResource(Rez.Strings.gradientUnit) });
		}
	}
	
	function initializeProperties(){
		carouselSec = app.getProperty("carouselSeconds") == null? 5 : app.getProperty("carouselSeconds");
		meanArraySize = app.getProperty("meanArraySize") == null? 60 : app.getProperty("meanArraySize");
		zScoreTrigger = app.getProperty("zScoreTrigger") == null? 3 : app.getProperty("zScoreTrigger");
		_lkmDC = app.getProperty("totlkmDataCollection") == null? true : app.getProperty("totlkmDataCollection");
		_lkmDisp= app.getProperty("totlkmDisplay") == null? true : app.getProperty("totlkmDisplay");
		_lkmhDC= app.getProperty("lkmhDataCollection") == null? true : app.getProperty("lkmhDataCollection");
		_lkmhDisp= app.getProperty("lkmhDisplay") == null? true : app.getProperty("lkmhDisplay");
		_avlkmhDisp= app.getProperty("avlkmhDisplay") == null? true : app.getProperty("avlkmhDisplay");
		_avlkmhDC= app.getProperty("avlkmhDataCollection") == null? true : app.getProperty("avlkmhDataCollection");
		_gradDC= app.getProperty("gradDataCollection") == null? true : app.getProperty("gradDataCollection");
		_gradDisp= app.getProperty("gradDisplay") == null? true : app.getProperty("gradDisplay");

	}

    function initialize() {
        DataField.initialize();
        app = Application.getApp();
        onSettingsChanged();
        lkm = 0.0f;
        lkmh = 0.0f;
        avlkmh = 0.0f;
       	steepness = 0.0f;
    }
    
    function initializeArray(){
	   	displayArray=[];
	   	if(_lkmDisp){
	   		displayArray.add(TOTLKM);
	   	}
	   	if(_lkmhDisp){
	   		displayArray.add(LKMH);
	   	}
	   	if(_avlkmhDisp){
	   		displayArray.add(AVLKMH);
	   	}
	   	if(_gradDisp){
	   		displayArray.add(GRAD);
	   	}
   }
    
    
    //ENUM of dataFields
    enum{
    LKMH,
    AVLKMH,
    GRAD,
    TOTLKM
    
    }
    
          // ENUM of timer states
    enum
    {
        STOPPED,
        PAUSED,
        RUNNING
    }
    
    
    //! The timer was started, so set the state to running.
    function onTimerStart()
    {
        _mTimerState = RUNNING;
    }

    //! The timer was stopped, so set the state to stopped.
    function onTimerStop()
    {
        _mTimerState = STOPPED;
    }

    //! The timer was started, so set the state to running.
    function onTimerPause()
    {
        _mTimerState = PAUSED;
    }

    //! The timer was stopped, so set the state to stopped.
    function onTimerResume()
    {
        _mTimerState = RUNNING;
    }

    //! The timer was reeset, so reset all our tracking variables
    function onTimerReset()
    {
        _mTimerState = STOPPED;       
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc) {
        var obscurityFlags = DataField.getObscurityFlags();

        // Top left quadrant so we'll use the top left layout
        if (obscurityFlags == (OBSCURE_TOP | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.TopLeftLayout(dc));

        // Top right quadrant so we'll use the top right layout
        } else if (obscurityFlags == (OBSCURE_TOP | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.TopRightLayout(dc));

        // Bottom left quadrant so we'll use the bottom left layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.BottomLeftLayout(dc));

        // Bottom right quadrant so we'll use the bottom right layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.BottomRightLayout(dc));

        // Use the generic, centered layout
        } else {
            View.setLayout(Rez.Layouts.MainLayout(dc));
            var labelView = View.findDrawableById("label");
            labelView.locY = labelView.locY - 16;
            var valueView = View.findDrawableById("value");
            valueView.locY = valueView.locY + 7;
        }

        View.findDrawableById("label").setText(Rez.Strings.label);
        return true;
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {    	
        // See Activity.Info in the documentation for available information.
       
        	lkm = LeistungsKiloMeter.getTotalLkm(info);
        	lkmh = LeistungsKiloMeter.getLeistungsKilometerProStunde(info);
        	avlkmh = LeistungsKiloMeter.getAverageLeistungsKilometerProStunde(info);
        	steepness = LeistungsKiloMeter.getSteepness(info) * 100;  
        	if(_mTimerState==RUNNING){    	        	
   		        if(_lkmhDC){
	        		_lkmh.setData(lkmh);
	        	}
	        	if(_lkmDC){
	        		_totLkm.setData(lkm);
	        	}
	        	if(_avlkmhDC){
	        		_avLkmh.setData(avlkmh);
	        	}
	        	if(_gradDC){
	        		_steepness.setData(steepness);
	        	}
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {
        // Set the background color
        View.findDrawableById("Background").setColor(getBackgroundColor());

        // Set the foreground color and valuedisplay
        var value = View.findDrawableById("value");
        var label = View.findDrawableById("label");
        if (getBackgroundColor() == Graphics.COLOR_BLACK) {
            value.setColor(Graphics.COLOR_WHITE);  
            label.setColor(Graphics.COLOR_WHITE);             
        } else {
            value.setColor(Graphics.COLOR_BLACK);
            label.setColor(Graphics.COLOR_BLACK);
        }
       	var numOfFields =  displayArray.size();
       	if(numOfFields!=0){
	       	var divided = Math.round(switchtimer/carouselSec);
	        var modulo = (divided % numOfFields); 
	        var dataFieldEnum = displayArray[modulo];
	        displayInformation(dataFieldEnum, value, label);
	
	      	switchtimer++;
	      	if(switchtimer==1000){
	      		switchtimer=0;
	      	}
		} else {
		 value.setText(Ui.loadResource(Rez.Strings.inSettings));
        label.setText(Ui.loadResource(Rez.Strings.pleaseSelect));
		}
       
        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }
    
    function displayInformation(dataFieldEnum, value, label){
     switch( dataFieldEnum){
      case LKMH:
      	 value.setText(lkmh.format("%.2f"));
        label.setText(Ui.loadResource(Rez.Strings.lkmShort)+Ui.loadResource(Rez.Strings.hShort));
        break;
     case AVLKMH:
       value.setText(avlkmh.format("%.2f"));
        label.setText(Ui.loadResource(Rez.Strings.aShort)+" "+Ui.loadResource(Rez.Strings.lkmShort)+Ui.loadResource(Rez.Strings.hShort));
     break;
   	 case GRAD:
    	value.setText(steepness.format("%.2f")+" "+Ui.loadResource(Rez.Strings.gradientUnit));
        label.setText(Ui.loadResource(Rez.Strings.gradientShort));
    	break;
   	case  TOTLKM:
   		value.setText(lkm.format("%.2f"));
       label.setText("Tot "+Ui.loadResource(Rez.Strings.lkmShort));
   
   break;
     }
    }

}
