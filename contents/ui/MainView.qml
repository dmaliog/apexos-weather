import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import "./js/fahrenheitFormatt.js" as FahrenheitFormatt

Item {

    property int generalMargin: 4

    property string formatTime: Plasmoid.configuration.UseFormat12hours ? "h ap" : "H"
    property var titles
    property var namesTitles

    property string titlesBeading: Plasmoid.configuration.selectedMetrics
    property string temperatureUnit: Plasmoid.configuration.temperatureUnit
    property string temperatureUnitUpdate: temperatureUnit
    property string windUnitUpdate: Plasmoid.configuration.windUnit

    property string formattTime: ""
    property var valuesMainView: []

    function getTranslatedWindUnit(unit) {
        if (unit === "km/h") return i18n("km/h")
        if (unit === "mph") return i18n("mph")
        if (unit === "m/s") return i18n("m/s")
        return unit
    }

    function getTranslatedTempUnit(unit) {
        if (unit === "Celsius") return "°C"
        if (unit === "Fahrenheit") return "°F"
        return unit
    }

    function getListMetrics() {
        return [
            { name: "Feels Like", nameText: "Feels Like", value: Math.round(temperatureUnit === "Celsius" ? weatherData.apparentTemperature : FahrenheitFormatt.fahrenheit(weatherData.apparentTemperature)) + "°"},
            { name: "UV Level", nameText: i18n("UV"), value: weatherData.currentUvIndexText },
            { name: "Humidity", nameText: "Humidity", value: Math.round(weatherData.currentHumidity) + "%" },
            { name: "Max/Min", nameText: i18n("Temperature Range"), value: i18n("from") + " " + Math.round(temperatureUnit === "Celsius" ? weatherData.dailyWeatherMax[0] : FahrenheitFormatt.fahrenheit(weatherData.dailyWeatherMax[0])) + "° " + i18n("to") + " " + Math.round(temperatureUnit === "Celsius" ? weatherData.dailyWeatherMin[0] : FahrenheitFormatt.fahrenheit(weatherData.dailyWeatherMin[0])) + "°" },
            { name: "Rain", nameText: i18n("Precipitation"), value: Math.round(weatherData.dailyPrecipitationProbabilityMax[0]) + "%"},
            { name: "Wind Speed", nameText: "Wind", value: Math.round(windUnitsUpdate(weatherData.windSpeed, Plasmoid.configuration.windUnit)) + " " + getTranslatedWindUnit(Plasmoid.configuration.windUnit)},
            { name: "Sunrise / Sunset", nameText: "Sunrise / Sunset", value: sunriseOrSunset() },
            { name: "Cloud Cover", nameText: "Cloudiness", value: Math.round(weatherData.cloudCover) + "%"}
        ]
    }

    function updateValues() {
        var newValues = [];
        var newNames = [];
        var metrics = getListMetrics();
        for (var i = 0; i < titles.length; i++) {
            for (var o = 0; o < metrics.length; o++){
                if (titles[i] === metrics[o].name) {
                    newNames.push(metrics[o].nameText);
                    newValues.push(metrics[o].value);
                }
            }
        }
        valuesMainView = newValues;
        namesTitles = newNames
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

    function sunriseOrSunset() {
        if (weatherData.hourlyIsDay[0] === 1) {
            return formatTimeWithCustomAMPM(weatherData.hourlyTimes[weatherData.hourlyIsDay.indexOf(0)], formatTime);
        } else {
            return formatTimeWithCustomAMPM(weatherData.hourlyTimes[weatherData.hourlyIsDay.indexOf(1)], formatTime);
        }
    }

    function windUnitsUpdate(kmh, x) {
        const metresPerSecond = kmh * (5 / 18);
        const milesPerHour = kmh * 0.621371;

        return x === "m/s"
        ? metresPerSecond
        : x === "mph"
        ? milesPerHour
        : kmh;
    }

    function roundMax2Number(val) {
        var n = Number(val);
        if (!isFinite(n)) return val;
        return Math.round(n * 100) / 100;
    }

    function formatMax2(val) {
        var n = Number(val);
        if (!isFinite(n)) return "";
        var s = n.toFixed(2).replace(/\.?0+$/, "");
        return s;
    }

    Connections {
        target: weatherData
        function onDataChanged() {
            updateValues()
        }
    }

    onTitlesBeadingChanged: {
        titles = [].concat(Plasmoid.configuration.selectedMetrics)
        updateValues()
        if (detailsSection) {
            detailsSection.updateModel()
        }
    }
    onWindUnitUpdateChanged: {
        titles = [].concat(Plasmoid.configuration.selectedMetrics)
        updateValues()
        if (detailsSection) {
            detailsSection.updateModel()
        }
    }

    onTemperatureUnitChanged: {
        titles = [].concat(Plasmoid.configuration.selectedMetrics)
        updateValues()
        if (detailsSection) {
            detailsSection.updateModel()
        }
    }
    onTemperatureUnitUpdateChanged: {
        titles = [].concat(Plasmoid.configuration.selectedMetrics)
        updateValues()
        if (detailsSection) {
            detailsSection.updateModel()
        }
    }
    
    onValuesMainViewChanged: {
        if (detailsSection) {
            detailsSection.updateModel()
        }
    }
    
    Connections {
        target: Plasmoid.configuration
        function onMetricsOrderChanged() {
        }
    }

    Component.onCompleted: {
        titles = [].concat(Plasmoid.configuration.selectedMetrics)
        if (weatherData.updateWeather) {
            updateValues()
        }
        if (detailsSection) {
            detailsSection.updateModel()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: generalMargin / 2
        spacing: 4

        Item {
            id: currentConditionsSection
            Layout.fillWidth: true
            Layout.preferredHeight: 64

            Text {
                id: currentTemp
                height: currentConditionsSection.height
                text: Math.round(temperatureUnit === "Celsius" ? weatherData.currentWeather : FahrenheitFormatt.fahrenheit(weatherData.currentWeather))
                color: Kirigami.Theme.textColor
                font.pixelSize: height
            }

            Text {
                id: tempUnit
                anchors.left: parent.left
                anchors.leftMargin: currentTemp.implicitWidth + 4
                anchors.bottom: maxMin.top
                text: getTranslatedTempUnit(temperatureUnit)
                color: Kirigami.Theme.textColor
                verticalAlignment: Text.AlignVCenter
                height: 64 - maxMin.height -4
                font.pixelSize: currentTemp.height/2
            }

            Kirigami.Heading {
                id: maxMin
                anchors.left: parent.left
                anchors.leftMargin: currentTemp.implicitWidth + 4
                anchors.bottom: parent.bottom
                text: weatherData.currentTextWeather ? weatherData.currentTextWeather : "--"
                font.weight: Font.DemiBold
                opacity: 0.6
                level: 5
            }

            Kirigami.Icon {
                id: weatherIcon
                width: parent.height
                height: width
                source: weatherData.currentIconWeather
                anchors.right: parent.right
            }
        }

        GridView {
            id: detailsSection
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 1
            cellWidth: width / 3
            cellHeight: (height - 10) / Math.ceil(titles.length / 3) + 5
            clip: true
            interactive: draggedIndex === -1
            boundsBehavior: draggedIndex === -1 ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds
            
            model: ListModel {
                id: metricsModel
            }
            
            readonly property real dragThresholdRatio: 0.3
            
            property int draggedIndex: -1
            property int dropTargetIndex: -1
            property Item currentDragVisual: null
            
            MouseArea {
                id: globalDragHandler
                anchors.fill: parent
                enabled: detailsSection.draggedIndex !== -1
                z: 10000
                cursorShape: Qt.ClosedHandCursor
                propagateComposedEvents: false
                onPositionChanged: function(mouse) {
                    mouse.accepted = true
                }
                onPressed: function(mouse) {
                    mouse.accepted = true
                }
                onReleased: function(mouse) {
                    mouse.accepted = true
                }
            }
            
            onDraggedIndexChanged: {
                if (draggedIndex !== -1) {
                    interactive = false
                } else {
                    interactive = true
                    if (currentDragVisual) {
                        currentDragVisual.destroy()
                        currentDragVisual = null
                    }
                }
            }
            

            delegate: Item {
                id: tileDelegate
                width: detailsSection.cellWidth - 5
                height: detailsSection.cellHeight - 5
                x: Math.floor((index % 3) * detailsSection.cellWidth) + 2.5
                y: Math.floor(Math.floor(index / 3) * detailsSection.cellHeight) + 2.5
                
                Connections {
                    target: detailsSection
                    function onDraggedIndexChanged() {
                        if (detailsSection.draggedIndex !== index) {
                            dragArea.isDragging = false
                            dragArea.dragStarted = false
                            dragArea.lastCalculatedIndex = -1
                            dragArea.lastPos = Qt.point(-1, -1)
                            if (dragArea.dragVisual && dragArea.dragVisual !== detailsSection.currentDragVisual) {
                                dragArea.dragVisual = null
                            }
                        }
                    }
                }
                
                KSvg.FrameSvgItem {
                    id: frame
                    anchors.fill: parent
                    imagePath: "widgets/viewitem"
                    prefix: {
                        if (detailsSection.draggedIndex === index && dragArea.drag.active) {
                            return "normal"
                        } else if (dragArea.pressed && !dragArea.dragStarted) {
                            return "selected"
                        } else if (dragArea.containsMouse && detailsSection.draggedIndex === -1) {
                            return "hover"
                        }
                        return "hover"
                    }
                    opacity: {
                        if (dragArea.containsMouse || (dragArea.pressed && !dragArea.dragStarted)) {
                            return 1.0
                        }
                        return 0.8
                    }
                    enabled: false
                }
                
                opacity: {
                    if (detailsSection.draggedIndex === index && dragArea.drag.active) {
                        return 0.8
                    }
                    return 1.0
                }
                
                Drag.active: dragArea.drag.active
                Drag.hotSpot.x: width / 2
                Drag.hotSpot.y: height / 2
                Drag.keys: ["metric"]
                
                MouseArea {
                    id: dragArea
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    hoverEnabled: true
                    z: 10
                    preventStealing: true
                    cursorShape: {
                        if ((detailsSection.draggedIndex === index && drag.active) || (detailsSection.draggedIndex === index && dragStarted)) {
                            return Qt.ClosedHandCursor
                        } else if (containsMouse && detailsSection.draggedIndex === -1) {
                            return Qt.OpenHandCursor
                        }
                        return Qt.ArrowCursor
                    }
                    drag.axis: Drag.XAndYAxis
                    drag.threshold: 5
                    propagateComposedEvents: false
                    enabled: detailsSection.draggedIndex === -1 || detailsSection.draggedIndex === index
                    
                    property Item dragVisual: null
                    property point startPos: Qt.point(0, 0)
                    property bool isDragging: false
                    property bool dragStarted: false
                    property int lastCalculatedIndex: -1
                    property point lastPos: Qt.point(-1, -1)
                    
                    onPressed: function(mouse) {
                        parent.forceActiveFocus()
                        
                        if (detailsSection.currentDragVisual) {
                            detailsSection.currentDragVisual.destroy()
                            detailsSection.currentDragVisual = null
                        }
                        
                        if (detailsSection.draggedIndex !== -1) {
                            detailsSection.cleanupDrag()
                            detailsSection.draggedIndex = -1
                            detailsSection.dropTargetIndex = -1
                        }
                        
                        startPos = Qt.point(mouse.x, mouse.y)
                        isDragging = false
                        dragStarted = false
                        lastCalculatedIndex = -1
                        lastPos = Qt.point(-1, -1)
                        dragVisual = null
                        mouse.accepted = true
                    }
                    
                    
                    onPositionChanged: function(mouse) {
                        if (!pressed) {
                            return
                        }
                        
                        mouse.accepted = true
                        
                        var deltaX = Math.abs(mouse.x - startPos.x)
                        var deltaY = Math.abs(mouse.y - startPos.y)
                        
                        if (!dragStarted && (deltaX > drag.threshold || deltaY > drag.threshold)) {
                            if (detailsSection.currentDragVisual) {
                                detailsSection.currentDragVisual.destroy()
                                detailsSection.currentDragVisual = null
                            }
                            if (detailsSection.draggedIndex !== -1 && detailsSection.draggedIndex !== index) {
                                detailsSection.draggedIndex = -1
                                detailsSection.dropTargetIndex = -1
                            }
                            
                            dragStarted = true
                            isDragging = true
                            detailsSection.draggedIndex = index
                            
                            var globalPos = mapToItem(detailsSection, mouse.x, mouse.y)
                            lastPos = globalPos
                            lastCalculatedIndex = index
                            
                            dragVisual = dragVisualComponent.createObject(detailsSection, {
                                x: globalPos.x - tileDelegate.width / 2,
                                y: globalPos.y - tileDelegate.height / 2,
                                width: tileDelegate.width,
                                height: tileDelegate.height,
                                metricNameText: nameText,
                                metricValue: value
                            })
                            detailsSection.currentDragVisual = dragVisual
                        }
                        
                        if (isDragging && dragVisual) {
                            var globalPos = mapToItem(detailsSection, mouse.x, mouse.y)
                            
                            dragVisual.x = globalPos.x - tileDelegate.width / 2
                            dragVisual.y = globalPos.y - tileDelegate.height / 2
                            
                            var posDeltaX = Math.abs(globalPos.x - lastPos.x)
                            var posDeltaY = Math.abs(globalPos.y - lastPos.y)
                            var minDelta = Math.max(detailsSection.cellWidth, detailsSection.cellHeight) * detailsSection.dragThresholdRatio
                            
                            if (lastCalculatedIndex === -1 || posDeltaX > minDelta || posDeltaY > minDelta) {
                                var cellX = Math.floor(globalPos.x / detailsSection.cellWidth)
                                var cellY = Math.floor(globalPos.y / detailsSection.cellHeight)
                                var newIndex = Math.max(0, Math.min(cellY * 3 + cellX, metricsModel.count - 1))
                                
                                if (newIndex >= 0 && newIndex < metricsModel.count && 
                                    newIndex !== detailsSection.draggedIndex && 
                                    newIndex !== detailsSection.dropTargetIndex &&
                                    newIndex !== lastCalculatedIndex) {
                                    detailsSection.dropTargetIndex = newIndex
                                    lastCalculatedIndex = newIndex
                                    lastPos = globalPos
                                }
                            }
                        }
                    }
                    
                    onReleased: {
                        if (detailsSection.draggedIndex === index) {
                            var targetIndex = detailsSection.dropTargetIndex
                            var fromIndex = detailsSection.draggedIndex
                            
                            dragVisual = null
                            isDragging = false
                            dragStarted = false
                            lastCalculatedIndex = -1
                            lastPos = Qt.point(-1, -1)
                            
                            if (targetIndex >= 0 && targetIndex !== fromIndex && fromIndex !== -1) {
                                detailsSection.moveItem(fromIndex, targetIndex)
                            }
                            
                            detailsSection.cleanupDrag()
                        }
                    }
                    
                    onCanceled: {
                        if (detailsSection.draggedIndex === index) {
                            dragVisual = null
                            isDragging = false
                            dragStarted = false
                            lastCalculatedIndex = -1
                            lastPos = Qt.point(-1, -1)
                            detailsSection.cleanupDrag()
                        }
                    }
                }

                DropArea {
                    id: dropArea
                    anchors.fill: parent
                    z: -2
                    keys: ["metric"]
                    enabled: detailsSection.draggedIndex !== -1 && detailsSection.draggedIndex !== index
                    
                    onEntered: function(drag) {
                        if (detailsSection.draggedIndex !== -1 && detailsSection.draggedIndex !== index && detailsSection.draggedIndex < metricsModel.count && index < metricsModel.count) {
                            detailsSection.dropTargetIndex = index
                        }
                        drag.accepted = false
                    }
                    
                    onExited: function(drag) {
                        if (detailsSection.dropTargetIndex === index) {
                            detailsSection.dropTargetIndex = -1
                        }
                        drag.accepted = false
                    }
                    
                    onDropped: function(drop) {
                        drop.accepted = true
                        var fromIndex = detailsSection.draggedIndex
                        var toIndex = index
                        
                        if (fromIndex !== -1 && fromIndex !== toIndex) {
                            detailsSection.moveItem(fromIndex, toIndex)
                        }
                        
                        detailsSection.cleanupDrag()
                    }
                }
                
                Component {
                    id: dragVisualComponent
                    Item {
                        parent: detailsSection
                        z: 100
                        scale: 1.05
                        opacity: 0.95
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.ClosedHandCursor
                            enabled: false
                            z: 1
                        }
                        
                        KSvg.FrameSvgItem {
                            id: dragFrame
                            anchors.fill: parent
                            imagePath: "widgets/viewitem"
                            prefix: "selected"
                        }
                        
                        Drag.active: true
                        Drag.keys: ["metric"]
                        Drag.hotSpot.x: width / 2
                        Drag.hotSpot.y: height / 2
                        
                        property string metricNameText: ""
                        property string metricValue: ""
                        
                        Column {
                            anchors.centerIn: parent
                            width: parent.width - dragFrame.margins.right * 2
                            spacing: 4

                            Kirigami.Heading {
                                width: parent.width
                                text: parent.parent.metricNameText === "Sunrise / Sunset" ? weatherData.hourlyIsDay[0] === 1 ? i18n("Sunset") : i18n("Sunrise") : i18n(parent.parent.metricNameText)
                                horizontalAlignment: Text.AlignHCenter
                                font.weight: Font.DemiBold
                                level: 5
                            }

                            Kirigami.Heading {
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                text: parent.parent.metricValue ? parent.parent.metricValue : "--"
                                opacity: 0.7
                                level: 5
                            }
                        }
                    }
                }

                Column {
                    anchors.centerIn: parent
                    width: parent.width - frame.margins.right * 2
                    spacing: 4
                    enabled: false

                    Kirigami.Heading {
                        width: parent.width
                        text: nameText === "Sunrise / Sunset" ? weatherData.hourlyIsDay[0] === 1 ? i18n("Sunset") : i18n("Sunrise") : i18n(nameText)
                        horizontalAlignment: Text.AlignHCenter
                        font.weight: Font.DemiBold
                        level: 5
                    }

                    Kirigami.Heading {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        text: value ? value : "--"
                        opacity: 0.7
                        level: 5
                    }
                }
            }
            
            function updateModel() {
                metricsModel.clear()
                if (!titles || titles.length === 0) {
                    return
                }
                
                var configOrder = Plasmoid.configuration.metricsOrder || []
                var validOrder = []
                for (var k = 0; k < configOrder.length; k++) {
                    if (configOrder[k] && configOrder[k].trim() !== "") {
                        validOrder.push(configOrder[k])
                    }
                }
                
                var order = (validOrder.length === titles.length) ? validOrder : titles
                
                for (var i = 0; i < order.length; i++) {
                    var metricName = order[i]
                    if (!metricName || metricName.trim() === "") {
                        continue
                    }
                    var metricIndex = -1
                    for (var j = 0; j < titles.length; j++) {
                        if (titles[j] === metricName) {
                            metricIndex = j
                            break
                        }
                    }
                    if (metricIndex >= 0 && metricIndex < titles.length) {
                        var nameTextValue = (namesTitles && namesTitles.length > metricIndex) ? namesTitles[metricIndex] : ""
                        var valueText = (valuesMainView && valuesMainView.length > metricIndex) ? valuesMainView[metricIndex] : "--"
                        metricsModel.append({
                            name: titles[metricIndex],
                            nameText: nameTextValue,
                            value: valueText
                        })
                    }
                }
            }
            
            function saveMetricsOrder() {
                var order = []
                for (var i = 0; i < metricsModel.count; i++) {
                    var item = metricsModel.get(i)
                    if (item && item.name) {
                        order.push(item.name)
                    }
                }
                if (order.length > 0) {
                    Plasmoid.configuration.metricsOrder = order
                }
            }
            
            function moveItem(fromIndex, toIndex) {
                if (fromIndex < 0 || toIndex < 0 || fromIndex >= metricsModel.count || toIndex >= metricsModel.count || fromIndex === toIndex) {
                    return
                }
                
                metricsModel.move(fromIndex, toIndex, 1)
                
                saveMetricsOrder()
            }
            
            function cleanupDrag() {
                if (currentDragVisual) {
                    currentDragVisual.destroy()
                    currentDragVisual = null
                }
                draggedIndex = -1
                dropTargetIndex = -1
                interactive = true
            }
        }
    }
}
