class ZCX_SRQLQUERY definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

public section.

  interfaces IF_T100_MESSAGE .

  constants:
    begin of ZCX_SRQLQUERY_RFC,
      msgid type symsgid value 'ZSRQL',
      msgno type symsgno value '000',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_SRQLQUERY_RFC .
  constants:
    begin of ZCX_SRQLQUERY_FIELD,
      msgid type symsgid value 'ZSRQL',
      msgno type symsgno value '001',
      attr1 type scx_attrname value 'FIELDNAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_SRQLQUERY_FIELD .
  constants:
    begin of ZCX_SRQLQUERY_NO_FIELD,
      msgid type symsgid value 'ZSRQL',
      msgno type symsgno value '002',
      attr1 type scx_attrname value 'FIELDNAME',
      attr2 type scx_attrname value 'TABLE',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_SRQLQUERY_NO_FIELD .
  constants:
    begin of ZCX_SRQLQUERY_CONJUNCTION,
      msgid type symsgid value 'ZSRQL',
      msgno type symsgno value '003',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_SRQLQUERY_CONJUNCTION .
  constants:
    begin of ZCX_SRQLQUERY_TABLE,
      msgid type symsgid value 'ZSRQL',
      msgno type symsgno value '004',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_SRQLQUERY_TABLE .
  constants:
    begin of ZCX_SRQLQUERY_EXECUTION,
      msgid type symsgid value 'ZSRQL',
      msgno type symsgno value '005',
      attr1 type scx_attrname value 'TABLE',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_SRQLQUERY_EXECUTION .
  constants:
    begin of ZCX_SRQLQUERY_STRUCTURE,
      msgid type symsgid value 'ZSRQL',
      msgno type symsgno value '006',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_SRQLQUERY_STRUCTURE .
  constants:
    begin of ZCX_SRQLQUERY_STRUC_NO_KEY,
      msgid type symsgid value 'ZSRQL',
      msgno type symsgno value '007',
      attr1 type scx_attrname value 'STRUCTURE',
      attr2 type scx_attrname value 'TABLE',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_SRQLQUERY_STRUC_NO_KEY .
  constants:
    begin of ZCX_SRQLQUERY_RESULT,
      msgid type symsgid value 'ZSRQL',
      msgno type symsgno value '008',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_SRQLQUERY_RESULT .
  data TABLE type TABNAME .
  data STRUCTURE type FIELDNAME .
  data FIELDNAME type FIELDNAME .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !TABLE type TABNAME optional
      !STRUCTURE type FIELDNAME optional
      !FIELDNAME type FIELDNAME optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_SRQLQUERY IMPLEMENTATION.


method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->TABLE = TABLE .
me->STRUCTURE = STRUCTURE .
me->FIELDNAME = FIELDNAME .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
endmethod.
ENDCLASS.
