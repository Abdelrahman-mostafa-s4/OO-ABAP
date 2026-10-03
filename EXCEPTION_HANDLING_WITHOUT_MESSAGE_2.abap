*&---------------------------------------------------------------------*
*& Report Z_EXCEPTION_HANDLING_NUM_MESS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_EXCEPTION_HANDLING_NUM_MESS.

data : wa_header type YZSTRHEAD,
      lo_exception type ref to ycx_test,
      message type string.

PARAMETERS : P_VBELN TYPE VBELN_VA.


START-OF-SELECTION.
write : / wa_header.

AT SELECTION-SCREEN.
  TRY .

    select single vbeln , ernam , erdat , erzet
      from YZSTRHEAD
      into CORRESPONDING FIELDS OF @wa_header
      where vbeln = @P_VBELN.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE ycx_test
          EXPORTING
            textid = ycx_test=>ycx_test
*            previous =
            lv_order = P_VBELN
            .

      ENDIF.

  CATCH ycx_test INTO lo_exception.
    CALL METHOD lo_exception->if_message~get_text
      RECEIVING
        result = message
        .

    MESSAGE message type 'E'.


  ENDTRY.