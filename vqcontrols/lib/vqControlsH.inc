// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

{ vqControlsH.inc           }
{ included in vqUtils.pas   }

{ Controls }

type
    TvqCaret = class;
    TvqCaretHideMethod = procedure (Caret: TvqCaret) of object;
    TvqCaret = class(TPersistent)
    private
        FShowing: Boolean;
        FAtFront: Boolean;
        FTimer: TTimer;
        FColor: TColor;
        FClientRect: TRect;
        FOwner: TControl;
        FHideMethod: TvqCaretHideMethod;
        procedure OnTimer(Sender: TObject);
        function GetInterval: Integer;
        function GetBlinking: Boolean;
        procedure SetBlinking(Value: Boolean);
        procedure SetInterval(Value: Integer);
        procedure SetColor(Value: TColor);
        procedure SetClientRect(Value: TRect); virtual;
        procedure BringToFront;
        procedure CarryToBack;
    protected
        procedure Change; virtual;
        procedure Invalidate; virtual;
        
        procedure DrawArrow(Canvas: TCanvas; Position: TvqPosition);
        procedure DrawLine(Canvas: TCanvas; Orientation: TvqOrientation);
        procedure DrawDot(Canvas: TCanvas; Orientation: TvqOrientation);
        
        procedure DrawBlock(Canvas: TCanvas; ACh: string; AFace: TFontName; 
            ASize: Integer; AStyle: TFontStyles; AFore: TColor); overload;
        procedure DrawBlock(Canvas: TCanvas); overload;
        procedure DrawBox(Canvas: TCanvas);
        procedure DrawInvert(Canvas: TCanvas);
        procedure DrawSubline(Canvas: TCanvas);
        procedure DrawLine(Canvas: TCanvas);
        
        procedure Paint; virtual;
        procedure DrawBack; virtual;
        property Owner: TControl read FOwner write FOwner;
    public
        constructor Create(AOwner: TControl); virtual;
        destructor Destroy; override;
        procedure Assign(Source: TPersistent); override;
        procedure Show;
        procedure Hide;
        procedure Pause;
        procedure Blink;
        
        property Blinking: Boolean read GetBlinking write SetBlinking;
        property Showing: Boolean read FShowing;
        property Interval: Integer read GetInterval write SetInterval;
        property Color: TColor read FColor write SetColor;
        property ClientRect: TRect read FClientRect write SetClientRect;
        property HideMethod: TvqCaretHideMethod read FHideMethod write FHideMethod;
    end;
    
    TvqTextCaretShape = (vqtcLine, vqtcBlock, vqtcSubline, vqtcBox);
    
    {
    
        property AutoSize;
        property BidiMode;
        property Caption;
        property DragCursor;
        property DragKind;
        property DragMode;
        property Font;
        property ParentBidiMode;
        property ParentFont;
        property PopupMenu;
        
        property TabOrder;
        property TabStop;
        
        property OnChange;
        
        property OnContextPopup;
        property OnDragDrop;
        property OnDragOver;
        property OnEndDrag;
        property OnPaint;
        property OnStartDrag;
        
        property OnUTF8KeyPress;
        
    }
    
    TvqCustomControl = class(TCustomControl)
    private
        FSpacing: Integer;
        FOnChange: TNotifyEvent;
        procedure CMBorderChanged(var Message: TLMessage); message CM_BORDERCHANGED;
        procedure CMChanged(var Message: TLMessage); message CM_CHANGED;
        procedure CMColorChanged(var Message: TLMessage); message CM_COLORCHANGED;
        procedure WMSetFocus(var Message: TLMSetFocus); message LM_SETFOCUS;
        procedure WMKillFocus(var Message: TLMKillFocus); message LM_KILLFOCUS;
        procedure CMFontChanged(var Message: TLMessage); message CM_FONTCHANGED;
        procedure CMControlListChange(var Message: TLMessage); message CM_CONTROLLISTCHANGE;

        procedure WMCancelMode(var Message: TLMessage); message LM_CANCELMODE;
        procedure WMEraseBkgnd(var Message: TLMEraseBkgnd); message LM_ERASEBKGND;
        procedure SetSpacing(Value: Integer);
    strict protected
        procedure OldCalculatePreferredSize(var PreferredWidth, PreferredHeight: Integer; WithThemeSpace: Boolean); virtual;
        procedure OldPaint; virtual;
        procedure OldKeyDown(var Key: Word; Shift: TShiftState); virtual;
        procedure OldKeyUp(var Key: Word; Shift: TShiftState); virtual;
        procedure OldMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
        procedure OldMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
        procedure OldMouseMove(Shift: TShiftState; X, Y: Integer); virtual;
        procedure OldMouseEnter; virtual;
        procedure OldMouseLeave; virtual;
        procedure OldClick; virtual;
    protected
        function IsInternalControl(AControl: TControl): Boolean; virtual;
        
        procedure DoOnShowHint(HintInfo: PHintInfo); override;
        procedure DoChange; virtual;
        procedure BorderChanged; virtual;
        procedure ColorChanged; virtual;
        procedure FocusChanged(AFocused: Boolean); virtual;
        procedure FontChanged; virtual;
        procedure ControlListChanged; virtual;
        procedure CancelMode; virtual;
        procedure UpdateMetrics; virtual;
        procedure SetShape(AShape: TvqRegion); virtual;
        property OnChange: TNotifyEvent read FOnChange write FOnChange;
    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;                        
        property Spacing: Integer read FSpacing write SetSpacing;
    published
        property Align;
        property Anchors;
        property Color;
        property Constraints;
        property DoubleBuffered;
        property Enabled;
        property ParentColor;
        property ParentDoubleBuffered;
        property ParentShowHint;
        property ShowHint;
        property Visible;
        
        property OnChangeBounds;
        property OnEnter;
        property OnExit;   
        property OnKeyDown;
        property OnKeyPress;
        property OnKeyUp;
        property OnClick;
        property OnDblClick;
        property OnMouseDown;
        property OnMouseEnter;
        property OnMouseLeave;
        property OnMouseMove;
        property OnMouseUp;
        property OnMouseWheel;
        property OnMouseWheelDown;
        property OnMouseWheelUp;
        property OnResize;
        property OnPaint;
    end;
    
    TvqGraphicControl = class(TGraphicControl)
    private
        FSpacing: Integer;
        FOnChange: TNotifyEvent;
        procedure CMChanged(var Message: TLMessage); message CM_CHANGED;
        procedure CMColorChanged(var Message: TLMessage); message CM_COLORCHANGED;
        procedure CMFontChanged(var Message: TLMessage); message CM_FONTCHANGED;
        procedure SetSpacing(Value: Integer);
    protected
        procedure DoOnShowHint(HintInfo: PHintInfo); override;
        procedure ColorChanged; virtual;
        procedure FontChanged; virtual;
        procedure DoChange; virtual;
        procedure UpdateMetrics; virtual;
        property OnChange: TNotifyEvent read FOnChange write FOnChange;
    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;         
        property Spacing: Integer read FSpacing write SetSpacing;
    published
        property Align;
        property Anchors;
        property Color;
        property Constraints;
        property Enabled;
        property ParentColor;
        property ParentShowHint;
        property ShowHint;
        property Visible;
        
        property OnChangeBounds;
        property OnClick;
        property OnDblClick;
        property OnMouseDown;
        property OnMouseEnter;
        property OnMouseLeave;
        property OnMouseMove;
        property OnMouseUp;
        property OnMouseWheel;
        property OnMouseWheelDown;
        property OnMouseWheelUp;
        property OnResize;
        property OnPaint;
    end;
    
    TPopupLayout = (plTop, plCenter, plBottom);
    
    TvqDropDownEvent = procedure (Sender: TObject; var Caller: TControl) of object;
    
    TvqPopupForm = class(TCustomForm)
    private
        FClosed: Boolean;
        FOnChange: TNotifyEvent;
        FOnReturn: TNotifyEvent;
        FFreeOnClose: Boolean;
        FBeveled: Boolean;
        FOnPopup: TNotifyEvent;
        FOnCloseUp: TNotifyEvent;
        
        procedure SetBeveled(Value: Boolean);
        procedure CMChanged(var Message: TLMessage); message CM_CHANGED;
        procedure CMColorChanged(var Message: TLMessage); message CM_COLORCHANGED;
        procedure CMFontChanged(var Message: TLMessage); message CM_FONTCHANGED;
        procedure WMActivate(var Message: TLMActivate); message LM_ACTIVATE;
        procedure FormDeactivate(Sender: TObject);
        procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    protected
        FCaller: TControl;
        procedure DoPopup; virtual;
        procedure DoCloseUp; virtual;
        procedure DoChange; virtual;
        procedure ColorChanged; virtual;
        procedure FontChanged; virtual;
        procedure RepaintBevel; virtual;
        procedure Paint; override; 
        function GetBevelColor: TColor; virtual;
        procedure DoShow; override;
        procedure AdjustClientRect(var Rect: TRect); override;
        property OnChange: TNotifyEvent read FOnChange write FOnChange;
    public
        constructor CreateNew(AOwner: TComponent; Num: Integer = 0); override;
        destructor Destroy; override;
        procedure Initialize; virtual;
        procedure DropDown(ACaller: TControl; AAlignment: TAlignment; ALayout: TTextLayout; AOrientation: TvqOrientation = vqHorizontal); virtual; overload;
        procedure DropDown(ACaller: TControl; X, Y: Integer); virtual; overload;
        procedure Popup(X, Y: Integer; AAlignment: TAlignment = taLeftJustify; ALayout: TTextLayout = tlTop); virtual;
        procedure Return; virtual;
        property Beveled: Boolean read FBeveled write SetBeveled;
        property OnReturn: TNotifyEvent read FOnReturn write FOnReturn;
        property FreeOnClose: Boolean read FFreeOnClose write FFreeOnClose;
        property OnPopUp: TNotifyEvent read FOnPopup write FOnPopup;
        property OnCloseUp: TNotifyEvent read FOnCloseUp write FOnCloseUp;
    end;
    
    TvqPopupMenuHelper = class helper for TPopupMenu
        procedure DropDown(ACaller: TControl; AAlignment: TAlignment; ALayout: TTextLayout; AOrientation: TvqOrientation = vqHorizontal); overload;
        procedure DropDown(ACaller: TControl; X, Y: Integer); overload;
    end;
    
    TvqCustomDialog = class(TExtCommonDialog)
    private
        FCaption: TCaption;
    protected
        function DialogFormClass: TCustomFormClass; virtual;
        procedure InitializeDialog; virtual;
        procedure OnMessageFormShow(Sender: TObject);
        procedure OnMessageFormClose(Sender: TObject; var CloseAction: TCloseAction);
        procedure OnMessageFormCloseQuery(Sender: TObject; var CanClose: Boolean);
    public
        function Execute: Boolean; override;
        
        property Caption: TCaption read FCaption write FCaption;
    end;
    
