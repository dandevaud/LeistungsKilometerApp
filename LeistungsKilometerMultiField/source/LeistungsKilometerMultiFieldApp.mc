using Toybox.Application;

class LeistungsKilometerMultiFieldApp extends Application.AppBase {

var _view ;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }
    
    function onSettingsChanged(){
    	_view.onSettingsChanged();
    }

    //! Return the initial view of your application here
    function getInitialView() {
    _view =  new LeistungsKilometerMultiFieldView();
        return [_view ];
    }

}