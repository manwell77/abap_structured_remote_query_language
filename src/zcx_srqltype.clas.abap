class ZCX_SRQLTYPE definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

public section.

  interfaces IF_T100_MESSAGE .

  constants:
    begin of ZCX_SRQLTYPE_COMPONENTS,
      msgid type symsgid value 'ZSRQL',
      msgno type symsgno value '011',
      attr1 type scx_attrname value 'STRUCTURE',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_SRQLTYPE_COMPONENTS .
  constants:
    begin of ZCX_SRQLTYPE,
      msgid type symsgid value 'ZSRQL',
      msgno type symsgno value '000',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_SRQLTYPE .
  constants:
    begin of ZCX_SRQLTYPE_KIND,
      msgid type symsgid value 'ZSRQL',
      msgno type symsgno value '009',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_SRQLTYPE_KIND .
  constants:
    begin of ZCX_SRQLTYPE_NAME,
      msgid type symsgid value 'ZSRQL',
      msgno type symsgno value '010',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_SRQLTYPE_NAME .
  constants:
    begin of ZCX_SRQLTYPE_DESCRIPTOR,
      msgid type symsgid value 'ZSRQL',
      msgno type symsgno value '012',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_SRQLTYPE_DESCRIPTOR .
  constants:
    begin of ZCX_SRQLTYPE_DATA,
      msgid type symsgid value 'ZSRQL',
      msgno type symsgno value '013',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_SRQLTYPE_DATA .
  constants:
    begin of ZCX_SRQLTYPE_ELEMENT,
      msgid type symsgid value 'ZSRQL',
      msgno type symsgno value '014',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_SRQLTYPE_ELEMENT .
  constants:
    begin of ZCX_SRQLTYPE_FIELD,
      msgid type symsgid value 'ZSRQL',
      msgno type symsgno value '016',
      attr1 type scx_attrname value 'FIELDNAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_SRQLTYPE_FIELD .
  constants:
    begin of ZCX_SRQLTYPE_FIELD_MOVE,
      msgid type symsgid value 'ZSRQL',
      msgno type symsgno value '017',
      attr1 type scx_attrname value 'FIELDNAME',
      attr2 type scx_attrname value 'FIELDTO',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_SRQLTYPE_FIELD_MOVE .
  data STRUCTURE type STRUKNAME .
  data FIELDNAME type FIELDNAME .
  data FIELDTO type FIELDNAME .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !STRUCTURE type STRUKNAME optional
      !FIELDNAME type FIELDNAME optional
      !FIELDTO type FIELDNAME optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_SRQLTYPE IMPLEMENTATION.


method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->STRUCTURE = STRUCTURE .
me->FIELDNAME = FIELDNAME .
me->FIELDTO = FIELDTO .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = ZCX_SRQLTYPE .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
endmethod.
ENDCLASS.
