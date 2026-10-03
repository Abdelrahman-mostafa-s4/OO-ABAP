*&---------------------------------------------------------------------*
*& Report YZ_RECAP_ALL_EVENTS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT yz_recap_all_events_v3.
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

       LO_GRID TYPE REF TO CL_GUI_ALV_GRID ,

       IT_ROWS TYPE LVC_T_ROW,
       WA_ROW TYPE LVC_S_ROW.


SELECT vbeln , ernam  , erdat , erzet
  FROM vbak
  INTO CORRESPONDING FIELDS OF TABLE @it_header
  WHERE vbeln IN @s_vbeln.

CLASS event_handle DEFINITION.
  PUBLIC SECTION.
    METHODS USER_COMMAND_EVENT FOR EVENT ADDED_FUNCTION OF cl_salv_events_table
      IMPORTING e_salv_function.

ENDCLASS.


CLASS event_handle IMPLEMENTATION.
  METHOD USER_COMMAND_EVENT.

    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
     IMPORTING
       E_GRID                           = LO_GRID
              .

    CALL METHOD lo_grid->get_selected_rows
      IMPORTING
        et_index_rows = IT_ROWS
*        et_row_no     =
        .

    READ TABLE IT_ROWS INTO WA_ROW INDEX 1.
    IF  SY-subrc = 0.
      READ TABLE IT_HEADER INTO WA_HEADER INDEX WA_ROW-index.
      IF SY-subrc = 0.
        SELECT VBELN , POSNR , MATNR
          FROM VBAP
          INTO CORRESPONDING FIELDS OF TABLE @IT_ITEM
          WHERE VBELN = @WA_HEADER-vbeln.

      ENDIF.

    ENDIF.

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

  SET PF-STATUS 'MYSTATUS'.

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


  CALL METHOD lo_salv_1->if_salv_gui_om_table_info~set_screen_status
    EXPORTING
      report        = SY-repid
      pfstatus      = 'MYSTATUS'
*      set_functions = CL_SALV_MODEL_BASE=>C_FUNCTIONS_NONE
      .





  SET HANDLER lo_event->USER_COMMAND_EVENT FOR lo_events.


  CALL METHOD lo_salv_1->if_salv_gui_om_table_action~display.