object frmAdditional: TfrmAdditional
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Additional'
  ClientHeight = 188
  ClientWidth = 367
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object lblNodeAddr: TLabel
    Left = 15
    Top = 35
    Width = 70
    Height = 13
    Caption = 'Node address:'
  end
  object lblMask: TLabel
    Left = 215
    Top = 35
    Width = 28
    Height = 13
    Caption = 'Mask:'
  end
  object lblRDPFile: TLabel
    Left = 15
    Top = 95
    Width = 41
    Height = 13
    Caption = 'RDP file:'
  end
  object bvl1: TBevel
    Left = 0
    Top = 143
    Width = 367
    Height = 45
    Align = alBottom
    Shape = bsTopLine
    ExplicitTop = 144
  end
  object chkAddRoute: TCheckBox
    Left = 15
    Top = 11
    Width = 177
    Height = 17
    Caption = 'Add route to connection'
    TabOrder = 0
  end
  object edtNodeAddr: TEdit
    Left = 91
    Top = 32
    Width = 100
    Height = 21
    TabOrder = 1
    Text = '172.20.128.0'
  end
  object edtMask: TEdit
    Left = 249
    Top = 32
    Width = 100
    Height = 21
    TabOrder = 2
    Text = '255.255.240.0'
  end
  object chkRDPConnect: TCheckBox
    Left = 15
    Top = 71
    Width = 168
    Height = 17
    Caption = 'Connect to remote computer'
    TabOrder = 3
  end
  object edtRDPFile: TEdit
    Left = 62
    Top = 92
    Width = 262
    Height = 21
    TabOrder = 4
    Text = 'E:\Documents\rdp\stoi.rdp'
  end
  object btnSelectRDP: TButton
    Left = 324
    Top = 92
    Width = 25
    Height = 21
    Caption = '...'
    TabOrder = 5
  end
  object btn1: TButton
    Left = 274
    Top = 155
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 6
  end
  object btnCancel: TButton
    Left = 195
    Top = 155
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 7
  end
end
