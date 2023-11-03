{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit vqcontrols;

{$warn 5023 off : no warning about unused units}
interface

uses
    vqFontUtils, vqStringList, vqUtils, vqThemes, vqAutoPath, vqAutoURL, 
    vqMDMarker, vqDateTimeUtils, vqAnimatedImages, vqAnimation, 
    vqAnimationPlayer, vqAPNG, vqAPNGReader, vqAPNGWriter, vqGIF, 
    VQControlsRegister, vqColorMap, vqScrollingControl, vqAnimate, vqArrow, 
    vqButtons, vqColorButton, vqControlBar, vqDial, vqDivider, vqFontButton, 
    vqLedLabel, vqLedUtils, vqMarkLabel, vqMenuBox, vqNotifier, vqPageControl, 
    vqQuickButton, vqSlider, vqSwitch, vqToolBar, vqToolButton, vqToolPanel, 
    vqToolTip, vqFontListBox, vqListBox, vqListBoxBuffer, vqListBoxModel_p, 
    vqListBoxUtils, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('VQControlsRegister', @VQControlsRegister.Register);
end;

initialization
  RegisterPackage('vqcontrols', @Register);
end.
