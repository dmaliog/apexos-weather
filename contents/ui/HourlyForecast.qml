import QtQuick
import QtQuick.Layouts
import "lib" as Lib
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import "./js/fahrenheitFormatt.js" as FahrenheitFormatt

Item {
    objectName: "rootHourlyForecast"

    property string temperatureUnit: Plasmoid.configuration.temperatureUnit
    property var iconsHourlyForecast: []
    property var weatherHourlyForecast: []
    property var rainHourlyForecast: []
    property var timesDatesForecast
    property string unitTemp: temperatureUnit
    property bool hours12Format: Plasmoid.configuration.UseFormat12hours
    property string prefixHoursFormatt: hours12Format ? "h ap" : "H"
    property int currentStartIndex: 1
    
    function updateStartIndex() {
        var now = new Date()
        var currentHour = now.getHours()
        if (weatherData.hourlyTimes && weatherData.hourlyTimes.length > 0) {
            for (var i = 0; i < weatherData.hourlyTimes.length; i++) {
                var dateObj = new Date(weatherData.hourlyTimes[i])
                var hour = parseInt(Qt.formatDateTime(dateObj, "H"))
                if (hour >= currentHour) {
                    currentStartIndex = i
                    return
                }
            }
        }
        currentStartIndex = 1
    }

    Lib.Card {
       anchors.left: parent.left
       anchors.right: parent.right
       anchors.top: parent.top
       anchors.bottom: parent.bottom
       anchors.leftMargin: 2
       anchors.rightMargin: 2
       anchors.topMargin: Kirigami.Units.smallSpacing * 2
       anchors.bottomMargin: 2
       
       Row {
           anchors.fill: parent
           anchors.margins: 5
           spacing: 6
           clip: true

           Repeater {
               id: repeater
               model: 5
               delegate: Item {
                   width: (parent.width - (parent.spacing * 4)) / 5
                   height: parent.height
                   
                   KSvg.FrameSvgItem {
                       id: frame
                       anchors.fill: parent
                       imagePath: "widgets/viewitem"
                       prefix: {
                           if (mouseArea.containsMouse) {
                               return "hover"
                           }
                           return "hover"
                       }
                       opacity: {
                           if (mouseArea.containsMouse) {
                               return 1.0
                           }
                           return 0.8
                       }
                       enabled: false
                   }
                   
                   MouseArea {
                       id: mouseArea
                       anchors.fill: parent
                       hoverEnabled: true
                   }

                   Item {
                       id: columnDelegate
                       anchors.fill: parent
                       anchors.margins: frame.margins.left
                       property int itemIndex: {
                           var root = columnDelegate
                           for (var i = 0; i < 10 && root.parent; i++) {
                               root = root.parent
                               if (root.hasOwnProperty && root.hasOwnProperty("currentStartIndex")) {
                                   return root.currentStartIndex + modelData
                               }
                           }
                           return modelData + 1
                       }
                       
                       Kirigami.Heading {
                           id: hours
                           anchors.top: parent.top
                           anchors.horizontalCenter: parent.horizontalCenter
                           width: parent.width
                           horizontalAlignment: Text.AlignHCenter
                           text: timesDatesForecast[parent.itemIndex] === undefined ? "--" : timesDatesForecast[parent.itemIndex]
                           level: 5
                       }
                       
                       Column {
                           anchors.centerIn: parent
                           width: parent.width
                           spacing: 4
                           
                           Kirigami.Icon {
                               id: icon
                               source: iconsHourlyForecast[parent.parent.itemIndex]
                               width: 24
                               anchors.horizontalCenter: parent.horizontalCenter
                               height: width
                           }
                           Kirigami.Heading {
                               id: temperature
                               width: parent.width
                               horizontalAlignment: Text.AlignHCenter
                               text: weatherHourlyForecast[parent.parent.itemIndex] === undefined ? "--" : Math.round(weatherHourlyForecast[parent.parent.itemIndex]) + "°"
                               level: 5
                           }
                       }
                       
                       Kirigami.Heading {
                           id: rain
                           anchors.bottom: parent.bottom
                           anchors.horizontalCenter: parent.horizontalCenter
                           width: parent.width
                           horizontalAlignment: Text.AlignHCenter
                           text: rainHourlyForecast[parent.itemIndex] === undefined ? "--" : "💧" +  Math.round(rainHourlyForecast[parent.itemIndex])
                           level: 5
                       }
                   }
               }
           }
       }
    }
    function formatTimeWithCustomAMPM(dateTime, format) {
        var dateObj = new Date(dateTime);
        var hour24 = parseInt(Qt.formatDateTime(dateObj, "H"));
        var is12Hour = Plasmoid.configuration.UseFormat12hours;
        var formatted;
        var timeOfDay = "";
        var localeName = Qt.locale().name;
        
        if (localeName && (localeName.indexOf("en") === 0)) {
            if (hour24 >= 0 && hour24 < 12) {
                timeOfDay = i18n("morning");
            } else {
                timeOfDay = i18n("afternoon");
            }
        } else {
            if (hour24 >= 5 && hour24 < 12) {
                timeOfDay = i18n("morning");
            } else if (hour24 >= 12 && hour24 < 17) {
                timeOfDay = i18n("afternoon");
            } else if (hour24 >= 17 && hour24 < 22) {
                timeOfDay = i18n("evening");
            } else {
                timeOfDay = i18n("night");
            }
        }
        
        var hour12;
        if (is12Hour) {
            if (hour24 === 0) {
                hour12 = 12;
            } else if (hour24 > 12) {
                hour12 = hour24 - 12;
            } else {
                hour12 = hour24;
            }
            formatted = hour12.toString();
        } else {
            var timeFormat = format.replace(" ap", "").replace("ap", "");
            if (timeFormat === "h" || timeFormat === "hh") {
                timeFormat = "H";
            }
            formatted = Qt.formatDateTime(dateObj, timeFormat);
        }
        return formatted + " " + timeOfDay;
    }

    function updateDatesWeather(){
        var newArrayWeatherHourlyForecast = []
        timesDatesForecast = weatherData.hourlyTimes.map(function(iso) {
            return formatTimeWithCustomAMPM(iso, prefixHoursFormatt)
        })
        iconsHourlyForecast = weatherData.iconsHourlyWeather
        for (var e = 0; e < weatherData.hourlyWeather.length; e++) {
            newArrayWeatherHourlyForecast.push(temperatureUnit === "Celsius" ? weatherData.hourlyWeather[e] : FahrenheitFormatt.fahrenheit(weatherData.hourlyWeather[e]))
        }
        weatherHourlyForecast = newArrayWeatherHourlyForecast
        rainHourlyForecast = weatherData.hourlyPrecipitationProbability
    }

    Connections {
        target: weatherData
        function onDataChanged() {
           updateDatesWeather()
           updateStartIndex()
        }
    }
    onTemperatureUnitChanged: {
        updateDatesWeather()
    }
    onUnitTempChanged: {
        updateDatesWeather()
    }
    Component.onCompleted: {
        updateDatesWeather()
        updateStartIndex()
    }
}
