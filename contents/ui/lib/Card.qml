import QtQuick
import Qt5Compat.GraphicalEffects
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami as Kirigami

Item {
    id: root
    HelperCard {
        id: background
        isShadow: false
        anchors.fill: parent
        isCustom: false
        customColorbg: Kirigami.Theme.backgroundColor
        visible: true
    }

    HelperCard {
        id: shadow
        isShadow: true
        anchors.fill: parent
        isCustom: false
        visible: true
        opacity: 0.8
    }
    HelperCard {
        id: mask
        isMask: true
        isCustom: false
        anchors.fill: parent
        visible: false
    }
}
