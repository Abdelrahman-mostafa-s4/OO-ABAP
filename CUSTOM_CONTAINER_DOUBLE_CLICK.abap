*&---------------------------------------------------------------------*
*& Report Y_OOALV_DOUBLE_CLOCK
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT y_ooalv_double_clock.

TABLES : vbak .

SELECT-OPTIONS s_vbeln FOR vbak-vbeln.

TYPES : BEGIN OF st_header,
          vbeln TYPE vbak-vbeln,
          ernam TYPE vbak-ernam,
          erdat TYPE vbak-erdat,
          erzet TYPE vbak-erzet,
        END OF st_header.


TYPES : BEGIN OF st_item,
          vbeln TYPE vbap-vbeln,
          posnR TYPE vbap-posnr,
          matnr TYPE vbap-matnr,
        END OF st_item.

DATA : it_header   TYPE TABLE OF st_header,
       wa_header   TYPE st_header,
       it_item     TYPE TABLE OF  st_item,
       wa_item     TYPE st_item,
       lo_objrct_1 TYPE REF TO cl_gui_custom_container,
       lo_grid_1   TYPE REF TO cl_gui_alv_grid,
       lo_objrct_2 TYPE REF TO cl_gui_custom_container,
       lo_grid_2   TYPE REF TO cl_gui_alv_grid.

SELECT vbeln,
       ernam,
       erdat,
       erzet
  FROM vbak
  INTO TABLE  @it_header
  WHERE vbeln IN @s_vbeln.

CLASS event_handelr DEFINITION.
  PUBLIC SECTION.
    METHODS double_click_event FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING e_row
                e_column
                es_row_no
                sender.

ENDCLASS.


CLASS event_handelr IMPLEMENTATION.
  METHOD double_click_event.
    READ TABLE it_header INTO wa_header INDEX e_row-index.
    IF sy-subrc = 0.
      SELECT vbeln,
             posnR,
             matnr
        FROM vBAP
        INTO TABLE @it_item
        WHERE vbeln = @wa_header-vbeln.

      CALL SCREEN '0200'.

    ENDIF.


  ENDMETHOD.


ENDCLASS.

START-OF-SELECTION.


CREATE OBJECT lo_objrct_1
  EXPORTING
    container_name = 'CC_1'.

CREATE OBJECT lo_grid_1
  EXPORTING
    i_parent = lo_objrct_1.

DATA LO_EVENT TYPE REF TO event_handelr.
CREATE OBJECT LO_EVENT.

SET HANDLER LO_EVENT->double_click_event FOR lo_grid_1.

CALL METHOD lo_grid_1->set_table_for_first_display
  EXPORTING
*   i_buffer_active               =
*   i_bypassing_buffer            =
*   i_consistency_check           =
    i_structure_name              = 'YSTRUCTURE'
*   is_variant                    =
*   i_save                        =
*   i_default                     = 'X'
*   is_layout                     =
*   is_print                      =
*   it_special_groups             =
*   it_toolbar_excluding          =
*   it_hyperlink                  =
*   it_alv_graphics               =
*   it_except_qinfo               =
*   ir_salv_adapter               =
  CHANGING
    it_outtab                     = it_header
*   it_fieldcatalog               =
*   it_sort                       =
*   it_filter                     =
  EXCEPTIONS
    invalid_parameter_combination = 1
    program_error                 = 2
    too_many_lines                = 3
    OTHERS                        = 4.
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.

CALL SCREEN '0100'.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  IF sy-ucomm = 'BACK'.
    LEAVE TO SCREEN 0.

  ENDIF.
ENDMODULE.


*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.
  CREATE OBJECT lo_objrct_2
    EXPORTING
      container_name = 'CC_2'.

  CREATE OBJECT lo_grid_2
    EXPORTING
      i_parent = lo_objrct_2.

CALL METHOD lo_grid_2->set_table_for_first_display
  EXPORTING
*    i_buffer_active               =
*    i_bypassing_buffer            =
*    i_consistency_check           =
    i_structure_name              = 'YSTRUCTURE_ITEM'
*    is_variant                    =
*    i_save                        =
*    i_default                     = 'X'
*    is_layout                     =
*    is_print                      =
*    it_special_groups             =
*    it_toolbar_excluding          =
*    it_hyperlink                  =
*    it_alv_graphics               =
*    it_except_qinfo               =
*    ir_salv_adapter               =
  CHANGING
    it_outtab                     = it_item
*    it_fieldcatalog               =
*    it_sort                       =
*    it_filter                     =
*  EXCEPTIONS
*    invalid_parameter_combination = 1
*    program_error                 = 2
*    too_many_lines                = 3
*    others                        = 4
        .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.

ENDMODULE.


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  IF sy-ucomm = 'BACK'.
    LEAVE TO SCREEN 0.

  ENDIF.

ENDMODULE.