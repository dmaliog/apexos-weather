import QtQuick
import QtQuick.Layouts
import "lib" as Lib
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.ksvg as KSvg
import "./js/fahrenheitFormatt.js" as FahrenheitFormatt

Item {

    property string temperatureUnit: Plasmoid.configuration.temperatureUnit
    property var iconsDaysForecast: []
    property var weatherMaxDaysForecast: []
    property var weatherMinDaysForecast: []
    property var rainDaysForecast: []
    property var timesDaysForecast: []

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
                        anchors.fill: parent
                        anchors.margins: frame.margins.left
                        
                        Kirigami.Heading {
                            id: days
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: timesDaysForecast[modelData +  1] === undefined ? "--" : timesDaysForecast[modelData +  1]
                            level: 5
                        }
                        
                        Column {
                            anchors.centerIn: parent
                            width: parent.width
                            spacing: 4
                            
                            Kirigami.Icon {
                                id: icon
                                source: iconsDaysForecast[modelData +  1]
                                width: 24
                                anchors.horizontalCenter: parent.horizontalCenter
                                height: width
                            }

                            Item {
                                id: tempItem
                                width: parent.width
                                property int spacing: 4
                                height: max.implicitHeight + min.implicitHeight + tempItem.spacing

                                Kirigami.Heading {
                                    id: max
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                    text: weatherMaxDaysForecast[modelData +  1] === undefined ? "--" : Math.round(weatherMaxDaysForecast[modelData +  1]) + "°"
                                    level: 5
                                }
                                Kirigami.Heading {
                                    id: min
                                    width: parent.width
                                    anchors.top: max.bottom
                                    anchors.topMargin: tempItem.spacing
                                    opacity: 0.6
                                    horizontalAlignment: Text.AlignHCenter
                                    text: weatherMinDaysForecast[modelData +  1] === undefined ? "--" : Math.round(weatherMinDaysForecast[modelData +  1]) + "°"
                                    level: 5
                                }
                            }
                        }

                        Kirigami.Heading {
                            id: rain
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: rainDaysForecast[modelData +  1] === undefined ? "--" : "💧" +  Math.round(rainDaysForecast[modelData +  1])
                            level: 5
                        }
                    }
                }
            }
        }
    }


    function updateTemperatures() {
        var newArrayMaxDaysForecast = []
        var newArrayMinDaysForecast = []

        for (var e = 0; e < weatherData.dailyWeatherMax.length; e++) {
            newArrayMaxDaysForecast.push(temperatureUnit === "Celsius" ? weatherData.dailyWeatherMax[e] : FahrenheitFormatt.fahrenheit(weatherData.dailyWeatherMax[e]))
            newArrayMinDaysForecast.push(temperatureUnit === "Celsius" ? weatherData.dailyWeatherMin[e] : FahrenheitFormatt.fahrenheit(weatherData.dailyWeatherMin[e]))
        }
        weatherMaxDaysForecast = newArrayMaxDaysForecast
        weatherMinDaysForecast = newArrayMinDaysForecast
    }

    Connections {
        target: weatherData
        function onDataChanged() {
            timesDaysForecast = weatherData.dailyTime.map(function(iso) {
                var dateDayTime = new Date((iso + "T00:00:00"))
                return dateDayTime.toLocaleString(Qt.locale(), "ddd");
            })

            iconsDaysForecast = weatherData.iconsDailyWather
            updateTemperatures()
            rainDaysForecast = weatherData.dailyPrecipitationProbabilityMax
        }
    }

    onTemperatureUnitChanged: {
        updateTemperatures()
    }


    Component.onCompleted: {
        timesDaysForecast = weatherData.dailyTime.map(function(iso) {
            var dateDayTime = new Date((iso + "T00:00:00"))
            return dateDayTime.toLocaleString(Qt.locale(), "ddd");
        })

        iconsDaysForecast = weatherData.iconsDailyWather
        updateTemperatures()
        rainDaysForecast = weatherData.dailyPrecipitationProbabilityMax
    }
}
