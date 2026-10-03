*&---------------------------------------------------------------------*
*& Report Y_CL_ALV_TABLE_COLUMN_SETTING
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT y_cl_alv_table_column_setting.
TABLES : vbak.
SELECT-OPTIONS : s_vbeln FOR vbak-vbeln.

TYPES:BEGIN OF st_header,
        vbeln TYPE vbak-vbeln,
        ernam TYPE vbak-ernam,
        erdat TYPE vbak-erdat,
        erzet TYPE vbak-erzet,
      END OF st_header.

DATA : it_header   TYPE TABLE OF st_header,
       lo_salv     TYPE REF TO cl_salv_table,
       lo_columns  TYPE REF TO cl_salv_columns_table,
       lo_column   TYPE REF TO cl_salv_column,
       lo_function TYPE REF TO cl_salv_functions_list
       .

SELECT vbeln , ernam , erdat ,erzet
  FROM vbak
  INTO CORRESPONDING FIELDS OF TABLE @it_header
  WHERE vbeln IN @s_vbeln.
TRY.
    CALL METHOD cl_salv_table=>factory
*      EXPORTING
*        list_display   = IF_SALV_C_BOOL_SAP=>FALSE
*        r_container    =
*        container_name =
      IMPORTING
        r_salv_table = lo_salv
      CHANGING
        t_table      = it_header.
  CATCH cx_salv_msg.
ENDTRY.

CALL METHOD lo_salv->if_salv_gui_om_table_info~get_columns
  RECEIVING
    value = lo_columns.

CALL METHOD lo_columns->set_column_position
  EXPORTING
    columnname = 'EDATE'
    position   = '1'.

CALL METHOD lo_columns->set_column_position
  EXPORTING
    columnname = 'VBELN'
    position   = '3'.

TRY.
    CALL METHOD lo_columns->get_column
      EXPORTING
        columnname = 'VBELN'
      RECEIVING
        value      = lo_column.
  CATCH cx_salv_not_found.
ENDTRY.

CALL METHOD lo_column->set_long_text
  EXPORTING
    value = 'SALES DOCUMNET NUMMBER'.


CALL METHOD lo_salv->if_salv_gui_om_table_info~get_functions
  RECEIVING
    value = lo_function.

CALL METHOD lo_function->set_all
  EXPORTING
    value = if_salv_c_bool_sap=>true.
CALL METHOD lo_salv->if_salv_gui_om_table_action~display.