//---------------------------------------------------------------------------

// This software is Copyright (c) 2015 Embarcadero Technologies, Inc.
// You may only use this software if you are an authorized licensee
// of an Embarcadero developer tools product.
// This software is considered a Redistributable as defined under
// the software license agreement that comes with the Embarcadero Products
// and is subject to that software license agreement.

//---------------------------------------------------------------------------

unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Platform,
  System.Notification, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo,
  FMX.Edit, FMX.EditBox, FMX.SpinBox;

type
  TNotificationsForm = class(TForm)
    ToolBar1: TToolBar;
    Label1: TLabel;
    ToolBar2: TToolBar;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    NotificationC: TNotificationCenter;
    mmo1: TMemo;
    btnGetRemainingNotifications: TButton;
    pnl1: TPanel;
    spnbx1: TSpinBox;
    btnSendMultipleNotifications: TButton;
    procedure btnSendScheduledNotificationClick(Sender: TObject);
    procedure btnSendMultipleNotificationsClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure NotificationCReceiveLocalNotification(Sender: TObject;
      ANotification: TNotification);
    procedure btnGetRemainingNotificationsClick(Sender: TObject);
    procedure Label1Tap(Sender: TObject; const Point: TPointF);
  private
    { Private declarations }


    procedure getScheduledNotifications;

  public
    { Public declarations }
  end;

var
  NotificationsForm: TNotificationsForm;
  Ones: array[0..9] of string = ('Zero', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine');

implementation
{$IFDEF ANDROID}uses System.Android.Notification; {$ENDIF}

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}

procedure TNotificationsForm.btnGetRemainingNotificationsClick(Sender: TObject);
begin
  getScheduledNotifications;
end;

procedure TNotificationsForm.btnSendMultipleNotificationsClick(
  Sender: TObject);

  procedure MyNotificationCreate(aNotificationName : string; aSecondDelay : Word) ;
  var
    Notification: TNotification;
  begin
    if (aSecondDelay < 0) or (aSecondDelay > 60) then
      raise Exception.Create('Seconds must be between 0 and 60');
    { verify if the service is actually supported }
    Notification := NotificationC.CreateNotification;
    try
      Notification.Name := aNotificationName;
      Notification.AlertBody := aNotificationName + ' ran after ' + inttostr(aSecondDelay) + ' seconds';

      { Fired in 10 second }
      Notification.FireDate := Now + EncodeTime(0,0,aSecondDelay,0);

      { Send notification in Notification Center }
      NotificationC.ScheduleNotification(Notification);
    finally
      Notification.DisposeOf;
    end;
  end;
var i, max : integer;

begin
  max := spnbx1.value.ToString.ToInteger;
  for I := 1 to max do begin
    MyNotificationCreate(Ones[i] , i*5);
  end;

  getScheduledNotifications;
end;

procedure TNotificationsForm.btnSendScheduledNotificationClick(Sender: TObject);
var
  Notification: TNotification;
begin

{ verify if the service is actually supported }
  Notification := NotificationC.CreateNotification;
  try
    Notification.Name := 'MyNotification';
    Notification.AlertBody := 'Delphi for Mobile is here!';

    { Fired in 10 second }
    Notification.FireDate := Now + EncodeTime(0,0,10,0);

    { Send notification in Notification Center }
    NotificationC.ScheduleNotification(Notification);
  finally
    Notification.DisposeOf;
  end;
end;

procedure TNotificationsForm.getScheduledNotifications;
var FExternalStore: TAndroidPreferenceAdapter;
    sTempStr : String;
    sl : TStringList;
begin


  mmo1.Lines.Add( '/\/\/\/\/\' );
  FExternalStore := TAndroidPreferenceAdapter.Create;
  try
    sl := FExternalStore.GetAllNotificationsNamesNonFiltered;
    try
      sTempStr := sl.Text;
    finally
      sl.Free;
    end;
    //sTempStr := FExternalStore.GetAllNotificationsNamesJStringToString;
    sTempStr := StringReplace(sTempStr, #13, '#13', [rfReplaceAll, rfIgnoreCase]);
    sTempStr := StringReplace(sTempStr, #10, '#10', [rfReplaceAll, rfIgnoreCase]);
    mmo1.Lines.Add( sTempStr );
  finally
    FExternalStore.Free;
  end;
end;

procedure TNotificationsForm.Label1Tap(Sender: TObject; const Point: TPointF);
begin
  mmo1.Lines.Clear;
end;

procedure TNotificationsForm.NotificationCReceiveLocalNotification(
  Sender: TObject; ANotification: TNotification);
begin
  showmessage('test');
  //getScheduledNotifications;

end;

procedure TNotificationsForm.SpeedButton1Click(Sender: TObject);
begin
    { providing the fact that you already have a MyNotification previously issued }
  NotificationC.CancelNotification('Three');
end;

procedure TNotificationsForm.SpeedButton2Click(Sender: TObject);
begin
  NotificationC.CancelAll;
end;

end.
