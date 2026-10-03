*&---------------------------------------------------------------------*
*& Report Z_EXCEPTION_HANDLING
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_EXCEPTION_HANDLING.

DATA : WA_HEADER TYPE YZSTRHEAD,
      LO_EXCEPTION TYPE REF TO ycx_header,
      MY_MESSAGE TYPE STRING.

PARAMETERS : P_VBELN TYPE VBAK-VBELN.


START-OF-SELECTION.
WRITE : / wa_header-erdat ,
        / wa_header-ernam ,
        / wa_header-erzet ,
        / wa_header-vbeln.

AT SELECTION-SCREEN.

  TRY.
  IF P_VBELN IS INITIAL.
    RAISE EXCEPTION TYPE ycx_header
      EXPORTING
        textid = ycx_header=>secont_text
*        previous =
        .

  ENDIF.

CATCH  ycx_header INTO lo_exception.
  CALL METHOD lo_exception->if_message~get_text
    RECEIVING
      result = MY_MESSAGE
      .
  MESSAGE my_message TYPE 'E'.

ENDTRY.

TRY.
SELECT SINGLE ERNAM , ERDAT , ERZET
  FROM YZSTRHEAD
  INTO CORRESPONDING FIELDS OF @WA_HEADER
  WHERE VBELN = @P_VBELN.

  IF SY-subrc <> 0.
    RAISE EXCEPTION TYPE ycx_header
      EXPORTING
        textid = YCX_HEADER=>ycx_header
*        previous =
        .


  ENDIF.
CATCH  ycx_header INTO LO_EXCEPTION.
  CALL METHOD lo_exception->if_message~get_text
    RECEIVING
      result = MY_MESSAGE
      .

  MESSAGE MY_MESSAGE TYPE 'E'.
ENDTRY.