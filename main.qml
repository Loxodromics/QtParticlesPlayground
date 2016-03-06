
import QtQuick 2.0
import QtQuick.Particles 2.0
import QtQuick.Window 2.0
import QtQuick.Controls 1.4

ApplicationWindow {
    visible: true
    width: 640
    height: 480

    Rectangle {
        color: "black"
        anchors.fill: parent
        ParticleSystem {
            id: sys
        }

        Turbulence {
            id: turb
            enabled: true
            system: sys

            anchors.fill: parent
            strength: 1
            //NumberAnimation on strength{from: 16; to: 64; easing.type: Easing.InOutBounce; duration: 1800; loops: -1}
        }

        Gravity {
            id: gravity
            enabled: true
            system: sys

            anchors.fill: parent
            magnitude: 2
            angle: -90
        }

        Emitter {
            system:sys
//            height: parent.height
            width: parent.width
            anchors.bottom: parent.bottom
//            anchors.fill: parent
            emitRate: 3
            lifeSpan: 600000
            velocity: PointDirection {x:0; y:-32; yVariation: 1}
            size: 36
            sizeVariation: 29
            startTime: 30000
        }

        ShaderEffectSource {
            id: theSource
            sourceItem: theItem
            hideSource: true
        }

        Image {
            id: theItem
            source: "qrc:/particle1.png"
        }

        CustomParticle {
            system: sys
            //! [vertex]
            vertexShader:"
            uniform lowp float qt_Opacity;
            varying lowp float fFade;
            varying lowp float fBlur;

            void main() {
                defaultMain();
                highp float t = (qt_Timestamp - qt_ParticleData.x) / qt_ParticleData.y;
                highp float fadeIn = min(t * 10., 1.);
                highp float fadeOut = 1. - max(0., min((t - 0.75) * 4., 1.));

                fFade = fadeIn * fadeOut * qt_Opacity;
                fBlur = max(0.2 * t, t * qt_ParticleR);
            }
        "
            //! [vertex]
            property variant source: theSource
            property variant blurred: ShaderEffectSource {
                sourceItem: ShaderEffect {
                    width: theItem.width
                    height: theItem.height
                    property variant delta: Qt.size(0.0, 1.0 / height)
                    property variant source: ShaderEffectSource {
                        sourceItem: ShaderEffect {
                            width: theItem.width
                            height: theItem.height
                            property variant delta: Qt.size(1.0 / width, 0.0)
                            property variant source: theSource
                            fragmentShader: "
                        uniform sampler2D source;
                        uniform lowp float qt_Opacity;
                        uniform highp vec2 delta;
                        varying highp vec2 qt_TexCoord0;
                        void main() {
                            gl_FragColor =(0.0538 * texture2D(source, qt_TexCoord0 - 3.182 * delta)
                                         + 0.3229 * texture2D(source, qt_TexCoord0 - 1.364 * delta)
                                         + 0.2466 * texture2D(source, qt_TexCoord0)
                                         + 0.3229 * texture2D(source, qt_TexCoord0 + 1.364 * delta)
                                         + 0.0538 * texture2D(source, qt_TexCoord0 + 3.182 * delta)) * qt_Opacity;
                        }"
                        }
                    }
                    fragmentShader: "
                uniform sampler2D source;
                uniform lowp float qt_Opacity;
                uniform highp vec2 delta;
                varying highp vec2 qt_TexCoord0;
                void main() {
                    gl_FragColor =(0.0538 * texture2D(source, qt_TexCoord0 - 3.182 * delta)
                                 + 0.3229 * texture2D(source, qt_TexCoord0 - 1.364 * delta)
                                 + 0.2466 * texture2D(source, qt_TexCoord0)
                                 + 0.3229 * texture2D(source, qt_TexCoord0 + 1.364 * delta)
                                 + 0.0538 * texture2D(source, qt_TexCoord0 + 3.182 * delta)) * qt_Opacity;
                }"
                }
            }
            //! [fragment]
            fragmentShader: "
            uniform sampler2D source;
            uniform sampler2D blurred;
            varying highp vec2 qt_TexCoord0;
            varying highp float fBlur;
            varying highp float fFade;
            void main() {
                gl_FragColor = mix(texture2D(source, qt_TexCoord0), texture2D(blurred, qt_TexCoord0), min(1.0,fBlur*3.0)) * fFade;
            }"
            //! [fragment]

        }
        Rectangle {
            id: colorOverlay
            anchors.fill: parent

            gradient: Gradient {
                GradientStop { position: 0.0; color: "#804682B4" }
                GradientStop { position: 1.0; color: "#f0000020" }
            }
        }
    }
}

