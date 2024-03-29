inherited CustomDialogForm: TCustomDialogForm
  Caption = 'CustomDialogForm'
  ClientHeight = 515
  OnCreate = FormCreate
  ExplicitHeight = 544
  PixelsPerInch = 96
  TextHeight = 13
  object TopPanel: TPanel
    Left = 0
    Top = 0
    Width = 335
    Height = 25
    Align = alTop
    Alignment = taLeftJustify
    BevelOuter = bvNone
    Caption = 'TopPanel'
    ParentBackground = False
    TabOrder = 0
    OnMouseDown = TopPanelMouseDown
  end
  object OkPanel: TPanel
    Left = 156
    Top = 456
    Width = 75
    Height = 20
    Caption = 'OK'
    ParentBackground = False
    TabOrder = 1
    Visible = False
    OnClick = OkPanelClick
    OnMouseEnter = OkPanelMouseEnter
    OnMouseLeave = OkPanelMouseLeave
  end
  object CancelPanel: TPanel
    Left = 237
    Top = 456
    Width = 75
    Height = 20
    Caption = #1054#1090#1084#1077#1085#1072
    ParentBackground = False
    TabOrder = 2
    Visible = False
    OnClick = CancelPanelClick
    OnMouseEnter = OkPanelMouseEnter
    OnMouseLeave = OkPanelMouseLeave
  end
  object CancelBtn: TBitBtn
    Left = 237
    Top = 479
    Width = 75
    Height = 25
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    Glyph.Data = {
      36030000424D3603000000000000360000002800000010000000100000000100
      18000000000000030000C40E0000C40E00000000000000000000FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE5E5EF9393BA5959963B
      3B823B3B825959969393BAE5E5EFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFB2B2D44141972323A81717C61313D41313D41717C62323A8414197B2B2
      D4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFB2B2D835359F1A1AC61212B61111D111
      11D11111D11111D11111B61717C434349FB2B2D8FFFFFFFFFFFFFFFFFFE5E5F3
      4242A72020C31212B2DCDCDC1111B21111C81111C81111B2EEEEEE1111B21717
      BE4141A7E5E5F3FFFFFFFFFFFF9393CD3030B41616C1D1D1D1D6D6D6DCDCDC11
      11AD1111ADEAEAEAEEEEEEEEEEEE1111BE2424AB9393CDFFFFFFFFFFFF5858B4
      3636C21212B41111B4D1D1D1D6D6D6DCDCDCE2E2E2E6E6E6EAEAEA1111B41111
      B41B1BB25858B4FFFFFFFFFFFF3B3BAB4545CD2626B51414AB1111AAD1D1D1D6
      D6D6DCDCDCE2E2E21111AA1111AA1111AA1A1AB03B3BABFFFFFFFFFFFF3B3BAE
      4A4AD13333BB2E2EB813139FCECECED1D1D1D6D6D6DCDCDC11119E1111A11111
      A11F1FAD3B3BAEFFFFFFFFFFFF5858BD4E4ED53737BF2323ABFFFFFFF7F7F7E8
      E8E8DEDEDEDBDBDBDDDDDD11119B1616A02F2FB75858BDFFFFFFFFFFFF9393D6
      4949CC4949D1FFFFFFFFFFFFFFFFFF4242CA4242CAFFFFFFFFFFFFFFFFFF4747
      CF4141C49393D6FFFFFFFFFFFFE5E5F54646BE5C5CE35151D9FFFFFF4F4FD74F
      4FD74F4FD74F4FD7FFFFFF5050D85555DD4545BDE5E5F5FFFFFFFFFFFFFFFFFF
      B2B2E43F3FC06161E95F5FE75B5BE35B5BE35B5BE35B5BE35F5FE75E5EE53E3E
      BFB2B2E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFB2B2E54747C24D4DD56262EB6B
      6BF36A6AF26161EA4C4CD44747C2B2B2E5FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFE5E5F69393DB5959C83B3BBE3B3BBE5959C89393DBE5E5F6FFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
    ModalResult = 2
    TabOrder = 3
  end
  object OkBtn: TBitBtn
    Left = 156
    Top = 479
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    Glyph.Data = {
      36030000424D3603000000000000360000002800000010000000100000000100
      18000000000000030000C40E0000C40E00000000000000000000FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFB8D2B7357F33C8DCC7FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFB9D8B7398E332BAE2041
      963CD7E9D6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFBADCB73C9B3333C32524CD132BBB1D4DA445E5F2E4FFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBBDDB73D9F334ACC3A29C31839CC2828
      C21731B1235AAD51F0F8EFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBBDFB7
      3EA43363DA5333BC2255D1453EA43334B6252CB81B36AC286AB861F7FBF7FFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFF3FA83370E65F59D0486BE15A3FA83398D09243
      AB373AB62932B2213BAB2D7BC373FDFEFDFFFFFFFFFFFFFFFFFFFFFFFFBCE1B7
      41AC3374EA6341AC33BCE1B7FFFFFFB8E0B340AE3340B72F38AF2740AE318CCD
      84FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBCE3B741AF33BCE3B7FFFFFFFFFFFFFF
      FFFF9DD69645B73758CF4756CD4545B536A3D99CFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFE84CD7A4DC13D61D8505FD6
      4F46B737B9E3B3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFF9FDF96DC66156CC466BE25A72E96243B533FFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0F9EF5DC24F77EE
      6643B933BDE6B7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFE3F5E044BB33BDE7B7FFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
    ModalResult = 1
    TabOrder = 4
  end
end
