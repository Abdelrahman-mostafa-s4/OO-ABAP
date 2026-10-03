*&---------------------------------------------------------------------*
*& Report YZ_RECAP_ALL_EVENTS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT yz_recap_all_events_v2.
TABLES : vbak.
SELECT-OPTIONS : s_vbeln FOR vbak-vbeln.

TYPES : BEGIN OF st_header,
          vbeln TYPE vbak-vbeln,
          ernam TYPE vbak-ernam,
          erdat TYPE vbak-erdat,
          erzet TYPE vbak-erzet,
        END OF st_header.

TYPES : BEGIN OF st_item,
          vbeln TYPE vbap-vbeln,
          posnr TYPE vbap-posnr,
          matnr TYPE vbap-matnr,
        END OF st_item.



DATA : it_header       TYPE TABLE OF st_header,
       wa_header       TYPE st_header,

       it_item         TYPE TABLE OF st_item,
       wa_item         TYPE st_item,

       lo_salv_1       TYPE REF TO cl_salv_table,
       lo_salv_2       TYPE REF TO cl_salv_table,

       lo_events       TYPE REF TO cl_salv_events_table,

       lo_columns      TYPE REF TO cl_salv_columns_table,
       lo_column       TYPE REF TO cl_salv_column,
       lo_column_table TYPE REF TO cl_salv_column_table.


SELECT vbeln , ernam  , erdat , erzet
  FROM vbak
  INTO CORRESPONDING FIELDS OF TABLE @it_header
  WHERE vbeln IN @s_vbeln.

CLASS event_handle DEFINITION.
  PUBLIC SECTION.
    METHODS hotspot_event FOR EVENT link_click OF cl_salv_events_table
      IMPORTING row.

ENDCLASS.


CLASS event_handle IMPLEMENTATION.
  METHOD hotspot_event.
    READ TABLE it_header INTO wa_header INDEX row.
    SELECT vbeln , posnr , matnr
      FROM vbap
      INTO CORRESPONDING FIELDS OF TABLE @it_item
      WHERE vbeln = @wa_header-vbeln.

    TRY.
        CALL METHOD cl_salv_table=>factory
*                EXPORTING
*                  list_display   = IF_SALV_C_BOOL_SAP=>FALSE
*                  r_container    =
*                  container_name =
          IMPORTING
            r_salv_table = lo_salv_2
          CHANGING
            t_table      = it_item.
      CATCH cx_salv_msg.
    ENDTRY.

    CALL METHOD lo_salv_2->if_salv_gui_om_table_action~display.


  ENDMETHOD.


ENDCLASS.


DATA lo_event TYPE REF TO event_handle.



START-OF-SELECTION.

  CREATE OBJECT lo_event.

  TRY.
      CALL METHOD cl_salv_table=>factory
*        EXPORTING
*          list_display   = IF_SALV_C_BOOL_SAP=>FALSE
*          r_container    =
*          container_name =
        IMPORTING
          r_salv_table = lo_salv_1
        CHANGING
          t_table      = it_header.
    CATCH cx_salv_msg.
  ENDTRY.

  CALL METHOD lo_salv_1->if_salv_gui_om_table_info~get_event
    RECEIVING
      value = lo_events.

  CALL METHOD lo_salv_1->if_salv_gui_om_table_info~get_columns
    RECEIVING
      value = lo_columns.

  TRY.
      CALL METHOD lo_columns->get_column
        EXPORTING
          columnname = 'VBELN'
        RECEIVING
          value      = lo_column.
    CATCH cx_salv_not_found.
  ENDTRY.


  lo_column_table ?= lo_column.


  CALL METHOD lo_column_table->set_cell_type
    EXPORTING
      value = if_salv_c_cell_type=>hotspot.
  SET HANDLER lo_event->hotspot_event
   FOR lo_events.
  CALL METHOD lo_salv_1->if_salv_gui_om_table_action~display.