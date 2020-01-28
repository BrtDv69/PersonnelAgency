object frmDM: TfrmDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Left = 267
  Top = 288
  Height = 213
  Width = 259
  object dbMain: TpFIBDatabase
    DBName = 'C:\ALBERT\PersonnelAgency\DATA.FDB'
    DBParams.Strings = (
      'user_name=BERT'
      'password=~69Crack'
      'lc_ctype=WIN1251')
    SQLDialect = 3
    Timeout = 0
    DesignDBOptions = []
    LibraryName = 'fbclient.dll'
    WaitForRestoreConnect = 10000
    Left = 24
    Top = 8
  end
  object cxStyleRepository: TcxStyleRepository
    Left = 32
    Top = 104
    object stHeader: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      TextColor = clWindowText
    end
    object stPreview: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 14737632
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      TextColor = 7303023
    end
    object cxIncSearch: TcxStyle
      AssignedValues = [svColor, svTextColor]
      Color = clHighlightText
      TextColor = clWindowText
    end
    object cxGridTableViewStyleSheet1: TcxGridTableViewStyleSheet
      Styles.IncSearch = cxIncSearch
      Styles.Header = stHeader
      Styles.Preview = stPreview
      BuiltIn = True
    end
  end
  object cxLookAndFeelController: TcxLookAndFeelController
    Kind = lfFlat
    NativeStyle = True
    Left = 136
    Top = 112
  end
  object trReport: TpFIBTransaction
    DefaultDatabase = dbMain
    TimeoutAction = TACommit
    TRParams.Strings = (
      'read'
      'read_committed'
      'rec_version'
      'nowait')
    TPBMode = tpbDefault
    Left = 133
    Top = 8
  end
  object frDesigner1: TfrDesigner
    Left = 188
    Top = 7
  end
  object ErrorHandler: TpFibErrorHandler
    Left = 80
    Top = 8
  end
end
