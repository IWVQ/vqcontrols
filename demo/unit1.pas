unit Unit1;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ComCtrls,
    StdCtrls, ExtCtrls, Buttons, vqControlBar, vqToolBar, vqPageControl,
    vqDivider, vqQuickButton, vqArrow, vqButtons, vqToolButton, vqColorButton,
    vqFontButton, vqSwitch, vqSlider, vqDial, vqMarkLabel, vqNotifier,
    vqLedLabel, vqMenuBox, vqAnimate, vqToolPanel, vqListBox, Types, vqMDMarker;

type

    { TForm1 }

    TForm1 = class(TForm)
        Bevel1: TBevel;
        Bevel2: TBevel;
        Bevel3: TBevel;
        Bevel4: TBevel;
        Button1: TButton;
        Button2: TButton;
        Button3: TButton;
        Button4: TButton;
        Button5: TButton;
        Button6: TButton;
        Button7: TButton;
        Button8: TButton;
        ColorDialog1: TColorDialog;
        ComboBox1: TComboBox;
        Edit1: TEdit;
        Edit2: TEdit;
        FontDialog1: TFontDialog;
        ImageList1: TImageList;
        ImageList2: TImageList;
        Label1: TLabel;
        Label3: TLabel;
        MainMenu1: TMainMenu;
        MenuItem1: TMenuItem;
        MenuItem10: TMenuItem;
        MenuItem11: TMenuItem;
        MenuItem12: TMenuItem;
        MenuItem13: TMenuItem;
        MenuItem14: TMenuItem;
        MenuItem15: TMenuItem;
        MenuItem16: TMenuItem;
        MenuItem17: TMenuItem;
        MenuItem18: TMenuItem;
        MenuItem19: TMenuItem;
        MenuItem2: TMenuItem;
        MenuItem20: TMenuItem;
        MenuItem21: TMenuItem;
        MenuItem22: TMenuItem;
        MenuItem23: TMenuItem;
        MenuItem24: TMenuItem;
        MenuItem25: TMenuItem;
        MenuItem26: TMenuItem;
        MenuItem27: TMenuItem;
        MenuItem28: TMenuItem;
        MenuItem29: TMenuItem;
        MenuItem3: TMenuItem;
        MenuItem30: TMenuItem;
        MenuItem31: TMenuItem;
        MenuItem4: TMenuItem;
        MenuItem5: TMenuItem;
        MenuItem6: TMenuItem;
        MenuItem7: TMenuItem;
        MenuItem8: TMenuItem;
        MenuItem9: TMenuItem;
        OpenDialog1: TOpenDialog;
        PageControl1: TPageControl;
        Panel1: TPanel;
        Panel2: TPanel;
        PopupMenu1: TPopupMenu;
        PopupMenu2: TPopupMenu;
        PopupMenu3: TPopupMenu;
        TabSheet1: TTabSheet;
        TabSheet2: TTabSheet;
        TabSheet3: TTabSheet;
        TabSheet4: TTabSheet;
        Timer1: TTimer;
        ToolButton1: TToolButton;
        ToolButton10: TToolButton;
        ToolButton11: TToolButton;
        ToolButton12: TToolButton;
        ToolButton13: TToolButton;
        ToolButton14: TToolButton;
        ToolButton15: TToolButton;
        ToolButton16: TToolButton;
        ToolButton17: TToolButton;
        ToolButton18: TToolButton;
        ToolButton19: TToolButton;
        ToolButton2: TToolButton;
        ToolButton20: TToolButton;
        ToolButton21: TToolButton;
        ToolButton22: TToolButton;
        ToolButton23: TToolButton;
        ToolButton24: TToolButton;
        ToolButton25: TToolButton;
        ToolButton26: TToolButton;
        ToolButton27: TToolButton;
        ToolButton28: TToolButton;
        ToolButton3: TToolButton;
        ToolButton4: TToolButton;
        ToolButton5: TToolButton;
        ToolButton6: TToolButton;
        ToolButton7: TToolButton;
        ToolButton8: TToolButton;
        ToolButton9: TToolButton;
        vqAnimate1: TvqAnimate;
        vqArrow1: TvqArrow;
        vqArrow2: TvqArrow;
        vqButton1: TvqButton;
        vqButton2: TvqButton;
        vqButton3: TvqButton;
        vqColorButton1: TvqColorButton;
        vqControlBar1: TvqControlBar;
        vqDial1: TvqDial;
        vqDivider1: TvqDivider;
        vqFontButton1: TvqFontButton;
        vqLedLabel1: TvqLedLabel;
        vqLedLabel2: TvqLedLabel;
        vqListBox1: TvqListBox;
        vqMarkLabel1: TvqMarkLabel;
        vqMenuBox1: TvqMenuBox;
        vqNotifier1: TvqNotifier;
        vqPageControl1: TvqPageControl;
        vqQuickButton1: TvqQuickButton;
        vqQuickButton10: TvqQuickButton;
        vqQuickButton11: TvqQuickButton;
        vqQuickButton12: TvqQuickButton;
        vqQuickButton13: TvqQuickButton;
        vqQuickButton14: TvqQuickButton;
        vqQuickButton2: TvqQuickButton;
        vqQuickButton3: TvqQuickButton;
        vqQuickButton4: TvqQuickButton;
        vqQuickButton5: TvqQuickButton;
        vqQuickButton6: TvqQuickButton;
        vqQuickButton7: TvqQuickButton;
        vqQuickButton8: TvqQuickButton;
        vqQuickButton9: TvqQuickButton;
        vqSlider1: TvqSlider;
        vqSwitch1: TvqSwitch;
        vqToolBar1: TvqToolBar;
        vqToolBar2: TvqToolBar;
        vqToolBar3: TvqToolBar;
        vqToolBar4: TvqToolBar;
        vqToolBar5: TvqToolBar;
        vqToolBar6: TvqToolBar;
        vqToolButton1: TvqToolButton;
        vqToolButton2: TvqToolButton;
        vqToolButton3: TvqToolButton;
        vqToolPanel1: TvqToolPanel;
        vqToolPanel2: TvqToolPanel;
        vqToolPanel3: TvqToolPanel;
        vqToolPanel4: TvqToolPanel;
        procedure Button1Click(Sender: TObject);
        procedure Button2Click(Sender: TObject);
        procedure Button3Click(Sender: TObject);
        procedure Button4Click(Sender: TObject);
        procedure Button5Click(Sender: TObject);
        procedure Button6Click(Sender: TObject);
        procedure Button7Click(Sender: TObject);
        procedure Button8Click(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure MenuItem18Click(Sender: TObject);
        procedure MenuItem20Click(Sender: TObject);
        procedure MenuItem25Click(Sender: TObject);
        procedure MenuItem30Click(Sender: TObject);
        procedure MenuItem31Click(Sender: TObject);
        procedure TabSheet1ContextPopup(Sender: TObject; MousePos: TPoint;
            var Handled: Boolean);
        procedure Timer1Timer(Sender: TObject);
        procedure vqMarkLabel1Hyperlink(Sender: TObject; ALabel, AAddress,
            AHint: string; AIndex: Integer; var Opened: Boolean);
        procedure vqNotifier1CloseBtnClick(Sender: TObject);
        procedure vqPageControl1AddBtnClick(Sender: TObject);
        procedure vqPageControl1CloseBtnClick(Sender: TObject;
            APage: TvqPageSheet);
        procedure vqQuickButton2Click(Sender: TObject);
        procedure vqSwitch1Change(Sender: TObject);
        procedure vqToolBar1Resize(Sender: TObject);
    private

    public

    end;

var
    Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }


procedure TForm1.FormCreate(Sender: TObject);
begin
    vqDivider1.Spacing := 3;
    vqMenuBox1.BorderStyle := bsSingle;
    // vqListBox1.BorderStyle := bsSingle;

    vqToolPanel1.LaunchButton.Visible := False;
    vqToolPanel2.LaunchButton.Kind := vqqbkArrowBottom;
    vqToolPanel3.LaunchButton.Kind := vqqbkArrowBottom;
    vqToolPanel4.LaunchButton.Visible := False;

    vqMenuBox1.MenuImages := ImageList2;
    vqMenuBox1.Assign(PopupMenu3);

    vqListBox1.ScrollBars := ssVertical;

    vqNotifier1.KindImage[vqnkCustom     ] := 1;
    vqNotifier1.KindImage[vqnkWarning    ] := 5;
    vqNotifier1.KindImage[vqnkError      ] := 0;
    vqNotifier1.KindImage[vqnkInformation] := 2;
    vqNotifier1.KindImage[vqnkShield     ] := 4;
    vqNotifier1.KindImage[vqnkQuestion   ] := 3;
end;

procedure TForm1.MenuItem18Click(Sender: TObject);
begin
    ShowMessage('hi');
end;

procedure TForm1.MenuItem20Click(Sender: TObject);
begin
    ShowMessage('clicked');
end;

procedure TForm1.MenuItem25Click(Sender: TObject);
begin
    ShowMessage('demo for VQControls');
end;

procedure TForm1.MenuItem30Click(Sender: TObject);
begin
    ShowMessage('resize and click the controls...');
end;

procedure TForm1.MenuItem31Click(Sender: TObject);
begin
    Close;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
    if vqNotifier1.Showing then
        vqNotifier1.Hide
    else
        vqNotifier1.ShowMessage(vqnkError, 'This is an _error_ notification');
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
    if OpenDialog1.Execute then begin
        vqAnimate1.Animation.LoadFromFile(OpenDialog1.FileName);
        vqAnimate1.Active := True;
    end;
end;

var
    RunLedStep: Integer = 0;

procedure TForm1.Button3Click(Sender: TObject);
begin
    RunLedStep := 0;
    Timer1.Enabled := True;
end;

var
    ListAddCounter: Integer = 0;

procedure TForm1.Button4Click(Sender: TObject);
var
    I: Integer;
begin
    // add list item
    I := vqListBox1.Lines.Add('List element N°' + IntToStr(ListAddCounter) + '--');
    vqListBox1.Items[I].ImageIndex := ListAddCounter mod 6;
    Inc(ListAddCounter);
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
    // delete list item
    vqListBox1.DeleteSelected;
end;

var
    PageNew: TvqPageSheet;
    Editor: TMemo;
    PageCounter: Integer = 0;

procedure TForm1.Button6Click(Sender: TObject);
begin
    // insert page at start
    PageNew := TvqPageSheet.Create(Self);
    PageNew.Caption := 'page N°' + IntToStr(PageCounter);
    PageNew.ImageIndex := PageCounter mod 6;
    Inc(PageCounter);
    vqPageControl1.InsertPage(PageNew, 0);
    Editor := TMemo.Create(Self);
    Editor.Parent := PageNew;
    Editor.SetBounds(10, 10, 200, 100);
    Editor.Font.Name := 'Courier New';
    Editor.Font.Size := 9;
end;

procedure TForm1.Button7Click(Sender: TObject);
var
    APage: TvqPageSheet;
begin
    // remove page at start
    APage := vqPageControl1.RemovePage(0);
    APage.Free;
end;

procedure TForm1.Button8Click(Sender: TObject);  
var
    APage: TvqPageSheet;
begin
    // move selected page to start
    APage := vqPageControl1.ActivePage;
    if APage <> nil then APage.Index := 0;
end;
       
procedure TForm1.Timer1Timer(Sender: TObject);
begin
    vqLedLabel2.SetIntegerLeds(RunLedStep);
    vqLedLabel2.Repaint;
    Inc(RunLedStep);
    if RunLedStep = 1000 then begin
        RunLedStep := 0;
        Timer1.Enabled := False;
    end;
end;

procedure TForm1.TabSheet1ContextPopup(Sender: TObject; MousePos: TPoint;
    var Handled: Boolean);
begin

end;

procedure TForm1.vqMarkLabel1Hyperlink(Sender: TObject; ALabel, AAddress,
    AHint: string; AIndex: Integer; var Opened: Boolean);
begin

end;

procedure TForm1.vqNotifier1CloseBtnClick(Sender: TObject);
begin
    vqNotifier1.Hide;
end;

procedure TForm1.vqPageControl1AddBtnClick(Sender: TObject);
var
    APage: TvqPageSheet;
begin
    APage := vqPageControl1.AddPage(True);
    APage.Caption := 'added page';
end;

procedure TForm1.vqPageControl1CloseBtnClick(Sender: TObject;
    APage: TvqPageSheet);
begin
    vqPageControl1.ClosePage(APage.Index);
end;

procedure TForm1.vqQuickButton2Click(Sender: TObject);
begin
    if vqMenuBox1.Current.Parent <> nil then
        vqMenuBox1.Current := vqMenuBox1.Current.Parent;
end;

procedure TForm1.vqSwitch1Change(Sender: TObject);
begin
    if vqSwitch1.Checked then
        vqSwitch1.Caption := 'On'
    else
        vqSwitch1.Caption := 'Off';
end;

var
    OriginalUnfoldWidth: Integer = 300;

procedure TForm1.vqToolBar1Resize(Sender: TObject);
var             
    Area: TRect;
    NewWidth: Integer;
    RibbonMaxWidth: Integer;
begin         
    Area := vqToolBar1.ClientRect;
    Inc(Area.Left, vqToolBar1.Indent);

    RibbonMaxWidth := 0;
    Inc(RibbonMaxWidth, vqToolPanel1.Width);
    Inc(RibbonMaxWidth, ToolButton13.Width);
    Inc(RibbonMaxWidth, OriginalUnfoldWidth); 
    Inc(RibbonMaxWidth, ToolButton14.Width);
    Inc(RibbonMaxWidth, vqToolPanel3.Width); 
    Inc(RibbonMaxWidth, ToolButton15.Width);
    Inc(RibbonMaxWidth, vqToolPanel4.Width);

    if RibbonMaxWidth > Area.Width then begin
           NewWidth := OriginalUnfoldWidth - (RibbonMaxWidth - Area.Width);
           if NewWidth > OriginalUnfoldWidth then
               NewWidth := OriginalUnfoldWidth;
           if NewWidth < 60 then NewWidth := 60;
           if NewWidth < 100 then begin
               NewWidth := 60;
               vqToolPanel2.Width := NewWidth;
               vqToolPanel2.Folded := True;
           end
           else begin
               vqToolPanel2.Width := NewWidth;
               vqToolPanel2.Folded := False;
           end;
    end
    else begin
           vqToolPanel2.Width := OriginalUnfoldWidth;
           vqToolPanel2.Folded := False;
           //
           //
    end;
end;

end.

