*&---------------------------------------------------------------------*
*& Report Y_CL_SALV_TABLE_FILTER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Y_CL_SALV_TABLE_FILTER.
TABLES : vbak.
SELECT-OPTIONS : s_vbeln FOR vbak-vbeln.

TYPES:BEGIN OF st_header,
        vbeln TYPE vbak-vbeln,
        ernam TYPE vbak-ernam,
        erdat TYPE vbak-erdat,
        erzet TYPE vbak-erzet,
      END OF st_header.

DATA : it_header TYPE TABLE OF st_header,
       lo_alv    TYPE REF TO cl_salv_table,
       lo_sort   TYPE REF TO cl_salv_sorts,
       lo_sort_  TYPE REF TO cl_salv_sort,
       LO_FILTERS TYPE REF TO CL_SALV_FILTERS,
       LO_FILTER TYPE REF TO CL_SALV_FILTER.

SELECT vbeln , ernam ,erdat , erzet
  FROM vbak
  INTO CORRESPONDING FIELDS OF TABLE @it_header
  WHERE vbeln IN @s_vbeln.

TRY.
    CALL METHOD cl_salv_table=>factory
*    EXPORTING
*      list_display   = IF_SALV_C_BOOL_SAP=>FALSE
*      r_container    =
*      container_name =
      IMPORTING
        r_salv_table = lo_alv
      CHANGING
        t_table      = it_header.
  CATCH cx_salv_msg.
ENDTRY.

CALL METHOD lo_alv->if_salv_gui_om_table_info~get_sorts
  RECEIVING
    value = lo_sort.

TRY.
    CALL METHOD lo_sort->add_sort
      EXPORTING
        columnname = 'ERDAT'
*       position   =
       sequence   = IF_SALV_C_SORT=>sort_down
       subtotal   = IF_SALV_C_BOOL_SAP=>true
*       group      = IF_SALV_C_SORT=>GROUP_NONE
*       obligatory = IF_SALV_C_BOOL_SAP=>FALSE
      RECEIVING
        value      = lo_sort_.
  CATCH cx_salv_not_found.
  CATCH cx_salv_existing.
  CATCH cx_salv_data_error.
ENDTRY.

TRY.

    CALL METHOD lo_sort_->set_sequence
      EXPORTING
        value = if_salv_c_sort=>sort_up.
  CATCH cx_salv_data_error.
ENDTRY.

CALL METHOD lo_alv->if_salv_gui_om_table_info~get_filters
  RECEIVING
    value  = LO_FILTERS
    .
TRY.
CALL METHOD lo_filters->add_filter
  EXPORTING
    columnname = 'ERNAM'
    sign       = 'I'
    option     = 'EQ'
    low        = 'A7MD.YOUSSEF'
*    high       =
  receiving
    value      = LO_FILTER
    .
  CATCH cx_salv_not_found.
  CATCH cx_salv_data_error.
  CATCH cx_salv_existing.
ENDTRY.

TRY.
CALL METHOD lo_filter->add_selopt
  EXPORTING
    sign   = 'I'
    option = 'EQ'
    low    = 'SAMIR.N'
*    high   =
*  RECEIVING
*    value  =
    .
  CATCH cx_salv_data_error.
ENDTRY.





CALL METHOD lo_alv->if_salv_gui_om_table_action~display.