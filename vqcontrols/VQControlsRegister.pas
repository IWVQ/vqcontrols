unit VQControlsRegister;

interface

uses
    InterfaceBase, LResources,
    SysUtils, Classes,
    { LIB }
    vqUtils,
    vqThemes,
    vqStringList,
    vqFontUtils,
    vqMDMarker,
    vqDateTimeUtils,
    vqAnimationPlayer,
    vqAPNG,
    vqGIF,
    vqAnimatedImages,
    vqAnimation,
    vqColorMap,
    vqSplitVector,

    vqToolTip,
    vqQuickButton,
    vqArrow,
    vqDivider,
    vqButtons,
    vqToolButton,
    vqColorButton,
    vqFontButton,
    vqSwitch,
    vqSlider,
    vqDial,
    vqMarkLabel,
    vqNotifier,
    vqAnimate,
    vqLedUtils,
    vqLedLabel,

    vqToolBar,
    vqToolPanel,
    vqControlBar,
    vqPageControl,

    vqListBox,
    vqMenuBox

	;

procedure Register;

implementation

procedure Register;
begin
    RegisterComponents('VQControls',
        [
        TvqQuickButton,
        TvqArrow,
        TvqDivider,
        TvqButton,
        TvqToolButton,
        TvqColorButton,
        TvqFontButton,
        TvqSwitch,
        TvqSlider,
        TvqDial,
        TvqMarkLabel,
        TvqNotifier,
        TvqAnimate,
        TvqLedLabel,
        TvqToolBar,
        TvqToolPanel,
        TvqControlBar,
        TvqPageControl,

        TvqListBox,
        TvqMenuBox
        ]);
end;

initialization

    {$I vqcontrolsimgs.lrs}

end.
