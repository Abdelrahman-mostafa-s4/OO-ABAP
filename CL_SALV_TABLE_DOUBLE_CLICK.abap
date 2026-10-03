&---------------------------------------------------------------------
& Report YZ_RECAP_ALL_EVENTS
&---------------------------------------------------------------------
&
&---------------------------------------------------------------------
REPORT YZ_RECAP_ALL_EVENTS.
TABLES  VBAK.
SELECT-OPTIONS  S_VBELN FOR VBAK-VBELN.

TYPES  BEGIN OF ST_HEADER,
  VBELN TYPE VBAK-VBELN,
  ERNAM TYPE VBAK-ERNAM,
  ERDAT TYPE VBAK-ERDAT,
  ERZET TYPE VBAK-ERZET,
  END OF ST_HEADER.

  TYPES  BEGIN OF ST_ITEM,
    VBELN TYPE VBAP-VBELN,
    POSNR TYPE VBAP-POSNR,
    MATNR TYPE VBAP-MATNR,
    END OF ST_ITEM.



    DATA  IT_HEADER TYPE TABLE OF ST_HEADER,
           WA_HEADER TYPE ST_HEADER,

           IT_ITEM TYPE TABLE OF ST_ITEM,
           WA_ITEM TYPE ST_ITEM,

           LO_SALV_1 TYPE REF TO cl_salv_table,
           LO_SALV_2 TYPE REF TO CL_SALV_TABLE,
           LO_EVENTS TYPE REF TO CL_SALV_EVENTS_TABLE.


    SELECT VBELN , ERNAM  , ERDAT , ERZET
      FROM VBAK
      INTO CORRESPONDING FIELDS OF TABLE @IT_HEADER
      WHERE VBELN IN @s_vbeln.

      CLASS EVENT_HANDLE DEFINITION.
        PUBLIC SECTION.
        METHODS DOUPLE_CLICK_EVENT FOR EVENT DOUBLE_CLICK OF CL_SALV_EVENTS_TABLE
        IMPORTING row.

        ENDCLASS.


        CLASS event_handle IMPLEMENTATION.
          METHOD douple_click_event.
            READ TABLE IT_HEADER INTO WA_HEADER INDEX ROW.
            SELECT VBELN , POSNR , MATNR
              FROM VBAP
              INTO CORRESPONDING FIELDS OF TABLE @IT_ITEM
              WHERE VBELN = @WA_HEADER-vbeln.

              TRY.
              CALL METHOD cl_salv_table=factory
                EXPORTING
                  list_display   = IF_SALV_C_BOOL_SAP=FALSE
                  r_container    =
                  container_name =
                IMPORTING
                  r_salv_table   = lo_salv_2
                CHANGING
                  t_table        = IT_ITEM
                  .
                CATCH cx_salv_msg.
              ENDTRY.

              CALL METHOD lo_salv_2-if_salv_gui_om_table_action~display
                  .


            ENDMETHOD.


          ENDCLASS.


          DATA LO_EVENT TYPE REF TO event_handle.



      START-OF-SELECTION.

      CREATE OBJECT LO_EVENT.

      TRY.
      CALL METHOD cl_salv_table=factory
        EXPORTING
          list_display   = IF_SALV_C_BOOL_SAP=FALSE
          r_container    =
          container_name =
        IMPORTING
          r_salv_table   = LO_SALV_1
        CHANGING
          t_table        = IT_HEADER
          .
        CATCH cx_salv_msg.
      ENDTRY.

      CALL METHOD lo_salv_1-if_salv_gui_om_table_info~get_event
        RECEIVING
          value  = LO_EVENTS

          .

      SET HANDLER LO_EVENT-douple_click_event FOR LO_EVENTS.


      CALL METHOD lo_salv_1-if_salv_gui_om_table_action~display
          .