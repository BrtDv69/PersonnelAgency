object frmExportOptions: TfrmExportOptions
  Left = 348
  Top = 157
  BorderStyle = bsToolWindow
  Caption = #1069#1082#1089#1087#1086#1088#1090
  ClientHeight = 71
  ClientWidth = 204
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object cbExportSelections: TcxCheckBox
    Left = -1
    Top = -1
    Width = 208
    Height = 21
    Hint = #1069#1082#1089#1087#1086#1088#1090' '#1074#1089#1077#1093' '#1089#1090#1088#1086#1082' '#1080#1083#1080' '#1090#1086#1083#1100#1082#1086' '#1074#1099#1076#1077#1083#1077#1085#1085#1099#1093
    Properties.DisplayUnchecked = 'False'
    Properties.Caption = #1069#1082#1089#1087#1086#1088#1090' '#1090#1086#1083#1100#1082#1086' '#1074#1099#1076#1077#1083#1077#1085#1085#1099#1093' '#1089#1090#1088#1086#1082
    Style.LookAndFeel.Kind = lfUltraFlat
    Style.LookAndFeel.NativeStyle = False
    Style.Shadow = False
    TabOrder = 0
  end
  object cbExportExpand: TcxCheckBox
    Left = -1
    Top = 19
    Width = 147
    Height = 21
    Hint = #1056#1072#1079#1074#1086#1088#1072#1095#1080#1074#1072#1090#1100' '#1083#1080' '#1087#1088#1080' '#1101#1082#1089#1087#1086#1088#1090#1077' '#1075#1088#1091#1087#1087#1099
    Properties.DisplayUnchecked = 'False'
    Properties.Caption = #1056#1072#1079#1074#1086#1088#1072#1095#1080#1074#1072#1090#1100' '#1075#1088#1091#1087#1087#1099
    Style.LookAndFeel.Kind = lfUltraFlat
    Style.LookAndFeel.NativeStyle = False
    Style.Shadow = False
    TabOrder = 1
  end
  object btnExport: TcxButton
    Left = 25
    Top = 42
    Width = 75
    Height = 25
    Cursor = crHandPoint
    Caption = #1069#1082#1089#1087#1086#1088#1090
    Default = True
    TabOrder = 2
    OnClick = btnExportClick
    LookAndFeel.Kind = lfUltraFlat
    LookAndFeel.NativeStyle = False
    UseSystemPaint = False
  end
  object btnClose: TcxButton
    Left = 105
    Top = 42
    Width = 75
    Height = 25
    Cursor = crHandPoint
    Cancel = True
    Caption = #1047#1072#1082#1088#1099#1090#1100
    ModalResult = 1
    TabOrder = 3
    LookAndFeel.Kind = lfUltraFlat
    LookAndFeel.NativeStyle = False
    UseSystemPaint = False
  end
  object svd: TSaveDialog
    DefaultExt = 'xls'
    Filter = 
      #1060#1072#1081#1083#1099' Excel (*.xls)|*.xls|'#1042#1077#1073'-'#1089#1090#1088#1072#1085#1080#1094#1072' (*.html)|*.html|'#1058#1077#1082#1089#1090#1086#1074#1099#1081 +
      ' '#1092#1072#1081#1083' (*.txt)|*.txt|'#1058#1072#1073#1083#1080#1094#1072' XML (*.xml)|*.xml'
    Options = [ofOverwritePrompt, ofPathMustExist, ofEnableSizing]
    Title = #1042#1099#1073#1086#1088' '#1080#1084#1077#1085#1080' '#1092#1072#1081#1083#1072' '#1101#1082#1089#1087#1086#1088#1090#1072
    OnTypeChange = svdTypeChange
    Left = 152
    Top = 32
  end
end
