object MainForm: TMainForm
  Left = 0
  Top = 0
  AlphaBlend = True
  BorderIcons = [biMinimize]
  BorderStyle = bsSingle
  Caption = 'Windows 10 Health Fix'
  ClientHeight = 224
  ClientWidth = 572
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    572
    224)
  PixelsPerInch = 96
  TextHeight = 13
  object SFCButton: TButton
    Left = 8
    Top = 191
    Width = 121
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'SFC /ScanNow'
    TabOrder = 0
    OnClick = SFCButtonClick
  end
  object DISMButton: TButton
    Left = 192
    Top = 191
    Width = 232
    Height = 25
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'DISM /Online /Cleanup-Image /RestoreHealth'
    TabOrder = 1
    OnClick = DISMButtonClick
  end
  object LogMemo: TMemo
    Left = 8
    Top = 8
    Width = 556
    Height = 177
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      
        'Welcome to Windows 10 Health Fix software (written in Delphi 10.' +
        '2 Tokyo)...')
    TabOrder = 2
  end
  object CloseButton: TButton
    Left = 489
    Top = 191
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Close'
    TabOrder = 3
    OnClick = CloseButtonClick
  end
end
