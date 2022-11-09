inherited pr: Tpr
  Caption = #1055#1088#1086#1083#1080#1074#1082#1072
  ClientWidth = 780
  OnCreate = FormCreate
  ExplicitWidth = 796
  PixelsPerInch = 96
  TextHeight = 13
  object pr: TPanel
    Tag = 1
    Left = 0
    Top = 25
    Width = 780
    Height = 177
    Align = alClient
    BevelOuter = bvNone
    Caption = 'pr'
    TabOrder = 0
    object LogBox: TListBox
      Left = 0
      Top = 0
      Width = 780
      Height = 177
      Style = lbOwnerDrawFixed
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = []
      ItemHeight = 13
      ParentFont = False
      PopupMenu = LogPopupMenu
      TabOrder = 0
      OnDblClick = LogBoxDblClick
      OnDrawItem = LogBoxDrawItem
      ExplicitTop = 6
    end
  end
  object ResultLabel: TPanel
    Left = 0
    Top = 0
    Width = 780
    Height = 25
    Align = alTop
    Alignment = taLeftJustify
    BevelOuter = bvNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 1
  end
  object ActionManager1: TActionManager
    ActionBars = <
      item
      end>
    Left = 296
    Top = 72
    StyleName = 'Platform Default'
    object CopyLogAction: TAction
      Caption = #1050#1086#1087#1080#1088#1086#1074#1072#1090#1100' '#1074' '#1073#1091#1092#1077#1088' '#1086#1073#1084#1077#1085#1072
      Hint = #1050#1086#1087#1080#1088#1086#1074#1072#1090#1100' '#1074' '#1073#1091#1092#1077#1088' '#1086#1073#1084#1077#1085#1072
      ImageIndex = 13
    end
  end
  object LogPopupMenu: TPopupMenu
    Left = 544
    Top = 74
    object N1: TMenuItem
      Caption = #1055#1088#1086#1083#1080#1090#1100' '#1089#1082#1088#1080#1087#1090
      Hint = #1055#1088#1086#1083#1080#1090#1100' '#1089#1082#1088#1080#1087#1090
      ImageIndex = 2
    end
    object N2: TMenuItem
      Caption = #1054#1090#1082#1088#1099#1090#1100' t01'
      Hint = #1054#1090#1082#1088#1099#1090#1100' t01'
      ImageIndex = 0
    end
    object N3: TMenuItem
      Caption = #1054#1090#1082#1088#1099#1090#1100' '#1087#1072#1087#1082#1091' '#1080#1085#1089#1090#1072#1083#1083#1103#1090#1086#1088#1072
      Hint = #1054#1090#1082#1088#1099#1090#1100' '#1087#1072#1087#1082#1091' '#1080#1085#1089#1090#1072#1083#1083#1103#1090#1086#1088#1072
      ImageIndex = 1
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object PostgreSQL1: TMenuItem
      Caption = #1050#1086#1085#1074#1077#1088#1090#1080#1088#1086#1074#1072#1090#1100' '#1074' PostgreSQL'
      ImageIndex = 14
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object N5: TMenuItem
      Action = CopyLogAction
    end
  end
end
