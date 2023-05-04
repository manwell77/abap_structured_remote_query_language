*&---------------------------------------------------------------------*
*&  Include           ZSRQL
*&---------------------------------------------------------------------*

****************************************************************************************************
* SRQL MACRO LIST                                                                                  *
****************************************************************************************************
*  1. _srql_build-type-descriptor: remote type descriptor builder                                  *
*  2. _srql_build-from-descriptor: remote type builder starting from type descriptor               *
*  3. _srql_build-element: remote data element builder                                             *
*  4. _srql_build-structure: remote structure builder                                              *
*  5. _srql_build-filtered-structure: remote structure builder with a subset of fields             *
*  6. _srql_build-itab: remote internal table builder                                              *
*  7. _srql_build-filtered-itab: remote internal table builder with a subset of fields             *
*  8. _srql_get-field: field value getter for dynamic lines                                        *
*  9. _srql_set-field: field value setter for dynamic lines                                        *
* 10. _srql_move-corresponding: move-corresponding field values between dynamic structures         *
* 11. _srql_move-mapping: move field values as defined in mapping table between dynamic structures *
* 12. _srql_move-field: move a single field between dynamic structures                             *
****************************************************************************************************

##NEEDED
define _srql_build-type-descriptor.

* &1: rfc destination
* &2: data type (data element, structure, internal table) -> see zif_srqltypekind constants
* &3: type name (data element or structure)
* &4: result (ref to zcl_srqltype)

* sy-subrc set to 0 if ok
* sy-subrc set to 8 if error occurred

  try.
      &4 = zcl_srqltype=>new( destination = &1 typekind = &2 typename = &3 ).
      ##WRITE_OK
      sy-subrc = 0.
    catch zcx_srqltype.
      ##WRITE_OK
      sy-subrc = 8.
  endtry.

end-of-definition.

##NEEDED
define _srql_build-from-descriptor.

* &1: type descriptor (ref to zcl_srqltype)
* &2: result: data

* sy-subrc set to 0 if ok
* sy-subrc set to 8 if error occurred

  try.
      &2 = &1->get_data( ).
      ##WRITE_OK
      sy-subrc = 0.
    catch zcx_srqltype.
      ##WRITE_OK
      sy-subrc = 8.
  endtry.

end-of-definition.

##NEEDED
define _srql_build-element.

* &1: rfc destination
* &2: data element name
* &3: result (data)

* sy-subrc set to 0 if ok
* sy-subrc set to 8 if error occurred

  try.
      &3 = zcl_srqltype=>new( destination = &1 typekind = zif_srqltypekind=>data_element typename = &2 )->get_data( ).
      ##WRITE_OK
      sy-subrc = 0.
    catch zcx_srqltype.
      ##WRITE_OK
      sy-subrc = 8.
  endtry.

end-of-definition.

##NEEDED
define _srql_build-structure.

* &1: rfc destination
* &2: structure name
* &3: with offset-fields
* &4: result (data)

* sy-subrc set to 0 if ok
* sy-subrc set to 8 if error occurred

  try.
      &4 = zcl_srqltype=>new( destination = &1 typekind = zif_srqltypekind=>structure typename = &2 offset_fields = &3 )->get_data( ).
      ##WRITE_OK
      sy-subrc = 0.
    catch zcx_srqltype.
      ##WRITE_OK
      sy-subrc = 8.
  endtry.

end-of-definition.

##NEEDED
define _srql_build-filtered-structure.

* &1: rfc destination
* &2: structure name
* &3: with offset-fields
* &4: field list (fieldname_tab itab)
* &5: result (data)

* sy-subrc set to 0 if ok
* sy-subrc set to 8 if error occurred

  try.
      &5 = zcl_srqltype=>new( destination = &1 typekind = zif_srqltypekind=>structure typename = &2 offset_fields = &3 typefields = &4 )->get_data( ).
      ##WRITE_OK
      sy-subrc = 0.
    catch zcx_srqltype.
      ##WRITE_OK
      sy-subrc = 8.
  endtry.

end-of-definition.

##NEEDED
define _srql_build-itab.

* &1: rfc destination
* &2: structure name of itab line
* &3: with offset-fields
* &4: result (data)

* sy-subrc set to 0 if ok
* sy-subrc set to 8 if error occurred

  try.
      &4 = zcl_srqltype=>new( destination = &1 typekind = zif_srqltypekind=>table_type typename = &2 offset_fields = &3 )->get_data( ).
      ##WRITE_OK
      sy-subrc = 0.
    catch zcx_srqltype.
      ##WRITE_OK
      sy-subrc = 8.
  endtry.

end-of-definition.

##NEEDED
define _srql_build-filtered-itab.

* &1: rfc destination
* &2: structure name
* &3: with offset-fields
* &4: field list (fieldname_tab itab)
* &5: result (data)

* sy-subrc set to 0 if ok
* sy-subrc set to 8 if error occurred

  try.
      &5 = zcl_srqltype=>new( destination = &1 typekind = zif_srqltypekind=>table_type typename = &2 offset_fields = &3 typefields = &4 )->get_data( ).
      ##WRITE_OK
      sy-subrc = 0.
    catch zcx_srqltype.
      ##WRITE_OK
      sy-subrc = 8.
  endtry.

end-of-definition.

##NEEDED
define _srql_get-field.

* &1: structure
* &2: field name
* &3: field value

* sy-subrc set to 0 if ok
* sy-subrc set to 8 if error occurred

  try.
      zcl_srqlutil=>get_field( exporting line = &1 fieldname = &2 importing value = &3 ).
      ##WRITE_OK
      sy-subrc = 0.
    catch zcx_srqltype.
      ##WRITE_OK
      sy-subrc = 8.
  endtry.

end-of-definition.

##NEEDED
define _srql_set-field.

* &1: structure
* &2: field name
* &3: field value

* sy-subrc set to 0 if ok
* sy-subrc set to 8 if error occurred

  try.
      zcl_srqlutil=>set_field( exporting fieldname = &2 value = &3 changing line = &1 ).
      ##WRITE_OK
      sy-subrc = 0.
    catch zcx_srqltype.
      ##WRITE_OK
      sy-subrc = 8.
  endtry.

end-of-definition.

##NEEDED
define _srql_move-corresponding.

* &1: structure from
* &2: structure to

* sy-subrc set to 0 if ok
* sy-subrc set to 8 if error occurred
* sy-dbcnt set to number of corresponding fields moved

  try.
      ##WRITE_OK
      zcl_srqlutil=>move_corresponding( exporting linefrom = &1 importing moved = sy-dbcnt changing lineto = &2 ).
      ##WRITE_OK
      sy-subrc = 0.
    catch zcx_srqltype.
      ##WRITE_OK
      sy-subrc = 8.
  endtry.

end-of-definition.

##NEEDED
define _srql_move-mapping.

* &1: structure from
* &2: structure to
* &3: field mapping (internal table zsrqlfieldmap_s_tt)

* sy-subrc set to 0 if ok
* sy-subrc set to 8 if error occurred
* sy-dbcnt set to number of corresponding fields moved

  try.
      ##WRITE_OK
      zcl_srqlutil=>move_mapping( exporting linefrom = &1 fieldmap = &3 importing moved = sy-dbcnt changing lineto = &2 ).
      ##WRITE_OK
      sy-subrc = 0.
    catch zcx_srqltype.
      ##WRITE_OK
      sy-subrc = 8.
  endtry.

end-of-definition.

##NEEDED
define _srql_move-field.

* &1: structure from
* &2: structure to
* &3: field from
* &4: field to

* sy-subrc set to 0 if ok
* sy-subrc set to 8 if error occurred

  try.
      zcl_srqlutil=>move_field( exporting linefrom = &1 fieldfrom = &3 fieldto = &4 changing lineto = &2 ).
      ##WRITE_OK
      sy-subrc = 0.
    catch zcx_srqltype.
      ##WRITE_OK
      sy-subrc = 8.
  endtry.

end-of-definition.
