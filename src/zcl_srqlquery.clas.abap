class ZCL_SRQLQUERY definition
  public
  create private .

public section.
  type-pools ABAP .

  methods EXECUTE
    raising
      ZCX_SRQLQUERY
      ZCX_SRQLTYPE .
  methods GET_RESULT
    importing
      value(INDEX) type I default 0
    exporting
      value(RESULT) type ANY .
  methods GET_RESULT_DATA
    returning
      value(RESULT) type ref to DATA .
  methods GET_RESULT_TIMESTAMP
    returning
      value(RESULT) type ZSRQLTIMESTAMP_S .
  methods GET_WHERE_AS_STRING
    returning
      value(RESULT) type STRING .
  methods PREPARE_RESULT
    importing
      value(FIELDS) type FIELDNAME_TAB optional
      value(DDIC_STRUCTURE) type STRUKNAME optional
    raising
      ZCX_SRQLQUERY .
  class-methods NEW
    importing
      value(DESTINATION) type RFCDEST optional
      value(TABLE) type TABNAME
    returning
      value(RESULT) type ref to ZCL_SRQLQUERY
    raising
      ZCX_SRQLQUERY .
  methods PREPARE_STATEMENT
    importing
      value(STRING) type STRING optional
      value(SELECT_OPTION) type ZSRQLSOQUERY_TT optional
      value(CONJUNCTION) type STRING optional
    raising
      ZCX_SRQLQUERY .
protected section.
private section.

  data DESTINATION type RFCDEST .
  data TABLE type TABNAME .
  data TABLE_FIELDS type DFIES_TAB .
  data WHERE type ZSRQLRFCDBOPT_TT .
  data RESULT_FIELDS type FIELDNAME_TAB .
  data RESULT type ref to DATA .
  data RESULT_DATE type SYDATUM .
  data RESULT_TIME type SYUZEIT .
  constants C_QUERYABLE_FIELD_MAX_LENGTH type I value 512. "#EC NOTEXT
  constants C_QUERY_LINE_RFC_LIMIT type I value 72. "#EC NOTEXT

  methods BUILD_WHERE
    importing
      value(INPUT) type STRING .
  methods DOULE_HYPHEN
    importing
      value(INPUT) type TEXT1024
    returning
      value(OUTPUT) type TEXT1024 .
  methods GET_SQL_OPERATOR
    importing
      value(SIGN) type TVARV_SIGN
      value(OPTION) type TVARV_OPTI
    returning
      value(RESULT) type STRING .
  methods CONSTRUCTOR
    importing
      value(DESTINATION) type RFCDEST optional
      value(TABLE) type TABNAME
    raising
      ZCX_SRQLQUERY .
  methods EXPLODE_SELECT_OPTION
    importing
      value(INPUT) type ZSRQLSOQUERY_TT
      value(ESCAPE) type XFELD default SPACE
    returning
      value(RESULT) type STRING .
ENDCLASS.



CLASS ZCL_SRQLQUERY IMPLEMENTATION.


method BUILD_WHERE.

  do.
*   last.
    if strlen( input ) le zcl_srqlquery=>c_query_line_rfc_limit. append input to me->where. exit. endif.
*   intermediate
    append input(zcl_srqlquery=>c_query_line_rfc_limit) to me->where. input = input+zcl_srqlquery=>c_query_line_rfc_limit.
  enddo.

endmethod.


method constructor.

* get table fields (destination already checked in new mwthod)
  if not destination is initial.
    call function 'DDIF_FIELDINFO_GET' destination destination exporting tabname = table tables dfies_tab = me->table_fields exceptions others = 1.
  else.
    call function 'DDIF_FIELDINFO_GET' exporting tabname = table tables dfies_tab = me->table_fields exceptions others = 1.
  endif.

* error handling
  if sy-subrc ne 0. raise exception type zcx_srqlquery exporting textid = zcx_srqlquery=>zcx_srqlquery_table. endif.

* initialize attributes
  me->destination = destination.
  me->table = table.

endmethod.


method doule_hyphen.

  field-symbols: <lv_str> type text1024.

  output = input.

  assign output to <lv_str>.

  while <lv_str> ca ''''.
    assign <lv_str>+sy-fdpos(*) to <lv_str>.
    shift <lv_str> right by 1 places.
    <lv_str>(1) = ''''.
    assign <lv_str>+2(*) to <lv_str>.
  endwhile.

endmethod.


method execute.

* object declaration
  data: lx_root  type ref to cx_root,
        lo_tyds  type ref to cl_abap_typedescr,
        lo_stds  type ref to cl_abap_structdescr,
        lo_ttds  type ref to cl_abap_tabledescr,
        lo_struc type ref to data.

* data declaration
  data: lv_field  type fieldname,
        lv_tabix  type sytabix,
        lv_tabiy  type sytabix,
        lv_fields type string,
        lv_group  type i,
        lv_len    type i,
        lv_comp   type fieldname,
        lv_where  type string,
        lv_dest   type string,
        ls_field  type dfies,
        ls_fld    type rfc_db_fld,
        ls_data   type tab512,
        ls_comp   type abap_componentdescr,
        lt_comp   type abap_component_tab,
        lt_data   type standard table of tab512,
        lt_field  type standard table of dfies,
        lt_fld    type standard table of rfc_db_fld.

* pointer declaration
  field-symbols: <lt_table>  type standard table,
                 <ls_line1>  type any,
                 <ls_line2>  type any,
                 <lv_field1> type any,
                 <lv_field2> type any.

  if me->destination is initial.
*   build depending on asked fields
    if not me->result_fields is initial.
*     get descriptor
      cl_abap_structdescr=>describe_by_name( exporting p_name = me->table receiving p_descr_ref = lo_tyds exceptions type_not_found = 1 others = 2 ).
      if sy-subrc ne 0. raise exception type zcx_srqlquery exporting textid = zcx_srqlquery=>zcx_srqlquery_execution table = me->table. endif.
*     get components
      try.
        lo_stds ?= lo_tyds. lt_comp = lo_stds->get_components( ). lt_comp = lo_stds->get_components( ).
      catch cx_sy_move_cast_error into lx_root.
        raise exception type zcx_srqlquery exporting textid = zcx_srqlquery=>zcx_srqlquery_execution previous = lx_root table = me->table.
      endtry.
*     purge undesired components
      loop at lt_comp into ls_comp.
        lv_tabix = sy-tabix.
        lv_comp = ls_comp-name. read table me->result_fields into lv_field with key table_line = lv_comp.
        if sy-subrc ne 0. delete lt_comp index lv_tabix. endif.
      endloop.
*     build table type
      try.
        free: lo_stds. lo_stds = cl_abap_structdescr=>create( lt_comp ).
        lo_ttds = cl_abap_tabledescr=>create( p_line_type = lo_stds p_table_kind = cl_abap_tabledescr=>tablekind_std p_unique = abap_false ).
      catch cx_sy_table_creation cx_sy_struct_creation into lx_root.
        raise exception type zcx_srqlquery exporting textid = zcx_srqlquery=>zcx_srqlquery_execution previous = lx_root table = me->table.
      endtry.
*     build data object
      create data me->result type handle lo_ttds.
    else.
*     build data object
      create data me->result type standard table of (me->table). if sy-subrc ne 0. free me->result. raise exception type zcx_srqlquery exporting textid = zcx_srqlquery=>zcx_srqlquery_execution table = me->table. endif.
    endif.
*   to fs for easy handling
    assign me->result->* to <lt_table>. if sy-subrc ne 0. free me->result. raise exception type zcx_srqlquery exporting textid = zcx_srqlquery=>zcx_srqlquery_execution table = me->table. endif.
*   get where clause as string
    lv_where = me->get_where_as_string( ).
*   fields of interest
    if not me->result_fields is initial. loop at me->result_fields into lv_field. lv_fields = |{ lv_fields } { lv_field }|.endloop. condense lv_fields. else. lv_fields = '*'. endif.
*   perform statement
    if not lv_where is initial. select (lv_fields) from (me->table) into corresponding fields of table <lt_table> where (lv_where). else. select (lv_fields) from (me->table) into corresponding fields of table <lt_table>. endif.
  else.
*   check destination
    lv_dest = destination.
    call function 'RFC_VERIFY_DESTINATION' exporting destination = lv_dest exceptions others = 1.
    if sy-subrc ne 0. raise exception type zcx_srqlquery exporting textid = zcx_srqlquery=>zcx_srqlquery_rfc. endif.
*   build data object
    lo_stds ?= zcl_srqltype=>new( destination = me->destination typename = me->table typekind = zif_srqltypekind=>structure typefields = me->result_fields )->get_descriptor( ).
    lo_ttds = cl_abap_tabledescr=>create( p_line_type = lo_stds p_table_kind = cl_abap_tabledescr=>tablekind_std p_unique = abap_false ).
    create data: lo_struc type handle lo_stds, me->result type handle lo_ttds.
*   check data object creation
    if not ( lo_struc is bound and me->result is bound ). raise exception type zcx_srqlquery exporting textid = zcx_srqlquery=>zcx_srqlquery_execution table = me->table. endif.
*   to symbols for handling
    assign: lo_struc->* to <ls_line1>, me->result->* to <lt_table>. if not ( <ls_line1> is assigned and <lt_table> is assigned ). raise exception type zcx_srqlquery exporting textid = zcx_srqlquery=>zcx_srqlquery_execution table = me->table. endif.
*   prepare rfc field list
    loop at me->result_fields into lv_field.
      read table me->table_fields into ls_field with key fieldname = lv_field. if sy-subrc ne 0. free me->result. raise exception type zcx_srqlquery exporting textid = zcx_srqlquery=>zcx_srqlquery_execution table = me->table. endif.
      append ls_field to lt_field.
    endloop.
*   nothing -> all
    if lt_field is initial. append lines of me->table_fields to lt_field. endif.
*   prepare fields
    loop at lt_field into ls_field.
*     get line index
      lv_tabix = sy-tabix.
*     get total fields length
      lv_len = lv_len + ls_field-leng.
*     check limit of data line in rfc_read_data
      if lv_len le zcl_srqlquery=>c_queryable_field_max_length. ls_fld-fieldname = ls_field-fieldname. append ls_fld to lt_fld. endif.
*     single field over -> skip, but mustn't happen
      if lv_len gt zcl_srqlquery=>c_queryable_field_max_length and lt_fld is initial. continue. endif.
*     limit, over limit or last line -> start getting data
      if ( lv_len ge zcl_srqlquery=>c_queryable_field_max_length and not lt_fld is initial ) or lv_tabix eq lines( lt_field ).
*       increase field group index (nb: initialized to 0!)
        add 1 to lv_group.
*       clean data
        refresh: lt_data.
*       remote query
        call function 'RFC_READ_TABLE' destination me->destination exporting query_table = me->table tables options = me->where fields = lt_fld data = lt_data exceptions others = 1.
        if sy-subrc ne 0. free me->result. raise exception type zcx_srqlquery exporting textid = zcx_srqlquery=>zcx_srqlquery_execution table = me->table. endif.
*       next field
        if lv_tabix ne lines( lt_field ). ls_fld-fieldname = ls_field-fieldname. append ls_fld to lt_fld. endif.
*       map data
        loop at lt_data into ls_data.
*         index
          lv_tabiy = sy-tabix.
*         first field group already processed -> record exist
          if lv_group gt 1. read table <lt_table> assigning <ls_line2> index lv_tabiy. if sy-subrc ne 0. raise exception type zcx_srqlquery exporting textid = zcx_srqlquery=>zcx_srqlquery_execution table = me->table. endif. endif.
*         prepare fields
          loop at lt_fld into ls_fld.
            if lv_group eq 1.
              assign component ls_fld-fieldname of structure <ls_line1> to <lv_field1>. if sy-subrc ne 0. raise exception type zcx_srqlquery exporting textid = zcx_srqlquery=>zcx_srqlquery_execution table = me->table. endif.
              try.
                  <lv_field1> = ls_data+ls_fld-offset(ls_fld-length).
                catch cx_static_check cx_dynamic_check into lx_root.
                  free me->result. raise exception type zcx_srqlquery exporting textid = zcx_srqlquery=>zcx_srqlquery_execution previous = lx_root table = me->table.
              endtry.
            else.
              assign component ls_fld-fieldname of structure <ls_line2> to <lv_field2>. if sy-subrc ne 0. raise exception type zcx_srqlquery exporting textid = zcx_srqlquery=>zcx_srqlquery_execution table = me->table. endif.
              try.
                  <lv_field2> = ls_data+ls_fld-offset(ls_fld-length).
                catch cx_static_check cx_dynamic_check into lx_root.
                  free me->result. raise exception type zcx_srqlquery exporting textid = zcx_srqlquery=>zcx_srqlquery_execution previous = lx_root table = me->table.
              endtry.
            endif.
          endloop.
*         first field group -> append temporary line to me->result
          if lv_group eq 1. append <ls_line1> to <lt_table>. continue. endif.
        endloop.
*       prepare for next loop
        refresh: lt_fld.
      endif.
    endloop.
  endif.

* set result timestamp
  me->result_date = sy-datum.
  me->result_time = sy-uzeit.

endmethod.


method explode_select_option.

* constants
  constants: gc_1024 type i value 1024.

* declarations
  data: ls_input      type zsrqlsoquery_s,
        lv_concat     type string,
        lv_last_fname type string,
        lv_op         type string,
        lv_last_sign  type tvarv_sign,
        lv_low        type text1024,
        lv_high       type text1024.

* pointers
  field-symbols: <lv_str> type any.

* order
  sort input by fieldname sign descending.

  loop at input into ls_input.
*   clean variables
    clear: lv_concat, lv_op, lv_low, lv_high.
*   prepare
    if sy-tabix eq 1.
      result = '('.
    elseif ( ls_input-fieldname eq lv_last_fname and ls_input-sign eq lv_last_sign ).
      if ls_input-sign eq 'I'. lv_concat = zif_srqlconjunction=>or. else. lv_concat = zif_srqlconjunction=>and. endif.
    else.
      result = |{ result } ) AND (|.
    endif.
*   get operator
    lv_op = me->get_sql_operator( sign = ls_input-sign option = ls_input-option ).
*   double quotation marks
    ls_input-low = me->doule_hyphen( ls_input-low ).
*   set low sql fieldvalue
    lv_low = |'{ ls_input-low }'|.
*   cp and np operators
    if ls_input-option eq 'CP' or ls_input-option eq 'NP'.
      assign lv_low to <lv_str>.
      if not ( <lv_str> ca '%_' and escape eq abap_true ). clear escape. endif.
      while <lv_str> ca '#*+%_'.
        assign <lv_str>+sy-fdpos(*) to <lv_str>.
        if <lv_str>(1) ca '%_' and escape = abap_true.
          if strlen( lv_low ) lt gc_1024. shift <lv_str> right by 1 places. <lv_str>(1) = '#'. assign <lv_str>+1(*) to <lv_str>. endif.
        elseif <lv_str>(1) = '#'.
          if strlen( <lv_str> ) gt 1 and <lv_str>+1(1) ca '#_%' and escape ne space. assign <lv_str>+1(*) to <lv_str>. else. shift <lv_str> left by 1 places. endif.
        elseif <lv_str>(1) = '*'.
          <lv_str>(1) = '%'.
        elseif <lv_str>(1) = '+'.
          <lv_str>(1) = '_'.
        endif.
        if strlen( <lv_str> ) gt 1. assign <lv_str>+1(*) to <lv_str>. else. exit. endif.
      endwhile.
      if escape eq abap_true. lv_high = | ESCAPE ''#''|. clear: escape. endif.
    endif.
*   bt and nb operators
    if ls_input-option eq 'BT' or ls_input-option = 'NB'.
      ls_input-high = me->doule_hyphen( ls_input-high ).
      lv_high = |AND '{ ls_input-high }'|.
    endif.
*   build result
    result = |{ result } { lv_concat } { ls_input-fieldname } { lv_op } { lv_low }|.
    if lv_high ne space. result = |{ result } { lv_high }|. endif.
*   temporary
    lv_last_fname = ls_input-fieldname. lv_last_sign = ls_input-sign.
  endloop.

* last parenthesis
  if not result is initial. result = |{ result } )|. endif.

endmethod.


method get_result.

  data: lo_desc   type ref to cl_abap_typedescr,
        lo_struc  type ref to cl_abap_structdescr,
        ls_result type ref to data.

  field-symbols: <ls_result1> type any,
                 <ls_result2> type any,
                 <lt_result1> type standard table,
                 <lt_result2> type standard table.

  if me->result is bound.
*   to fs to handle easily
    assign me->result->* to <lt_result1>.
*   nothing to return
    if <lt_result1> is initial. return. endif.
*   specific line or full recordset
    if index gt 0.
*     just a specific line
      read table <lt_result1> assigning <ls_result1> index index. if sy-subrc eq 0. move-corresponding <ls_result1> to result. endif.
    else.
*     to fs to easy handle
      assign result to <lt_result2>.
*     first line to have a structured data
      read table <lt_result1> assigning <ls_result1> index 1.
*     dynamic build second one as first one
      lo_desc = cl_abap_structdescr=>describe_by_data( <ls_result1> ).
      lo_struc ?= lo_desc. create data ls_result type handle lo_struc.
*     to fs to easy handle
      assign ls_result->* to <ls_result2>.
*     prepare result
      loop at <lt_result1> assigning <ls_result1>. move-corresponding <ls_result1> to <ls_result2>. append <ls_result2> to <lt_result2>. endloop.
    endif.
  endif.

endmethod.


method get_result_data.

  result = me->result.

endmethod.


method get_result_timestamp.

  if not me->result_date is initial. result-date = me->result_date. endif.
  if not me->result_time is initial. result-time = me->result_time. endif.

endmethod.


method GET_SQL_OPERATOR.

  if sign eq 'I'.
    case option.
      when 'BT'. result = 'BETWEEN'.
      when 'NB'. result = 'NOT BETWEEN'.
      when 'CP'. result = 'LIKE'.
      when 'NP'. result = 'NOT LIKE'.
      when others. result = 'EQ'.
    endcase.
  else.
    case option.
      when 'EQ'. result = 'NE'.
      when 'NE'. result = 'EQ'.
      when 'GT'. result = 'LE'.
      when 'LE'. result = 'GT'.
      when 'GE'. result = 'LT'.
      when 'LT'. result = 'GE'.
      when 'BT'. result = 'NOT BETWEEN'.
      when 'NB'. result = 'BETWEEN'.
      when 'CP'. result = 'NOT LIKE'.
      when 'NP'. result = 'LIKE'.
      when others. clear result.
    endcase.
  endif.

endmethod.


method get_where_as_string.

  data: ls_query type rfc_db_opt.

  loop at me->where into ls_query. result = |{ result }{ ls_query-text }|. endloop.

  condense result.

endmethod.


method new.

  data: lv_dest type string.

* check destination
  if not destination is initial.
    lv_dest = destination.
    call function 'RFC_VERIFY_DESTINATION' exporting destination = lv_dest exceptions others = 1.
    if sy-subrc ne 0. raise exception type zcx_srqlquery exporting textid = zcx_srqlquery=>zcx_srqlquery_rfc. endif.
  endif.

* table check
  if table is initial. raise exception type zcx_srqlquery exporting textid = zcx_srqlquery=>zcx_srqlquery_table. endif.

* build object
  create object result exporting destination = destination table = table.

endmethod.


method prepare_result.

  data: lv_field type fieldname,
        ls_field type dfies,
        ls_dfies type dfies,
        lt_dfies type standard table of dfies.

* check input
  if ( fields is initial and ddic_structure is initial ) or ( not fields is initial and not ddic_structure is initial ).
    raise exception type zcx_srqlquery exporting textid = zcx_srqlquery=>zcx_srqlquery_result.
  endif.

* field list
  if not fields is initial.
*   check specififed fields
    loop at fields into lv_field.
*     keep only queryable fields (length less or equal 512 characters)
      read table me->table_fields into ls_field with key fieldname = lv_field.
      if not ( sy-subrc eq 0 and ls_field-leng le zcl_srqlquery=>c_queryable_field_max_length ). raise exception type zcx_srqlquery exporting textid = zcx_srqlquery=>zcx_srqlquery_rfc fieldname = ls_field-fieldname. endif.
    endloop.
*   prepare
    loop at me->table_fields into ls_field.
*     always add key fields
      if ls_field-keyflag eq 'X'. append ls_field-fieldname to me->result_fields. continue. endif.
*     requested -> add
      read table fields into lv_field with key table_line = ls_field-fieldname.
      if sy-subrc eq 0. append ls_field-fieldname to me->result_fields. continue. endif.
    endloop.
  endif.

* input structure
  if not ddic_structure is initial.
*   get ddic structure fields
    call function 'DDIF_FIELDINFO_GET' exporting tabname = ddic_structure tables dfies_tab = lt_dfies exceptions others = 1.
    if sy-subrc ne 0. raise exception type zcx_srqlquery exporting textid = zcx_srqlquery=>zcx_srqlquery_structure. endif.
*   check key fields specified
    loop at me->table_fields into ls_field where keyflag eq 'X'.
      read table lt_dfies into ls_dfies with key fieldname = ls_field-fieldname.
      if sy-subrc ne 0. raise exception type zcx_srqlquery exporting textid = zcx_srqlquery=>zcx_srqlquery_struc_no_key structure = ddic_structure table = me->table. endif.
    endloop.
*   prepare fields
    loop at lt_dfies into ls_dfies. append ls_dfies-fieldname to me->result_fields. endloop.
  endif.

endmethod.


method prepare_statement.

  data: lt_split type standard table of string,
        ls_field type dfies,
        ls_so    type zsrqlsoquery_s,
        lv_split type string,
        lv_fname type fieldname.

* all to upper
  translate: string to upper case.

* check input
  if not string is initial and not select_option is initial and not ( conjunction eq zif_srqlconjunction=>and or conjunction eq zif_srqlconjunction=>or ).
    raise exception type zcx_srqlquery exporting textid = zcx_srqlquery=>zcx_srqlquery_conjunction.
  endif.

* check select option fields - if specified
  loop at select_option into ls_so.
    read table me->table_fields into ls_field with key fieldname = ls_so-fieldname.
    if sy-subrc ne 0. raise exception type zcx_srqlquery exporting textid = zcx_srqlquery=>zcx_srqlquery_no_field table = me->table fieldname = ls_so-fieldname. endif.
  endloop.

* check string - if specified
  split string at space into table lt_split.
* purge logical words & values
  delete lt_split where ( table_line eq `(` or table_line eq `)` or table_line cp `'*'` or table_line co '0123456789.' or
                          table_line eq 'EQ' or table_line eq 'BETWEEN' or table_line eq 'NOT' or table_line eq 'LIKE' or table_line eq 'NE' or table_line eq 'LT' or table_line eq 'GT' or table_line eq 'LE' or table_line eq 'GE' or
                          table_line eq '=' or table_line eq '<>'  or table_line eq '>' or table_line eq '<' or table_line eq '>=' or table_line eq '<=' ).
* check left words (fields)
  loop at lt_split into lv_split.
    lv_fname = lv_split.
    read table me->table_fields into ls_field with key fieldname = lv_fname.
    if sy-subrc ne 0. raise exception type zcx_srqlquery exporting textid = zcx_srqlquery=>zcx_srqlquery_no_field table = me->table fieldname = lv_fname. endif.
  endloop.

* prepare
  if not string is initial and not select_option is initial. string = |( { string } ) { conjunction } (|. endif.
  if not select_option is initial. string = |{ string } { me->explode_select_option( select_option ) }|. endif.

* no border gaps
  condense string.

* fill instance attribute
  me->build_where( string ).

endmethod.
ENDCLASS.
