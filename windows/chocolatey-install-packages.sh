choco feature enable -n allowGlobalConfirmation

#System
choco install amd-ryzen-chipset
choco install wsl2 --params "/Version:2 /Retry:true"
choco install eartrumpet
choco install bulk-crap-uninstaller
choco install 7zip

#DEV Tools
#choco install ultraedit
#choco install strawberryperl
choco install python3
choco install racket
choco install docker-desktop

#C++ Tooling
choco install cmake --installargs 'ADD_CMAKE_TO_PATH=System'
choco install ninja
#clan gcc llvm ....
choco install winlibs

#Java
choco install AdoptOpenJDK --params="/ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome /INSTALLDIR=C:\Program Files\AdoptOpenJDK\ /quiet"

#Applications
choco install foxitreader --ia '/MERGETASKS="!desktopicon /COMPONENTS=*pdfviewer,*ffse,*installprint,*ffaddin,*ffspellcheck,!connectedpdf"'
choco install microsoft-office-deployment --params '/64bit  /Product:O365HomePremRetail  /Exclude=Publisher,Lync,Groove,Access'
choco install authy-desktop
choco install speedtest

#Content Creation
choco install ffmpeg-full
choco install sox.portable
#choco install audacity
choco install openshot
choco install inkscape
choco install discord

#OBS
choco install obs-studio
choco install obs-virtualcam

#Games
choco install retroarch
