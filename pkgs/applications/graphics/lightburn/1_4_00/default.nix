{ lib, stdenv, fetchurl, p7zip
, cups, nss, nspr, libusb1, qtbase
, qtmultimedia, qtserialport
, autoPatchelfHook, wrapQtAppsHook
, gst_all_1
}:

stdenv.mkDerivation rec {
  pname = "lightburn";
  version = "1.4.00";
  primaryBinary = "LightBurn";
  dontWrapQtApps = true;

  src = fetchurl {
    url = "https://github.com/LightBurnSoftware/deployment/releases/download/${version}/LightBurn-Linux64-v${version}.7z";
    sha256 = "1v0mayxbabjlcym2zv82970jk0kbq1s52lci8sljnaiyi4h5ayrn";
  };

  nativeBuildInputs = [
    p7zip
    autoPatchelfHook
    wrapQtAppsHook
  ];

  # qtWrapperArgs = [ ''--prefix PATH : /LightBurn/lib/'' ];

  buildInputs = [
    cups nss nspr libusb1
    qtbase qtmultimedia qtserialport
  ];

  # We nuke the vendored Qt5 libraries that LightBurn ships and instead use our
  # own.
  unpackPhase = ''
    7z x $src
    # rm -rf LightBurn/lib
    # rm -rf LightBurn/plugins

    # rm LightBurn/lib/libicudata.so.56
    # rm LightBurn/lib/libicui18n.so.56
    # rm LightBurn/lib/libicuuc.so.56
    # rm LightBurn/lib/libQt5MultimediaGstTools.so.5
    # rm LightBurn/lib/libQt5XcbQpa.so.5
    # rm LightBurn/lib/libQt5DBus.so.5
    # rm LightBurn/lib/libQt5Multimedia.so.5
    # rm LightBurn/lib/libQt5OpenGL.so.5
    # rm LightBurn/lib/libQt5Svg.so.5

    # rm LightBurn/lib/libQt5Core.so.5
    # rm LightBurn/lib/libQt5Network.so.5
    # rm LightBurn/lib/libQt5SerialPort.so.5
    # rm LightBurn/lib/libQt5Xml.so.5
    # rm LightBurn/lib/libQt5Gui.so.5
    # rm LightBurn/lib/libQt5MultimediaWidgets.so.5
    # rm LightBurn/lib/libQt5PrintSupport.so.5
    # rm LightBurn/lib/libQt5Widgets.so.5

  '';

  installPhase = ''
    mkdir -p $out/share $out/bin
    cp -ar LightBurn $out/share/LightBurn
    ln -s $out/share/LightBurn/LightBurn $out/bin

    wrapQtApp $out/bin/LightBurn --prefix PATH : LightBurn/lib/::LightBurn/plugins
  '';

  meta = {
    description = "Layout, editing, and control software for your laser cutter";
    homepage = "https://lightburnsoftware.com/";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ q3k ];
    platforms = [ "x86_64-linux" ];
  };
}