TARGET = harbour-colordots

# Application version
DEFINES += APP_VERSION=\\\"$$VERSION\\\"
DEFINES += APP_RELEASE=\\\"$$RELEASE\\\"

CONFIG += sailfishapp
QT += xml

SOURCES += \
    main.cpp

HEADERS +=

OTHER_FILES = \
    rpm/harbour-colordots.spec \
    rpm/harbour-colordots.yaml \
    rpm/harbour-colordots.changes \
    qml/CoverPage.qml \
    qml/MainPage.qml \
    qml/Settings.qml \
    qml/main.qml \
    qml/AboutPage.qml \
    qml/Dot.qml \
    qml/Line.qml \
    qml/storage.js \
    qml/Rectangle.qml \
    qml/Diamond.qml \
    qml/SettingsDialog.qml \
    qml/Star.qml \
    qml/Cross.qml

INCLUDEPATH += $$PWD
