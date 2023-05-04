*&---------------------------------------------------------------------*
*& Report  ZSRQLDEMO
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

report zsrqldemo.

* PROGRAM SHOW HOW TO USE REMOTE TYPE BUILDER AND QUERY ENGINE, THERE'S NO OUTPUT! YOU CAN ENABLE PRE-DEFINED EXAMPLE BREAKPOINTS
* IN ORDER TO SEE HOW TYPES ARE BUILT AND HANDLED AND HOW QUERIES ARE PERFORMED OR YOU CAN SET YOUR OWN BREAKPOINTS.

* include macros
  include zsrql.

* break-point macro definition
  define _break.
    ##NO_BREAK
    break-point.
  end-of-definition.

* MAIN program class definition
  class cl_main definition final.
    public section.
      methods start importing value(vv_dest) type rfcdest value(vv_break) type xfeld value(vv_type) type xfeld value(vv_query) type xfeld value(vv_macro) type xfeld raising zcx_srqltype zcx_srqlquery.
    private section.
      methods demo_typing importing value(vv_dest) type rfcdest value(vv_break) type xfeld raising zcx_srqltype.
      methods demo_querying importing value(vv_dest) type rfcdest value(vv_break) type xfeld raising zcx_srqltype zcx_srqlquery.
      methods demo_macro importing value(vv_dest) type rfcdest value(vv_break) type xfeld raising zcx_srqltype zcx_srqlquery.
  endclass.

  class cl_main implementation.

    method start.
*     remote typing
      if vv_type eq 'X'. me->demo_typing( vv_dest = vv_dest vv_break = vv_break ). endif.
*     remote querying
      if vv_query eq 'X'. me->demo_querying( vv_dest = vv_dest vv_break = vv_break ). endif.
*     macro
      if vv_macro eq 'X'. me->demo_macro( vv_dest = vv_dest vv_break = vv_break ). endif.
    endmethod.

    method demo_typing.

*     declarations
      data: lo_type type ref to zcl_srqltype,
            lo_ele1 type ref to data,
            lo_ele2 type ref to data,
            lo_ele3 type ref to data,
            lo_stru type ref to data,
            lo_scut type ref to data,
            lo_itab type ref to data,
            lo_icut type ref to data,
            lt_flds type fieldname_tab,
            lv_par  type symsgv.

*     symbols definition
      field-symbols: <lv_ele1> type any,
                     <lv_ele2> type any,
                     <lv_ele3> type any,
                     <ls_stru> type any,
                     <ls_scut> type any,
                     <lt_itab> type standard table,
                     <lt_icut> type standard table.

*     EXAMPLE 1: <lv_dele> built as remote data element mandt and valued as local client
      if vv_break eq 'X'. _break. endif.

*     build remote type descriptor (once build you can generate as more data as you want without keeping calling the backend)
      lo_type = zcl_srqltype=>new( destination = vv_dest typekind = zif_srqltypekind=>data_element typename = 'MANDT' ).

*     build multiple data based on same descriptor
      lo_ele1 = lo_type->get_data( ).
      lo_ele2 = lo_type->get_data( ).
      lo_ele3 = lo_type->get_data( ).

*     to handle
      assign: lo_ele1->* to <lv_ele1>, lo_ele2->* to <lv_ele2>, lo_ele3->* to <lv_ele3>.

*     assign value
      <lv_ele1> = sy-mandt.
      <lv_ele2> = sy-mandt + 1.
      <lv_ele3> = sy-mandt + 2.

*     EXAMPLE 2: <ls_stru> built as remote structure bapiret2 and valued using standard module balw_bapireturn_get2
      if vv_break eq 'X'. _break. endif.

*     build remote structure
      lo_stru = zcl_srqltype=>new( destination = vv_dest typekind = zif_srqltypekind=>structure typename = 'BAPIRET2' )->get_data( ).
      assign lo_stru->* to <ls_stru>.
*     assign value
      lv_par = vv_dest. call function 'BALW_BAPIRETURN_GET2' exporting type = 'S' cl = 'ZSRQL' number = '015' par1 = 'BAPIRET2' par2 = lv_par importing return = <ls_stru>.

*     EXAMPLE 3: <lt_itab> built as an internal table with line defined as remote structure bapiret2 (previous <ls_stru> line has been appended)
      if vv_break eq 'X'. _break. endif.

*     build remote internal table
      lo_itab = zcl_srqltype=>new( destination = vv_dest typekind = zif_srqltypekind=>table_type typename = 'BAPIRET2' )->get_data( ).
      assign lo_itab->* to <lt_itab>.
*     add line
      append <ls_stru> to <lt_itab>.

*     EXAMPLE 4: <ls_scut> built as a subset of fields (id, number, message) defined on a remote structure bapiret2 and valued moving corresponding fields from previous structure
      if vv_break eq 'X'. _break. endif.

*     build remote structure (only some fields)
      append 'TYPE' to lt_flds. append 'ID' to lt_flds. append 'NUMBER' to lt_flds. append 'MESSAGE' to lt_flds.
      lo_scut = zcl_srqltype=>new( destination = vv_dest typekind = zif_srqltypekind=>structure typename = 'BAPIRET2' typefields = lt_flds )->get_data( ).
      assign lo_scut->* to <ls_scut>.
*     assign values
      move-corresponding <ls_stru> to <ls_scut>.

*     EXAMPLE 5: <lt_icut> built as internal table with line defined as a subset of fields (id, number, message) of remote structure bapiret2 (previous <ls_scut> line has been appended)
      if vv_break eq 'X'. _break. endif.

*     build remote internal table (only some fields)
      lo_icut = zcl_srqltype=>new( destination = vv_dest typekind = zif_srqltypekind=>table_type typename = 'BAPIRET2' typefields = lt_flds )->get_data( ).
      assign lo_icut->* to <lt_icut>.
*     add line
      append <ls_scut> to <lt_icut>.

    endmethod.

    method demo_querying.

*     data declaration
      data: lo_srql       type ref to zcl_srqlquery,
            lo_t006d      type ref to zcl_srqlquery,
            lo_t006t      type ref to zcl_srqlquery,
            lo_t006d_data type ref to data,
            lo_t006t_data type ref to data,
            lo_dims_data  type ref to data,
            lo_dimt_data  type ref to data,
            lt_fld        type fieldname_tab,
            lt_query      type standard table of zsrqlsoquery_s,
            ##NEEDED
            lt_data1      type standard table of zsrqlt000demo_s,
            ##NEEDED
            lt_data2      type standard table of zsrqlt000demo_s,
            ls_query      type zsrqlsoquery_s.

*     symbols definition
      field-symbols: <lt_t006d> type standard table,
                     <lt_t006t> type standard table,
                     <lt_dim> type standard table,
                     <ls_t006d> type any,
                     <ls_t006t> type any,
                     <ls_line> type any,
                     <lt_text> type standard table,
                     <ls_dim>  type any,
                     <lv_dim1> type any,
                     <lv_dim2> type any.

*     EXAMPLE 1: remote t000 query with field filters
      if vv_break eq 'X'. _break. endif.

*     code
      lo_srql = zcl_srqlquery=>new( destination = vv_dest table = 'T000' ).
      lo_srql->prepare_result( ddic_structure = 'ZSRQLT000DEMO_S' ).
      lo_srql->execute( ).
      lo_srql->get_result( importing result = lt_data1 ).

*     EXAMPLE 2: remote t000 query with field filter based on field list and result assigned to local structure (with these fields)
      if vv_break eq 'X'. _break. endif.

*     code
      refresh: lt_fld. append: 'MANDT' to lt_fld, 'MTEXT' to lt_fld, 'ORT01' to lt_fld, 'CHANGEUSER' to lt_fld.
      lo_srql = zcl_srqlquery=>new( destination = vv_dest table = 'T000' ).
      lo_srql->prepare_result( fields = lt_fld ).
      lo_srql->execute( ).
      lo_srql->get_result( importing result = lt_data2 ).

*     EXAMPLE 3: remote query on t006d and t006t with result remapping on dynamic built structures/internal tables
      if vv_break eq 'X'. _break. endif.

*     build dynamic structure <ls_dim> and internal table <lt_dim> with line zsrqldimdemo_s (built from local defined so that you can test: no destination passed in method new)
      lo_dims_data = zcl_srqltype=>new( typename = 'ZSRQLDIMDEMO_S' typekind = zif_srqltypekind=>structure )->get_data( ).
      lo_dimt_data = zcl_srqltype=>new( typename = 'ZSRQLDIMDEMO_S' typekind = zif_srqltypekind=>table_type )->get_data( ).
      assign: lo_dims_data->* to <ls_dim>, lo_dimt_data->* to <lt_dim>.

*     specify query logical clause as select option (ask for length and mass)
      ls_query-fieldname = 'DIMID'.
      ls_query-sign      = 'I'.
      ls_query-option    = 'EQ'.
      ls_query-low       = 'MASS'.
      append ls_query to lt_query.
      ls_query-low       = 'LENGTH'.
      append ls_query to lt_query.

*     prepare & execute remote t006d query
      lo_t006d = zcl_srqlquery=>new( destination = vv_dest table = 'T006D' ).
      lo_t006d->prepare_statement( select_option = lt_query ).
      lo_t006d->execute( ).
      lo_t006d_data = lo_t006d->get_result_data( ). assign lo_t006d_data->* to <lt_t006d>.

*     specify query logical clause as select-option (ask for french, english and italian)
      ls_query-fieldname = 'SPRAS'.
      ls_query-low       = 'F'.
      append ls_query to lt_query.
      ls_query-low       = 'E'.
      append ls_query to lt_query.
      ls_query-low       = 'I'.
      append ls_query to lt_query.

*     prepare & execute remote t006t query
      lo_t006t = zcl_srqlquery=>new( destination = 'RISCLNT001' table = 'T006T' ).
      lo_t006t->prepare_statement( select_option = lt_query ).
      lo_t006t->execute( ).
      lo_t006t_data = lo_t006t->get_result_data( ). assign lo_t006t_data->* to <lt_t006t>.

*     remap in result
      loop at <lt_t006d> assigning <ls_t006d>.
*       set header
        assign component 'DIMENSION' of structure <ls_dim> to <ls_line>. <ls_line> = <ls_t006d>.
*       get my items
        assign component 'TEXT' of structure <ls_dim> to <lt_text>.
*       get header dimension to check
        assign component 'DIMID' of structure <ls_line> to <lv_dim1>.
*       search for my dimension text
        loop at <lt_t006t> assigning <ls_t006t>.
          assign component 'DIMID' of structure <ls_t006t> to <lv_dim2>.
          if <lv_dim1> eq <lv_dim2>. append <ls_t006t> to <lt_text>. endif.
        endloop.
        append <ls_dim> to <lt_dim>.
        refresh: <lt_text>. clear: <ls_dim>.
      endloop.

    endmethod.

    method demo_macro.

      data: lo_de_logsys type ref to zcl_srqltype,
            lo_ds_t000   type ref to zcl_srqltype,
            lo_dt_t000   type ref to zcl_srqltype,
            lo_element   type ref to data,
            lo_line1     type ref to data,
            lo_line2     type ref to data,
            lo_itab      type ref to data,
            lo_sys1      type ref to data,
            lo_sys2      type ref to data,
            lo_sys3      type ref to data,
            lo_t000s     type ref to data,
            lo_t000t     type ref to data,
            lt_map       type zsrqlfieldmap_s_tt,
            ls_map       type zsrqlfieldmap_s,
            lv_par       type symsgv.

      field-symbols: <lv_ele>   type any,
                     <lv_sys1>  type any,
                     <lv_sys2>  type any,
                     <lv_sys3>  type any,
                     <ls_t000>  type any,
                     <ls_line1> type any,
                     <ls_line2> type any,
                     <lt_t000>  type standard table,
                     <lt_itab>  type standard table.

*     EXAMPLE 1: multiple data creation using descriptor
      if vv_break eq 'X'. _break. endif.

*     build decsriptors (useful to avoid same backend call replicatin if many variables are needed related to same data type)
      _srql_build-type-descriptor vv_dest: zif_srqltypekind=>data_element 'LOGSYS' lo_de_logsys, zif_srqltypekind=>structure 'T000' lo_ds_t000, zif_srqltypekind=>table_type 'T000' lo_dt_t000.
*     build many data from same descriptor
      _srql_build-from-descriptor lo_de_logsys: lo_sys1, lo_sys2, lo_sys3.
      assign: lo_sys1->* to <lv_sys1>, lo_sys2->* to <lv_sys2>, lo_sys3->* to <lv_sys3>.
*     build structure and internal table data for t000
      _srql_build-from-descriptor: lo_ds_t000 lo_t000s, lo_dt_t000 lo_t000t.
      assign: lo_t000s->* to <ls_t000>, lo_t000t->* to <lt_t000>.
*     set values
      <lv_sys1> = 'XKSCLNT100'.
      <lv_sys2> = 'XKTCLNT250'.
      <lv_sys3> = 'XKPCLNT800'.
*     move & append some fields
      select single * from t000 into corresponding fields of <ls_t000> where mandt eq sy-mandt.
      append <ls_t000> to <lt_t000>.

*     EXAMPLE 2: build a data element and set value
      if vv_break eq 'X'. _break. endif.

      _srql_build-element vv_dest 'MANDT' lo_element.
      assign lo_element->* to <lv_ele>.
      <lv_ele> = sy-mandt.

*     EXAMPLE 3: build structures & move fields
      if vv_break eq 'X'. _break. endif.

      _srql_build-structure vv_dest: 'BAPIRET2' space lo_line1, 'BAPIRETURN' space lo_line2.
      assign: lo_line1->* to <ls_line1>, lo_line2->* to <ls_line2>.
*     fill line1
      lv_par = vv_dest. call function 'BALW_BAPIRETURN_GET2' exporting type = 'S' cl = 'ZSRQL' number = '015' par1 = 'BAPIRET2' par2 = lv_par importing return = <ls_line1>.
*     move fields with same name
      _srql_move-corresponding <ls_line1> <ls_line2>.
*     set value of other fields
      _srql_set-field <ls_line1>: 'ROW' 1, 'SYSTEM' sy-sysid.
      _srql_move-field <ls_line1> <ls_line2>: 'ROW' 'LOG_MSG_NO', 'SYSTEM' 'CODE'.

*     EXAMPLE 4: move-mapping and append to a itab
      if vv_break eq 'X'. _break. endif.

*     build itab
      _srql_build-itab vv_dest 'BAPIRETURN' space lo_itab.
      assign lo_itab->* to <lt_itab>.

*     mapping
      clear <ls_line2>.
      ls_map-fieldfrom = 'TYPE'.       ls_map-fieldto = 'TYPE'.       append ls_map to lt_map.
      ls_map-fieldfrom = 'ID'.         ls_map-fieldto = 'CODE'.       append ls_map to lt_map.
      ls_map-fieldfrom = 'MESSAGE'.    ls_map-fieldto = 'MESSAGE'.    append ls_map to lt_map.
      ls_map-fieldfrom = 'LOG_NO'.     ls_map-fieldto = 'LOG_NO'.     append ls_map to lt_map.
      ls_map-fieldfrom = 'NUMBER'.     ls_map-fieldto = 'LOG_MSG_NO'. append ls_map to lt_map.
      ls_map-fieldfrom = 'MESSAGE_V1'. ls_map-fieldto = 'MESSAGE_V1'. append ls_map to lt_map.
      ls_map-fieldfrom = 'MESSAGE_V2'. ls_map-fieldto = 'MESSAGE_V2'. append ls_map to lt_map.
      ls_map-fieldfrom = 'MESSAGE_V3'. ls_map-fieldto = 'MESSAGE_V3'. append ls_map to lt_map.
      ls_map-fieldfrom = 'MESSAGE_V4'. ls_map-fieldto = 'MESSAGE_V4'. append ls_map to lt_map.

*     moving fields and adding to itab
      _srql_move-mapping <ls_line1> <ls_line2> lt_map.
      append <ls_line2> to <lt_itab>.

    endmethod.

  endclass.

* gui definition
  selection-screen begin of block bl1 with frame title text-001.

    parameters: p_dest  type rfcdest obligatory,
                p_break type xfeld default 'X'.

  selection-screen end of block bl1.

  selection-screen begin of block bl2 with frame title text-002.

    parameters: p_type  type xfeld radiobutton group gr1 default 'X',
                p_query type xfeld radiobutton group gr1,
                p_macro type xfeld radiobutton group gr1.

  selection-screen end of block bl2.

start-of-selection.

  ##NEEDED
  data: lx_root type ref to cx_root,
        lo_main type ref to cl_main,
        lv_mess type string.

  try.
      create object lo_main.
      lo_main->start( vv_dest = p_dest vv_break = p_break vv_type = p_type vv_query = p_query vv_macro = p_macro  ).
  catch cx_sy_create_object_error zcx_srqltype into lx_root.
    lv_mess = lx_root->get_text( ). write: / lv_mess.
  endtry.
