*&---------------------------------------------------------------------*
*& Report YRECAP_CL_SALV_TABLE_CONTAINER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT YRECAP_CL_SALV_TABLE_CONTAINER.
TABLES : VBAK.
SELECT-OPTIONS : S_VBELN FOR VBAK-VBELN.

TYPES : BEGIN OF ST_HEADER,
  VBELN TYPE VBAK-VBELN,
  ERNAM TYPE VBAK-ERNAM,
  ERDAT TYPE VBAK-ERDAT,
  ERZET TYPE VBAK-ERZET,
  END OF ST_HEADER.

  DATA : IT_HEADER TYPE TABLE OF ST_HEADER,
         LO_SALV TYPE REF TO CL_SALV_TABLE,
         LO_CONT TYPE REF TO cl_gui_custom_container.

  SELECT VBELN , ERNAM , ERZET , ERDAT
    FROM VBAK
    INTO CORRESPONDING FIELDS OF TABLE @IT_HEADER
    WHERE VBELN IN @s_vbeln.

    CREATE OBJECT lo_cont
    EXPORTING
      container_name  = 'CC'.

    TRY.
    CALL METHOD cl_salv_table=>factory
      EXPORTING
        list_display   = IF_SALV_C_BOOL_SAP=>FALSE
        r_container    = LO_CONT
*        container_name =
      IMPORTING
        r_salv_table   = LO_SALV
      CHANGING
        t_table        = IT_HEADER
        .
      CATCH cx_salv_msg.
    ENDTRY.

  CALL METHOD lo_salv->if_salv_gui_om_table_action~display
      .
  CALL SCREEN '0100'.