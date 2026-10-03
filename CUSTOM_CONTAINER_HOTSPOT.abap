*&---------------------------------------------------------------------*
*& Report Y_HOTSPOT_EVENT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Y_HOTSPOT_EVENT.
TABLES : VBAK.

SELECT-OPTIONS : S_VBELN FOR VBAK-vbeln.



TYPES : BEGIN OF ST_HEADER,
  VBELN TYPE VBAK-VBELN,
  ERNAM TYPE VBAK-ERNAM,
  ERDAT TYPE VBAK-erdat,
  ERZET TYPE VBAK-ERZET,

  END OF st_header.

  TYPES : BEGIN OF ST_ITEM,
  VBELN TYPE VBAP-VBELN,
  POSNR TYPE VBAP-posnr,
  MATNR TYPE VBAP-matnr,
  MATWA TYPE VBAP-matwa,

  END OF ST_ITEM.


  DATA: IT_HEADER TYPE TABLE OF ST_HEADER,
        WA_HEADER TYPE ST_HEADER,
        IT_ITEM TYPE TABLE OF ST_ITEM,
        WA_ITEM TYPE ST_ITEM,
        LO_CONT TYPE REF TO cl_gui_custom_container,
        LO_GRID TYPE REF TO cl_gui_alv_grid,
        IT_FCAT TYPE LVC_T_FCAT ,
        WA_FCAT TYPE LVC_S_FCAT,
        LO_CONT_ITEM TYPE REF TO cl_gui_custom_container,
        LO_GRID_ITEM TYPE REF TO cl_gui_alv_grid,
        IT_FCAT_ITEM TYPE LVC_T_FCAT ,
        WA_FCAT_ITEM TYPE LVC_S_FCAT .

  CLASS EVENT_HANDLER DEFINITION.
    PUBLIC SECTION.
    METHODS HOTSPOT_EVENT FOR EVENT HOTSPOT_CLICK OF cl_gui_alv_grid
                                   IMPORTING e_row_id
                                             e_column_id.
    ENDCLASS .

    CLASS event_handler IMPLEMENTATION.
      METHOD hotspot_event.
        READ TABLE IT_HEADER INTO WA_HEADER INDEX e_row_id-index.
        SELECT POSNR , MATNR , MATWA
          FROM VBAP
          INTO CORRESPONDING FIELDS OF TABLE @it_item
          WHERE VBELN = @WA_HEADER-vbeln.
        CALL SCREEN '0200'.
        ENDMETHOD.
      ENDCLASS.
DATA : LO_EVENT TYPE REF TO event_handler.

  START-OF-SELECTION.

  CALL SCREEN '0100'.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
 SET PF-STATUS 'NEW_VONE'.
* SET TITLEBAR 'xxx'.
 CREATE OBJECT lo_cont
 EXPORTING
   container_name = 'CC'.
 CREATE OBJECT lo_grid
 EXPORTING
   i_parent = lo_cont.

 CREATE OBJECT LO_EVENT.


 SELECT VBELN , ERNAM , ERDAT , ERZET
   FROM VBAK
   INTO CORRESPONDING FIELDS OF TABLE @IT_HEADER
   WHERE VBELN IN @s_vbeln.

   wa_fcat-fieldname = 'VBELN'.
   wa_fcat-scrtext_m = 'SALES DOCUMENT NUMBER'.
   wa_fcat-hotspot = 'X'.
   APPEND wa_fcat TO IT_FCAT.
   CLEAR wa_fcat.
      wa_fcat-fieldname = 'ERNAM'.
   wa_fcat-scrtext_m = 'NAME'.
   APPEND wa_fcat TO IT_FCAT.
      CLEAR wa_fcat.
      wa_fcat-fieldname = 'ERDAT'.
   wa_fcat-scrtext_m = 'DATE'.
   APPEND wa_fcat TO IT_FCAT.
      CLEAR wa_fcat.
      wa_fcat-fieldname = 'ERZET'.
   wa_fcat-scrtext_m = 'TIME'.
   APPEND wa_fcat TO IT_FCAT.
      CLEAR wa_fcat.

SET HANDLER lo_event->hotspot_event FOR lo_grid.

   CALL METHOD lo_grid->set_table_for_first_display
*     EXPORTING
*       i_buffer_active               =
*       i_bypassing_buffer            =
*       i_consistency_check           =
*       i_structure_name              =
*       is_variant                    =
*       i_save                        =
*       i_default                     = 'X'
*       is_layout                     =
*       is_print                      =
*       it_special_groups             =
*       it_toolbar_excluding          =
*       it_hyperlink                  =
*       it_alv_graphics               =
*       it_except_qinfo               =
*       ir_salv_adapter               =
     CHANGING
       it_outtab                     = it_header
       it_fieldcatalog               = IT_FCAT
*       it_sort                       =
*       it_filter                     =
     EXCEPTIONS
       invalid_parameter_combination = 1
       program_error                 = 2
       too_many_lines                = 3
       others                        = 4
           .
   IF sy-subrc <> 0.
*    Implement suitable error handling here
   ENDIF.



ENDMODULE.


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
IF SY-ucomm = '&F03'.
LEAVE TO SCREEN 0.
ENDIF.
ENDMODULE.


*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
 SET PF-STATUS 'NEW_VONE'.
* SET TITLEBAR 'xxx'.
 CREATE OBJECT lo_cont_item
 EXPORTING
   container_name = 'CC_ITEM'
   .

 CREATE OBJECT lo_grid_item
 EXPORTING
   i_parent = lo_cont_item .



 wa_fcat_item-fieldname = 'POSNR'.
 wa_fcat_item-scrtext_m = 'ITEM NUMBER'.
 APPEND wa_fcat_item TO it_fcat_item.
 CLEAR wa_fcat_item.

  wa_fcat_item-fieldname = 'MATNR'.
 wa_fcat_item-scrtext_m = 'MATERIAL '.
 APPEND wa_fcat_item TO it_fcat_item.
 CLEAR wa_fcat_item.

  wa_fcat_item-fieldname = 'MATWA'.
 wa_fcat_item-scrtext_m = 'DESCRIPTION'.
 APPEND wa_fcat_item TO it_fcat_item.
 CLEAR wa_fcat_item.

 CALL METHOD lo_grid_item->set_table_for_first_display
*   EXPORTING
*     i_buffer_active               =
*     i_bypassing_buffer            =
*     i_consistency_check           =
*     i_structure_name              =
*     is_variant                    =
*     i_save                        =
*     i_default                     = 'X'
*     is_layout                     =
*     is_print                      =
*     it_special_groups             =
*     it_toolbar_excluding          =
*     it_hyperlink                  =
*     it_alv_graphics               =
*     it_except_qinfo               =
*     ir_salv_adapter               =
   CHANGING
     it_outtab                     = it_item
     it_fieldcatalog               = it_fcat_item
*     it_sort                       =
*     it_filter                     =
*   EXCEPTIONS
*     invalid_parameter_combination = 1
*     program_error                 = 2
*     too_many_lines                = 3
*     others                        = 4
         .
 IF sy-subrc <> 0.
*  Implement suitable error handling here
 ENDIF.

  REFRESH it_item.
 CLEAR it_fcat_item.


ENDMODULE.


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
IF SY-ucomm = '&F03'.
LEAVE TO SCREEN 0.
ENDIF.
ENDMODULE.