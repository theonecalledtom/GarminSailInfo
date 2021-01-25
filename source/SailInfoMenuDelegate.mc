using Toybox.WatchUi;
using Toybox.System;

class SailInfoMenuDelegate extends WatchUi.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
        System.println("SailInfoMenuDelegate.initialize");
    }

    function onMenuItem(item) {
        System.println("SailInfoMenuDelegate.onMenuItem");
        if (item == :item_1) {
            System.println("-> Menu item 1");
        } else if (item == :item_2) {
            System.println("-> Menu item 2");
        }
    }

}