class ZCL_SRQLTYPE definition
  public
  final
  create private .

public section.

  methods GET_BUILD_DATE
    returning
      value(RESULT) type SYDATUM .
  methods GET_BUILD_TIME
    returning
      value(RESULT) type SYUZEIT .
  methods GET_DATA
    returning
      value(RESULT) type ref to DATA
    raising
      ZCX_SRQLTYPE .
  methods GET_DESCRIPTOR
    returning
      value(RESULT) type ref to CL_ABAP_DATADESCR .
  methods OFFSET_FIELDS_PURGED
    returning
      value(RESULT) type XFELD .
  class-methods NEW
    importing
      value(DESTINATION) type RFCDEST optional
      value(TYPENAME) type TYPENAME
      value(TYPEKIND) type ZSRQLTYPEKIND
      value(TYPEFIELDS) type FIELDNAME_TAB optional
      value(OFFSET_FIELDS) type XFELD default SPACE
    returning
      value(RESULT) type ref to ZCL_SRQLTYPE
    raising
      ZCX_SRQLTYPE .
protected section.
private section.

  data DESTINATION type RFCDEST .
  data TYPENAME type TYPENAME .
  data TYPEKIND type ZSRQLTYPEKIND .
  data TYPEFIELDS type FIELDNAME_TAB .
  data OFFSET_FIELDS type XFELD .
  data DESCRIPTOR type ref to CL_ABAP_DATADESCR .
  data BUILD_DATE type SYDATUM .
  data BUILD_TIME type SYUZEIT .
  constants OFFSET_FNAME_PREFIX type STRING value 'ZZOFFSET_'. "#EC NOTEXT

  methods CONSTRUCTOR
    importing
      value(DESTINATION) type RFCDEST optional
      value(TYPENAME) type TYPENAME
      value(TYPEKIND) type ZSRQLTYPEKIND
      value(TYPEFIELDS) type FIELDNAME_TAB optional
      value(OFFSET_FIELDS) type XFELD default SPACE
    raising
      ZCX_SRQLTYPE .
  methods BUILD_ELE_DESCRIPTOR
    importing
      value(ELEMENT) type TYPENAME optional
      value(INTERNAL_TYPE) type INTTYPE optional
      value(INTERNAL_LENGTH) type I optional
      value(DECIMALS) type I optional
    returning
      value(RESULT) type ref to CL_ABAP_ELEMDESCR
    raising
      ZCX_SRQLTYPE .
  methods BUILD_STR_DESCRIPTOR
    importing
      value(STRUCTURE) type TYPENAME
      value(FIELDS) type FIELDNAME_TAB optional
    returning
      value(RESULT) type ref to CL_ABAP_STRUCTDESCR
    raising
      ZCX_SRQLTYPE .
  methods BUILD_TTY_DESCRIPTOR
    importing
      value(LINE) type TYPENAME
      value(FIELDS) type FIELDNAME_TAB optional
    returning
      value(RESULT) type ref to CL_ABAP_TABLEDESCR
    raising
      ZCX_SRQLTYPE .
  type-pools ABAP .
  methods GET_TYPE_COMPONENTS
    importing
      value(STRUCTURE) type TYPENAME
      value(FIELDS) type FIELDNAME_TAB optional
    returning
      value(RESULT) type ABAP_COMPONENT_TAB
    raising
      ZCX_SRQLTYPE .
ENDCLASS.



CLASS ZCL_SRQLTYPE IMPLEMENTATION.


method build_ele_descriptor.

  data: lx_root type ref to cx_root,
        ls_dd4  type dd04v,
        lv_dty  type inttype,
        lv_dle  type i,
        lv_dcs  type i,
        lv_int2 type int2,
        lv_int1 type int1.

  try.

*     local
      if me->destination is initial. result ?= cl_abap_elemdescr=>describe_by_name( element ). return. endif.

*     remote with name
      if not element is initial.
        call function 'SRTT_GET_REMOTE_DTEL_DEF' destination me->destination exporting iv_dtel_name = element importing ev_dd04v = ls_dd4 exceptions others = 1.
        if sy-subrc ne 0. raise exception type zcx_srqltype exporting textid = zcx_srqltype=>zcx_srqltype_descriptor. endif.
        lv_dty = ls_dd4-datatype. lv_dle = ls_dd4-leng. lv_dcs = ls_dd4-decimals.
        result = me->build_ele_descriptor( internal_type = lv_dty internal_length = lv_dle decimals = lv_dcs ).
        return.
      endif.

*     remote with specification
      case internal_type.
        when cl_abap_elemdescr=>typekind_int.     result = cl_abap_elemdescr=>get_i( ).
        when cl_abap_elemdescr=>typekind_int1.    result ?= cl_abap_elemdescr=>describe_by_data( lv_int1 ). " no getters for int1
        when cl_abap_elemdescr=>typekind_int2.    result ?= cl_abap_elemdescr=>describe_by_data( lv_int2 ). " no getters for int2
        when cl_abap_elemdescr=>typekind_float.   result = cl_abap_elemdescr=>get_f( ).
        when cl_abap_elemdescr=>typekind_date.    result = cl_abap_elemdescr=>get_d( ).
        when cl_abap_elemdescr=>typekind_packed.  result = cl_abap_elemdescr=>get_p( p_length = internal_length p_decimals = decimals ).
        when cl_abap_elemdescr=>typekind_char.    result = cl_abap_elemdescr=>get_c( p_length = internal_length ).
        when cl_abap_elemdescr=>typekind_time.    result = cl_abap_elemdescr=>get_t( ).
        when cl_abap_elemdescr=>typekind_num.     result = cl_abap_elemdescr=>get_n( internal_length ).
        when cl_abap_elemdescr=>typekind_hex.     result = cl_abap_elemdescr=>get_x( internal_length ).
        when cl_abap_elemdescr=>typekind_string.  result = cl_abap_elemdescr=>get_string( ).
        when cl_abap_elemdescr=>typekind_xstring. result = cl_abap_elemdescr=>get_xstring( ).
        when others. raise exception type zcx_srqltype exporting textid = zcx_srqltype=>zcx_srqltype_descriptor.
      endcase.

    catch cx_static_check cx_dynamic_check into lx_root.

      raise exception type zcx_srqltype exporting textid = zcx_srqltype=>zcx_srqltype_descriptor previous = lx_root.

  endtry.

endmethod.


method build_str_descriptor.

  data: lx_root type ref to cx_root.

  try.

*     local
      if me->destination is initial. result ?= cl_abap_structdescr=>describe_by_name( structure ). return. endif.

*     remote
      result = cl_abap_structdescr=>create( me->get_type_components( structure = structure fields = fields ) ).

    catch cx_static_check cx_dynamic_check into lx_root.

      raise exception type zcx_srqltype exporting textid = zcx_srqltype=>zcx_srqltype_descriptor previous = lx_root.

  endtry.

endmethod.


method build_tty_descriptor.

  data: lo_line type ref to cl_abap_datadescr,
        lx_root type ref to cx_root.

  try.

      if me->destination is initial.
*       local
        lo_line ?= cl_abap_structdescr=>describe_by_name( line ).
      else.
*       remote
        lo_line = cl_abap_structdescr=>create( me->get_type_components( structure = line fields = fields ) ).
      endif.

*     build table type
      result = cl_abap_tabledescr=>create( p_line_type = lo_line p_table_kind = cl_abap_tabledescr=>tablekind_std p_unique = abap_false ).

    catch cx_static_check cx_dynamic_check into lx_root.

      raise exception type zcx_srqltype exporting textid = zcx_srqltype=>zcx_srqltype_descriptor previous = lx_root.

  endtry.

endmethod.


method constructor.

* set attributes
  me->destination = destination.
  me->typename = typename.
  me->typekind = typekind.

* check typefields
  if typekind eq zif_srqltypekind=>data_element and ( not typefields is initial or offset_fields eq 'X' ). raise exception type zcx_srqltype exporting textid = zcx_srqltype=>zcx_srqltype_element. endif.

  me->typefields = typefields.
  me->offset_fields = offset_fields.

* check exist
  case typekind.
    when zif_srqltypekind=>data_element. me->descriptor = me->build_ele_descriptor( element = me->typename ).
    when zif_srqltypekind=>structure. me->descriptor = me->build_str_descriptor( structure = me->typename fields = me->typefields ).
    when zif_srqltypekind=>table_type. me->descriptor = me->build_tty_descriptor( line = me->typename fields = me->typefields ).
    when others. raise exception type zcx_srqltype exporting textid = zcx_srqltype=>zcx_srqltype_kind.
  endcase.

* set build date
  me->build_date = sy-datum.
  me->build_time = sy-uzeit.

endmethod.


method get_build_date.

  result = me->build_date.

endmethod.


method get_build_time.

  result = me->build_time.

endmethod.


method get_data.

  data: lx_root type ref to cx_root.

  try.
    create data result type handle me->descriptor.
    catch cx_static_check cx_dynamic_check into lx_root.
      raise exception type zcx_srqltype exporting textid = zcx_srqltype=>zcx_srqltype_data previous = lx_root.
  endtry.

endmethod.


method get_descriptor.

  result = me->descriptor.

endmethod.


method get_type_components.

  data: lt_fields    type standard table of dfies,
        lt_lines     type ddtypelist,
        ls_line      type ddtypedesc,
        ls_lfield    type dfies,
        ls_comp      type abap_componentdescr,
        ls_dfies     type dfies,
        ls_tmp_dfies type dfies,
        ls_x030l     type x030l,
        lv_intlen    type i,
        lv_decimals  type i,
        lv_off       type i,
        lv_tabix     type sytabix,
        lv_field     type fieldname,
        lv_count     type numc3 value 1.

  data: lo_struc     type ref to cl_abap_structdescr,
        lx_root      type ref to cx_root.

* check typekind
  if not ( me->typekind eq zif_srqltypekind=>table_type or me->typekind eq zif_srqltypekind=>structure ). raise exception type zcx_srqltype exporting textid = zcx_srqltype=>zcx_srqltype_components structure = structure. endif.

* component table builder
  try.

*     local
      if me->destination is initial. lo_struc ?= cl_abap_structdescr=>describe_by_name( structure ). result = lo_struc->get_components( ). return. endif.

*     remote
      call function 'DDIF_FIELDINFO_GET' destination me->destination exporting tabname = structure all_types = 'X' importing x030l_wa = ls_x030l lines_descr = lt_lines tables dfies_tab = lt_fields exceptions others = 1.
      if sy-subrc ne 0. raise exception type zcx_srqltype exporting textid = zcx_srqltype=>zcx_srqltype_components structure = structure. endif.
*     build structure field by field (nested structures have lfieldname valued has struc-field)
      loop at lt_fields into ls_dfies where not lfieldname cs '-'.
*       internal length determination
        case ls_dfies-inttype.
          when cl_abap_elemdescr=>typekind_char or cl_abap_elemdescr=>typekind_date or cl_abap_elemdescr=>typekind_time or cl_abap_elemdescr=>typekind_num. lv_intlen   = ls_dfies-intlen / ls_x030l-unicodelg.
          when cl_abap_elemdescr=>typekind_table or cl_abap_elemdescr=>typekind_struct1 or cl_abap_elemdescr=>typekind_struct2. "do nothing -> intlen doesn't matter when building elements!
          when others. lv_intlen = ls_dfies-intlen.
        endcase.
*       decimals
        lv_decimals = ls_dfies-decimals.
*       offset management with a dummy fill to handle rfc return misplacement (if needed)
        if ls_dfies-offset - ( ls_tmp_dfies-offset + ls_tmp_dfies-intlen ) gt 0.
*         build byte element
          lv_off = ls_dfies-offset - ( ls_tmp_dfies-offset + ls_tmp_dfies-intlen ).
          ls_comp-type = cl_abap_elemdescr=>get_x( lv_off ). ls_comp-name = |{ zcl_srqltype=>offset_fname_prefix }_{ lv_count }|. append ls_comp to result. add 1 to lv_count.
        endif.
*       field management by means of internal abap types
        ls_comp-name = ls_dfies-fieldname.
*       build field data type
        case ls_dfies-inttype.
*         build table type
          when cl_abap_elemdescr=>typekind_table.
*           build nested table type
            read table lt_lines into ls_line with key typename = ls_dfies-rollname. if sy-subrc ne 0. raise exception type zcx_srqltype exporting textid = zcx_srqltype=>zcx_srqltype_components structure = structure. endif.
            read table ls_line-fields into ls_lfield with key tabname = ls_line-typename. if sy-subrc ne 0. raise exception type zcx_srqltype exporting textid = zcx_srqltype=>zcx_srqltype_components structure = structure. endif.
            ls_comp-type = me->build_tty_descriptor( ls_lfield-rollname ).
*         build structure
          when cl_abap_elemdescr=>typekind_struct1 or cl_abap_elemdescr=>typekind_struct2.
*           build nested structure
            ls_comp-type = me->build_str_descriptor( ls_dfies-rollname ).
*         build element (also for included structures)
          when others.
*           build element
            ls_comp-type = me->build_ele_descriptor( internal_type = ls_dfies-inttype internal_length = lv_intlen decimals = lv_decimals ).
        endcase.
*       add in result
        append ls_comp to result.
*       set as temporary
        ls_tmp_dfies = ls_dfies.
      endloop.

*     purge offsets (if asked)
      if me->offset_fields ne abap_true. delete result where name cp |{ zcl_srqltype=>offset_fname_prefix }_*|. endif.

*     purge undesired fields (but keep offset if previously left)
      if not fields is initial.
        loop at result into ls_comp where not name cp |{ zcl_srqltype=>offset_fname_prefix }_*|. lv_tabix = sy-tabix.
          read table fields into lv_field
            "#EC WARNOK
            with key table_line = ls_comp-name. if sy-subrc ne 0. delete result index lv_tabix. endif.
        endloop.
      endif.

    catch cx_static_check cx_dynamic_check into lx_root.

      raise exception type zcx_srqltype exporting textid = zcx_srqltype=>zcx_srqltype_components previous = lx_root structure = structure.

  endtry.

endmethod.


method new.

  data: lv_dest type string.

* check destination
  if not destination is initial.
    lv_dest = destination.
    call function 'RFC_VERIFY_DESTINATION' exporting destination = lv_dest exceptions others = 1.
    if sy-subrc ne 0. raise exception type zcx_srqltype exporting textid = zcx_srqltype=>zcx_srqltype. endif.
  endif.

* check typekind
  if not ( typekind eq zif_srqltypekind=>structure or typekind eq zif_srqltypekind=>table_type or typekind eq zif_srqltypekind=>data_element ). raise exception type zcx_srqltype exporting textid = zcx_srqltype=>zcx_srqltype_kind. endif.

* check name
  if typename is initial. raise exception type zcx_srqltype exporting textid = zcx_srqltype=>zcx_srqltype_name. endif.

* build object
  create object result exporting destination = destination typename = typename typekind = typekind typefields = typefields offset_fields = offset_fields.

endmethod.


method offset_fields_purged.

  if me->offset_fields ne abap_true. result = abap_true. endif.

endmethod.
ENDCLASS.
