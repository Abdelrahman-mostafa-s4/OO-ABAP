*&---------------------------------------------------------------------*
*& Report Z_EXCEPTION_HANDLING_WITH_MSG
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_exception_handling_with_msg.

DATA : wa_header    TYPE yzstrhead,
       lo_exception TYPE REF TO ycx_exception_class_with_msg,
       my_message type string.

PARAMETERS lv_vbeln TYPE vbeln_va.


AT SELECTION-SCREEN.

  TRY.
      IF lv_vbeln IS INITIAL.
        RAISE EXCEPTION TYPE ycx_exception_class_with_msg
          EXPORTING
            textid = ycx_exception_class_with_msg=>empty_field
*           previous =
*           lv_order =
          .
      ENDIF.

    CATCH  ycx_exception_class_with_msg INTO lo_exception.
      CALL METHOD lo_exception->if_message~get_text
        RECEIVING
          result = my_message.
      MESSAGE my_message TYPE 'E'.


  ENDTRY.


  TRY.
    SELECT SINGLE ERNAM , ERDAT , ERZET
      FROM YZSTRHEAD
      INTO CORRESPONDING FIELDS OF @WA_HEADER
      WHERE VBELN = @lv_vbeln.
      IF  SY-subrc <> 0.
        RAISE EXCEPTION TYPE ycx_exception_class_with_msg
          EXPORTING
            textid = ycx_exception_class_with_msg=>ycx_exception_class_with_msg
*            previous =
            lv_order = lv_vbeln
            .
      ENDIF.

  CATCH ycx_exception_class_with_msg INTO lo_exception .
    CALL METHOD lo_exception->if_message~get_text
      RECEIVING
        result = MY_MESSAGE
        .
    MESSAGE MY_MESSAGE TYPE 'E'.



  ENDTRY.