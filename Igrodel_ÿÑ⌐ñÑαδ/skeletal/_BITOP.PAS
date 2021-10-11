{Source from SWAG}
unit _BITOP;

interface

Procedure SetBit(Var Number : Byte; Bit : Byte);
Procedure ClearBit(Var Number : Byte; Bit : Byte);
Function ReadBit(Number, Bit : Byte) : Boolean;


implementation

Procedure SetBit(Var Number : Byte; Bit : Byte);

 Begin
  Number := Number OR (1 SHL Bit);
 End;

Procedure ClearBit(Var Number : Byte; Bit : Byte);

 Begin
  Number := Number AND NOT (1 SHL Bit);
 End;

Function ReadBit(Number, Bit : Byte) : Boolean;

 Begin
  ReadBit := (Number AND (1 SHL Bit)) <> 0;
 End;
end.